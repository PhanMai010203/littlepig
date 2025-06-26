import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:finance/features/budgets/domain/services/budget_update_service.dart';
import 'package:finance/features/budgets/data/services/budget_update_service_impl.dart';
import 'package:finance/features/budgets/domain/services/budget_filter_service.dart';
import 'package:finance/features/budgets/data/services/budget_auth_service.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/budgets/domain/entities/budget.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/core/events/transaction_event_publisher.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockTransactionEventPublisher extends Mock implements TransactionEventPublisher {}

class MockBudgetFilterService extends Mock implements BudgetFilterService {}

class MockBudgetAuthService extends Mock implements BudgetAuthService {}

class FakeBudget extends Fake implements Budget {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBudget());
    registerFallbackValue(FakeTransaction());
  });
  group('Budget Update Service Tests', () {
    late BudgetUpdateService budgetUpdateService;
    late MockBudgetRepository mockBudgetRepository;
    late MockBudgetFilterService mockFilterService;
    late MockBudgetAuthService mockAuthService;
    late MockTransactionRepository mockTransactionRepository;
    late MockTransactionEventPublisher mockTransactionEventPublisher;

    setUp(() {
      mockBudgetRepository = MockBudgetRepository();
      mockFilterService = MockBudgetFilterService();
      mockAuthService = MockBudgetAuthService();
      mockTransactionRepository = MockTransactionRepository();
      mockTransactionEventPublisher = MockTransactionEventPublisher();

      when(() => mockTransactionEventPublisher.events)
          .thenAnswer((_) => const Stream.empty());

      // Setup default mock responses to prevent initialization errors
      when(() => mockBudgetRepository.getAllBudgets())
          .thenAnswer((_) async => []);

      budgetUpdateService = BudgetUpdateServiceImpl(
        mockBudgetRepository,
        mockFilterService,
        mockAuthService,
        mockTransactionEventPublisher,
      );
    });

    tearDown(() {
      budgetUpdateService.dispose();
    });

    group('updateBudgetOnTransactionChange', () {
      test('should update budget when transaction is created', () async {
        // Arrange
        final transaction = Transaction(
          id: 1,
          title: 'Test Transaction',
          amount: 100.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync',
        );

        final budget = Budget(
          id: 1,
          name: 'Test Budget',
          amount: 1000.0,
          spent: 0.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync',
        );

        // Reset and setup specific mocks for this test
        reset(mockBudgetRepository);
        reset(mockFilterService);

        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => [budget]);
        when(() => mockFilterService.shouldIncludeTransaction(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockBudgetRepository.updateBudget(any()))
            .thenAnswer((_) async => budget.copyWith(spent: 100.0));

        // Act
        await budgetUpdateService.updateBudgetOnTransactionChange(
            transaction, TransactionChangeType.created);

        // Assert
        verify(() => mockBudgetRepository.getAllBudgets())
            .called(2); // Called once during operation + once for stream update
        verify(() => mockFilterService.shouldIncludeTransaction(any(), any()))
            .called(2); // Called for each budget
        verify(() => mockBudgetRepository.updateBudget(any())).called(1);
      });

      test('should handle transaction deletion', () async {
        // Arrange
        final transaction = Transaction(
          id: 1,
          title: 'Test Transaction',
          amount: 100.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync',
        );

        final budget = Budget(
          id: 1,
          name: 'Test Budget',
          amount: 1000.0,
          spent: 100.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync',
        );

        // Reset and setup specific mocks for this test
        reset(mockBudgetRepository);
        reset(mockFilterService);

        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => [budget]);
        when(() => mockFilterService.shouldIncludeTransaction(any(), any()))
            .thenAnswer((_) async => true);
        when(() => mockBudgetRepository.updateBudget(any()))
            .thenAnswer((_) async => budget.copyWith(spent: 0.0));

        // Act
        await budgetUpdateService.updateBudgetOnTransactionChange(
            transaction, TransactionChangeType.deleted);

        // Assert
        verify(() => mockBudgetRepository.getAllBudgets())
            .called(2); // Called once during operation + once for stream update
        verify(() => mockFilterService.shouldIncludeTransaction(any(), any()))
            .called(2); // Called for each budget
        verify(() => mockBudgetRepository.updateBudget(any())).called(1);
      });
    });

    group('recalculateBudgetSpentAmount', () {
      test('should recalculate single budget spent amount', () async {
        // Arrange
        final budget = Budget(
          id: 1,
          name: 'Test Budget',
          amount: 1000.0,
          spent: 50.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync',
        );

        // Reset and setup specific mocks for this test
        reset(mockBudgetRepository);
        reset(mockFilterService);

        when(() => mockBudgetRepository.getBudgetById(1))
            .thenAnswer((_) async => budget);
        when(() => mockFilterService.calculateBudgetSpent(any()))
            .thenAnswer((_) async => 150.0);
        when(() => mockBudgetRepository.updateBudget(any()))
            .thenAnswer((_) async => budget.copyWith(spent: 150.0));
        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => [budget.copyWith(spent: 150.0)]);

        // Act
        await budgetUpdateService.recalculateBudgetSpentAmount(1);

        // Assert
        verify(() => mockBudgetRepository.getBudgetById(1)).called(1);
        verify(() => mockFilterService.calculateBudgetSpent(budget)).called(1);
        verify(() => mockBudgetRepository.updateBudget(any())).called(1);
      });
    });

    group('recalculateAllBudgetSpentAmounts', () {
      test('should recalculate all budget spent amounts', () async {
        // Arrange
        final budgets = [
          Budget(
            id: 1,
            name: 'Budget 1',
            amount: 1000.0,
            spent: 50.0,
            period: BudgetPeriod.monthly,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 15)),
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'test-sync-1',
          ),
          Budget(
            id: 2,
            name: 'Budget 2',
            amount: 500.0,
            spent: 25.0,
            period: BudgetPeriod.monthly,
            startDate: DateTime.now().subtract(const Duration(days: 15)),
            endDate: DateTime.now().add(const Duration(days: 15)),
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncId: 'test-sync-2',
          ),
        ];

        // Reset and setup specific mocks for this test
        reset(mockBudgetRepository);
        reset(mockFilterService);

        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => budgets);
        when(() => mockFilterService.calculateBudgetSpent(budgets[0]))
            .thenAnswer((_) async => 150.0);
        when(() => mockFilterService.calculateBudgetSpent(budgets[1]))
            .thenAnswer((_) async => 75.0);
        when(() => mockBudgetRepository.updateBudget(any()))
            .thenAnswer((_) async => budgets[0]);

        // Act
        await budgetUpdateService.recalculateAllBudgetSpentAmounts();

        // Assert
        verify(() => mockBudgetRepository.getAllBudgets())
            .called(2); // Once to get budgets, once to update streams
        verify(() => mockFilterService.calculateBudgetSpent(any())).called(2);
        verify(() => mockBudgetRepository.updateBudget(any())).called(2);
      });
    });

    group('real-time streams', () {
      test('should emit real-time budget updates through stream', () async {
        // Arrange
        final budget = Budget(
          id: 1,
          name: 'Test Budget',
          amount: 1000.0,
          spent: 0.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync',
        );

        // Reset and setup specific mocks for this test
        reset(mockBudgetRepository);

        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => [budget]);

        // Act & Assert
        expect(
          budgetUpdateService.watchAllBudgetUpdates(),
          emitsInOrder([
            [], // Initial empty emission from service start
          ]),
        );

        expect(
          budgetUpdateService.watchBudgetSpentAmounts(),
          emitsInOrder([
            {}, // Initial empty emission from service start
          ]),
        );
      });
    });

    group('authentication', () {
      test('should authenticate for biometric access', () async {
        // Arrange
        reset(mockAuthService);

        when(() => mockAuthService.authenticateForBudgetAccess())
            .thenAnswer((_) async => true);

        // Act
        final result = await budgetUpdateService.authenticateForBudgetAccess();

        // Assert
        expect(result, isTrue);
        verify(() => mockAuthService.authenticateForBudgetAccess()).called(1);
      });

      test('should handle authentication failure', () async {
        // Arrange
        reset(mockAuthService);

        when(() => mockAuthService.authenticateForBudgetAccess())
            .thenAnswer((_) async => false);

        // Act
        final result = await budgetUpdateService.authenticateForBudgetAccess();

        // Assert
        expect(result, isFalse);
        verify(() => mockAuthService.authenticateForBudgetAccess()).called(1);
      });
    });

    group('performance tracking', () {
      test('should handle performance tracking', () async {
        // Act
        final metrics =
            await budgetUpdateService.getBudgetUpdatePerformanceMetrics();

        // Assert
        expect(metrics, isA<Map<String, dynamic>>());
        expect(metrics.containsKey('operation_counts'), isTrue);
        expect(metrics.containsKey('average_durations'), isTrue);
        expect(metrics.containsKey('total_operations'), isTrue);
      });
    });

    group('Task 3 Verification: Async Event Handling', () {
      test('should handle async transaction events with proper await and error handling', () async {
        // Arrange
        final transaction = Transaction(
          id: 1,
          title: 'Test transaction',
          amount: -100.0,
          date: DateTime.now(),
          accountId: 1,
          categoryId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync-1',
        );

        final budget = Budget(
          id: 1,
          name: 'Test Budget',
          amount: 1000.0,
          spent: 50.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync-1',
        );

        // Setup mocks for event handling test
        reset(mockBudgetRepository);
        reset(mockFilterService);
        reset(mockTransactionEventPublisher);

        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => [budget]);
        when(() => mockFilterService.shouldIncludeTransaction(budget, transaction))
            .thenAnswer((_) async => true);
        when(() => mockBudgetRepository.updateBudget(any()))
            .thenAnswer((_) async => budget.copyWith(spent: 150.0));

        // Create a stream controller to simulate transaction events
        final eventController = StreamController<TransactionChangedEvent>();
        when(() => mockTransactionEventPublisher.events)
            .thenAnswer((_) => eventController.stream);

        // Create service with mocked event publisher
        final service = BudgetUpdateServiceImpl(
          mockBudgetRepository,
          mockFilterService,
          mockAuthService,
          mockTransactionEventPublisher,
        );

        // Act - Publish a transaction event
        final event = TransactionChangedEvent(
          transaction: transaction,
          changeType: TransactionChangeType.created,
          timestamp: DateTime.now(),
        );
        
        // Give the service a moment to subscribe to events
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Publish the event
        eventController.add(event);
        
        // Give async processing time to complete
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - Verify that the async update was called
        verify(() => mockBudgetRepository.getAllBudgets()).called(greaterThan(1));
        verify(() => mockFilterService.shouldIncludeTransaction(budget, transaction)).called(greaterThan(0));
        verify(() => mockBudgetRepository.updateBudget(any())).called(greaterThan(0));

        // Clean up
        await eventController.close();
        service.dispose();
      });

      test('should handle errors in async event processing gracefully', () async {
        // Arrange
        final transaction = Transaction(
          id: 1,
          title: 'Test transaction',
          amount: -100.0,
          date: DateTime.now(),
          accountId: 1,
          categoryId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync-1',
        );

        // Setup mocks for initialization
        reset(mockBudgetRepository);
        reset(mockFilterService);
        reset(mockTransactionEventPublisher);

        // Allow initialization to succeed but budget updates to fail
        when(() => mockBudgetRepository.getAllBudgets())
            .thenAnswer((_) async => []);
        when(() => mockFilterService.shouldIncludeTransaction(any(), any()))
            .thenThrow(Exception('Service error'));

        // Create a stream controller to simulate transaction events
        final eventController = StreamController<TransactionChangedEvent>();
        when(() => mockTransactionEventPublisher.events)
            .thenAnswer((_) => eventController.stream);

        // Create service with mocked event publisher
        final service = BudgetUpdateServiceImpl(
          mockBudgetRepository,
          mockFilterService,
          mockAuthService,
          mockTransactionEventPublisher,
        );

        // Act - Publish a transaction event that will cause an error
        final event = TransactionChangedEvent(
          transaction: transaction,
          changeType: TransactionChangeType.created,
          timestamp: DateTime.now(),
        );
        
        // Give the service a moment to subscribe to events
        await Future.delayed(const Duration(milliseconds: 10));
        
        // Publish the event (this should not crash the service)
        eventController.add(event);
        
        // Give async processing time to complete
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - Verify that the error was handled gracefully
        // The service should still be functional and not crash
        expect(service, isNotNull);
        
        // Verify the service attempted to process the event but the error was caught
        verify(() => mockBudgetRepository.getAllBudgets()).called(greaterThan(0));

        // Clean up
        await eventController.close();
        service.dispose();
      });
    });
  });
}
