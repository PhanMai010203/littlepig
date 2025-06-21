import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/di/injection.dart';
import '../features/accounts/domain/entities/account.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/budgets/domain/entities/budget.dart';
import '../features/budgets/domain/repositories/budget_repository.dart';
import '../features/categories/domain/entities/category.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/domain/entities/transaction_enums.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';

/// A utility class to seed the database with mock data for development.
class DataSeeder {
  final _transactionRepository = getIt<TransactionRepository>();
  final _accountRepository = getIt<AccountRepository>();
  final _categoryRepository = getIt<CategoryRepository>();
  final _budgetRepository = getIt<BudgetRepository>();
  final _uuid = Uuid();

  /// Clears existing data and seeds the database with a fresh set of mock data.
  Future<void> seedDatabase() async {
    await _clearDatabase();
    await _seedData();
  }

  Future<void> _clearDatabase() async {
    // This is a simple way to clear data. In a real app, you might want
    // a more robust way to handle this, e.g., by deleting the database file.
    final transactions = await _transactionRepository.getAllTransactions();
    for (final transaction in transactions) {
      await _transactionRepository.deleteTransaction(transaction.id!);
    }

    final accounts = await _accountRepository.getAllAccounts();
    for (final account in accounts) {
      await _accountRepository.deleteAccount(account.id!);
    }

    final categories = await _categoryRepository.getAllCategories();
    for (final category in categories) {
      await _categoryRepository.deleteCategory(category.id!);
    }

    final budgets = await _budgetRepository.getAllBudgets();
    for (final budget in budgets) {
      await _budgetRepository.deleteBudget(budget.id!);
    }
  }

