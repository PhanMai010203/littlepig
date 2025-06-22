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

void main() {
  group('Phase 2 - Budget Filter Manual Integration Tests', () {
    late AppDatabase database;
    late BudgetRepositoryImpl budgetRepository;
    late TransactionRepositoryImpl transactionRepository;
    late AccountRepositoryImpl accountRepository;
    late BudgetFilterServiceImpl filterService;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      budgetRepository = BudgetRepositoryImpl(database);
      transactionRepository = TransactionRepositoryImpl(database);
      accountRepository = AccountRepositoryImpl(database);

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
      await database.close();
    });

    group('Manual Budget Filtering Tests', () {
      test('should calculate spent amount correctly for manual budgets',
          () async {
        // Arrange
        final budget = await _createManualBudget(budgetRepository);
        final transaction1 =
            await _createTestTransaction(database, amount: 100.0);
        final transaction2 =
            await _createTestTransaction(database, amount: 150.0);
        final transaction3 =
            await _createTestTransaction(database, amount: 75.0);

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
            await _createTestTransaction(database, amount: 200.0);
        final transaction2 =
            await _createTestTransaction(database, amount: 300.0);
        final transaction3 =
            await _createTestTransaction(database, amount: 400.0);

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
        final automaticBudget = await _createAutomaticBudget(budgetRepository);

        final transaction =
            await _createTestTransaction(database, amount: 100.0);

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
            await _createTestTransaction(database, amount: 300.0);
        final transaction2 =
            await _createTestTransaction(database, amount: 200.0);

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
  BudgetRepositoryImpl repository, {
  double budgetAmount = 1000.0,
}) async {
  final budget = TestEntityBuilders.createTestBudget(
    name: 'Manual Budget ${DateTime.now().millisecondsSinceEpoch}',
    amount: budgetAmount,
    // No walletFks = manual mode
  );
  return await repository.createBudget(budget);
}

/// Helper to create an automatic budget (with wallet filters)
Future<Budget> _createAutomaticBudget(
  BudgetRepositoryImpl repository, {
  double budgetAmount = 1000.0,
}) async {
  final budget = Budget(
    name: 'Automatic Budget ${DateTime.now().millisecondsSinceEpoch}',
    amount: budgetAmount,
    spent: 0.0,
    period: BudgetPeriod.monthly,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    syncId: 'test-auto-budget-${DateTime.now().millisecondsSinceEpoch}',
    walletFks: ['1'], // Has wallet filters = automatic mode
  );
  return await repository.createBudget(budget);
}

/// Helper to create a test transaction
Future<Transaction> _createTestTransaction(
  AppDatabase database, {
  double amount = 100.0,
}) async {
  return await _createTestTransactionWithDate(
    database,
    date: DateTime.now(),
    amount: amount,
  );
}

/// Helper to create a test transaction with specific date
Future<Transaction> _createTestTransactionWithDate(
  AppDatabase database, {
  required DateTime date,
  double amount = 100.0,
}) async {
  // Create a test account first
  final accountId = await database.into(database.accountsTable).insert(
        AccountsTableCompanion.insert(
          name: 'Test Account',
          syncId: 'test_account_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

  // Create a test category
  final categoryId = await database.into(database.categoriesTable).insert(
        CategoriesTableCompanion.insert(
          name: 'Test Category',
          icon: '🧪',
          color: 0xFF000000,
          isExpense: true,
          syncId: 'test_category_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

  // Create the transaction
  final transactionId = await database.into(database.transactionsTable).insert(
        TransactionsTableCompanion.insert(
          title: 'Test Transaction',
          amount: amount,
          categoryId: categoryId,
          accountId: accountId,
          date: date,
          syncId: 'test_transaction_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

  return Transaction(
    id: transactionId,
    title: 'Test Transaction',
    amount: amount,
    categoryId: categoryId,
    accountId: accountId,
    date: date,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    syncId: 'test_transaction_${DateTime.now().millisecondsSinceEpoch}',
  );
}

/// Mock CurrencyService for testing
class MockCurrencyService implements CurrencyService {
  @override
  Future<double> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // Simple mock - just return the original amount
    return amount;
  }

  // Add other required methods as no-ops for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock BudgetCsvService for testing
class MockBudgetCsvService implements BudgetCsvService {
  @override
  Future<void> exportBudgetToCSV(Budget budget, String filePath) async {
    // No-op for testing
  }

  @override
  Future<void> exportBudgetsToCSV(List<Budget> budgets) async {
    // No-op for testing
  }

  // Add other required methods as no-ops for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
