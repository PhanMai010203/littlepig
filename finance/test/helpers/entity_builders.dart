import 'package:flutter/material.dart';
import '../../lib/features/transactions/domain/entities/transaction.dart';
import '../../lib/features/transactions/domain/entities/transaction_enums.dart';
import '../../lib/features/accounts/domain/entities/account.dart';
import '../../lib/features/budgets/domain/entities/budget.dart';
import '../../lib/features/categories/domain/entities/category.dart';
import '../../lib/features/transactions/domain/entities/attachment.dart';

/// ✅ PHASE 4.3: Test Entity Builders
///
/// Provides helper methods to create clean test entities with only syncId sync fields.
/// All entities use Phase 4 structure - no legacy sync fields (deviceId, isSynced, version, lastSyncAt).
class TestEntityBuilders {
  /// Creates a test transaction with essential fields and proper syncId
  static Transaction createTestTransaction({
    String? syncId,
    String title = 'Test Transaction',
    double amount = 100.0,
    int categoryId = 1,
    int accountId = 1,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionType transactionType = TransactionType.expense,
    TransactionRecurrence recurrence = TransactionRecurrence.none,
    TransactionState transactionState = TransactionState.completed,
    String? note,
  }) {
    final now = DateTime.now();
    return Transaction(
      syncId: syncId ?? 'test-txn-${now.millisecondsSinceEpoch}',
      title: title,
      note: note,
      amount: amount,
      categoryId: categoryId,
      accountId: accountId,
      date: date ?? now,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      transactionType: transactionType,
      recurrence: recurrence,
      transactionState: transactionState,
      // ✅ PHASE 4: Only essential fields, no legacy sync fields
    );
  }

  /// Creates a subscription transaction for testing recurring transactions
  static Transaction createTestSubscription({
    String? syncId,
    String title = 'Test Subscription',
    double amount = -9.99,
    int categoryId = 1,
    int accountId = 1,
  }) {
    final now = DateTime.now();
    return Transaction(
      syncId: syncId ?? 'test-sub-${now.millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      categoryId: categoryId,
      accountId: accountId,
      date: now,
      createdAt: now,
      updatedAt: now,
      transactionType: TransactionType.subscription,
      recurrence: TransactionRecurrence.monthly,
      periodLength: 1,
      endDate: now.add(const Duration(days: 365)),
      transactionState: TransactionState.scheduled,
    );
  }

  /// Creates a test account with default values
  static Account createTestAccount({
    String? syncId,
    String name = 'Test Account',
    double balance = 1000.0,
    String currency = 'USD',
    bool isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Account(
      syncId: syncId ?? 'test-acc-${now.millisecondsSinceEpoch}',
      name: name,
      balance: balance,
      currency: currency,
      isDefault: isDefault,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a test budget with default values
  static Budget createTestBudget({
    String? syncId,
    String name = 'Test Budget',
    double amount = 500.0,
    double spent = 100.0,
    int? categoryId,
    BudgetPeriod period = BudgetPeriod.monthly,
    DateTime? startDate,
    DateTime? endDate,
    bool isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    final start = startDate ?? DateTime(now.year, now.month, 1);
    final end = endDate ?? DateTime(now.year, now.month + 1, 0);

    return Budget(
      syncId: syncId ?? 'test-budget-${now.millisecondsSinceEpoch}',
      name: name,
      amount: amount,
      spent: spent,
      categoryId: categoryId,
      period: period,
      startDate: start,
      endDate: end,
      isActive: isActive,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a test category with default values
  static Category createTestCategory({
    String? syncId,
    String name = 'Test Category',
    String icon = 'shopping_cart',
    Color color = Colors.blue,
    bool isExpense = true,
    bool isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Category(
      syncId: syncId ?? 'test-cat-${now.millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      color: color,
      isExpense: isExpense,
      isDefault: isDefault,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Creates a test attachment with default values
  static Attachment createTestAttachment({
    String? syncId,
    int transactionId = 1,
    String fileName = 'test_image.jpg',
    AttachmentType type = AttachmentType.image,
    bool isUploaded = true,
    bool isDeleted = false,
    bool isCapturedFromCamera = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return Attachment(
      syncId: syncId ?? 'test-att-${now.millisecondsSinceEpoch}',
      transactionId: transactionId,
      fileName: fileName,
      type: type,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      isUploaded: isUploaded,
      isDeleted: isDeleted,
      isCapturedFromCamera: isCapturedFromCamera,
    );
  }

  /// Creates a batch of test transactions for testing lists
  static List<Transaction> createTestTransactionBatch({
    int count = 5,
    String? baseSyncId,
    String baseTitle = 'Transaction',
    double baseAmount = 100.0,
  }) {
    return List.generate(count, (index) {
      return createTestTransaction(
        syncId: baseSyncId != null ? '$baseSyncId-$index' : null,
        title: '$baseTitle $index',
        amount: baseAmount + (index * 10),
      );
    });
  }

  /// Creates a batch of test accounts for testing
  static List<Account> createTestAccountBatch({
    int count = 3,
    String? baseSyncId,
    String baseName = 'Account',
    double baseBalance = 1000.0,
  }) {
    return List.generate(count, (index) {
      return createTestAccount(
        syncId: baseSyncId != null ? '$baseSyncId-$index' : null,
        name: '$baseName $index',
        balance: baseBalance + (index * 500),
        isDefault: index == 0, // First account is default
      );
    });
  }

  /// Creates default test categories (income and expense)
  static List<Category> createDefaultTestCategories() {
    final now = DateTime.now();
    return [
      Category(
        syncId: 'test-cat-income-salary',
        name: 'Salary',
        icon: '💰',
        color: Colors.green,
        isExpense: false,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        syncId: 'test-cat-expense-food',
        name: 'Food',
        icon: '🍔',
        color: Colors.orange,
        isExpense: true,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        syncId: 'test-cat-expense-transport',
        name: 'Transport',
        icon: '🚗',
        color: Colors.red,
        isExpense: true,
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Creates test data for a complete scenario (accounts, categories, transactions)
  static Map<String, dynamic> createCompleteTestScenario() {
    final accounts = createTestAccountBatch(count: 2);
    final categories = createDefaultTestCategories();
    final transactions = [
      createTestTransaction(
        title: 'Salary',
        amount: 3000.0,
        categoryId: 1, // Salary category
        accountId: 1, // First account
      ),
      createTestTransaction(
        title: 'Groceries',
        amount: -50.0,
        categoryId: 2, // Food category
        accountId: 1,
      ),
      createTestSubscription(
        title: 'Netflix',
        amount: -15.99,
        categoryId: 2,
        accountId: 1,
      ),
    ];

    return {
      'accounts': accounts,
      'categories': categories,
      'transactions': transactions,
    };
  }
}
