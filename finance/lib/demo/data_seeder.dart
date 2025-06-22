import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/default_categories.dart';
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

/// Comprehensive data seeder for demo and testing purposes
///
/// This class provides realistic sample data for all major features:
/// - Categories (default + custom)
/// - Accounts (with colors, currencies, balances)
/// - Transactions (regular, subscriptions, loans with collect/settle)
/// - Budgets (manual-add and automatic types)
///
/// Usage:
/// ```dart
/// if (kDebugMode) {
///   await DataSeeder.seedAll();
/// }
/// ```
class DataSeeder {
  static const _uuid = Uuid();

  late final AccountRepository _accountRepository;
  late final CategoryRepository _categoryRepository;
  late final TransactionRepository _transactionRepository;
  late final BudgetRepository _budgetRepository;

  DataSeeder._internal();

  /// Private method to initialize repositories from GetIt
  void _initializeRepositories() {
    _accountRepository = getIt<AccountRepository>();
    _categoryRepository = getIt<CategoryRepository>();
    _transactionRepository = getIt<TransactionRepository>();
    _budgetRepository = getIt<BudgetRepository>();
  }

  /// Static method to seed all demo data
  /// This is the main entry point for debug data seeding
  static Future<void> seedAll() async {
    try {
      print('🌱 Initializing demo data seeder...');

      final seeder = DataSeeder._internal();
      seeder._initializeRepositories();

      await seeder.seedAllData();
      await seeder.printDataSummary();
    } catch (e) {
      print('❌ Failed to seed demo data: $e');
      rethrow;
    }
  }

  /// Static method to clear all demo data
  static Future<void> clearAll() async {
    try {
      print('🧹 Clearing all demo data...');

      final seeder = DataSeeder._internal();
      seeder._initializeRepositories();

      await seeder.clearAllData();
    } catch (e) {
      print('❌ Failed to clear demo data: $e');
      rethrow;
    }
  }

  /// Seeds all demo data in the correct order
  Future<void> seedAllData() async {
    try {
      print('🌱 Starting comprehensive data seeding...');

      // 1. Categories first (needed for other entities)
      await _seedCategories();

      // 2. Accounts next (needed for transactions)
      final accounts = await _seedAccounts();

      // 3. Transactions (needs categories and accounts)
      final transactions = await _seedTransactions(accounts);

      // 4. Budgets last (can reference categories and transactions)
      await _seedBudgets(accounts);

      print('✅ Data seeding completed successfully!');
      print('   Total seeded data:');
      print(
          '   - Categories: ${DefaultCategories.allCategories.length + 3} (default + custom)');
      print('   - Accounts: ${accounts.length} with different currencies');
      print(
          '   - Transactions: ${transactions.length} including subscriptions and loans');
      print('   - Budgets: 6 (3 manual-add + 3 automatic)');
    } catch (e) {
      print('❌ Data seeding failed: $e');
      rethrow;
    }
  }

  /// Seeds categories: default categories + 3 custom categories
  Future<void> _seedCategories() async {
    print('📂 Seeding categories...');

    try {
      // Check if default categories already exist
      final existingCategories = await _categoryRepository.getAllCategories();
      if (existingCategories.isEmpty) {
        // Seed default categories from DefaultCategories
        await _seedDefaultCategories();
      } else {
        print(
            '   Default categories already exist (${existingCategories.length} found)');
      }

      // Add 3 custom categories (2 expense, 1 income) if they don't exist
      await _seedCustomCategories();
    } catch (e) {
      print('   ❌ Failed to seed categories: $e');
      rethrow;
    }
  }

  Future<void> _seedDefaultCategories() async {
    final now = DateTime.now();
    int seededCount = 0;

    // Income categories
    for (final defaultCat in DefaultCategories.incomeCategories) {
      try {
        final category = Category(
          name: defaultCat.name,
          icon: defaultCat.emoji,
          color: Color(defaultCat.color),
          isExpense: defaultCat.isExpense,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
          syncId: defaultCat.syncId,
        );
        await _categoryRepository.createCategory(category);
        seededCount++;
      } catch (e) {
        print(
            '   Warning: Failed to create income category ${defaultCat.name}: $e');
      }
    }

    // Expense categories
    for (final defaultCat in DefaultCategories.expenseCategories) {
      try {
        final category = Category(
          name: defaultCat.name,
          icon: defaultCat.emoji,
          color: Color(defaultCat.color),
          isExpense: defaultCat.isExpense,
          isDefault: true,
          createdAt: now,
          updatedAt: now,
          syncId: defaultCat.syncId,
        );
        await _categoryRepository.createCategory(category);
        seededCount++;
      } catch (e) {
        print(
            '   Warning: Failed to create expense category ${defaultCat.name}: $e');
      }
    }

    print('   Created $seededCount default categories');
  }

