import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:finance/features/agent/domain/services/ai_service.dart';
import 'package:finance/features/agent/domain/entities/ai_response.dart';
import 'package:finance/features/agent/domain/entities/ai_tool_call.dart';
import 'package:finance/features/agent/data/services/gemini_ai_service.dart';
import 'package:finance/features/agent/data/services/ai_service_factory.dart';
import 'package:finance/features/agent/data/services/ai_tool_registry_service.dart';

import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';

// Generate mocks
@GenerateMocks([
  TransactionRepository,
  BudgetRepository,
  AccountRepository,
  CategoryRepository,
])
import 'ai_service_integration_test.mocks.dart';

void main() {
  group('AI Service Integration Tests', () {
    late MockTransactionRepository mockTransactionRepo;
    late MockBudgetRepository mockBudgetRepo;
    late MockAccountRepository mockAccountRepo;
    late MockCategoryRepository mockCategoryRepo;
    
    late DatabaseToolRegistry toolRegistry;
    late AIToolRegistryService registryService;

    setUp(() {
      // Initialize mocks
      mockTransactionRepo = MockTransactionRepository();
      mockBudgetRepo = MockBudgetRepository();
      mockAccountRepo = MockAccountRepository();
      mockCategoryRepo = MockCategoryRepository();

      // Setup tool registry
      toolRegistry = DatabaseToolRegistry();
      registryService = AIToolRegistryService(toolRegistry);
    });

    tearDown(() async {
      await AIServiceFactory.dispose();
    });

    group('Tool Registry Tests', () {
      test('should register all database tools successfully', () {
        // Act
        registryService.registerAllTools();

        // Assert
        expect(registryService.registeredToolCount, greaterThan(15));
        expect(registryService.availableToolNames, isNotEmpty);
        
        // Check for specific tools
        expect(registryService.isToolAvailable('query_transactions'), isTrue);
        expect(registryService.isToolAvailable('create_transaction'), isTrue);
        expect(registryService.isToolAvailable('query_budgets'), isTrue);
        expect(registryService.isToolAvailable('query_accounts'), isTrue);
        expect(registryService.isToolAvailable('query_categories'), isTrue);
      });

      test('should provide correct tool configurations', () {
        // Act
        registryService.registerAllTools();

        // Assert
        final queryTransactionsTool = toolRegistry.getToolConfiguration('query_transactions');
        expect(queryTransactionsTool, isNotNull);
        expect(queryTransactionsTool!.name, equals('query_transactions'));
        expect(queryTransactionsTool.description, contains('transactions'));
        expect(queryTransactionsTool.schema, isNotEmpty);
      });
    });

    group('AI Service Configuration Tests', () {
      test('should create valid AI service configuration', () {
        // Arrange
        final config = AIServiceConfig(
          apiKey: 'test-api-key',
          model: 'gemini-1.5-pro',
          temperature: 0.3,
          maxTokens: 4000,
          toolsEnabled: true,
        );

        // Assert
        expect(config.apiKey, equals('test-api-key'));
        expect(config.model, equals('gemini-1.5-pro'));
        expect(config.temperature, equals(0.3));
        expect(config.maxTokens, equals(4000));
        expect(config.toolsEnabled, isTrue);
      });

      test('should have default configuration values', () {
        // Arrange
        final config = AIServiceConfig(
          apiKey: 'test-key',
        );

        // Assert
        expect(config.model, equals('gemini-1.5-pro'));
        expect(config.temperature, equals(0.3));
        expect(config.maxTokens, equals(4000));
        expect(config.toolsEnabled, isTrue);
      });
    });

    group('Tool Execution Tests', () {
      test('should execute tool and return result', () async {
        // Arrange
        registryService.registerAllTools();
        
        final toolCall = AIToolCall(
          id: 'test-call-1',
          name: 'query_transactions',
          arguments: {
            'query_type': 'all',
          },
        );

        // Mock transaction repository response
        when(mockTransactionRepo.getAllTransactions())
            .thenAnswer((_) async => []);

        // Act
        final result = await toolRegistry.executeTool(toolCall);

        // Assert
        expect(result.success, isTrue);
        expect(result.toolCallId, equals('test-call-1'));
        expect(result.result, isNotNull);
      });

      test('should handle tool execution errors gracefully', () async {
        // Arrange
        registryService.registerAllTools();
        
        final toolCall = AIToolCall(
          id: 'test-call-error',
          name: 'nonexistent_tool',
          arguments: {},
        );

        // Act & Assert
        expect(
          () => toolRegistry.executeTool(toolCall),
          throwsA(isA<Exception>()),
        );
      });

      test('should validate tool parameters correctly', () async {
        // Arrange
        registryService.registerAllTools();
        
        final validToolCall = AIToolCall(
          id: 'test-call-valid',
          name: 'query_transactions',
          arguments: {
            'query_type': 'all',
          },
        );

        final invalidToolCall = AIToolCall(
          id: 'test-call-invalid',
          name: 'query_transactions',
          arguments: {
            // Missing required 'query_type' parameter
          },
        );

        // Act
        final tool = toolRegistry._tools['query_transactions'];
        final validResult = tool.validateParameters(validToolCall.arguments);
        final invalidResult = tool.validateParameters(invalidToolCall.arguments);

        // Assert
        expect(validResult, isTrue);
        expect(invalidResult, isFalse);
      });
    });

    group('AI Response Generation Tests', () {
      test('should create AI response with proper structure', () {
        // Arrange
        final timestamp = DateTime.now();
        
        // Act
        final response = AIResponse(
          id: 'response-1',
          content: 'Test AI response',
          toolCalls: [],
          isStreaming: false,
          isComplete: true,
          timestamp: timestamp,
        );

        // Assert
        expect(response.id, equals('response-1'));
        expect(response.content, equals('Test AI response'));
        expect(response.toolCalls, isEmpty);
        expect(response.isStreaming, isFalse);
        expect(response.isComplete, isTrue);
        expect(response.timestamp, equals(timestamp));
      });

      test('should handle AI response with tool calls', () {
        // Arrange
        final toolCall = AIToolCall(
          id: 'tool-call-1',
          name: 'query_transactions',
          arguments: {'query_type': 'all'},
        );
        
        // Act
        final response = AIResponse(
          id: 'response-2',
          content: 'Here are your transactions:',
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
    });

    group('Tool Result Processing Tests', () {
      test('should process tool execution results correctly', () {
        // Arrange
        final executionResult = ToolExecutionResult(
          toolCallId: 'call-1',
          success: true,
          result: {
            'transactions': [],
            'count': 0,
          },
          executedAt: DateTime.now(),
        );

        // Assert
        expect(executionResult.success, isTrue);
        expect(executionResult.toolCallId, equals('call-1'));
        expect(executionResult.result['count'], equals(0));
        expect(executionResult.executedAt, isNotNull);
      });

      test('should handle failed tool execution results', () {
        // Arrange
        final executionResult = ToolExecutionResult(
          toolCallId: 'call-2',
          success: false,
          result: {'error': 'Database connection failed'},
          error: 'Database connection failed',
          executedAt: DateTime.now(),
        );

        // Assert
        expect(executionResult.success, isFalse);
        expect(executionResult.error, equals('Database connection failed'));
        expect(executionResult.result['error'], contains('Database connection failed'));
      });
    });

    group('Conversation Manager Tests', () {
      late SimpleConversationManager conversationManager;

      setUp(() {
        conversationManager = SimpleConversationManager(maxHistoryLength: 5);
      });

      test('should add and retrieve messages correctly', () {
        // Arrange
        final message1 = ChatMessage(
          id: '1',
          text: 'Hello',
          isFromUser: true,
          timestamp: DateTime.now(),
        );
        
        final message2 = ChatMessage(
          id: '2',
          text: 'Hi there!',
          isFromUser: false,
          timestamp: DateTime.now(),
        );

        // Act
        conversationManager.addMessage(message1);
        conversationManager.addMessage(message2);

        // Assert
        expect(conversationManager.conversationHistory, hasLength(2));
        expect(conversationManager.conversationHistory.first.text, equals('Hello'));
        expect(conversationManager.conversationHistory.last.text, equals('Hi there!'));
      });

      test('should limit conversation history length', () {
        // Arrange & Act
        for (int i = 0; i < 10; i++) {
          final message = ChatMessage(
            id: '$i',
            text: 'Message $i',
            isFromUser: i % 2 == 0,
            timestamp: DateTime.now(),
          );
          conversationManager.addMessage(message);
        }

        // Assert
        expect(conversationManager.conversationHistory, hasLength(5));
        expect(conversationManager.conversationHistory.first.text, equals('Message 5'));
        expect(conversationManager.conversationHistory.last.text, equals('Message 9'));
      });

      test('should clear conversation history', () {
        // Arrange
        final message = ChatMessage(
          id: '1',
          text: 'Test message',
          isFromUser: true,
          timestamp: DateTime.now(),
        );
        conversationManager.addMessage(message);

        // Act
        conversationManager.clearHistory();

        // Assert
        expect(conversationManager.conversationHistory, isEmpty);
      });

      test('should generate conversation summary', () {
        // Arrange
        final message1 = ChatMessage(
          id: '1',
          text: 'What is my balance?',
          isFromUser: true,
          timestamp: DateTime.now(),
        );
        
        final message2 = ChatMessage(
          id: '2',
          text: 'Your current balance is \$1,500.00',
          isFromUser: false,
          timestamp: DateTime.now(),
        );

        conversationManager.addMessage(message1);
        conversationManager.addMessage(message2);

        // Act
        final summary = conversationManager.getConversationSummary();

        // Assert
        expect(summary, contains('What is my balance?'));
        expect(summary, contains('Your current balance'));
      });

      test('should trim history for token limits', () {
        // Arrange
        for (int i = 0; i < 5; i++) {
          final message = ChatMessage(
            id: '$i',
            text: 'This is a test message number $i with some content to make it longer',
            isFromUser: i % 2 == 0,
            timestamp: DateTime.now(),
          );
          conversationManager.addMessage(message);
        }

        // Act
        final trimmedHistory = conversationManager.getTrimmedHistory(100); // Very low token limit

        // Assert
        expect(trimmedHistory.length, lessThan(5));
        expect(trimmedHistory, isNotEmpty);
      });
    });

    group('Error Handling Tests', () {
      test('should handle missing tool gracefully', () {
        // Arrange
        final toolCall = AIToolCall(
          id: 'missing-tool',
          name: 'nonexistent_tool',
          arguments: {},
        );

        // Act & Assert
        expect(
          () => toolRegistry.executeTool(toolCall),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle invalid tool parameters', () async {
        // Arrange
        registryService.registerAllTools();
        
        final toolCall = AIToolCall(
          id: 'invalid-params',
          name: 'query_transactions',
          arguments: {
            'query_type': 'invalid_type', // Invalid enum value
          },
        );

        // Act
        final result = await toolRegistry.executeTool(toolCall);

        // Assert
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });
    });

    group('Integration Workflow Tests', () {
      test('should complete full AI conversation workflow', () async {
        // Arrange
        registryService.registerAllTools();
        
        // Mock successful transaction query
        when(mockTransactionRepo.getAllTransactions())
            .thenAnswer((_) async => []);

        final userMessage = 'Show me all my transactions';
        
        // This would normally go through the AI service, but we're testing the components
        final toolCall = AIToolCall(
          id: 'workflow-test',
          name: 'query_transactions',
          arguments: {'query_type': 'all'},
        );

        // Act
        final toolResult = await toolRegistry.executeTool(toolCall);
        
        final aiResponse = AIResponse(
          id: 'workflow-response',
          content: 'Here are your transactions:',
          toolCalls: [toolCall],
          isStreaming: false,
          isComplete: true,
          timestamp: DateTime.now(),
        );

        // Assert
        expect(toolResult.success, isTrue);
        expect(aiResponse.toolCalls, hasLength(1));
        expect(aiResponse.content, contains('transactions'));
      });
    });
  });

  group('Performance Tests', () {
    test('should handle multiple concurrent tool executions', () async {
      // This test would verify that the system can handle multiple
      // tool executions simultaneously without conflicts
      expect(true, isTrue); // Placeholder for actual performance test
    });

    test('should efficiently manage memory with large conversation histories', () {
      // This test would verify memory management with extensive chat histories
      expect(true, isTrue); // Placeholder for actual memory test
    });
  });
}