  Future<void> _seedData() async {
    final now = DateTime.now();

    // 1. Create Accounts
    final mainAccount = await _accountRepository.createAccount(Account(
      name: 'Main Bank Account',
      balance: 5000.0,
      currency: 'USD',
      color: Color(0xFF4CAF50),
      isDefault: true,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final creditCard = await _accountRepository.createAccount(Account(
      name: 'Credit Card',
      balance: -1500.0,
      currency: 'USD',
      color: Color(0xFFF44336),
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final savingsAccount = await _accountRepository.createAccount(Account(
      name: 'Savings',
      balance: 12000.0,
      currency: 'USD',
      color: Color(0xFF2196F3),
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // 2. Create Categories
    // NOTE: Default categories are assumed to be created by a separate process.
    // Here we add the 3 custom categories.

    final customIncomeCategory =
        await _categoryRepository.createCategory(Category(
      name: 'Freelance Work',
      icon: 'laptop_mac',
      color: Color(0xFF1DE9B6), // Teal accent
      isExpense: false,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final customExpenseCategory1 =
        await _categoryRepository.createCategory(Category(
      name: 'Vacation',
      icon: 'flight_takeoff',
      color: Color(0xFF7C4DFF), // Deep Purple accent
      isExpense: true,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final customExpenseCategory2 =
        await _categoryRepository.createCategory(Category(
      name: 'Pet Supplies',
      icon: 'pets',
      color: Color(0xFFF57C00), // Orange
      isExpense: true,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final salaryCategory = await _categoryRepository.createCategory(Category(
      name: 'Salary',
      icon: 'work',
      color: Color(0xFF2E7D32),
      isExpense: false,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final foodCategory = await _categoryRepository.createCategory(Category(
      name: 'Food & Drinks',
      icon: 'fastfood',
      color: Color(0xFFD32F2F),
      isExpense: true,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final transportCategory = await _categoryRepository.createCategory(Category(
      name: 'Transportation',
      icon: 'commute',
      color: Color(0xFF0288D1),
      isExpense: true,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    final shoppingCategory = await _categoryRepository.createCategory(Category(
      name: 'Shopping',
      icon: 'shopping_cart',
      color: Color(0xFF7B1FA2),
      isExpense: true,
      isDefault: false,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // 3. Create Budgets

    // Manual Add Budget for a vacation
    final vacationBudget = await _budgetRepository.createBudget(Budget(
      name: 'Japan Trip',
      amount: 2500,
      spent: 0,
      period: BudgetPeriod.yearly, // One-off event
      startDate: DateTime(now.year, 10, 1),
      endDate: DateTime(now.year, 10, 20),
      isActive: true,
      isIncomeBudget: false,
      // walletFks is null for Manual Add mode
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // Automatic Add Budget for monthly food expenses
    final monthlyFoodBudget = await _budgetRepository.createBudget(Budget(
      name: 'Monthly Food Budget',
      amount: 400,
      spent: 0,
      period: BudgetPeriod.monthly,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month, 1).add(Duration(days: 30)),
      isActive: true,
      isIncomeBudget: false,
      walletFks: [mainAccount.syncId, creditCard.syncId], // Tracks two accounts
      categoryId: foodCategory.id, // Tracks only food category
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // 4. Create Transactions
    final random = Random();

    // Transactions for the current month
    for (int i = 0; i < 15; i++) {
      await _transactionRepository.createTransaction(Transaction(
        title: 'Groceries ${i + 1}',
        amount: -(random.nextDouble() * 100 + 20), // 20-120
        accountId: creditCard.id!,
        categoryId: foodCategory.id!,
        date: now.subtract(Duration(days: random.nextInt(now.day > 0 ? now.day -1 : 0))),
        note: 'Weekly groceries',
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
      ));
    }

    // Link one of the groceries to the manual vacation budget
    // This would typically be done by the user in the UI.
    // We simulate it here by creating a link record if the repositories allow.
    // For now, we'll just add a specific transaction for the budget.
    await _transactionRepository.createTransaction(Transaction(
      title: 'Flights to Tokyo',
      amount: -1200,
      accountId: savingsAccount.id!,
      categoryId: customExpenseCategory1.id!, // Vacation category
      date: now.subtract(Duration(days: 60)),
      note: 'Booked flights for the Japan trip.',
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
      // In a real app, logic would link this to `vacationBudget`
    ));


    await _transactionRepository.createTransaction(Transaction(
      title: 'Monthly Salary',
      amount: 3500,
      accountId: mainAccount.id!,
      categoryId: salaryCategory.id!,
      date: DateTime(now.year, now.month, 1),
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // Subscription Transaction (Advanced)
    await _transactionRepository.createTransaction(Transaction(
      title: 'Netflix Subscription',
      amount: -15.99,
      accountId: creditCard.id!,
      categoryId: shoppingCategory.id!, // Assuming 'entertainment' is under shopping
      date: now.subtract(Duration(days: 10)),
      transactionType: TransactionType.subscription,
      recurrence: TransactionRecurrence.monthly,
      transactionState: TransactionState.scheduled,
      note: 'Monthly streaming service, next payment due soon.',
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // Loan Transaction - Lent Money (Advanced)
    final lentTransaction = await _transactionRepository.createTransaction(Transaction(
      title: 'Loan to Alex',
      amount: -300,
      accountId: mainAccount.id!,
      categoryId: customExpenseCategory2.id!, // "Other" or a custom loan category
      date: now.subtract(Duration(days: 45)),
      transactionType: TransactionType.loan,
      specialType: TransactionSpecialType.credit,
      transactionState: TransactionState.actionRequired,
      remainingAmount: 300.0, // Full amount is outstanding
      note: 'Lent for emergency, to be paid back in installments.',
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // Partial Collection on the Loan
    await _transactionRepository.createTransaction(Transaction(
      title: 'Partial payback from Alex',
      amount: 100, // Positive amount, coming into the account
      accountId: mainAccount.id!,
      categoryId: customIncomeCategory.id!,
      date: now.subtract(Duration(days: 15)),
      parentTransactionId: lentTransaction.id, // Linking to the original loan
      note: 'First installment paid back.',
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));
    // In a real app, a service would update `lentTransaction.remainingAmount` to 200.
    // For the seeder, we will just leave it as is, or manually update if repository allows.
    // final updatedLent = lentTransaction.copyWith(remainingAmount: 200);
    // await _transactionRepository.updateTransaction(updatedLent);


    // Loan Transaction - Borrowed Money (Advanced)
    await _transactionRepository.createTransaction(Transaction(
      title: 'Borrowed from Savings',
      amount: 500,
      accountId: mainAccount.id!,
      categoryId: customIncomeCategory.id!, // Or a custom 'internal transfer' category
      date: now.subtract(Duration(days: 20)),
      transactionType: TransactionType.loan,
      specialType: TransactionSpecialType.debt,
      transactionState: TransactionState.actionRequired,
      remainingAmount: 500.0,
      note: 'To cover some large expenses. Need to settle this debt.',
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    await _transactionRepository.createTransaction(Transaction(
      title: 'Bus Fare',
      amount: -2.75,
      accountId: mainAccount.id!,
      categoryId: transportCategory.id!,
      date: now.subtract(Duration(days: 3)),
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    await _transactionRepository.createTransaction(Transaction(
      title: 'New Shoes',
      amount: -120,
      accountId: creditCard.id!,
      categoryId: shoppingCategory.id!,
      date: now.subtract(Duration(days: 5)),
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // Transactions for the previous month
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    for (int i = 0; i < 10; i++) {
      await _transactionRepository.createTransaction(Transaction(
        title: 'Restaurant visit ${i + 1}',
        amount: -(random.nextDouble() * 70 + 15),
        accountId: creditCard.id!,
        categoryId: foodCategory.id!,
        date: lastMonth.add(Duration(days: random.nextInt(28))),
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
      ));
    }

    await _transactionRepository.createTransaction(Transaction(
      title: 'Last Month Salary',
      amount: 3500,
      accountId: mainAccount.id!,
      categoryId: salaryCategory.id!,
      date: lastMonth,
      createdAt: now,
      updatedAt: now,
      syncId: _uuid.v4(),
    ));

    // Transactions for two months ago
    final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);
    for (int i = 0; i < 5; i++) {
      await _transactionRepository.createTransaction(Transaction(
        title: 'Old Purchase ${i + 1}',
        amount: -(random.nextDouble() * 200 + 50),
        accountId: savingsAccount.id!,
        categoryId: shoppingCategory.id!,
        date: twoMonthsAgo.add(Duration(days: random.nextInt(28))),
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
      ));
    }
  }
}