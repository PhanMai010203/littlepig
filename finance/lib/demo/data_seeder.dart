import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/di/injection.dart';
import '../features/accounts/domain/entities/account.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/categories/domain/entities/category.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/transactions/domain/entities/transaction.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';

/// A utility class to seed the database with mock data for development.
class DataSeeder {
  final _transactionRepository = getIt<TransactionRepository>();
  final _accountRepository = getIt<AccountRepository>();
  final _categoryRepository = getIt<CategoryRepository>();
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

    // 3. Create Transactions
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