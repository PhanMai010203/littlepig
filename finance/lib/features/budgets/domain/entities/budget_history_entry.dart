import 'package:equatable/equatable.dart';

class BudgetHistoryEntry extends Equatable {
  final String periodName;
  final double totalSpent;
  final double totalBudgeted;

  const BudgetHistoryEntry({
    required this.periodName,
    required this.totalSpent,
    required this.totalBudgeted,
  });

  double get difference => totalBudgeted - totalSpent;
  double get utilizationPercentage => totalBudgeted > 0 ? (totalSpent / totalBudgeted * 100) : 0;
  bool get isUnderBudget => difference >= 0;
  bool get isOverBudget => difference < 0;
  double get absoluteDifference => difference.abs();

  @override
  List<Object?> get props => [periodName, totalSpent, totalBudgeted];
}