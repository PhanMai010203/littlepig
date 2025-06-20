import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/budgets/domain/entities/budget.dart';
import 'package:finance/features/budgets/domain/entities/transaction_budget_link.dart';
import 'package:finance/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import 'package:finance/core/database/app_database.dart';
import '../../helpers/test_database_setup.dart';
import '../../helpers/entity_builders.dart';

void main() {
  group('Phase 2 - Manual Budget Linking Tests', () {
    late AppDatabase database;
    late BudgetRepositoryImpl repository;

    setUp(() async {
      database = await TestDatabaseSetup.createCleanTestDatabase();
      repository = BudgetRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    group('Repository CRUD Tests', () {
      test('should add transaction to budget successfully', () async {
        // Arrange
        final budget = await _createTestBudget(repository);
        final transaction = await _createTestTransaction(database);

        // Act
        await repository.addTransactionToBudget(
          transaction.id!,
          budget.id!,
          amount: 50.0,
        );

        // Assert
        final budgets = await repository.getBudgetsForTransaction(transaction.id!);
        expect(budgets.length, 1);
        expect(budgets.first.id, budget.id);

        final links = await repository.getTransactionLinksForBudget(budget.id!);
        expect(links.length, 1);
        expect(links.first.transactionId, transaction.id);
        expect(links.first.budgetId, budget.id);
        expect(links.first.amount, 50.0);
      });

      test('should prevent duplicate transaction-budget links', () async {
        // Arrange
        final budget = await _createTestBudget(repository);
        final transaction = await _createTestTransaction(database);

        // Act - Add same link twice
        await repository.addTransactionToBudget(
          transaction.id!,
          budget.id!,
          amount: 30.0,
        );
        await repository.addTransactionToBudget(
          transaction.id!,
          budget.id!,
          amount: 50.0,
        );

        // Assert - Should only have one link with updated amount
        final links = await repository.getTransactionLinksForBudget(budget.id!);
        expect(links.length, 1);
        expect(links.first.amount, 50.0); // Updated amount
      });

      test('should remove transaction from budget successfully', () async {
        // Arrange
        final budget = await _createTestBudget(repository);
        final transaction = await _createTestTransaction(database);
        await repository.addTransactionToBudget(
          transaction.id!,
          budget.id!,
          amount: 75.0,
        );

        // Act
        await repository.removeTransactionFromBudget(
          transaction.id!,
          budget.id!,
        );

        // Assert
        final budgets = await repository.getBudgetsForTransaction(transaction.id!);
        expect(budgets.isEmpty, true);

        final links = await repository.getTransactionLinksForBudget(budget.id!);
        expect(links.isEmpty, true);
      });

      test('should get all transaction budget links', () async {
        // Arrange
        final budget1 = await _createTestBudget(repository);
        final budget2 = await _createTestBudget(repository);
        final transaction1 = await _createTestTransaction(database);
        final transaction2 = await _createTestTransaction(database);

        // Act
        await repository.addTransactionToBudget(transaction1.id!, budget1.id!, amount: 100.0);
        await repository.addTransactionToBudget(transaction2.id!, budget1.id!, amount: 200.0);
        await repository.addTransactionToBudget(transaction1.id!, budget2.id!, amount: 150.0);

        // Assert
        final allLinks = await repository.getAllTransactionBudgetLinks();
        expect(allLinks.length, 3);
        
        final amounts = allLinks.map((link) => link.amount).toList();
        expect(amounts, containsAll([100.0, 200.0, 150.0]));
      });
    });

    group('Budget Manual Mode Tests', () {
      test('should identify manual-add budget correctly', () {
        // Arrange & Act
        final manualBudget = TestEntityBuilders.createTestBudget(
          name: 'Vacation Fund',
          // No walletFks parameter = manual mode
        );

        final automaticBudget = Budget(
          id: 2,
          name: 'Monthly Grocery',
          amount: 1000.0,
          spent: 0.0,
          period: BudgetPeriod.monthly,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncId: 'test-budget-auto',
          walletFks: ['1', '2'], // Has wallet filters = automatic mode
        );

        // Assert
        expect(manualBudget.manualAddMode, true);
        expect(automaticBudget.manualAddMode, false);
      });
    });

    group('Cascade Delete Tests', () {
      test('should delete transaction budget links when budget is deleted', () async {
        // Arrange
        final budget = await _createTestBudget(repository);
        final transaction = await _createTestTransaction(database);
        await repository.addTransactionToBudget(transaction.id!, budget.id!);

        // Verify link was created
        var links = await repository.getAllTransactionBudgetLinks();
        expect(links.where((link) => link.budgetId == budget.id).length, 1);

        // Act
        await repository.deleteBudget(budget.id!);

        // Assert
        links = await repository.getAllTransactionBudgetLinks();
        expect(links.where((link) => link.budgetId == budget.id).isEmpty, true);
      });
    });
  });
}

/// Helper to create a test budget
Future<Budget> _createTestBudget(BudgetRepositoryImpl repository) async {
  final now = DateTime.now();
  final uniqueId = '${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';
  final budget = TestEntityBuilders.createTestBudget(
    syncId: 'test-budget-$uniqueId',
    name: 'Test Budget $uniqueId',
    amount: 1000.0,
    // No walletFks parameter = manual mode
  );
  return await repository.createBudget(budget);
}

/// Helper to create a test transaction
Future<Transaction> _createTestTransaction(AppDatabase database, {double amount = 100.0}) async {
  final now = DateTime.now();
  final uniqueId = '${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';
  
  // Create a test account first
  final accountId = await database.into(database.accountsTable).insert(
    AccountsTableCompanion.insert(
      name: 'Test Account',
      syncId: 'test_account_$uniqueId',
    ),
  );

  // Create a test category
  final categoryId = await database.into(database.categoriesTable).insert(
    CategoriesTableCompanion.insert(
      name: 'Test Category',
      icon: '🧪',
      color: 0xFF000000,
      isExpense: true,
      syncId: 'test_category_$uniqueId',
    ),
  );

  // Create the transaction
  final transactionSyncId = 'test_transaction_$uniqueId';
  final transactionId = await database.into(database.transactionsTable).insert(
    TransactionsTableCompanion.insert(
      title: 'Test Transaction',
      amount: amount,
      categoryId: categoryId,
      accountId: accountId,
      date: now,
      syncId: transactionSyncId,
    ),
  );

  return Transaction(
    id: transactionId,
    title: 'Test Transaction',
    amount: amount,
    categoryId: categoryId,
    accountId: accountId,
    date: now,
    createdAt: now,
    updatedAt: now,
    syncId: transactionSyncId,
  );
} 