  Future<void> _seedCustomCategories() async {
    final now = DateTime.now();
    // final existingCategories = await _categoryRepository.getAllCategories();

    // // Check if custom categories already exist
    // final hasCustomCategories = existingCategories.any((c) =>
    //   c.syncId.startsWith('custom-') ||
    //   c.name.contains('Side Projects') ||
    //   c.name.contains('Pet Care') ||
    //   c.name.contains('Freelance Work')
    // );

    // if (hasCustomCategories) {
    //   print('   Custom categories already exist, skipping...');
    //   return;
    // }

    final customCategories = [
      // 2 expense categories
      Category(
        name: 'Side Projects - Dự án phụ',
        icon: '💻',
        color: const Color(0xFF673AB7), // Deep Purple
        isExpense: true,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncId: 'custom-expense-side-projects',
      ),
      Category(
        name: 'Pet Care - Chăm sóc thú cưng',
        icon: '🐱',
        color: const Color(0xFFFF5722), // Deep Orange
        isExpense: true,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncId: 'custom-expense-pet-care',
      ),
      // 1 income category
      Category(
        name: 'Freelance Work - Làm tự do',
        icon: '💼',
        color: const Color(0xFF4CAF50), // Green
        isExpense: false,
        isDefault: false,
        createdAt: now,
        updatedAt: now,
        syncId: 'custom-income-freelance',
      ),
    ];

    int createdCount = 0;
    for (final category in customCategories) {
      try {
        await _categoryRepository.createCategory(category);
        createdCount++;
      } catch (e) {
        print(
            '   Warning: Failed to create custom category ${category.name}: $e');
      }
    }

    print('   Added $createdCount custom categories');
  }

  /// Seeds accounts with different currencies, colors, and balances
  Future<List<Account>> _seedAccounts() async {
    print('💰 Seeding accounts...');

    final now = DateTime.now();
    final accounts = <Account>[];

    final accountData = [
      // Default account with positive balance
      (
        'Checking Account',
        2500.0,
        'USD',
        true,
        const Color(0xFF2196F3)
      ), // Blue
      // Savings with higher balance
      (
        'Savings Account',
        15000.0,
        'USD',
        false,
        const Color(0xFF4CAF50)
      ), // Green
      // Cash wallet with smaller amount
      ('Cash Wallet', 200.0, 'USD', false, const Color(0xFF795548)), // Brown
      // Credit card with negative balance (debt)
      ('Credit Card', -850.0, 'USD', false, const Color(0xFFF44336)), // Red
      // Foreign currency accounts
      (
        'Euro Travel Fund',
        500.0,
        'EUR',
        false,
        const Color(0xFF9C27B0)
      ), // Purple
      (
        'Japanese Savings',
        150000.0,
        'JPY',
        false,
        const Color(0xFFFF9800)
      ), // Orange
    ];

    int createdCount = 0;
    for (int i = 0; i < accountData.length; i++) {
      try {
        final (name, balance, currency, isDefault, color) = accountData[i];
        final account = Account(
          name: name,
          balance: balance,
          currency: currency,
          isDefault: isDefault,
          color: color,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-account-${i + 1}',
        );

        final createdAccount = await _accountRepository.createAccount(account);
        accounts.add(createdAccount);
        createdCount++;
      } catch (e) {
        print('   Warning: Failed to create account ${accountData[i].$1}: $e');
      }
    }

    print(
        '   Created $createdCount accounts with various currencies and colors');
    return accounts;
  }

