import 'dart:convert';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/ai_response.dart';
import '../../domain/entities/ai_tool_call.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/services/ai_service.dart';
import 'gemini_ai_service.dart';

/// Simple AI service implementation for demonstration and testing
class SimpleAIService implements AIService {
  DatabaseToolRegistry? _toolRegistry;
  AIServiceConfig? _config;
  final _uuid = const Uuid();
  bool _isInitialized = false;

  SimpleAIService(this._toolRegistry);

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isConfigured => _config != null;

  @override
  Future<void> initialize(AIServiceConfig config) async {
    try {
      _config = config;
      _isInitialized = true;
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
      final responseId = _uuid.v4();
      
      // Check if message requires tool usage
      final toolCall = _analyzeMessageForTools(message);
      
      if (toolCall != null) {
        // Execute tool and provide response
        yield* _handleToolExecution(responseId, message, toolCall);
      } else {
        // Generate direct response
        yield* _generateDirectResponse(responseId, message);
      }
      
    } catch (e) {
      yield AIResponse(
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
  Future<AIResponse> sendMessage(
    String message, {
    List<ChatMessage>? conversationHistory,
    List<AIToolConfiguration>? availableTools,
  }) async {
    if (!isInitialized) {
      throw StateError('AI service not initialized');
    }

    try {
      final responseId = _uuid.v4();
      
      // Check if message requires tool usage
      final toolCall = _analyzeMessageForTools(message);
      
      if (toolCall != null && _toolRegistry != null) {
        // Execute tool and provide response
        final toolResult = await _toolRegistry!.executeTool(toolCall);
        
        return AIResponse(
          id: responseId,
          content: _formatToolResponse(message, toolCall, toolResult),
          toolCalls: [toolCall],
          isStreaming: false,
          isComplete: true,
          timestamp: DateTime.now(),
          metadata: {
            'model': _config?.model,
            'tool_result': {
              'toolCallId': toolResult.toolCallId,
              'success': toolResult.success,
              'result': toolResult.result,
              'error': toolResult.error,
            },
          },
        );
      } else {
        // Generate direct response
        return AIResponse(
          id: responseId,
          content: _generateSmartResponse(message),
          toolCalls: [],
          isStreaming: false,
          isComplete: true,
          timestamp: DateTime.now(),
          metadata: {
            'model': _config?.model,
            'response_type': 'direct',
          },
        );
      }
      
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
    _config = config;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
    _config = null;
  }

  /// Analyze user message to determine if it requires tool usage
  AIToolCall? _analyzeMessageForTools(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Transaction queries
    if (lowerMessage.contains('transaction') || 
        lowerMessage.contains('expense') || 
        lowerMessage.contains('income') ||
        lowerMessage.contains('spending')) {
      return AIToolCall(
        id: _uuid.v4(),
        name: 'query_transactions',
        arguments: {'query_type': 'all'},
      );
    }
    
    // Budget queries
    if (lowerMessage.contains('budget')) {
      return AIToolCall(
        id: _uuid.v4(),
        name: 'query_budgets',
        arguments: {'query_type': 'all'},
      );
    }
    
    // Account queries
    if (lowerMessage.contains('balance') || 
        lowerMessage.contains('account')) {
      return AIToolCall(
        id: _uuid.v4(),
        name: 'query_accounts',
        arguments: {'query_type': 'all', 'include_balance': true},
      );
    }
    
    // Category queries
    if (lowerMessage.contains('categor')) {
      return AIToolCall(
        id: _uuid.v4(),
        name: 'query_categories',
        arguments: {'query_type': 'all'},
      );
    }
    
    return null;
  }

  /// Handle tool execution with streaming response
  Stream<AIResponse> _handleToolExecution(
    String responseId,
    String message,
    AIToolCall toolCall,
  ) async* {
    // Start with processing message
    yield AIResponse(
      id: responseId,
      content: 'Let me check that for you...',
      toolCalls: [toolCall],
      isStreaming: true,
      isComplete: false,
      timestamp: DateTime.now(),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Execute the tool
      final toolResult = await _toolRegistry!.executeTool(toolCall);
      
      // Provide final response
      yield AIResponse(
        id: responseId,
        content: _formatToolResponse(message, toolCall, toolResult),
        toolCalls: [toolCall],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {
          'tool_result': {
            'success': toolResult.success,
            'result': toolResult.result,
          },
        },
      );
    } catch (e) {
      yield AIResponse(
        id: responseId,
        content: 'I encountered an error while retrieving your data: ${e.toString()}',
        toolCalls: [toolCall],
        isStreaming: false,
        isComplete: true,
        timestamp: DateTime.now(),
        metadata: {'error': e.toString()},
      );
    }
  }

  /// Generate streaming direct response
  Stream<AIResponse> _generateDirectResponse(
    String responseId,
    String message,
  ) async* {
    final response = _generateSmartResponse(message);
    final words = response.split(' ');
    
    String accumulatedResponse = '';
    
    for (int i = 0; i < words.length; i++) {
      accumulatedResponse += '${words[i]} ';
      
      yield AIResponse(
        id: responseId,
        content: accumulatedResponse.trim(),
        toolCalls: [],
        isStreaming: i < words.length - 1,
        isComplete: i >= words.length - 1,
        timestamp: DateTime.now(),
      );
      
      // Small delay for streaming effect
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Format tool execution response for user
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
      return 'I couldn\'t find any data for your request.';
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
      return 'You don\'t have any transactions recorded yet. Would you like me to help you add some?';
    }
    
    String response = 'I found $count transaction${count == 1 ? '' : 's'} for you:\n\n';
    
    for (int i = 0; i < transactions.take(5).length; i++) {
      final transaction = transactions[i] as Map<String, dynamic>;
      final amount = transaction['amount'] ?? 0.0;
      final description = transaction['description'] ?? 'Unknown';
      final date = transaction['date'] ?? 'ai_chat.unknown_date'.tr();
      
      response += '• ${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)} - $description ($date)\n';
    }
    
    if (transactions.length > 5) {
      response += '\n... and ${transactions.length - 5} more transactions.';
    }
    
    return response;
  }

  String _formatBudgetResponse(Map<String, dynamic> result) {
    final count = result['count'] ?? 0;
    final budgets = result['budgets'] as List? ?? [];
    
    if (count == 0) {
      return 'You don\'t have any budgets set up yet. Would you like me to help you create one?';
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
      return 'You don\'t have any accounts set up yet. Would you like me to help you add one?';
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
      return 'You don\'t have any categories set up yet. The app will use default categories.';
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

  /// Generate smart contextual response
  String _generateSmartResponse(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m your AI financial assistant. I can help you track transactions, manage budgets, check account balances, and analyze your spending patterns. What would you like to know about your finances?';
    }
    
    if (lowerMessage.contains('help')) {
      return 'I can help you with:\n\n• View your transactions and spending\n• Check account balances\n• Review budget status\n• Analyze spending by category\n• Create new transactions and budgets\n• Provide financial insights\n\nJust ask me about any of these topics!';
    }
    
    if (lowerMessage.contains('thank')) {
      return 'You\'re welcome! I\'m here to help you manage your finances. Is there anything else you\'d like to know?';
    }
    
    if (lowerMessage.contains('bye') || lowerMessage.contains('goodbye')) {
      return 'Goodbye! Feel free to come back anytime you need help with your finances. Have a great day!';
    }
    
    // Default intelligent response
    return 'I understand you\'re asking about "${message}". I have access to all your financial data and can help you with transactions, budgets, accounts, and categories. Could you be more specific about what you\'d like to know?';
  }
}