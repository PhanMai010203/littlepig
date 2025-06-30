import 'package:flutter/material.dart';
import 'budget.dart';

/// Lightweight view-model object for budget display data
class BudgetCardData {
  final Budget budget;
  final String formattedAmount;
  final String formattedSpent;
  final String formattedRemaining;
  final double spentPercentage;
  final Color budgetColor;
  final bool isOverspent;
  final String dailyAllowanceText;

  const BudgetCardData({
    required this.budget,
    required this.formattedAmount,
    required this.formattedSpent,
    required this.formattedRemaining,
    required this.spentPercentage,
    required this.budgetColor,
    required this.isOverspent,
    required this.dailyAllowanceText,
  });

  factory BudgetCardData.fromBudget({
    required Budget budget,
    required double realTimeSpent,
    required Color budgetColor,
    required String formattedAmount,
    required String formattedSpent,
    required String formattedRemaining,
    required String dailyAllowanceText,
  }) {
    final remaining = budget.amount - realTimeSpent;
    final spentPercentage = budget.amount > 0 ? realTimeSpent / budget.amount : 0.0;
    final isOverspent = remaining < 0;

    return BudgetCardData(
      budget: budget,
      formattedAmount: formattedAmount,
      formattedSpent: formattedSpent,
      formattedRemaining: formattedRemaining,
      spentPercentage: spentPercentage.clamp(0.0, 1.0),
      budgetColor: budgetColor,
      isOverspent: isOverspent,
      dailyAllowanceText: dailyAllowanceText,
    );
  }
}