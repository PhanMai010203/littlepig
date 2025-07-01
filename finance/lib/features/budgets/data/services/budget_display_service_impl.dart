import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_card_data.dart';
import '../../domain/services/budget_display_service.dart';

@LazySingleton(as: BudgetDisplayService)
class BudgetDisplayServiceImpl implements BudgetDisplayService {
  @override
  Future<List<BudgetCardData>> prepareBudgetCardsData(
    List<Budget> budgets,
    Map<int, double> realTimeSpentAmounts,
  ) async {
    final List<BudgetCardData> budgetCards = [];

    for (final budget in budgets) {
      final realTimeSpent = realTimeSpentAmounts[budget.id] ?? 0.0;
      final remaining = budget.amount - realTimeSpent;

      // Format amounts
      final formattedAmount = '\$${budget.amount.toStringAsFixed(0)}';
      final formattedSpent = '\$${realTimeSpent.toStringAsFixed(0)}';
      final formattedRemaining = '\$${remaining.abs().toStringAsFixed(0)}';

      // Calculate daily allowance
      final dailyAllowanceText = calculateDailyAllowanceText(budget, remaining);

      // Determine budget color
      final budgetColor = _pickBudgetColor(budget);

      final budgetCardData = BudgetCardData.fromBudget(
        budget: budget,
        realTimeSpent: realTimeSpent,
        budgetColor: budgetColor,
        formattedAmount: formattedAmount,
        formattedSpent: formattedSpent,
        formattedRemaining: formattedRemaining,
        dailyAllowanceText: dailyAllowanceText,
      );

      budgetCards.add(budgetCardData);
    }

    return budgetCards;
  }

  @override
  Color calculateBudgetColor(Budget budget, BuildContext context) {
    return _pickBudgetColor(budget);
  }

  Color _pickBudgetColor(Budget budget) {
    // Use the budget's color if available, otherwise fall back to hash-based selection
    if (budget.colour != null && budget.colour!.isNotEmpty) {
      return HexColor(budget.colour!);
    }
    final palette = getSelectableColors();
    return palette[budget.name.hashCode.abs() % palette.length];
  }

  @override
  Future<String> formatBudgetAmount(Budget budget, double amount) async {
    // For now, simple dollar formatting
    // This can be enhanced with currency service integration
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  String calculateDailyAllowanceText(Budget budget, double remaining) {
    if (remaining <= 0) {
      return 'budgets.overspent'.tr();
    }

    final now = DateTime.now();
    final endDate = budget.endDate;
    final daysRemaining = endDate.difference(now).inDays;

    if (daysRemaining <= 0) {
      return 'budgets.budget_ended'.tr();
    }

    final dailyAllowance = remaining / daysRemaining;
    return 'budgets.daily_allowance'.tr(namedArgs: {
      'amount': dailyAllowance.toStringAsFixed(0),
    });
  }

  @override
  bool shouldDisableExpensiveMotion(BuildContext context) {
    return AppSettings.reduceAnimations || 
           AppSettings.batterySaver ||
           MediaQuery.of(context).disableAnimations;
  }

  @override
  double getBudgetProgress(Budget budget, double spent) {
    if (budget.amount <= 0) return 0.0;
    return (spent / budget.amount).clamp(0.0, 1.0);
  }
}