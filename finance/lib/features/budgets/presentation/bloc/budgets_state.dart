import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_history_entry.dart';

abstract class BudgetsState extends Equatable {
  const BudgetsState();

  @override
  List<Object?> get props => [];
}

class BudgetsInitial extends BudgetsState {}

class BudgetsLoading extends BudgetsState {}

class BudgetsLoaded extends BudgetsState {
  final List<Budget> budgets;
  final Map<int, double> realTimeSpentAmounts;
  final Map<int, double> dailySpendingAllowances;
  final bool isRealTimeActive;
  final Map<int, bool> authenticatedBudgets;
  final bool isExporting;
  final String? exportStatus;

  const BudgetsLoaded({
    required this.budgets,
    this.realTimeSpentAmounts = const {},
    this.dailySpendingAllowances = const {},
    this.isRealTimeActive = false,
    this.authenticatedBudgets = const {},
    this.isExporting = false,
    this.exportStatus,
  });

  BudgetsLoaded copyWith({
    List<Budget>? budgets,
    Map<int, double>? realTimeSpentAmounts,
    Map<int, double>? dailySpendingAllowances,
    bool? isRealTimeActive,
    Map<int, bool>? authenticatedBudgets,
    bool? isExporting,
    String? exportStatus,
  }) {
    return BudgetsLoaded(
      budgets: budgets ?? this.budgets,
      realTimeSpentAmounts: realTimeSpentAmounts ?? this.realTimeSpentAmounts,
      dailySpendingAllowances:
          dailySpendingAllowances ?? this.dailySpendingAllowances,
      isRealTimeActive: isRealTimeActive ?? this.isRealTimeActive,
      authenticatedBudgets: authenticatedBudgets ?? this.authenticatedBudgets,
      isExporting: isExporting ?? this.isExporting,
      exportStatus: exportStatus ?? this.exportStatus,
    );
  }

  @override
  List<Object?> get props => [
        budgets,
        realTimeSpentAmounts,
        dailySpendingAllowances,
        isRealTimeActive,
        authenticatedBudgets,
        isExporting,
        exportStatus,
      ];
}

class BudgetsError extends BudgetsState {
  final String message;

  const BudgetsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetDetailsError extends BudgetsState {
  final String message;

  const BudgetDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetDetailsLoading extends BudgetsState {}

class BudgetDetailsLoaded extends BudgetsState {
  final Budget budget;
  final List<BudgetHistoryEntry> history;
  final double dailySpendingAllowance;

  const BudgetDetailsLoaded({
    required this.budget,
    required this.history,
    this.dailySpendingAllowance = 0.0,
  });

  @override
  List<Object?> get props => [budget, history, dailySpendingAllowance];
}

class BudgetAuthenticationRequired extends BudgetsState {
  final int budgetId;

  const BudgetAuthenticationRequired(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class BudgetAuthenticationSuccess extends BudgetsState {
  final int budgetId;

  const BudgetAuthenticationSuccess(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

class BudgetAuthenticationFailed extends BudgetsState {
  final int budgetId;
  final String reason;

  const BudgetAuthenticationFailed(this.budgetId, this.reason);

  @override
  List<Object?> get props => [budgetId, reason];
}
