import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_tool_call.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/services/ai_service.dart';
import 'gemini_ai_service.dart' show DatabaseToolRegistry;
import 'ai_error_handler.dart';

/// Real implementation of AIService using Google Generative AI (Gemini)
/// This replaces the placeholder implementation with actual Gemini API calls
class RealGeminiAIService implements AIService {
  GenerativeModel? _model;
  AIServiceConfig? _config;
  final DatabaseToolRegistry _toolRegistry;
  final _uuid = const Uuid();
  bool _isInitialized = false;
  ChatSession? _chatSession;

  RealGeminiAIService(this._toolRegistry) {
    debugPrint('🤖 RealGeminiAIService - Constructor called');
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isConfigured => _config != null;

  @override
  Future<void> initialize(AIServiceConfig config) async {
    debugPrint('🔧 RealGeminiAIService - Starting initialization...');
    debugPrint('🔧 API Key provided: ${config.apiKey.isNotEmpty ? "Yes (${config.apiKey.length} chars)" : "No"}');
    debugPrint('🔧 Model: ${config.model}');
    debugPrint('🔧 Temperature: ${config.temperature}');
    debugPrint('🔧 Max Tokens: ${config.maxTokens}');
    debugPrint('🔧 Tools Enabled: ${config.toolsEnabled}');
    
    try {
      _config = config;
      
      // Validate configuration
      final validationErrors = AIErrorHandler.validateConfiguration(
        apiKey: config.apiKey,
        model: config.model,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
      );
      
      if (validationErrors.isNotEmpty) {
        debugPrint('❌ Configuration validation failed: ${validationErrors.join(', ')}');
        throw Exception('Configuration errors: ${validationErrors.join(', ')}');
      }

      debugPrint('✅ Configuration validation passed');

      // Build tools for Gemini
      final geminiTools = _buildGeminiTools();
      debugPrint('🛠️ Built ${geminiTools.length} Gemini tools');
      
      // Initialize Gemini model with function calling capabilities
      debugPrint('🔧 Initializing Gemini model with function calling...');
      _model = GenerativeModel(
        model: config.model,
        apiKey: config.apiKey,
        tools: geminiTools,
        generationConfig: GenerationConfig(
          temperature: config.temperature,
          maxOutputTokens: config.maxTokens,
        ),
        systemInstruction: Content.system(_buildSystemPrompt()),
      );

      // Start a new chat session for conversation context
      debugPrint('💬 Starting Gemini chat session...');
      _chatSession = _model!.startChat();
      
      _isInitialized = true;
      debugPrint('✅ RealGeminiAIService - Initialization completed successfully');
    } catch (e) {
      debugPrint('❌ RealGeminiAIService - Initialization failed: $e');
      throw Exception('Failed to initialize Gemini AI service: ${AIErrorHandler.handleError(e)}');
    }
  }

  @override
  Stream<AIResponse> sendMessageStream(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async* {
    debugPrint('📤 RealGeminiAIService - sendMessageStream called');
    debugPrint('📤 User message: "$message"');
    debugPrint('📤 Conversation history length: ${conversationHistory?.length ?? 0}');
    
    if (!isInitialized || _chatSession == null) {
      debugPrint('❌ AI service not initialized or chat session null');
      throw StateError('AI service not initialized');
    }

    try {
      // Apply rate limiting
      debugPrint('⏱️ Checking rate limit...');
      await AIErrorHandler.checkRateLimit('sendMessageStream');
      debugPrint('✅ Rate limit check passed');
      
      final responseId = _uuid.v4();
      debugPrint('🆔 Generated response ID: $responseId');
      
      // Send message to Gemini with retry logic
      debugPrint('📡 Sending message to Gemini API...');
      final response = await AIErrorHandler.executeWithRetry(() async {
        debugPrint('🔄 Executing API call (with retry logic)');
        return _chatSession!.sendMessageStream(Content.text(message));
      });
      debugPrint('📡 Gemini API call initiated successfully');

      String accumulatedContent = '';
      List<AIToolCall> toolCalls = [];
      bool hasToolCalls = false;
      int chunkCount = 0;

      await for (final chunk in response) {
        chunkCount++;
        debugPrint('📦 Processing chunk #$chunkCount');
        
        // Handle tool calls if present
        if (chunk.functionCalls.isNotEmpty && !hasToolCalls) {
          hasToolCalls = true;
          debugPrint('🛠️ Function calls detected: ${chunk.functionCalls.length}');
          
          // Process function calls
          final functionCallsList = chunk.functionCalls.toList();
          for (int i = 0; i < functionCallsList.length; i++) {
            final functionCall = functionCallsList[i];
            debugPrint('🔧 Processing function call ${i + 1}/${functionCallsList.length}: ${functionCall.name}');
            debugPrint('🔧 Function arguments: ${jsonEncode(functionCall.args)}');
            
            final toolCall = AIToolCall(
              id: _uuid.v4(),
              name: functionCall.name,
              arguments: functionCall.args,
            );
            toolCalls.add(toolCall);

            // Execute the tool
            debugPrint('⚙️ Executing tool: ${toolCall.name}');
            final toolResult = await _toolRegistry.executeTool(toolCall);
            debugPrint('⚙️ Tool execution result - Success: ${toolResult.success}');
            if (toolResult.success) {
              final resultString = jsonEncode(toolResult.result);
              final previewLength = resultString.length > 200 ? 200 : resultString.length;
              debugPrint('✅ Tool result: ${resultString.substring(0, previewLength)}${resultString.length > 200 ? '...' : ''}');
            } else {
              debugPrint('❌ Tool error: ${toolResult.error}');
            }
            
            // Store tool result for potential formatting later
            debugPrint('💾 Storing tool result for potential formatting');
            final updatedToolCall = toolCall.copyWith(
              result: jsonEncode(toolResult.result),
              isExecuted: true,
              error: toolResult.success ? null : toolResult.error,
            );
            
            // Replace the tool call in the list
            final index = toolCalls.indexOf(toolCall);
            if (index >= 0) {
              toolCalls[index] = updatedToolCall;
            }

            // Send tool result back to Gemini for response generation
            debugPrint('📡 Sending tool result back to Gemini...');
            final geminiResponse = await _chatSession!.sendMessage(Content.functionResponse(
              functionCall.name,
              toolResult.success ? toolResult.result : {'error': toolResult.error},
            ));
            debugPrint('📡 Tool result sent to Gemini successfully');
            
            // If Gemini provides a text response, add it to accumulated content
            if (geminiResponse.text != null && geminiResponse.text!.isNotEmpty) {
              accumulatedContent += geminiResponse.text!;
              debugPrint('📝 Added Gemini response to content: ${geminiResponse.text!.length} chars');
            }
          }

          // Yield response with tool execution
          yield AIResponse(
            id: responseId,
            content: 'Let me get that information for you...',
            toolCalls: toolCalls,
            isStreaming: true,
            isComplete: false,
            timestamp: DateTime.now(),
          );
          debugPrint('📤 Yielded intermediate response with tool execution');
        }

        // Handle text content
        if (chunk.text != null) {
          accumulatedContent += chunk.text!;
          debugPrint('📝 Accumulated content length: ${accumulatedContent.length}');
          
          yield AIResponse(
            id: responseId,
            content: accumulatedContent,
            toolCalls: toolCalls,
            isStreaming: true,
            isComplete: false,
            timestamp: DateTime.now(),
            metadata: {
              'model': _config?.model ?? 'gemini-1.5-pro',
              'has_tool_calls': hasToolCalls,
              'chunk_count': chunkCount,
            },
          );
          debugPrint('📤 Yielded streaming response chunk #$chunkCount');
        }
      }

      debugPrint('🏁 Streaming completed. Total chunks: $chunkCount');
      debugPrint('🏁 Final content length: ${accumulatedContent.length}');
      debugPrint('🏁 Tool calls executed: ${toolCalls.length}');

      // Final response - format tool results if no text content
      String finalContent = accumulatedContent;
      if (finalContent.isEmpty && toolCalls.isNotEmpty) {
        // Format tool results since Gemini didn't provide text
        finalContent = _formatMultipleToolResults(toolCalls);
        debugPrint('📝 Generated formatted content from tool results: ${finalContent.length} chars');
      } else if (finalContent.isEmpty) {
        finalContent = 'I have completed your request.';
      }

      yield AIResponse(
        id: responseId,
        content: finalContent,
        toolCalls: toolCalls,
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {
          'model': _config?.model ?? 'gemini-1.5-pro',
          'has_tool_calls': hasToolCalls,
          'tool_count': toolCalls.length,
          'total_chunks': chunkCount,
        },
      );
      debugPrint('✅ Final response yielded successfully');
      
    } catch (e) {
      debugPrint('❌ sendMessageStream error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      yield AIResponse(
        id: _uuid.v4(),
        content: AIErrorHandler.handleError(e),
        toolCalls: [],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
      debugPrint('📤 Error response yielded');
    }
  }

  @override
  Future<AIResponse> sendMessage(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async {
    debugPrint('📤 RealGeminiAIService - sendMessage called');
    debugPrint('📤 User message: "$message"');
    
    if (!isInitialized || _model == null) {
      debugPrint('❌ AI service not initialized or model null');
      throw StateError('AI service not initialized');
    }

    try {
      // Apply rate limiting
      debugPrint('⏱️ Checking rate limit...');
      await AIErrorHandler.checkRateLimit('sendMessage');
      debugPrint('✅ Rate limit check passed');
      
      final responseId = _uuid.v4();
      debugPrint('🆔 Generated response ID: $responseId');
      
      // Send message to Gemini with retry logic
      debugPrint('📡 Sending message to Gemini API...');
      final response = await AIErrorHandler.executeWithRetry(() async {
        debugPrint('🔄 Executing API call (with retry logic)');
        return _model!.generateContent([Content.text(message)]);
      });
      debugPrint('📡 Gemini API call completed successfully');

      final toolCalls = <AIToolCall>[];
      String content = '';

      // Handle function calls
              if (response.functionCalls.isNotEmpty) {
          debugPrint('🛠️ Function calls detected: ${response.functionCalls.length}');
          
          final functionCallsList = response.functionCalls.toList();
          for (int i = 0; i < functionCallsList.length; i++) {
            final functionCall = functionCallsList[i];
            debugPrint('🔧 Processing function call ${i + 1}/${functionCallsList.length}: ${functionCall.name}');
            debugPrint('🔧 Function arguments: ${jsonEncode(functionCall.args)}');
          
          final toolCall = AIToolCall(
            id: _uuid.v4(),
            name: functionCall.name,
            arguments: functionCall.args,
          );
          toolCalls.add(toolCall);

          // Execute the tool
          debugPrint('⚙️ Executing tool: ${toolCall.name}');
          final toolResult = await _toolRegistry.executeTool(toolCall);
          debugPrint('⚙️ Tool execution result - Success: ${toolResult.success}');
          if (toolResult.success) {
            final resultString = jsonEncode(toolResult.result);
            final previewLength = resultString.length > 200 ? 200 : resultString.length;
            debugPrint('✅ Tool result: ${resultString.substring(0, previewLength)}${resultString.length > 200 ? '...' : ''}');
          } else {
            debugPrint('❌ Tool error: ${toolResult.error}');
          }
          
          // Format the response
          content = _formatToolResponse(message, toolCall, toolResult);
          debugPrint('📝 Formatted tool response length: ${content.length}');
        }
      } else if (response.text != null) {
        content = response.text!;
        debugPrint('📝 Direct text response length: ${content.length}');
      }

      debugPrint('✅ sendMessage completed successfully');
      return AIResponse(
        id: responseId,
        content: content,
        toolCalls: toolCalls,
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {
          'model': _config?.model ?? 'gemini-1.5-pro',
          'response_type': toolCalls.isNotEmpty ? 'tool_call' : 'direct',
          'tool_count': toolCalls.length,
        },
      );
      
    } catch (e) {
      debugPrint('❌ sendMessage error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      return AIResponse(
        id: _uuid.v4(),
        content: AIErrorHandler.handleError(e),
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
    debugPrint('🔧 RealGeminiAIService - updateConfiguration called');
    await dispose();
    await initialize(config);
  }

  @override
  Future<void> dispose() async {
    debugPrint('🗑️ RealGeminiAIService - dispose called');
    _isInitialized = false;
    _config = null;
    _model = null;
    _chatSession = null;
    debugPrint('🗑️ RealGeminiAIService - disposed successfully');
  }

  /// Build Gemini function tools from available database tools
  List<Tool> _buildGeminiTools() {
    debugPrint('🛠️ Building Gemini tools from available database tools...');
    final tools = <Tool>[];
    final availableTools = _toolRegistry.availableTools;
    debugPrint('🛠️ Available tools count: ${availableTools.length}');
    
    for (int i = 0; i < availableTools.length; i++) {
      final toolConfig = availableTools[i];
      debugPrint('🔧 Building tool ${i + 1}/${availableTools.length}: ${toolConfig.name}');
      
      final functionDeclaration = FunctionDeclaration(
        toolConfig.name,
        toolConfig.description,
        Schema.object(
          properties: _convertSchemaProperties(toolConfig.schema['properties'] as Map<String, dynamic>? ?? {}),
          requiredProperties: (toolConfig.schema['required'] as List<dynamic>?)?.cast<String>() ?? [],
          description: toolConfig.description,
        ),
      );
      
      tools.add(Tool(functionDeclarations: [functionDeclaration]));
      debugPrint('✅ Tool built: ${toolConfig.name}');
    }
    
    debugPrint('🛠️ Total Gemini tools built: ${tools.length}');
    return tools;
  }

  /// Convert JSON schema properties to Gemini Schema properties
  Map<String, Schema> _convertSchemaProperties(Map<String, dynamic> properties) {
    final converted = <String, Schema>{};
    
    properties.forEach((key, value) {
      final prop = value as Map<String, dynamic>;
      final type = prop['type'] as String?;
      
      switch (type) {
        case 'string':
          if (prop['enum'] != null) {
            converted[key] = Schema.enumString(
              description: prop['description'] as String?,
              enumValues: (prop['enum'] as List).cast<String>(),
            );
          } else {
            converted[key] = Schema.string(
              description: prop['description'] as String?,
            );
          }
          break;
        case 'number':
          converted[key] = Schema.number(
            description: prop['description'] as String?,
          );
          break;
        case 'integer':
          converted[key] = Schema.integer(
            description: prop['description'] as String?,
          );
          break;
        case 'boolean':
          converted[key] = Schema.boolean(
            description: prop['description'] as String?,
          );
          break;
        case 'array':
          converted[key] = Schema.array(
            description: prop['description'] as String?,
            items: Schema.string(), // Simplified - could be more complex
          );
          break;
        case 'object':
          converted[key] = Schema.object(
            properties: <String, Schema>{},
            description: prop['description'] as String?,
          );
          break;
        default:
          converted[key] = Schema.string(
            description: prop['description'] as String?,
          );
      }
    });
    
    return converted;
  }

  /// Build comprehensive system prompt for financial assistant
  String _buildSystemPrompt() {
    return '''
You are an AI Financial Assistant for a personal finance management app. You have access to comprehensive financial tools and data.

**Your Role:**
- Help users understand their financial situation
- Provide insights and recommendations
- Execute financial operations through available tools
- Maintain a professional, helpful, and encouraging tone

**Your Capabilities:**
- Query and analyze transactions, budgets, accounts, and categories
- Create, update, and delete financial records
- Provide financial insights and recommendations
- Calculate budgets, spending patterns, and trends
- Help with financial planning and goal setting

**Communication Style:**
- Be conversational but professional
- Use clear, easy-to-understand language
- Format financial data clearly (use bullet points, tables when appropriate)
- Provide actionable insights and suggestions
- Always ask clarifying questions when needed
- Be encouraging about financial goals and progress

**Financial Expertise:**
- Understand budgeting principles
- Recognize spending patterns and trends
- Suggest cost-saving opportunities
- Help with financial goal planning
- Provide context for financial decisions

**Tool Usage Guidelines:**
- Always use appropriate tools to access current user data
- Format responses with actual data, not assumptions
- Explain what you're checking when using tools
- Provide summaries and insights after retrieving data

**Data Presentation:**
- Show amounts with proper currency formatting
- Include relevant dates and timeframes
- Highlight important trends or alerts
- Use clear categorization and organization

Remember: You have access to the user's complete financial data through your tools. Always provide helpful, accurate, and personalized advice based on their actual financial situation.
''';
  }

  /// Format tool execution response for user presentation
  String _formatToolResponse(
    String originalMessage,
    AIToolCall toolCall,
    ToolExecutionResult toolResult,
  ) {
    if (!toolResult.success) {
      return 'I encountered an issue retrieving your ${toolCall.name.replaceAll('query_', '').replaceAll('_', ' ')}: ${toolResult.error ?? 'Unknown error'}';
    }

    final result = toolResult.result as Map<String, dynamic>?;
    if (result == null) {
      return 'I could not find any data for your request.';
    }

    switch (toolCall.name) {
      case 'query_transactions':
        return _formatTransactionResponse(result);
      case 'query_budgets':
        return _formatBudgetResponse(result);
      case 'query_accounts':
        return _formatAccountResponse(result);
      case 'query_categories':
        return _formatCategoryResponse(result);
      default:
        return 'I found some information about your ${toolCall.name.replaceAll('query_', '').replaceAll('_', ' ')}: ${jsonEncode(result)}';
    }
  }

  String _formatTransactionResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final transactions = result['transactions'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any transactions recorded yet. Would you like me to help you add some?';
    }
    
    // Create a rich formatted response with structured data for UI rendering
    String response = 'I found $count transaction${count == 1 ? '' : 's'} matching your search:\n\n';
    
    // Add structured transaction data that the UI can parse for rich display
    response += '[TRANSACTIONS_DATA]\n';
    response += jsonEncode(transactions.take(5).toList());
    response += '\n[/TRANSACTIONS_DATA]\n\n';
    
    // Add readable text summary
    for (int i = 0; i < transactions.take(3).length; i++) {
      final transaction = transactions[i] as Map<String, dynamic>;
      final amount = transaction['amount'] ?? 0.0;
      final description = transaction['description'] ?? 'Unknown';
      final date = transaction['date'] ?? 'Unknown date';
      
      response += '💰 ${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} - $description ($date)\n';
    }
    
    if (transactions.length > 3) {
      response += '\n... and ${transactions.length - 3} more transaction${transactions.length - 3 == 1 ? '' : 's'}. Tap on any transaction above to view details.';
    } else if (transactions.isNotEmpty) {
      response += '\nTap on any transaction above to view details.';
    }
    
    return response;
  }

  String _formatBudgetResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final budgets = result['budgets'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any budgets set up yet. Would you like me to help you create one?';
    }
    
    String response = 'Here are your current budgets:\n\n';
    
    for (final budget in budgets.take(3)) {
      final budgetData = budget as Map<String, dynamic>;
      final amount = budgetData['amount'] ?? 0.0;
      final name = budgetData['name'] ?? 'Unnamed Budget';
      final spent = budgetData['spent'] ?? 0.0;
      final remaining = amount - spent;
      
      response += '• $name: ${spent.toStringAsFixed(2)} / ${amount.toStringAsFixed(2)} (${remaining.toStringAsFixed(2)} remaining)\n';
    }
    
    return response;
  }

  String _formatAccountResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final accounts = result['accounts'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any accounts set up yet. Would you like me to help you add one?';
    }
    
    String response = 'Here are your accounts:\n\n';
    double totalBalance = 0.0;
    
    for (final account in accounts) {
      final accountData = account as Map<String, dynamic>;
      final balance = accountData['balance'] ?? 0.0;
      final name = accountData['name'] ?? 'Unnamed Account';
      final currency = accountData['currency'] ?? 'USD';
      
      response += '• $name: ${balance.toStringAsFixed(2)} $currency\n';
      totalBalance += balance;
    }
    
    response += '\nTotal Balance: ${totalBalance.toStringAsFixed(2)}';
    
    return response;
  }

  String _formatCategoryResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final categories = result['categories'] as List? ?? [];
    
    if (count == 0) {
      return 'You do not have any categories set up yet. The app will use default categories.';
    }
    
    final expenseCategories = categories.where((c) => 
      (c as Map<String, dynamic>)['is_expense'] == true
    ).length;
    final incomeCategories = count - expenseCategories;
    
    String response = 'You have $count categories set up:\n';
    response += '• $expenseCategories expense categories\n';
    response += '• $incomeCategories income categories\n\n';
    
    response += 'This helps you organize and track your financial transactions effectively!';
    
    return response;
  }

  /// Format multiple tool results when Gemini doesn't provide text response
  String _formatMultipleToolResults(List<AIToolCall> toolCalls) {
    if (toolCalls.isEmpty) return 'No data found.';
    
    final StringBuffer response = StringBuffer();
    
    for (final toolCall in toolCalls) {
      if (toolCall.result != null) {
        try {
          final resultData = jsonDecode(toolCall.result!);
          final formattedResult = _formatToolResultData(toolCall.name, resultData);
          response.writeln(formattedResult);
        } catch (e) {
          debugPrint('❌ Error formatting tool result: $e');
          response.writeln(_formatToolCallFallback(toolCall));
        }
      } else {
        response.writeln(_formatToolCallFallback(toolCall));
      }
      
      if (toolCalls.length > 1) response.writeln();
    }
    
    return response.toString().trim();
  }

  /// Format tool result data using the same logic as existing formatters
  String _formatToolResultData(String toolName, dynamic resultData) {
    if (resultData is! Map<String, dynamic>) {
      return 'I retrieved the data but couldn\'t format it properly.';
    }

    final result = resultData;
    
    switch (toolName) {
      case 'query_transactions':
        return _formatTransactionResponse(result);
      case 'query_budgets':
        return _formatBudgetResponse(result);
      case 'query_accounts':
        return _formatAccountResponse(result);
      case 'query_categories':
        return _formatCategoryResponse(result);
      default:
        return 'I found some information about your ${toolName.replaceAll('query_', '').replaceAll('_', ' ')}: ${jsonEncode(result)}';
    }
  }

  /// Fallback formatting when tool result is not available
  String _formatToolCallFallback(AIToolCall toolCall) {
    switch (toolCall.name) {
      case 'query_transactions':
        if (toolCall.arguments['keyword'] != null) {
          return 'I searched for transactions containing "${toolCall.arguments['keyword']}" but couldn\'t retrieve the results properly. Please try asking again or check your transaction list directly.';
        }
        return 'I found your transactions but couldn\'t display them properly. Please try asking again.';
      case 'query_budgets':
        return 'I retrieved your budget information but couldn\'t display it properly. Please try asking again.';
      case 'query_accounts':
        return 'I found your account information but couldn\'t display it properly. Please try asking again.';
      case 'query_categories':
        return 'I retrieved your categories but couldn\'t display them properly. Please try asking again.';
      default:
        return 'I executed the requested operation but couldn\'t display the results properly. Please try asking again.';
    }
  }
}