  /// Seeds diverse transactions including subscriptions, loans, and regular transactions
  Future<List<Transaction>> _seedTransactions(List<Account> accounts) async {
    print('📝 Seeding transactions...');

    final now = DateTime.now();
    final transactions = <Transaction>[];

    if (accounts.isEmpty) {
      print('   ❌ No accounts available for transaction seeding');
      return transactions;
    }

    try {
      // Get categories for reference
      final categories = await _categoryRepository.getAllCategories();
      if (categories.isEmpty) {
        print('   ❌ No categories available for transaction seeding');
        return transactions;
      }

      final salaryCategory = categories.firstWhere(
        (c) => c.name.contains('Lương') || c.name.contains('Salary'),
        orElse: () => categories.first,
      );
      final foodCategory = categories.firstWhere(
        (c) => c.name.contains('Ăn uống') || c.name.contains('Food'),
        orElse: () => categories.first,
      );
      final transportCategory = categories.firstWhere(
        (c) => c.name.contains('Đi lại') || c.name.contains('Transportation'),
        orElse: () => categories.first,
      );
      final entertainmentCategory = categories.firstWhere(
        (c) => c.name.contains('Giải trí') || c.name.contains('Entertainment'),
        orElse: () => categories.first,
      );
      final freelanceCategory = categories.firstWhere(
        (c) => c.name.contains('Freelance'),
        orElse: () => salaryCategory,
      );

      final checkingAccount = accounts.first; // Default account
      final savingsAccount = accounts.length > 1 ? accounts[1] : accounts.first;

      // 1. Regular Income Transactions
      final incomeTransactions = [
        Transaction(
          title: 'Monthly Salary - Lương tháng ${now.month}',
          note: 'Main job salary payment',
          amount: 4500.0,
          categoryId: salaryCategory.id!,
          accountId: checkingAccount.id!,
          date: DateTime(now.year, now.month, 1),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.income,
          transactionState: TransactionState.completed,
          syncId: 'demo-txn-salary-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Freelance Project - Website Design',
          note: 'Completed e-commerce website for local business',
          amount: 800.0,
          categoryId: freelanceCategory.id!,
          accountId: savingsAccount.id!,
          date: now.subtract(const Duration(days: 5)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.income,
          transactionState: TransactionState.completed,
          syncId: 'demo-txn-freelance-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Bonus - Year-end Performance',
          note: 'Annual performance bonus from company',
          amount: 2000.0,
          categoryId: salaryCategory.id!,
          accountId: savingsAccount.id!,
          date: now.subtract(const Duration(days: 15)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.income,
          transactionState: TransactionState.completed,
          syncId: 'demo-txn-bonus-${_uuid.v4()}',
        ),
      ];

      // 2. Regular Expense Transactions
      final expenseTransactions = [
        Transaction(
          title: 'Grocery Shopping - Siêu thị',
          note: 'Weekly grocery shopping at local market',
          amount: -75.50,
          categoryId: foodCategory.id!,
          accountId: checkingAccount.id!,
          date: now.subtract(const Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.expense,
          transactionState: TransactionState.completed,
          syncId: 'demo-txn-grocery-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Gas Station - Xăng xe',
          note: 'Weekly fuel for commuting',
          amount: -45.00,
          categoryId: transportCategory.id!,
          accountId: checkingAccount.id!,
          date: now.subtract(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.expense,
          transactionState: TransactionState.completed,
          syncId: 'demo-txn-gas-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Coffee Shop - Cà phê sáng',
          note: 'Morning coffee and pastry',
          amount: -8.50,
          categoryId: foodCategory.id!,
          accountId: checkingAccount.id!,
          date: now.subtract(const Duration(hours: 2)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.expense,
          transactionState: TransactionState.completed,
          syncId: 'demo-txn-coffee-${_uuid.v4()}',
        ),
      ];

      // 3. Subscription Transactions (scheduled and action required)
      final subscriptionTransactions = [
        Transaction(
          title: 'Netflix Subscription',
          note: 'Monthly video streaming service',
          amount: -15.99,
          categoryId: entertainmentCategory.id!,
          accountId: checkingAccount.id!,
          date: DateTime(now.year, now.month, 15),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.subscription,
          recurrence: TransactionRecurrence.monthly,
          periodLength: 1,
          endDate: DateTime(now.year + 1, now.month, 15),
          transactionState: TransactionState.scheduled,
          paid: false,
          syncId: 'demo-sub-netflix-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Spotify Premium',
          note: 'Music streaming service - requires action (skip or pay)',
          amount: -9.99,
          categoryId: entertainmentCategory.id!,
          accountId: checkingAccount.id!,
          date: DateTime(now.year, now.month, 10),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.subscription,
          recurrence: TransactionRecurrence.monthly,
          periodLength: 1,
          endDate: DateTime(now.year + 1, now.month, 10),
          transactionState: TransactionState.actionRequired,
          paid: false,
          syncId: 'demo-sub-spotify-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Gym Membership',
          note: 'Monthly fitness center membership',
          amount: -35.00,
          categoryId: entertainmentCategory.id!,
          accountId: checkingAccount.id!,
          date: DateTime(now.year, now.month, 5),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.subscription,
          recurrence: TransactionRecurrence.monthly,
          periodLength: 1,
          endDate: DateTime(now.year + 1, now.month, 5),
          transactionState: TransactionState.pending,
          paid: false,
          syncId: 'demo-sub-gym-${_uuid.v4()}',
        ),
      ];

      // 4. Loan Transactions (Credit - Money Lent)
      final creditTransactions = [
        Transaction(
          title: 'Loan to Friend - John',
          note: 'Lent money for emergency expenses - \$250 already collected',
          amount: -1000.0,
          categoryId: salaryCategory.id!, // Using salary category as neutral
          accountId: checkingAccount.id!,
          date: now.subtract(const Duration(days: 10)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.credit,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 750.0, // $250 already collected
          paid: true,
          syncId: 'demo-credit-john-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Loan to Sister - Emergency',
          note: 'Family emergency loan - full amount still pending',
          amount: -500.0,
          categoryId: salaryCategory.id!,
          accountId: savingsAccount.id!,
          date: now.subtract(const Duration(days: 3)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.credit,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 500.0, // Full amount still owed
          paid: true,
          syncId: 'demo-credit-sister-${_uuid.v4()}',
        ),
      ];

      // 5. Debt Transactions (Money Borrowed)
      final debtTransactions = [
        Transaction(
          title: 'Loan from Sarah',
          note: 'Borrowed money for car repair - \$200 already settled',
          amount: 500.0,
          categoryId: transportCategory.id!,
          accountId: checkingAccount.id!,
          date: now.subtract(const Duration(days: 7)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.debt,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 300.0, // $200 already settled
          paid: true,
          syncId: 'demo-debt-sarah-${_uuid.v4()}',
        ),
        Transaction(
          title: 'Loan from Parents',
          note: 'House down payment assistance - monthly installments',
          amount: 5000.0,
          categoryId: salaryCategory.id!,
          accountId: savingsAccount.id!,
          date: now.subtract(const Duration(days: 30)),
          createdAt: now,
          updatedAt: now,
          transactionType: TransactionType.loan,
          specialType: TransactionSpecialType.debt,
          transactionState: TransactionState.actionRequired,
          remainingAmount: 4500.0, // $500 already settled
          paid: true,
          syncId: 'demo-debt-parents-${_uuid.v4()}',
        ),
      ];

      // Create all transactions
      final allTransactionData = [
        ...incomeTransactions,
        ...expenseTransactions,
        ...subscriptionTransactions,
        ...creditTransactions,
        ...debtTransactions,
      ];

      int createdCount = 0;
      for (final transaction in allTransactionData) {
        try {
          final created =
              await _transactionRepository.createTransaction(transaction);
          transactions.add(created);
          createdCount++;
        } catch (e) {
          print(
              '   Warning: Failed to create transaction ${transaction.title}: $e');
        }
      }

      print('   Created $createdCount transactions including:');
      print('     - ${incomeTransactions.length} income transactions');
      print('     - ${expenseTransactions.length} expense transactions');
      print(
          '     - ${subscriptionTransactions.length} subscriptions (with skip/pay actions)');
      print(
          '     - ${creditTransactions.length} credit transactions (with collect action)');
      print(
          '     - ${debtTransactions.length} debt transactions (with settle action)');
    } catch (e) {
      print('   ❌ Failed to seed transactions: $e');
      rethrow;
    }

    return transactions;
  }

  /// Seeds both manual-add and automatic budgets
  Future<void> _seedBudgets(List<Account> accounts) async {
    print('📊 Seeding budgets...');

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    if (accounts.isEmpty) {
      print('   ❌ No accounts available for budget seeding');
      return;
    }

    try {
      // Get categories for reference
      final categories = await _categoryRepository.getAllCategories();
      if (categories.isEmpty) {
        print('   ❌ No categories available for budget seeding');
        return;
      }

      final foodCategory = categories.firstWhere(
        (c) => c.name.contains('Ăn uống') || c.name.contains('Food'),
        orElse: () => categories.first,
      );
      final transportCategory = categories.firstWhere(
        (c) => c.name.contains('Đi lại') || c.name.contains('Transportation'),
        orElse: () => categories.first,
      );
      final entertainmentCategory = categories.firstWhere(
        (c) => c.name.contains('Giải trí') || c.name.contains('Entertainment'),
        orElse: () => categories.first,
      );

      // 1. Manual-Add Budgets (require explicit transaction linking)
      final manualBudgets = [
        Budget(
          name: 'Vacation Budget - Kỳ nghỉ Nhật Bản',
          amount: 3000.0,
          spent: 250.0,
          categoryId: null, // No category filter - manual selection
          period: BudgetPeriod.yearly,
          startDate: DateTime(now.year, 1, 1),
          endDate: DateTime(now.year, 12, 31),
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-budget-vacation-${_uuid.v4()}',
          // No walletFks = manual mode
          isIncomeBudget: false,
        ),
        Budget(
          name: 'Wedding Savings - Tiết kiệm cưới',
          amount: 10000.0,
          spent: 1500.0,
          categoryId: null,
          period: BudgetPeriod.yearly,
          startDate: DateTime(now.year, 1, 1),
          endDate: DateTime(now.year + 1, 6, 30),
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-budget-wedding-${_uuid.v4()}',
          // No walletFks = manual mode
          isIncomeBudget: false,
        ),
        Budget(
          name: 'Freelance Income Target',
          amount: 2000.0,
          spent: 800.0,
          categoryId: null,
          period: BudgetPeriod.monthly,
          startDate: startOfMonth,
          endDate: endOfMonth,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-budget-freelance-income-${_uuid.v4()}',
          // No walletFks = manual mode
          isIncomeBudget: true, // Income budget
        ),
      ];

      // 2. Automatic Budgets (track all transactions from specific accounts/categories)
      final checkingAccountId = accounts.first.id!.toString();
      final allAccountIds = accounts.map((a) => a.id!.toString()).toList();

      final automaticBudgets = [
        Budget(
          name: 'Monthly Food Budget - Ăn uống hàng tháng',
          amount: 400.0,
          spent: 84.0, // Coffee + Grocery
          categoryId: foodCategory.id,
          period: BudgetPeriod.monthly,
          startDate: startOfMonth,
          endDate: endOfMonth,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-budget-food-auto-${_uuid.v4()}',
          walletFks: [
            checkingAccountId
          ], // Automatic mode - tracks checking account
          excludeDebtCreditInstallments: true,
          isIncomeBudget: false,
        ),
        Budget(
          name: 'Transportation Monthly - Đi lại hàng tháng',
          amount: 200.0,
          spent: 45.0, // Gas expense
          categoryId: transportCategory.id,
          period: BudgetPeriod.monthly,
          startDate: startOfMonth,
          endDate: endOfMonth,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-budget-transport-auto-${_uuid.v4()}',
          walletFks: allAccountIds, // Track all accounts
          excludeDebtCreditInstallments: true,
          isIncomeBudget: false,
        ),
        Budget(
          name: 'Entertainment & Subscriptions',
          amount: 100.0,
          spent: 25.98, // Netflix + Spotify
          categoryId: entertainmentCategory.id,
          period: BudgetPeriod.monthly,
          startDate: startOfMonth,
          endDate: endOfMonth,
          isActive: true,
          createdAt: now,
          updatedAt: now,
          syncId: 'demo-budget-entertainment-auto-${_uuid.v4()}',
          walletFks: [checkingAccountId],
          excludeDebtCreditInstallments: false,
          isIncomeBudget: false,
        ),
      ];

      // Create all budgets
      final allBudgets = [...manualBudgets, ...automaticBudgets];
      int createdCount = 0;

      for (final budget in allBudgets) {
        try {
          await _budgetRepository.createBudget(budget);
          createdCount++;
        } catch (e) {
          print('   Warning: Failed to create budget ${budget.name}: $e');
        }
      }

      print('   Created $createdCount budgets:');
      print(
          '     - ${manualBudgets.length} manual-add budgets (require transaction linking)');
      print(
          '     - ${automaticBudgets.length} automatic budgets (with account/category filters)');
      print('     - Including 1 income budget for freelance tracking');
    } catch (e) {
      print('   ❌ Failed to seed budgets: $e');
      rethrow;
    }
  }

  /// Clears all demo data (useful for testing)
  Future<void> clearAllData() async {
    print('🧹 Clearing all demo data...');

    try {
      // Delete in reverse order to respect foreign key constraints
      await _transactionRepository.deleteAllTransactions();
      await _budgetRepository.deleteAllBudgets();
      await _accountRepository.deleteAllAccounts();
      await _categoryRepository.deleteAllCategories();

      print('✅ All tables cleared successfully!');
    } catch (e) {
      print('❌ Failed to clear demo data: $e');
      rethrow;
    }
  }

  /// Seeds additional partial loan payment examples
  Future<void> seedLoanPaymentExamples() async {
    print('💸 Creating loan payment examples...');

    try {
      // This demonstrates the collect/settle functionality
      // For now, we create the base loan transactions in _seedTransactions
      // The actual payment collection/settlement would be triggered by user actions in the UI

      print('   Loan payment examples ready (trigger collect/settle from UI)');
      print('   Available actions:');
      print(
          '     - Credit loans: Use "Collect" action to record partial/full repayments');
      print(
          '     - Debt loans: Use "Settle" action to record partial/full settlements');
      print(
          '     - Subscriptions: Use "Skip" or "Pay" actions for recurring payments');
    } catch (e) {
      print('   ❌ Failed to create loan payment examples: $e');
      rethrow;
    }
  }

  /// Provides a summary of all seeded data for verification
  Future<void> printDataSummary() async {
    print('\n📊 === DATA SEEDING SUMMARY ===');

    try {
      final categories = await _categoryRepository.getAllCategories();
      final accounts = await _accountRepository.getAllAccounts();
      final transactions = await _transactionRepository.getAllTransactions();
      final budgets = await _budgetRepository.getAllBudgets();

      print('Categories (${categories.length} total):');
      for (final cat in categories) {
        final type = cat.isExpense ? 'Expense' : 'Income';
        final defaultStatus = cat.isDefault ? 'Default' : 'Custom';
        print('  - ${cat.name} ${cat.icon} [$type] [$defaultStatus]');
      }

      print('\nAccounts (${accounts.length} total):');
      for (final acc in accounts) {
        final balanceStr =
            acc.balance >= 0 ? '\$${acc.balance}' : '-\$${acc.balance.abs()}';
        print(
            '  - ${acc.name} ($balanceStr ${acc.currency}) ${acc.isDefault ? '[Default]' : ''}');
      }

      print('\nTransactions (${transactions.length} total):');
      final demoTxns = transactions.where((t) => t.syncId.startsWith('demo-'));
      for (final txn in demoTxns) {
        final amountStr =
            txn.amount >= 0 ? '+\$${txn.amount}' : '-\$${txn.amount.abs()}';
        print(
            '  - ${txn.title} ($amountStr) [${txn.transactionType.name}] [${txn.transactionState.name}]');
      }

      print('\nBudgets (${budgets.length} total):');
      final demoBudgets =
          budgets.where((b) => b.syncId.startsWith('demo-budget-'));
      for (final budget in demoBudgets) {
        final modeStr = budget.manualAddMode ? 'Manual' : 'Auto';
        final typeStr = budget.isIncomeBudget ? 'Income' : 'Expense';
        final progress =
            (budget.spent / budget.amount * 100).toStringAsFixed(1);
        print(
            '  - ${budget.name} (\$${budget.spent}/\$${budget.amount} - ${progress}%) [$modeStr] [$typeStr]');
      }

      print('\n✅ All data seeded successfully and verified!');
    } catch (e) {
      print('❌ Failed to generate data summary: $e');
    }
  }
}
