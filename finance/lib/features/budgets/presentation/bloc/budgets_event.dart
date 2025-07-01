import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_enums.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/domain/entities/category.dart';

abstract class BudgetsEvent extends Equatable {
  const BudgetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllBudgets extends BudgetsEvent {}

class LoadBudgetDetails extends BudgetsEvent {
  final int budgetId;

  const LoadBudgetDetails(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}

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

// Budget Creation Events
class BudgetTrackingTypeChanged extends BudgetsEvent {
  final BudgetTrackingType trackingType;
  const BudgetTrackingTypeChanged(this.trackingType);
  @override
  List<Object?> get props => [trackingType];
}

class LoadAccountsForBudget extends BudgetsEvent {}

class LoadCategoriesForBudget extends BudgetsEvent {}

class BudgetAccountsSelected extends BudgetsEvent {
  final List<Account> selectedAccounts;
  final bool isAllSelected;
  const BudgetAccountsSelected(this.selectedAccounts, this.isAllSelected);
  @override
  List<Object?> get props => [selectedAccounts, isAllSelected];
}

class BudgetIncludeCategoriesSelected extends BudgetsEvent {
  final List<Category> selectedCategories;
  final bool isAllSelected;
  const BudgetIncludeCategoriesSelected(this.selectedCategories, this.isAllSelected);
  @override
  List<Object?> get props => [selectedCategories, isAllSelected];
}

class BudgetExcludeCategoriesSelected extends BudgetsEvent {
  final List<Category> selectedCategories;
  const BudgetExcludeCategoriesSelected(this.selectedCategories);
  @override
  List<Object?> get props => [selectedCategories];
}
