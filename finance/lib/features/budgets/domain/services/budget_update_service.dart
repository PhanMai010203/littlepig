import 'dart:async';
import '../entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../../core/events/transaction_event_publisher.dart';

abstract class BudgetUpdateService {
  Future<void> updateBudgetOnTransactionChange(
      Transaction transaction, TransactionChangeType changeType);

  Future<void> recalculateAllBudgetSpentAmounts();
  Future<void> recalculateBudgetSpentAmount(int budgetId);

  Stream<Budget> watchBudgetUpdates(int budgetId);
  Stream<List<Budget>> watchAllBudgetUpdates();
  Stream<Map<int, double>> watchBudgetSpentAmounts();

  // Authentication for sensitive budget operations
  Future<bool> authenticateForBudgetAccess();

  // Performance monitoring
  Future<Map<String, dynamic>> getBudgetUpdatePerformanceMetrics();

  // Cleanup
  void dispose();
}

