import 'dart:convert';
import 'dart:async';
import 'package:langchain/langchain.dart' as lc;
import 'package:langchain_google/langchain_google.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_tool_call.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/services/ai_service.dart';
import '../tools/database_tool_registry.dart';

/// Concrete implementation of AIService using Gemini via LangChain
class GeminiAIService implements AIService {
  lc.ChatGoogleGenerativeAI? _chatModel;
  AIServiceConfig? _config;
  final DatabaseToolRegistry _toolRegistry;
  final _uuid = const Uuid();

  GeminiAIService(this._toolRegistry);

  @override
  bool get isInitialized => _chatModel != null;

  @override
  bool get isConfigured => _config != null;

  @override
  Future<void> initialize(AIServiceConfig config) async {
    try {
      _config = config;
      
      // Convert our database tools to LangChain ToolSpec format
      final toolSpecs = _convertToToolSpecs(_toolRegistry.getAllTools());
      
      _chatModel = lc.ChatGoogleGenerativeAI(
        apiKey: config.apiKey,
        defaultOptions: lc.ChatGoogleGenerativeAIOptions(
          model: config.model,
          temperature: config.temperature,
          maxOutputTokens: config.maxTokens,
          tools: config.toolsEnabled ? toolSpecs : null,
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize AI service: $e');
    }
  }

  @override
  Stream<AIResponse> sendMessageStream(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async* {
    if (!isInitialized) {
      throw StateError('AI service not initialized');
    }

    try {
      final messages = _buildLangChainMessageHistory(message, conversationHistory);
      final promptValue = lc.PromptValue.chat(messages);
      
      // Create a chain with the chat model and string output parser
      final chain = _chatModel!.pipe(lc.StringOutputParser());
      
      final stream = chain.stream({});
      String accumulatedContent = '';
      final responseId = _uuid.v4();
      
      await for (final chunk in _chatModel!.stream(promptValue)) {
        accumulatedContent += chunk.output.content;
        
        // Check if this chunk contains tool calls
        final toolCalls = _extractToolCalls(chunk);
        
        yield AIResponse(
          id: responseId,
          content: accumulatedContent,
          toolCalls: toolCalls,
          isStreaming: true,
          isComplete: false,
          timestamp: DateTime.now(),
        );
      }
      
      // Final response with completion status
      yield AIResponse(
        id: responseId,
        content: accumulatedContent,
        toolCalls: [],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      yield AIResponse(
        id: _uuid.v4(),
        content: 'Error: ${e.toString()}',
        toolCalls: [],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  @override
  Future<AIResponse> sendMessage(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async {
    if (!isInitialized) {
      throw StateError('AI service not initialized');
    }

    try {
      final messages = _buildLangChainMessageHistory(message, conversationHistory);
      final promptValue = lc.PromptValue.chat(messages);
      
      final result = await _chatModel!.invoke(promptValue);
      final toolCalls = _extractToolCalls(result);
      
      // If there are tool calls, execute them and get a follow-up response
      if (toolCalls.isNotEmpty) {
        return await _handleToolCallsAndRespond(
          messages,
          result,
          toolCalls,
        );
      }
      
      return AIResponse(
        id: _uuid.v4(),
        content: result.output.content,
        toolCalls: toolCalls,
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {
          'model': _config?.model,
          'usage': _extractUsageInfo(result),
        },
      );
      
    } catch (e) {
      return AIResponse(
        id: _uuid.v4(),
        content: 'I apologize, but I encountered an error while processing your request. Please try again.',
        toolCalls: [],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> updateConfiguration(AIServiceConfig config) async {
    await initialize(config);
  }

  @override
  Future<void> dispose() async {
    _chatModel = null;
    _config = null;
  }

  /// Convert our AIToolConfiguration objects to LangChain ToolSpec format
  List<lc.ToolSpec> _convertToToolSpecs(List<AIToolConfiguration> tools) {
    return tools.map((tool) => lc.ToolSpec(
      name: tool.name,
      description: tool.description,
      inputJsonSchema: tool.schema,
    )).toList();
  }

  /// Build message history for LangChain format
  List<lc.ChatMessage> _buildLangChainMessageHistory(
    String message,
    List<ChatMessage>? conversationHistory,
  ) {
    final messages = <lc.ChatMessage>[];
    
    // Add system prompt
    messages.add(lc.ChatMessage.system(_getSystemPrompt()));
    
    // Add conversation history if provided
    if (conversationHistory != null) {
      for (final historyMessage in conversationHistory) {
        if (historyMessage.isFromUser) {
          messages.add(lc.ChatMessage.humanText(historyMessage.text));
        } else {
          messages.add(lc.ChatMessage.ai(historyMessage.text));
        }
      }
    }
    
    // Add current user message
    messages.add(lc.ChatMessage.humanText(message));
    
    return messages;
  }

  /// Extract tool calls from ChatResult
  List<AIToolCall> _extractToolCalls(lc.ChatResult result) {
    final toolCalls = <AIToolCall>[];
    
    // Check if the result contains tool calls in metadata or output
    final metadata = result.metadata;
    if (metadata != null && metadata.containsKey('tool_calls')) {
      final calls = metadata['tool_calls'] as List?;
      if (calls != null) {
        for (final call in calls) {
          if (call is Map<String, dynamic>) {
            toolCalls.add(AIToolCall(
              id: call['id'] ?? _uuid.v4(),
              name: call['name'] ?? '',
              arguments: call['arguments'] ?? {},
            ));
          }
        }
      }
    }
    
    return toolCalls;
  }

  /// Handle tool calls and get follow-up response
  Future<AIResponse> _handleToolCallsAndRespond(
    List<lc.ChatMessage> messages,
    lc.ChatResult initialResult,
    List<AIToolCall> toolCalls,
  ) async {
    final toolResults = <ToolExecutionResult>[];
    
    // Execute each tool call
    for (final toolCall in toolCalls) {
      try {
        final result = await _toolRegistry.executeTool(toolCall);
        toolResults.add(result);
      } catch (e) {
        toolResults.add(ToolExecutionResult(
          toolCallId: toolCall.id,
          result: {'error': 'Tool execution failed: ${e.toString()}'},
          success: false,
          error: 'Tool execution failed: ${e.toString()}',
          executedAt: DateTime.now(),
        ));
      }
    }
    
    // Build follow-up message with tool results
    final toolResultsMessage = _buildToolResultsMessage(toolResults);
    final updatedMessages = [...messages, toolResultsMessage];
    
    // Get follow-up response from AI
    final followUpResult = await _chatModel!.invoke(
      lc.PromptValue.chat(updatedMessages),
    );
    
    return AIResponse(
      id: _uuid.v4(),
      content: followUpResult.output.content,
      toolCalls: toolCalls,
      isStreaming: false,
      isComplete: true,
      timestamp: DateTime.now(),
      metadata: {
        'model': _config?.model,
        'tool_results': toolResults.map((r) => {
          'toolCallId': r.toolCallId,
          'success': r.success,
          'result': r.result,
          'error': r.error,
          'executedAt': r.executedAt?.toIso8601String(),
        }).toList(),
        'usage': _extractUsageInfo(followUpResult),
      },
    );
  }

  /// Build a message containing tool execution results
  lc.ChatMessage _buildToolResultsMessage(List<ToolExecutionResult> results) {
    final resultTexts = results.map((result) {
      if (result.success) {
        return 'Tool ${result.toolCallId} executed successfully: ${jsonEncode(result.result)}';
      } else {
        return 'Tool ${result.toolCallId} failed: ${jsonEncode(result.result)}';
      }
    }).join('\n');
    
    return lc.ChatMessage.ai('Tool execution results:\n$resultTexts');
  }

  /// Extract usage information from ChatResult
  Map<String, dynamic>? _extractUsageInfo(lc.ChatResult result) {
    final usage = result.usage;
    if (usage == null) return null;
    
    return {
      'input_tokens': usage.promptTokens,
      'output_tokens': usage.responseTokens,
      'total_tokens': usage.totalTokens,
    };
  }

  /// Get comprehensive system prompt for the financial assistant
  String _getSystemPrompt() {
    return '''
You are a knowledgeable and helpful financial assistant for a personal finance management app. Your role is to help users manage their money effectively through the following capabilities:

## Your Available Tools:
- **Transaction Management**: Query, create, update, and delete transactions with detailed filtering and analytics
- **Budget Management**: Create and monitor budgets, track spending against budget limits, and provide budget recommendations
- **Account Management**: Query account balances, create accounts, and provide account-specific insights
- **Category Management**: Organize transactions by categories and provide spending insights by category

## Your Expertise:
- Personal financial planning and budgeting strategies
- Expense tracking and analysis
- Financial goal setting and monitoring
- Money-saving tips and recommendations
- Basic investment concepts and debt management advice

## Guidelines:
1. **Always use tools** when users ask about their financial data - never make up numbers or provide generic responses about their specific finances
2. **Be proactive** in suggesting relevant financial insights and recommendations based on their data
3. **Focus on actionable advice** that can help improve their financial situation
4. **Ask clarifying questions** when needed to provide more targeted help
5. **Maintain a supportive and encouraging tone** while being honest about financial realities
6. **Respect privacy** - never store or reference personal financial information outside of tool calls
7. **Format numbers clearly** using appropriate currency symbols and proper formatting

## Response Style:
- Use clear, concise language that non-financial experts can understand
- Provide specific, data-driven insights when possible
- Include relevant financial tips and best practices
- Use bullet points and formatting to make information scannable
- Always end with a helpful suggestion or next step

Remember: You're not just retrieving data - you're a financial advisor helping users make better money decisions.
''';
  }
}

/// Tool registry that manages all available database tools
class DatabaseToolRegistry implements AIToolManager {
  final Map<String, dynamic> _tools = {};
  final Map<String, AIToolConfiguration> _toolConfigurations = {};

  @override
  List<AIToolConfiguration> get availableTools => _toolConfigurations.values.toList();

  @override
  void registerTool(AIToolConfiguration tool) {
    _toolConfigurations[tool.name] = tool;
  }

  void registerDatabaseTool(dynamic tool) {
    if (tool.configuration != null) {
      final config = tool.configuration as AIToolConfiguration;
      _tools[config.name] = tool;
      registerTool(config);
    }
  }

  List<AIToolConfiguration> getAllTools() {
    return availableTools;
  }

  @override
  Future<ToolExecutionResult> executeTool(AIToolCall toolCall) async {
    final tool = _tools[toolCall.name];
    if (tool == null) {
      throw Exception('Tool ${toolCall.name} not found');
    }

    final startTime = DateTime.now();
    try {
      final result = await tool.execute(toolCall.arguments);
      final endTime = DateTime.now();
      
      return ToolExecutionResult(
        toolCallId: toolCall.id,
        result: result,
        success: true,
        executedAt: endTime,
      );
    } catch (e) {
      final endTime = DateTime.now();
      return ToolExecutionResult(
        toolCallId: toolCall.id,
        result: {'error': e.toString()},
        success: false,
        error: e.toString(),
        executedAt: endTime,
      );
    }
  }

  @override
  Future<List<ToolExecutionResult>> executeTools(List<AIToolCall> toolCalls) async {
    return Future.wait(toolCalls.map((toolCall) => executeTool(toolCall)));
  }

  @override
  bool isToolAvailable(String toolName) {
    return _tools.containsKey(toolName);
  }

  @override
  AIToolConfiguration? getToolConfiguration(String toolName) {
    return _toolConfigurations[toolName];
  }
}

/// Simple conversation manager implementation
class SimpleConversationManager implements ConversationManager {
  final List<ChatMessage> _history = [];
  final int _maxHistoryLength;

  SimpleConversationManager({int maxHistoryLength = 50}) 
    : _maxHistoryLength = maxHistoryLength;

  @override
  void addMessage(ChatMessage message) {
    _history.add(message);
    
    // Keep history within limits
    if (_history.length > _maxHistoryLength) {
      _history.removeRange(0, _history.length - _maxHistoryLength);
    }
  }

  @override
  List<ChatMessage> get conversationHistory => List.unmodifiable(_history);

  @override
  void clearHistory() {
    _history.clear();
  }

  @override
  String getConversationSummary() {
    if (_history.isEmpty) return 'No conversation history';
    
    final recentMessages = _history.take(5).map((msg) => 
      '${msg.isFromUser ? "User" : "AI"}: ${msg.text.length > 100 ? '${msg.text.substring(0, 100)}...' : msg.text}'
    ).join('\n');
    
    return 'Recent conversation:\n$recentMessages';
  }

  @override
  List<ChatMessage> getTrimmedHistory(int maxTokens) {
    // Simple implementation - estimate ~4 characters per token
    final maxChars = maxTokens * 4;
    var totalChars = 0;
    final trimmedHistory = <ChatMessage>[];
    
    // Add messages from newest to oldest until we hit the limit
    for (int i = _history.length - 1; i >= 0; i--) {
      final message = _history[i];
      totalChars += message.text.length;
      
      if (totalChars > maxChars && trimmedHistory.isNotEmpty) {
        break;
      }
      
      trimmedHistory.insert(0, message);
    }
    
    return trimmedHistory;
  }
}