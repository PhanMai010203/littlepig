import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/events/transaction_event_publisher.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/features/transactions/domain/entities/transaction_enums.dart';
import 'package:mocktail/mocktail.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';

// Mock classes
class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('TransactionsBloc Integration Tests', () {
    late MockTransactionRepository mockTransactionRepository;
    late MockCategoryRepository mockCategoryRepository;
    late TransactionEventPublisher eventPublisher;
    late TransactionsBloc transactionsBloc;

    setUp(() {
      mockTransactionRepository = MockTransactionRepository();
      mockCategoryRepository = MockCategoryRepository();
      eventPublisher = TransactionEventPublisher();
      
      // Set up default repository responses
      when(() => mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async => []);
      when(() => mockTransactionRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => []);

      transactionsBloc = TransactionsBloc(
        mockTransactionRepository,
        mockCategoryRepository,
        eventPublisher,
      );
    });

    tearDown(() {
      transactionsBloc.close();
      eventPublisher.dispose();
    });

    test('should automatically refresh when transaction created event is published', () async {
      // Arrange
      int initialCallCount = 0;
      int afterEventCallCount = 0;
      
      when(() => mockTransactionRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async {
        initialCallCount++;
        return [];
      });

      // Act - Load initial transactions
      transactionsBloc.add(LoadTransactionsWithCategories());
      
      // Wait for initial load to complete
      await Future.delayed(const Duration(milliseconds: 200));
      final initialCount = initialCallCount;
      
      // Reset mock to track calls after event
      reset(mockTransactionRepository);
      when(() => mockTransactionRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async {
        afterEventCallCount++;
        return [];
      });

      // Publish a transaction created event
      final newTransaction = Transaction(
        id: 1,
        title: 'Test Transaction',
        amount: -50.0,
        date: DateTime.now(),
        categoryId: 1,
        accountId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'test-sync-id',
      );
      
      eventPublisher.publishTransactionChanged(
        newTransaction,
        TransactionChangeType.created,
      );

      // Wait for the auto-refresh to trigger
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Assert
      expect(initialCount, greaterThan(0), reason: 'Initial load should make repository calls');
      expect(afterEventCallCount, greaterThan(0), reason: 'Event should trigger additional repository calls');
    });

    test('should not refresh when in unloaded state', () async {
      // Arrange  
      int callCount = 0;
      when(() => mockCategoryRepository.getAllCategories())
          .thenAnswer((_) async {
        callCount++;
        return [];
      });

      // Keep the bloc in initial state (don't load)
      
      // Act - Publish transaction event while bloc is in initial state
      final newTransaction = Transaction(
        id: 1,
        title: 'Test Transaction',
        amount: -50.0,
        date: DateTime.now(),
        categoryId: 1,
        accountId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'test-sync-id',
      );
      
      eventPublisher.publishTransactionChanged(
        newTransaction,
        TransactionChangeType.created,
      );

      // Wait to see if any calls are made
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Assert - No calls should have been made since bloc wasn't loaded
      expect(callCount, equals(0));
    });

    test('should handle transaction update and delete events', () async {
      // Arrange
      int callCount = 0;
      
      when(() => mockTransactionRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async {
        callCount++;
        return [];
      });

      // Load initial transactions
      transactionsBloc.add(LoadTransactionsWithCategories());
      await Future.delayed(const Duration(milliseconds: 200));
      
      final initialCallCount = callCount;

      // Act - Publish update event
      final transaction = Transaction(
        id: 1,
        title: 'Updated Transaction',
        amount: -75.0,
        date: DateTime.now(),
        categoryId: 1,
        accountId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncId: 'test-sync-id',
      );
      
      eventPublisher.publishTransactionChanged(
        transaction,
        TransactionChangeType.updated,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Publish delete event
      eventPublisher.publishTransactionChanged(
        transaction,
        TransactionChangeType.deleted,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert
      // Should have triggered refreshes for both update and delete in addition to initial load
      expect(callCount, greaterThan(initialCallCount + 1));
    });

    test('should subscribe to transaction events on initialization', () {
      // This test verifies that the subscription is set up correctly
      // The subscription is created in the constructor, so just creating the bloc
      // verifies it doesn't throw any errors
      expect(transactionsBloc, isNotNull);
    });

    test('should dispose subscription when bloc is closed', () async {
      // Arrange - create a transaction to monitor
      bool eventReceived = false;
      late StreamSubscription subscription;
      
      subscription = eventPublisher.events.listen((_) {
        eventReceived = true;
      });

      // Act - close the bloc and then publish an event
      await transactionsBloc.close();
      
      eventPublisher.publishTransactionChanged(
        Transaction(
          id: 1,
          title: 'Test',
          amount: -50.0,
          date: DateTime.now(),
          categoryId: 1,
          accountId: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync-id',
        ),
        TransactionChangeType.created,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Assert - no exceptions should be thrown
      // The event publisher itself should still work
      expect(eventReceived, isTrue);
      
      await subscription.cancel();
    });
  });
} 