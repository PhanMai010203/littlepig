import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entities/budget.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../budgets/domain/services/budget_update_service.dart';
import '../../../../core/events/transaction_event_publisher.dart';

/// A lightweight, no-op implementation of [BudgetUpdateService] that is only
/// used in the test environment. It avoids touching any native SQLite code
/// so that unit tests can run on machines where `libsqlite3.so` isn't
/// available.
@LazySingleton(as: BudgetUpdateService, env: [Environment.test])
class BudgetUpdateServiceNoOp implements BudgetUpdateService {
  @override
  Future<bool> authenticateForBudgetAccess() async => true;

  @override
  void dispose() {}

  @override
  Stream<List<Budget>> watchAllBudgetUpdates() => const Stream.empty();

  @override
  Stream<Budget> watchBudgetUpdates(int budgetId) => const Stream.empty();

  @override
  Stream<Map<int, double>> watchBudgetSpentAmounts() => const Stream.empty();

  @override
  Future<void> recalculateAllBudgetSpentAmounts() async {}

  @override
  Future<void> recalculateBudgetSpentAmount(int budgetId) async {}

  @override
  Future<Map<String, dynamic>> getBudgetUpdatePerformanceMetrics() async => const {};

  @override
  Future<void> updateBudgetOnTransactionChange(
    Transaction transaction,
    TransactionChangeType changeType,
  ) async {}
} 