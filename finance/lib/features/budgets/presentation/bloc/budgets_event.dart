import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';

abstract class BudgetsEvent extends Equatable {
  const BudgetsEvent();

  @override
  List<Object?> get props => [];
}

// Existing events
class LoadAllBudgets extends BudgetsEvent {}

class CreateBudget extends BudgetsEvent {
  final Budget budget;
  const CreateBudget(this.budget);
  @override
  List<Object?> get props => [budget];
}

class UpdateBudget extends BudgetsEvent {
  final Budget budget;
  const UpdateBudget(this.budget);
  @override
  List<Object?> get props => [budget];
}

class DeleteBudget extends BudgetsEvent {
  final int budgetId;
  const DeleteBudget(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}

// Real-time update events
class StartRealTimeUpdates extends BudgetsEvent {}

class StopRealTimeUpdates extends BudgetsEvent {}

class BudgetRealTimeUpdateReceived extends BudgetsEvent {
  final List<Budget> budgets;
  const BudgetRealTimeUpdateReceived(this.budgets);
  @override
  List<Object?> get props => [budgets];
}

class BudgetSpentAmountUpdateReceived extends BudgetsEvent {
  final Map<int, double> spentAmounts;
  const BudgetSpentAmountUpdateReceived(this.spentAmounts);
  @override
  List<Object?> get props => [spentAmounts];
}

class AuthenticateForBudgetAccess extends BudgetsEvent {
  final int budgetId;
  const AuthenticateForBudgetAccess(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}

class RecalculateAllBudgets extends BudgetsEvent {}

class RecalculateBudget extends BudgetsEvent {
  final int budgetId;
  const RecalculateBudget(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}

class ExportBudgetData extends BudgetsEvent {
  final Budget budget;
  const ExportBudgetData(this.budget);
  @override
  List<Object?> get props => [budget];
}

class ExportMultipleBudgets extends BudgetsEvent {
  final List<Budget> budgets;
  const ExportMultipleBudgets(this.budgets);
  @override
  List<Object?> get props => [budgets];
} 