import 'package:flutter/material.dart';
import '../entities/budget.dart';
import '../entities/budget_card_data.dart';

abstract class BudgetDisplayService {
  /// Prepare budget card data for display
  Future<List<BudgetCardData>> prepareBudgetCardsData(
    List<Budget> budgets,
    Map<int, double> realTimeSpentAmounts,
  );

  /// Calculate color for a budget based on its properties
  Color calculateBudgetColor(Budget budget, BuildContext context);

  /// Format budget amount with currency
  Future<String> formatBudgetAmount(Budget budget, double amount);

  /// Calculate daily allowance text for a budget
  String calculateDailyAllowanceText(Budget budget, double remaining);

  /// Check if expensive motion should be disabled
  bool shouldDisableExpensiveMotion(BuildContext context);

  /// Get progress percentage for a budget
  double getBudgetProgress(Budget budget, double spent);
}