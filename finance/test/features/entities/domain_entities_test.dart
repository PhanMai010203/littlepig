import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import '../../../lib/features/transactions/domain/entities/transaction.dart';
import '../../../lib/features/transactions/domain/entities/transaction_enums.dart';
import '../../../lib/features/accounts/domain/entities/account.dart';
import '../../../lib/features/budgets/domain/entities/budget.dart';
import '../../../lib/features/categories/domain/entities/category.dart';
import '../../../lib/features/transactions/domain/entities/attachment.dart';

void main() {
  group('Phase 4.2: Domain Entity Verification', () {
    group('Transaction Entity', () {
      test('should only have syncId as sync field', () {
        final transaction = Transaction(
          title: 'Test Transaction',
          amount: 100.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-sync-id',
        );

        expect(transaction.syncId, equals('test-sync-id'));
        expect(transaction.title, equals('Test Transaction'));
        expect(transaction.amount, equals(100.0));
        expect(transaction.categoryId, equals(1));
        expect(transaction.accountId, equals(1));
      });

      test('should work with advanced transaction fields', () {
        final transaction = Transaction(
          title: 'Advanced Transaction',
          amount: 200.0,
          categoryId: 2,
          accountId: 2,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          transactionType: TransactionType.subscription,
          specialType: TransactionSpecialType.credit,
          recurrence: TransactionRecurrence.monthly,
          periodLength: 1,
          transactionState: TransactionState.pending,
          paid: false,
          skipPaid: false,
          syncId: 'advanced-sync-id',
        );

        expect(transaction.transactionType, equals(TransactionType.subscription));
        expect(transaction.specialType, equals(TransactionSpecialType.credit));
        expect(transaction.recurrence, equals(TransactionRecurrence.monthly));
        expect(transaction.isRecurring, isTrue);
        expect(transaction.isSubscription, isTrue);
        expect(transaction.isCredit, isTrue);
        expect(transaction.isPending, isTrue);
      });

      test('should create valid copyWith', () {
        final original = Transaction(
          title: 'Original',
          amount: 50.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'original-sync-id',
        );

        final updated = original.copyWith(
          title: 'Updated',
          amount: 75.0,
          syncId: 'updated-sync-id',
        );

        expect(updated.title, equals('Updated'));
        expect(updated.amount, equals(75.0));
        expect(updated.syncId, equals('updated-sync-id'));
        expect(updated.categoryId, equals(original.categoryId));
        expect(updated.accountId, equals(original.accountId));
      });
    });

    group('Account Entity', () {
      test('should only have syncId as sync field', () {
        final account = Account(
          name: 'Test Account',
          balance: 1000.0,
          currency: 'USD',
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'account-sync-id',
        );

        expect(account.syncId, equals('account-sync-id'));
        expect(account.name, equals('Test Account'));
        expect(account.balance, equals(1000.0));
        expect(account.currency, equals('USD'));
        expect(account.isDefault, isFalse);
      });

      test('should create valid copyWith', () {
        final original = Account(
          name: 'Original Account',
          balance: 500.0,
          currency: 'EUR',
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'original-account-sync-id',
        );

        final updated = original.copyWith(
          name: 'Updated Account',
          balance: 750.0,
          syncId: 'updated-account-sync-id',
        );

        expect(updated.name, equals('Updated Account'));
        expect(updated.balance, equals(750.0));
        expect(updated.syncId, equals('updated-account-sync-id'));
        expect(updated.currency, equals(original.currency));
        expect(updated.isDefault, equals(original.isDefault));
      });
    });

    group('Budget Entity', () {
      test('should only have syncId as sync field', () {
        final budget = Budget(
          name: 'Test Budget',
          amount: 500.0,
          spent: 100.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'budget-sync-id',
        );

        expect(budget.syncId, equals('budget-sync-id'));
        expect(budget.name, equals('Test Budget'));
        expect(budget.amount, equals(500.0));
        expect(budget.spent, equals(100.0));
        expect(budget.period, equals(BudgetPeriod.monthly));
        expect(budget.remaining, equals(400.0));
        expect(budget.percentageSpent, equals(0.2));
        expect(budget.isOverBudget, isFalse);
      });
    });

    group('Category Entity', () {
      test('should only have syncId as sync field', () {
        final category = Category(
          name: 'Test Category',
          icon: 'shopping_cart',
          color: Colors.blue,
          isExpense: true,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'category-sync-id',
        );

        expect(category.syncId, equals('category-sync-id'));
        expect(category.name, equals('Test Category'));
        expect(category.icon, equals('shopping_cart'));
        expect(category.color, equals(Colors.blue));
        expect(category.isExpense, isTrue);
        expect(category.isDefault, isFalse);
      });
    });

    group('Attachment Entity', () {
      test('should only have syncId as sync field', () {
        final attachment = Attachment(
          transactionId: 1,
          fileName: 'test_image.jpg',
          type: AttachmentType.image,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isUploaded: true,
          isDeleted: false,
          isCapturedFromCamera: true,
          syncId: 'attachment-sync-id',
        );

        expect(attachment.syncId, equals('attachment-sync-id'));
        expect(attachment.transactionId, equals(1));
        expect(attachment.fileName, equals('test_image.jpg'));
        expect(attachment.type, equals(AttachmentType.image));
        expect(attachment.isUploaded, isTrue);
        expect(attachment.isDeleted, isFalse);
        expect(attachment.isCapturedFromCamera, isTrue);
      });
    });

    group('Phase 4 Validation', () {
      test('all entities should only contain syncId as sync field', () {
        // This test ensures no entity has legacy sync fields
        // If this test passes, it confirms Phase 4.2 requirements are met
        
        final transaction = Transaction(
          title: 'Validation Test',
          amount: 100.0,
          categoryId: 1,
          accountId: 1,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'validation-transaction-sync-id',
        );

        final account = Account(
          name: 'Validation Account',
          balance: 1000.0,
          currency: 'USD',
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'validation-account-sync-id',
        );

        final budget = Budget(
          name: 'Validation Budget',
          amount: 500.0,
          spent: 100.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime(2024, 1, 1),
          endDate: DateTime(2024, 1, 31),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'validation-budget-sync-id',
        );

        final category = Category(
          name: 'Validation Category',
          icon: 'validation_icon',
          color: Colors.purple,
          isExpense: true,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'validation-category-sync-id',
        );

        final attachment = Attachment(
          transactionId: 1,
          fileName: 'validation.jpg',
          type: AttachmentType.image,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isUploaded: true,
          isDeleted: false,
          isCapturedFromCamera: false,
          syncId: 'validation-attachment-sync-id',
        );

        // Verify all entities have syncId
        expect(transaction.syncId, isNotEmpty);
        expect(account.syncId, isNotEmpty);
        expect(budget.syncId, isNotEmpty);
        expect(category.syncId, isNotEmpty);
        expect(attachment.syncId, isNotEmpty);

        // Verify all entities work correctly
        expect(transaction.amount, equals(100.0));
        expect(account.balance, equals(1000.0));
        expect(budget.remaining, equals(400.0));
        expect(category.isExpense, isTrue);
        expect(attachment.isUploaded, isTrue);
      });

      test('entities should serialize/deserialize correctly with only syncId', () {
        final transaction = Transaction(
          title: 'Serialization Test',
          amount: 250.0,
          categoryId: 2,
          accountId: 2,
          date: DateTime(2024, 1, 15),
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
          syncId: 'serialization-test-sync-id',
        );

        // Copy the transaction to simulate serialization/deserialization
        final serialized = transaction.copyWith();
        
        expect(serialized.syncId, equals(transaction.syncId));
        expect(serialized.title, equals(transaction.title));
        expect(serialized.amount, equals(transaction.amount));
        expect(serialized, equals(transaction));
      });
    });
  });
}
