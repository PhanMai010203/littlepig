import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/budgets/domain/entities/budget.dart';
import 'package:finance/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:finance/features/budgets/data/services/budget_filter_service_impl.dart';
import 'package:finance/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finance/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/services/currency_service.dart';
import 'package:finance/features/budgets/data/services/budget_csv_service.dart';
import '../helpers/test_database_setup.dart';
import '../helpers/entity_builders.dart';
import 'package:mocktail/mocktail.dart';
import 'package:drift/drift.dart';
import 'package:finance/core/events/transaction_event_publisher.dart';
import 'package:finance/core/di/injection.dart';
import '../helpers/test_di.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/categories/domain/entities/category.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
class MockCurrencyService extends Mock implements CurrencyService {}
class MockBudgetCsvService extends Mock implements BudgetCsvService {}
class MockTransactionEventPublisher extends Mock implements TransactionEventPublisher {}

// Skip this integration test in headless CI environments; requires full DI and database setup.
@Skip('Skipping integration test in CI until DI setup is fully supported')

void main() {
  group('Phase 2 - Budget Filter Manual Integration Tests', skip: true, () {
    late AppDatabase database;
    late BudgetRepository budgetRepository;
    late TransactionRepository transactionRepository;
    late AccountRepository accountRepository;
    late CategoryRepository categoryRepository;
    late BudgetFilterServiceImpl filterService;
    
    setUpAll(() async {
      // Ensure binding is initialized before using shared_preferences or other
      // Flutter services in DI setup.
      TestWidgetsFlutterBinding.ensureInitialized();

      // Provide mock implementation for SharedPreferences used in DI.
      // Prevents MissingPluginException in pure Dart test environment.
      SharedPreferences.setMockInitialValues({});

      await configureTestDependencies();
    });

    setUp(() async {
      database = getIt<AppDatabase>();
      transactionRepository = getIt<TransactionRepository>();
      budgetRepository = getIt<BudgetRepository>();
      accountRepository = getIt<AccountRepository>();
      categoryRepository = getIt<CategoryRepository>();

      // Mock services for testing
      final mockCurrencyService = MockCurrencyService();
      final mockCsvService = MockBudgetCsvService();

      filterService = BudgetFilterServiceImpl(
        transactionRepository,
        accountRepository,
        budgetRepository,
        mockCurrencyService,
        mockCsvService,
      );
    });

    tearDown(() async {
      await getIt.reset();
    });

    group('Manual Budget Filtering Tests', () {
      test('should calculate spent amount correctly for manual budgets',
          () async {
        // Arrange
        final budget = await _createManualBudget(budgetRepository);
        final transaction1 =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 100.0);
        final transaction2 =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 150.0);
        await _createTestTransaction(database, accountRepository, categoryRepository, amount: 75.0);

        // Link only transaction1 and transaction2 to the budget
        await budgetRepository.addTransactionToBudget(
            transaction1.id!, budget.id!);
        await budgetRepository.addTransactionToBudget(
            transaction2.id!, budget.id!);

        // Act
        final spentAmount = await filterService.calculateBudgetSpent(budget);

        // Assert
        expect(spentAmount, 250.0); // Only linked transactions (100 + 150)
        expect(spentAmount,
            isNot(equals(325.0))); // Should not include transaction3
      });

      test('should get filtered transactions for manual budgets', () async {
        // Arrange
        final budget = await _createManualBudget(budgetRepository);
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now().add(const Duration(days: 30));

        final transaction1 =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 200.0);
        await _createTestTransaction(database, accountRepository, categoryRepository, amount: 300.0);
        final transaction3 =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 400.0);

        // Link only transaction1 and transaction3 to the budget
        await budgetRepository.addTransactionToBudget(
            transaction1.id!, budget.id!);
        await budgetRepository.addTransactionToBudget(
            transaction3.id!, budget.id!);

        // Act
        final transactions =
            await filterService.getFilteredTransactionsForBudget(
          budget,
          startDate,
          endDate,
        );

        // Assert
        expect(transactions.length, 2);
        final amounts = transactions.map((t) => t.amount).toList();
        expect(amounts, containsAll([200.0, 400.0]));
        expect(amounts,
            isNot(contains(300.0))); // Should not include unlinked transaction
      });

      test('should exclude transactions outside date range for manual budgets',
          () async {
        // Arrange
        final budget = await _createManualBudget(budgetRepository);
        final startDate = DateTime.now();
        final endDate = DateTime.now().add(const Duration(days: 7));

        // Create transactions - one in range, one outside range
        final transactionInRange = await _createTestTransactionWithDate(
          database,
          date: DateTime.now().add(const Duration(days: 3)),
          amount: 100.0,
        );
        final transactionOutsideRange = await _createTestTransactionWithDate(
          database,
          date: DateTime.now().subtract(const Duration(days: 10)),
          amount: 200.0,
        );

        // Link both transactions to the budget
        await budgetRepository.addTransactionToBudget(
            transactionInRange.id!, budget.id!);
        await budgetRepository.addTransactionToBudget(
            transactionOutsideRange.id!, budget.id!);

        // Act
        final transactions =
            await filterService.getFilteredTransactionsForBudget(
          budget,
          startDate,
          endDate,
        );

        // Assert
        expect(transactions.length, 1);
        expect(
            transactions.first.amount, 100.0); // Only the in-range transaction
      });

      test('should handle automatic budgets differently from manual budgets',
          () async {
        // Arrange
        final manualBudget = await _createManualBudget(budgetRepository);
        final automaticBudget = await _createAutomaticBudget(budgetRepository, accountRepository);

        final transaction =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 100.0);

        // Link transaction only to manual budget
        await budgetRepository.addTransactionToBudget(
            transaction.id!, manualBudget.id!);

        // Act
        final manualSpent =
            await filterService.calculateBudgetSpent(manualBudget);
        final automaticSpent =
            await filterService.calculateBudgetSpent(automaticBudget);

        // Assert
        expect(manualBudget.manualAddMode, true);
        expect(automaticBudget.manualAddMode, false);
        expect(manualSpent, 100.0); // Manual budget sees linked transaction
        expect(automaticSpent,
            0.0); // Automatic budget uses different logic (no linked transactions)
      });
    });

    group('Budget Remaining Calculation Tests', () {
      test('should calculate remaining amount correctly for manual budgets',
          () async {
        // Arrange
        final budget =
            await _createManualBudget(budgetRepository, budgetAmount: 1000.0);
        final transaction1 =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 300.0);
        final transaction2 =
            await _createTestTransaction(database, accountRepository, categoryRepository, amount: 200.0);

        await budgetRepository.addTransactionToBudget(
            transaction1.id!, budget.id!);
        await budgetRepository.addTransactionToBudget(
            transaction2.id!, budget.id!);

        // Act
        final remaining = await filterService.calculateBudgetRemaining(budget);

        // Assert
        expect(remaining, 500.0); // 1000 - (300 + 200)
      });
    });
  });
}

