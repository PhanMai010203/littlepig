import 'package:equatable/equatable.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_history_entry.dart';
import '../../domain/entities/budget_enums.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/domain/entities/category.dart';

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

// Budget Creation States
class BudgetCreationState extends BudgetsState {
  final BudgetTrackingType trackingType;
  final List<Account> availableAccounts;
  final List<Account> selectedAccounts;
  final bool isAllAccountsSelected;
  final List<Category> availableCategories;
  final List<Category> includedCategories;
  final bool isAllCategoriesIncluded;
  final List<Category> excludedCategories;
  final bool isAccountsLoading;
  final bool isCategoriesLoading;

  const BudgetCreationState({
    this.trackingType = BudgetTrackingType.automatic,
    this.availableAccounts = const [],
    this.selectedAccounts = const [],
    this.isAllAccountsSelected = true,
    this.availableCategories = const [],
    this.includedCategories = const [],
    this.isAllCategoriesIncluded = true,
    this.excludedCategories = const [],
    this.isAccountsLoading = false,
    this.isCategoriesLoading = false,
  });

  BudgetCreationState copyWith({
    BudgetTrackingType? trackingType,
    List<Account>? availableAccounts,
    List<Account>? selectedAccounts,
    bool? isAllAccountsSelected,
    List<Category>? availableCategories,
    List<Category>? includedCategories,
    bool? isAllCategoriesIncluded,
    List<Category>? excludedCategories,
    bool? isAccountsLoading,
    bool? isCategoriesLoading,
  }) {
    return BudgetCreationState(
      trackingType: trackingType ?? this.trackingType,
      availableAccounts: availableAccounts ?? this.availableAccounts,
      selectedAccounts: selectedAccounts ?? this.selectedAccounts,
      isAllAccountsSelected: isAllAccountsSelected ?? this.isAllAccountsSelected,
      availableCategories: availableCategories ?? this.availableCategories,
      includedCategories: includedCategories ?? this.includedCategories,
      isAllCategoriesIncluded: isAllCategoriesIncluded ?? this.isAllCategoriesIncluded,
      excludedCategories: excludedCategories ?? this.excludedCategories,
      isAccountsLoading: isAccountsLoading ?? this.isAccountsLoading,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
    );
  }

  bool get shouldShowAccountsSelector => trackingType.isAutomatic;
  bool get shouldReduceIncludeCategoriesOpacity => excludedCategories.isNotEmpty;

  @override
  List<Object?> get props => [
    trackingType,
    availableAccounts,
    selectedAccounts,
    isAllAccountsSelected,
    availableCategories,
    includedCategories,
    isAllCategoriesIncluded,
    excludedCategories,
    isAccountsLoading,
    isCategoriesLoading,
  ];
}
