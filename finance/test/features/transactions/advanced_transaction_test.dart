import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/features/transactions/domain/entities/transaction_enums.dart';

void main() {
  group('Advanced Transaction Features', () {
    test('should create transaction with advanced fields', () {
      // Arrange
      final transaction = Transaction(
        title: 'Test Subscription',
        amount: -9.99,
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: 'test-device',
        isSynced: false,
        syncId: 'test-sync-id',
        version: 1,
        
        // Advanced fields
        transactionType: TransactionType.subscription,
        specialType: null,
        recurrence: TransactionRecurrence.monthly,
        periodLength: 1,
        endDate: DateTime.now().add(const Duration(days: 365)),
        transactionState: TransactionState.scheduled,
        paid: false,
        skipPaid: false,
      );

      // Assert
      expect(transaction.isSubscription, true);
      expect(transaction.isRecurring, true);
      expect(transaction.isScheduled, true);
      expect(transaction.transactionType, TransactionType.subscription);
      expect(transaction.recurrence, TransactionRecurrence.monthly);
      expect(transaction.periodLength, 1);
      expect(transaction.paid, false);
    });

    test('should create loan transaction with credit type', () {
      // Arrange
      final transaction = Transaction(
        title: 'Money Lent to John',
        amount: -500.0,
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: 'test-device',
        isSynced: false,
        syncId: 'test-sync-id-2',
        version: 1,
        
        // Advanced fields
        transactionType: TransactionType.loan,
        specialType: TransactionSpecialType.credit,
        recurrence: TransactionRecurrence.none,
        transactionState: TransactionState.actionRequired,
        paid: true, // Initially paid (money was given out)
        skipPaid: false,
      );

      // Assert
      expect(transaction.isLoan, true);
      expect(transaction.isCredit, true);
      expect(transaction.needsAction, true);
      expect(transaction.transactionType, TransactionType.loan);
      expect(transaction.specialType, TransactionSpecialType.credit);
      expect(transaction.paid, true);
      expect(transaction.availableActions, contains(TransactionAction.edit));
      expect(transaction.availableActions, contains(TransactionAction.delete));
    });

    test('should create debt transaction', () {
      // Arrange
      final transaction = Transaction(
        title: 'Money Borrowed from Jane',
        amount: 300.0,
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: 'test-device',
        isSynced: false,
        syncId: 'test-sync-id-3',
        version: 1,
        
        // Advanced fields
        transactionType: TransactionType.loan,
        specialType: TransactionSpecialType.debt,
        recurrence: TransactionRecurrence.none,
        transactionState: TransactionState.actionRequired,
        paid: true, // Initially paid (money was received)
        skipPaid: false,
      );

      // Assert
      expect(transaction.isLoan, true);
      expect(transaction.isDebt, true);
      expect(transaction.needsAction, true);
      expect(transaction.transactionType, TransactionType.loan);
      expect(transaction.specialType, TransactionSpecialType.debt);
      expect(transaction.paid, true);
    });

    test('should provide correct available actions based on state and type', () {
      // Test regular completed transaction
      final regularTransaction = Transaction(
        title: 'Regular Expense',
        amount: -25.0,
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: 'test-device',
        isSynced: false,
        syncId: 'test-sync-id-4',
        version: 1,
      );

      expect(regularTransaction.availableActions, contains(TransactionAction.edit));
      expect(regularTransaction.availableActions, contains(TransactionAction.delete));
      expect(regularTransaction.availableActions, isNot(contains(TransactionAction.pay)));

      // Test pending transaction
      final pendingTransaction = regularTransaction.copyWith(
        transactionState: TransactionState.pending,
      );

      expect(pendingTransaction.availableActions, contains(TransactionAction.pay));
      expect(pendingTransaction.availableActions, contains(TransactionAction.skip));
      expect(pendingTransaction.availableActions, contains(TransactionAction.edit));
      expect(pendingTransaction.availableActions, contains(TransactionAction.delete));
    });

    test('should copy transaction with new advanced fields', () {
      // Arrange
      final originalTransaction = Transaction(
        title: 'Original',
        amount: -10.0,
        categoryId: 1,
        accountId: 1,
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deviceId: 'test-device',
        isSynced: false,
        syncId: 'test-sync-id-5',
        version: 1,
      );

      // Act
      final modifiedTransaction = originalTransaction.copyWith(
        transactionType: TransactionType.subscription,
        recurrence: TransactionRecurrence.weekly,
        periodLength: 2,
        transactionState: TransactionState.scheduled,
      );

      // Assert
      expect(modifiedTransaction.title, 'Original');
      expect(modifiedTransaction.transactionType, TransactionType.subscription);
      expect(modifiedTransaction.recurrence, TransactionRecurrence.weekly);
      expect(modifiedTransaction.periodLength, 2);
      expect(modifiedTransaction.transactionState, TransactionState.scheduled);
      expect(modifiedTransaction.isSubscription, true);
      expect(modifiedTransaction.isRecurring, true);
      expect(modifiedTransaction.isScheduled, true);
    });

    test('should handle enum conversions correctly', () {
      // Test all transaction types
      expect(TransactionType.values.length, 6);
      expect(TransactionType.values, contains(TransactionType.income));
      expect(TransactionType.values, contains(TransactionType.expense));
      expect(TransactionType.values, contains(TransactionType.transfer));
      expect(TransactionType.values, contains(TransactionType.subscription));
      expect(TransactionType.values, contains(TransactionType.loan));
      expect(TransactionType.values, contains(TransactionType.adjustment));

      // Test special types
      expect(TransactionSpecialType.values.length, 2);
      expect(TransactionSpecialType.values, contains(TransactionSpecialType.credit));
      expect(TransactionSpecialType.values, contains(TransactionSpecialType.debt));

      // Test recurrence types
      expect(TransactionRecurrence.values.length, 5);
      expect(TransactionRecurrence.values, contains(TransactionRecurrence.none));
      expect(TransactionRecurrence.values, contains(TransactionRecurrence.daily));
      expect(TransactionRecurrence.values, contains(TransactionRecurrence.weekly));
      expect(TransactionRecurrence.values, contains(TransactionRecurrence.monthly));
      expect(TransactionRecurrence.values, contains(TransactionRecurrence.yearly));

      // Test states
      expect(TransactionState.values.length, 5);
      expect(TransactionState.values, contains(TransactionState.completed));
      expect(TransactionState.values, contains(TransactionState.pending));
      expect(TransactionState.values, contains(TransactionState.scheduled));
      expect(TransactionState.values, contains(TransactionState.cancelled));
      expect(TransactionState.values, contains(TransactionState.actionRequired));      // Test actions
      expect(TransactionAction.values.length, 8);
      expect(TransactionAction.values, contains(TransactionAction.none));
      expect(TransactionAction.values, contains(TransactionAction.pay));
      expect(TransactionAction.values, contains(TransactionAction.skip));
      expect(TransactionAction.values, contains(TransactionAction.unpay));
      expect(TransactionAction.values, contains(TransactionAction.collect));
      expect(TransactionAction.values, contains(TransactionAction.settle));
      expect(TransactionAction.values, contains(TransactionAction.edit));
      expect(TransactionAction.values, contains(TransactionAction.delete));
    });
  });
}
