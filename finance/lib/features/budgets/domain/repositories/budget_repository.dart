import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<List<Budget>> getActiveBudgets();
  Future<Budget?> getBudgetById(int id);
  Future<Budget?> getBudgetBySyncId(String syncId);
  Future<List<Budget>> getBudgetsByCategory(int categoryId);
  
  Future<Budget> createBudget(Budget budget);
  Future<Budget> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
  
  Future<void> updateSpentAmount(int budgetId, double spentAmount);
  
  // Sync related
  Future<List<Budget>> getUnsyncedBudgets();
  Future<void> markAsSynced(String syncId, DateTime syncTime);
  Future<void> insertOrUpdateFromSync(Budget budget);
}
