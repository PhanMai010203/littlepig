import '../entities/budget.dart';
import '../entities/transaction_budget_link.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<List<Budget>> getActiveBudgets();
  Future<Budget?> getBudgetById(int id);
  Future<Budget?> getBudgetBySyncId(String syncId);
  Future<List<Budget>> getBudgetsByCategory(int categoryId);

  Future<Budget> createBudget(Budget budget);
  Future<Budget> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
  Future<void> deleteAllBudgets();

  Future<void> updateSpentAmount(int budgetId, double spentAmount);

  // Manual budget linking methods (Phase 2)
  Future<void> addTransactionToBudget(int transactionId, int budgetId,
      {double? amount});
  Future<void> removeTransactionFromBudget(int transactionId, int budgetId);
  Future<List<Budget>> getBudgetsForTransaction(int transactionId);
  Future<List<TransactionBudgetLink>> getTransactionLinksForBudget(
      int budgetId);
  Future<List<TransactionBudgetLink>> getAllTransactionBudgetLinks();

  // Sync related
  Future<List<Budget>> getUnsyncedBudgets();
  Future<void> markAsSynced(String syncId, DateTime syncTime);
  Future<void> insertOrUpdateFromSync(Budget budget);
}
