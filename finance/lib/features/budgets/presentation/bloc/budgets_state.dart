import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

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
  final bool isRealTimeActive;
  final Map<int, bool> authenticatedBudgets;
  final bool isExporting;
  final String? exportStatus;

  const BudgetsLoaded({
    required this.budgets,
    this.realTimeSpentAmounts = const {},
    this.isRealTimeActive = false,
    this.authenticatedBudgets = const {},
    this.isExporting = false,
    this.exportStatus,
  });

  BudgetsLoaded copyWith({
    List<Budget>? budgets,
    Map<int, double>? realTimeSpentAmounts,
    bool? isRealTimeActive,
    Map<int, bool>? authenticatedBudgets,
    bool? isExporting,
    String? exportStatus,
  }) {
    return BudgetsLoaded(
      budgets: budgets ?? this.budgets,
      realTimeSpentAmounts: realTimeSpentAmounts ?? this.realTimeSpentAmounts,
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
