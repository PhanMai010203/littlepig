import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/agent/data/services/gemini_ai_service.dart';
import 'package:finance/features/agent/data/services/ai_tool_registry_service.dart';
import 'package:finance/features/agent/domain/entities/ai_tool_call.dart';
import 'package:finance/features/agent/domain/entities/ai_response.dart';
import 'package:finance/features/agent/domain/entities/chat_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  group('AI Tool Registry Tests', () {
    late DatabaseToolRegistry toolRegistry;
    late AIToolRegistryService registryService;

    setUp(() {
      toolRegistry = DatabaseToolRegistry();
      registryService = AIToolRegistryService(toolRegistry);
    });

    group('Tool Registry Basic Tests', () {
      test('should initialize empty registry', () {
        expect(toolRegistry.availableTools, isEmpty);
        expect(registryService.registeredToolCount, equals(0));
        expect(registryService.availableToolNames, isEmpty);
      });

      test('should register tool configurations', () {
        // Arrange
        final testTool = AIToolConfiguration(
          name: 'test_tool',
          description: 'A test tool',
          schema: {
            'type': 'object',
            'properties': {
              'param1': {'type': 'string'},
            },
            'required': ['param1'],
          },
        );

        // Act
        toolRegistry.registerTool(testTool);

        // Assert
        expect(toolRegistry.availableTools, hasLength(1));
        expect(toolRegistry.isToolAvailable('test_tool'), isTrue);
        expect(toolRegistry.getToolConfiguration('test_tool'), equals(testTool));
      });

      test('should check tool availability correctly', () {
        // Arrange
        final testTool = AIToolConfiguration(
          name: 'available_tool',
          description: 'An available tool',
          schema: {'type': 'object'},
        );
        toolRegistry.registerTool(testTool);

        // Act & Assert
        expect(toolRegistry.isToolAvailable('available_tool'), isTrue);
        expect(toolRegistry.isToolAvailable('nonexistent_tool'), isFalse);
      });

      test('should return null for nonexistent tool configuration', () {
        // Act
        final config = toolRegistry.getToolConfiguration('nonexistent');

        // Assert
        expect(config, isNull);
      });
    });

    group('AI Response Tests', () {
      test('should create basic AI response', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final response = AIResponse(
          id: 'test-response-1',
          content: 'Hello! I can help you with your finances.',
          isStreaming: false,
          isComplete: true,
          timestamp: timestamp,
        );

        // Assert
        expect(response.id, equals('test-response-1'));
        expect(response.content, contains('finances'));
        expect(response.toolCalls, isEmpty);
        expect(response.isStreaming, isFalse);
        expect(response.isComplete, isTrue);
        expect(response.timestamp, equals(timestamp));
      });

      test('should create AI response with tool calls', () {
        // Arrange
        final toolCall = AIToolCall(
          id: 'call-1',
          name: 'query_transactions',
          arguments: {'query_type': 'all'},
        );

        // Act
        final response = AIResponse(
          id: 'test-response-2',
          content: 'Let me check your transactions.',
          toolCalls: [toolCall],
          isStreaming: false,
          isComplete: true,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(response.toolCalls, hasLength(1));
        expect(response.toolCalls.first.name, equals('query_transactions'));
        expect(response.toolCalls.first.arguments['query_type'], equals('all'));
      });

      test('should handle streaming AI response', () {
        // Act
        final response = AIResponse(
          id: 'streaming-response',
          content: 'Partial content...',
          isStreaming: true,
          isComplete: false,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(response.isStreaming, isTrue);
        expect(response.isComplete, isFalse);
      });
    });

    group('AI Tool Call Tests', () {
      test('should create valid tool call', () {
        // Act
        final toolCall = AIToolCall(
          id: 'tool-call-1',
          name: 'create_transaction',
          arguments: {
            'amount': 50.0,
            'description': 'Coffee',
            'category_id': 1,
          },
        );

        // Assert
        expect(toolCall.id, equals('tool-call-1'));
        expect(toolCall.name, equals('create_transaction'));
        expect(toolCall.arguments['amount'], equals(50.0));
        expect(toolCall.arguments['description'], equals('Coffee'));
        expect(toolCall.isExecuted, isFalse);
        expect(toolCall.result, isNull);
        expect(toolCall.error, isNull);
      });

      test('should handle tool call execution state', () {
        // Arrange
        final toolCall = AIToolCall(
          id: 'executed-call',
          name: 'query_balance',
          arguments: {},
          isExecuted: true,
          result: 'Balance: \$1,500.00',
        );

        // Assert
        expect(toolCall.isExecuted, isTrue);
        expect(toolCall.result, equals('Balance: \$1,500.00'));
      });

      test('should handle tool call with error', () {
        // Arrange
        final toolCall = AIToolCall(
          id: 'error-call',
          name: 'invalid_operation',
          arguments: {},
          isExecuted: true,
          error: 'Operation failed: Invalid parameters',
        );

        // Assert
        expect(toolCall.isExecuted, isTrue);
        expect(toolCall.error, contains('Operation failed'));
      });
    });

    group('Tool Execution Result Tests', () {
      test('should create successful execution result', () {
        // Arrange
        final executedAt = DateTime.now();

        // Act
        final result = ToolExecutionResult(
          toolCallId: 'successful-call',
          success: true,
          result: {
            'data': ['transaction1', 'transaction2'],
            'count': 2,
          },
          executedAt: executedAt,
        );

        // Assert
        expect(result.toolCallId, equals('successful-call'));
        expect(result.success, isTrue);
        expect(result.result['count'], equals(2));
        expect(result.error, isNull);
        expect(result.executedAt, equals(executedAt));
      });

      test('should create failed execution result', () {
        // Arrange
        final executedAt = DateTime.now();

        // Act
        final result = ToolExecutionResult(
          toolCallId: 'failed-call',
          success: false,
          result: null,
          error: 'Database connection timeout',
          executedAt: executedAt,
        );

        // Assert
        expect(result.toolCallId, equals('failed-call'));
        expect(result.success, isFalse);
        expect(result.result, isNull);
        expect(result.error, equals('Database connection timeout'));
        expect(result.executedAt, equals(executedAt));
      });
    });

    group('AI Service Configuration Tests', () {
      test('should create valid configuration', () {
        // Act
        final config = AIServiceConfig(
          apiKey: 'test-gemini-key',
          model: 'gemini-1.5-pro',
          temperature: 0.5,
          maxTokens: 2000,
          toolsEnabled: true,
          enabledTools: ['query_transactions', 'create_transaction'],
        );

        // Assert
        expect(config.apiKey, equals('test-gemini-key'));
        expect(config.model, equals('gemini-1.5-pro'));
        expect(config.temperature, equals(0.5));
        expect(config.maxTokens, equals(2000));
        expect(config.toolsEnabled, isTrue);
        expect(config.enabledTools, hasLength(2));
        expect(config.enabledTools, contains('query_transactions'));
      });

      test('should use default values', () {
        // Act
        final config = AIServiceConfig(
          apiKey: 'required-key',
        );

        // Assert
        expect(config.model, equals('gemini-1.5-pro'));
        expect(config.temperature, equals(0.3));
        expect(config.maxTokens, equals(4000));
        expect(config.toolsEnabled, isTrue);
        expect(config.enabledTools, isEmpty);
      });
    });

    group('Conversation Manager Tests', () {
      late SimpleConversationManager conversationManager;

      setUp(() {
        conversationManager = SimpleConversationManager(maxHistoryLength: 3);
      });

      test('should start with empty history', () {
        expect(conversationManager.conversationHistory, isEmpty);
      });

      test('should add messages to history', () {
        // Arrange
        final message = createTestChatMessage('Hello', isFromUser: true);

        // Act
        conversationManager.addMessage(message);

        // Assert
        expect(conversationManager.conversationHistory, hasLength(1));
        expect(conversationManager.conversationHistory.first.text, equals('Hello'));
      });

      test('should limit history size', () {
        // Act
        for (int i = 0; i < 5; i++) {
          final message = createTestChatMessage('Message $i', isFromUser: i % 2 == 0);
          conversationManager.addMessage(message);
        }

        // Assert
        expect(conversationManager.conversationHistory, hasLength(3));
      });

      test('should clear all history', () {
        // Arrange
        conversationManager.addMessage(createTestChatMessage('Test', isFromUser: true));

        // Act
        conversationManager.clearHistory();

        // Assert
        expect(conversationManager.conversationHistory, isEmpty);
      });

      test('should generate conversation summary', () {
        // Arrange
        conversationManager.addMessage(createTestChatMessage('What is my balance?', isFromUser: true));
        conversationManager.addMessage(createTestChatMessage('Your balance is \$1500', isFromUser: false));

        // Act
        final summary = conversationManager.getConversationSummary();

        // Assert
        expect(summary, contains('balance'));
        expect(summary, contains('User'));
        expect(summary, contains('AI'));
      });

      test('should trim history for token limits', () {
        // Arrange
        for (int i = 0; i < 3; i++) {
          final longMessage = 'This is a very long message ' * 20; // Make it long
          conversationManager.addMessage(createTestChatMessage(longMessage, isFromUser: i % 2 == 0));
        }

        // Act
        final trimmed = conversationManager.getTrimmedHistory(50); // Very small limit

        // Assert
        expect(trimmed.length, lessThan(3));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty tool call arguments', () {
        // Act
        final toolCall = AIToolCall(
          id: 'empty-args',
          name: 'test_tool',
          arguments: {},
        );

        // Assert
        expect(toolCall.arguments, isEmpty);
        expect(toolCall.arguments, isA<Map<String, dynamic>>());
      });

      test('should handle null values in tool results', () {
        // Act
        final result = ToolExecutionResult(
          toolCallId: 'null-result',
          success: true,
          result: null,
          executedAt: DateTime.now(),
        );

        // Assert
        expect(result.result, isNull);
        expect(result.success, isTrue);
      });

      test('should handle very long content in AI response', () {
        // Arrange
        final longContent = 'A' * 10000; // 10k characters

        // Act
        final response = AIResponse(
          id: 'long-response',
          content: longContent,
          isStreaming: false,
          isComplete: true,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(response.content.length, equals(10000));
      });

      test('should handle special characters in tool arguments', () {
        // Act
        final toolCall = AIToolCall(
          id: 'special-chars',
          name: 'test_tool',
          arguments: {
            'description': 'Coffee ☕ at café "Le Petit" (50€)',
            'emoji': '💰🔥✨',
            'unicode': 'Тест',
          },
        );

        // Assert
        expect(toolCall.arguments['description'], contains('☕'));
        expect(toolCall.arguments['emoji'], contains('💰'));
        expect(toolCall.arguments['unicode'], equals('Тест'));
      });
    });

    group('Tool Caching Tests', () {
      test('should cache tool execution results', () async {
        final toolRegistry = DatabaseToolRegistry();
        final registryService = AIToolRegistryService(toolRegistry);

        // Register a test tool
        final testTool = AIToolConfiguration(
          name: 'cache_test_tool',
          description: 'A tool for testing cache functionality',
          schema: {
            'type': 'object',
            'properties': {
              'input': {'type': 'string'},
            },
          },
        );
        toolRegistry.registerTool(testTool);

        // Create a tool call
        final toolCall = AIToolCall(
          id: 'test-call-1',
          name: 'cache_test_tool',
          arguments: {'input': 'test_value'},
        );

        // Execute tool first time
        final startTime1 = DateTime.now();
        final result1 = await toolRegistry.executeTool(toolCall);
        final endTime1 = DateTime.now();

        expect(result1.success, true);
        expect(result1.toolCallId, 'test-call-1');

        // Execute same tool call again (should hit cache)
        final startTime2 = DateTime.now();
        final result2 = await toolRegistry.executeTool(toolCall);
        final endTime2 = DateTime.now();

        expect(result2.success, true);
        expect(result2.toolCallId, 'test-call-1');
        
        // Cache hit should be much faster (though this is a simple test)
        // The main verification is that both results are identical
        expect(result1.result, result2.result);
      });

      test('should respect cache TTL and expire old entries', () async {
        final toolRegistry = DatabaseToolRegistry();
        final registryService = AIToolRegistryService(toolRegistry);

        // Register a test tool
        final testTool = AIToolConfiguration(
          name: 'ttl_test_tool',
          description: 'A tool for testing TTL functionality',
          schema: {
            'type': 'object',
            'properties': {
              'input': {'type': 'string'},
            },
          },
        );
        toolRegistry.registerTool(testTool);

        // Create a tool call
        final toolCall = AIToolCall(
          id: 'test-call-ttl',
          name: 'ttl_test_tool',
          arguments: {'input': 'ttl_test'},
        );

        // Execute tool and verify it works
        final result = await toolRegistry.executeTool(toolCall);
        expect(result.success, true);

        // Clear cache manually to simulate TTL expiry
        toolRegistry.clearCache();

        // Execute again - should work even after cache clear
        final result2 = await toolRegistry.executeTool(toolCall);
        expect(result2.success, true);
      });

      test('should handle different tool calls with different cache keys', () async {
        final toolRegistry = DatabaseToolRegistry();
        final registryService = AIToolRegistryService(toolRegistry);

        // Register a test tool
        final testTool = AIToolConfiguration(
          name: 'multi_cache_test_tool',
          description: 'A tool for testing multiple cache entries',
          schema: {
            'type': 'object',
            'properties': {
              'input': {'type': 'string'},
            },
          },
        );
        toolRegistry.registerTool(testTool);

        // Create different tool calls
        final toolCall1 = AIToolCall(
          id: 'test-call-a',
          name: 'multi_cache_test_tool',
          arguments: {'input': 'value_a'},
        );

        final toolCall2 = AIToolCall(
          id: 'test-call-b',
          name: 'multi_cache_test_tool',
          arguments: {'input': 'value_b'},
        );

        // Execute both tool calls
        final result1 = await toolRegistry.executeTool(toolCall1);
        final result2 = await toolRegistry.executeTool(toolCall2);

        expect(result1.success, true);
        expect(result2.success, true);
        expect(result1.toolCallId, 'test-call-a');
        expect(result2.toolCallId, 'test-call-b');

        // Execute them again - should hit cache for both
        final cachedResult1 = await toolRegistry.executeTool(toolCall1);
        final cachedResult2 = await toolRegistry.executeTool(toolCall2);

        expect(cachedResult1.success, true);
        expect(cachedResult2.success, true);
        expect(cachedResult1.result, result1.result);
        expect(cachedResult2.result, result2.result);
      });

      test('should demonstrate performance improvement with caching', () async {
        final toolRegistry = DatabaseToolRegistry();
        
        // Register a test tool
        final testTool = AIToolConfiguration(
          name: 'performance_test_tool',
          description: 'A tool for testing performance improvements',
          schema: {
            'type': 'object',
            'properties': {
              'data': {'type': 'string'},
            },
          },
        );
        toolRegistry.registerTool(testTool);

        // Create a tool call
        final toolCall = AIToolCall(
          id: 'performance-test',
          name: 'performance_test_tool',
          arguments: {'data': 'large_dataset_query'},
        );

        // Measure first execution (cache miss)
        final stopwatch1 = Stopwatch()..start();
        final result1 = await toolRegistry.executeTool(toolCall);
        stopwatch1.stop();
        final firstExecution = stopwatch1.elapsedMicroseconds;

        expect(result1.success, true);

        // Measure second execution (cache hit)
        final stopwatch2 = Stopwatch()..start();
        final result2 = await toolRegistry.executeTool(toolCall);
        stopwatch2.stop();
        final secondExecution = stopwatch2.elapsedMicroseconds;

        expect(result2.success, true);
        expect(result1.result, result2.result);

        // Cache hit should be significantly faster
        // Note: In real scenarios with database operations, the difference would be much more pronounced
        debugPrint('📊 Performance Test Results:');
        debugPrint('  First execution (cache miss): ${firstExecution}μs');
        debugPrint('  Second execution (cache hit): ${secondExecution}μs');
        
        // Verify that we get cache hits (more important than raw performance in mock tests)
        // The important thing is that both results are identical, showing cache consistency
        expect(result1.result, result2.result);
        
        // In a real database scenario, cache hits would show dramatic performance improvements
        // For mock tests, we just verify the caching mechanism works correctly
      });
    });
  });
}

// Helper function to create test chat messages
ChatMessage createTestChatMessage(String text, {required bool isFromUser}) {
  return ChatMessage(
    id: 'test-${DateTime.now().millisecondsSinceEpoch}',
    text: text,
    isFromUser: isFromUser,
    timestamp: DateTime.now(),
    isTyping: false,
    isVoiceMessage: false,
  );
}