/// Helper to create a manual budget (no wallet filters)
Future<Budget> _createManualBudget(
  BudgetRepository repository, {
  double budgetAmount = 1000.0,
}) async {
  final budget = TestEntityBuilders.createTestBudget(
    name: 'Manual Budget ${DateTime.now().millisecondsSinceEpoch}',
    amount: budgetAmount,
    // Manual mode – no wallet filters
  );
  return await repository.createBudget(budget);
}

/// Helper to create an automatic budget (with wallet filters)
Future<Budget> _createAutomaticBudget(
  BudgetRepository repository,
  AccountRepository accountRepository, {
  double budgetAmount = 1000.0,
}) async {
  final account = await accountRepository.createAccount(
    Account(
      name: 'Test Account For Auto',
      balance: 10000.0,
      currency: 'USD',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncId: 'sync-auto-acc-${DateTime.now().millisecondsSinceEpoch}',
      color: Colors.blue,
    ),
  );
  final budget = TestEntityBuilders.createTestBudget(
    name: 'Automatic Budget ${DateTime.now().millisecondsSinceEpoch}',
    amount: budgetAmount,
    spent: 0.0,
    period: BudgetPeriod.monthly,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    isActive: true,
    // Automatic mode – restrict to wallet IDs
  );
  return await repository.createBudget(budget);
}

/// Helper to create a test transaction
Future<Transaction> _createTestTransaction(
  AppDatabase database,
  AccountRepository accountRepository,
  CategoryRepository categoryRepository, {
  double amount = 100.0,
}) async {
  final account = await accountRepository.createAccount(
    Account(
      name: 'Test Account Tx',
      balance: 10000.0,
      currency: 'USD',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncId: 'sync-tx-acc-${DateTime.now().millisecondsSinceEpoch}',
      color: Colors.green,
    ),
  );
  final category = await categoryRepository.createCategory(
    Category(
      name: 'Test Category Tx',
      icon: 'test_icon',
      color: Colors.red,
      isExpense: true,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncId: 'sync-tx-cat-${DateTime.now().millisecondsSinceEpoch}',
    ),
  );
  return await _createTestTransactionWithDate(
    database,
    date: DateTime.now(),
    amount: amount,
    accountId: account.id,
    categoryId: category.id,
  );
}

/// Helper to create a test transaction with a specific date
Future<Transaction> _createTestTransactionWithDate(
  AppDatabase database, {
  required DateTime date,
  required double amount,
  int? accountId,
  int? categoryId,
}) async {
  // Insert directly into the Drift table since domain entity doesn't expose
  // toCompanion / fromCompanion helpers after Phase-4 refactor.

  final now = DateTime.now();
  final syncId = 'test_tx_${now.microsecondsSinceEpoch}';

  final id = await database.into(database.transactionsTable).insert(
    TransactionsTableCompanion.insert(
      title: 'Integration Test Tx',
      amount: amount,
      categoryId: categoryId ?? 1,
      accountId: accountId ?? 1,
      date: date,
      syncId: syncId,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
  );

  return Transaction(
    id: id,
    title: 'Integration Test Tx',
    amount: amount,
    categoryId: categoryId ?? 1,
    accountId: accountId ?? 1,
    date: date,
    createdAt: now,
    updatedAt: now,
    syncId: syncId,
  );
}
