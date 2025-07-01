import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/budget_history_entry.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/services/budget_update_service.dart';
import '../../domain/services/budget_filter_service.dart';
import '../../domain/entities/budget.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import 'budgets_event.dart';
import 'budgets_state.dart';

@injectable
class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  final BudgetRepository _budgetRepository;
  final BudgetUpdateService _budgetUpdateService;
  final BudgetFilterService _budgetFilterService;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription<List<Budget>>? _budgetUpdatesSubscription;
  StreamSubscription<Map<int, double>>? _spentAmountsSubscription;

  BudgetsBloc(
    this._budgetRepository,
    this._budgetUpdateService,
    this._budgetFilterService,
    this._accountRepository,
    this._categoryRepository,
  ) : super(BudgetsInitial()) {
    on<LoadAllBudgets>(_onLoadAllBudgets);
    on<LoadBudgetDetails>(_onLoadBudgetDetails);
    on<CreateBudget>(_onCreateBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<StartRealTimeUpdates>(_onStartRealTimeUpdates);
    on<StopRealTimeUpdates>(_onStopRealTimeUpdates);
    on<BudgetRealTimeUpdateReceived>(_onBudgetRealTimeUpdateReceived);
    on<BudgetSpentAmountUpdateReceived>(_onBudgetSpentAmountUpdateReceived);
    on<AuthenticateForBudgetAccess>(_onAuthenticateForBudgetAccess);
    on<RecalculateAllBudgets>(_onRecalculateAllBudgets);
    on<RecalculateBudget>(_onRecalculateBudget);
    on<ExportBudgetData>(_onExportBudgetData);
    on<ExportMultipleBudgets>(_onExportMultipleBudgets);
    
    // Budget Creation Events
    on<BudgetTrackingTypeChanged>(_onBudgetTrackingTypeChanged);
    on<LoadAccountsForBudget>(_onLoadAccountsForBudget);
    on<LoadCategoriesForBudget>(_onLoadCategoriesForBudget);
    on<BudgetAccountsSelected>(_onBudgetAccountsSelected);
    on<BudgetIncludeCategoriesSelected>(_onBudgetIncludeCategoriesSelected);
    on<BudgetExcludeCategoriesSelected>(_onBudgetExcludeCategoriesSelected);
  }

  double _calculateDailyAllowance(Budget budget, double spentAmount) {
    final remainingAmount = budget.amount - spentAmount;
    if (remainingAmount <= 0) {
      return 0.0;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(budget.endDate.year, budget.endDate.month, budget.endDate.day);

    // If the budget has expired (end date is before today), there's no allowance.
    if (today.isAfter(endDate)) {
      return 0.0;
    }

    // Calculate the number of days left, including today.
    final int daysLeft = endDate.difference(today).inDays + 1;

    // This should not happen with the check above, but as a safeguard:
    if (daysLeft <= 0) {
      return 0.0;
    }

    return remainingAmount / daysLeft;
  }

  Future<void> _onLoadAllBudgets(
      LoadAllBudgets event, Emitter<BudgetsState> emit) async {
    emit(BudgetsLoading());
    try {
      final budgets = await _budgetRepository.getAllBudgets();
      final spentAmounts = <int, double>{};
      final dailyAllowances = <int, double>{};

      for (var budget in budgets) {
        final spent =
            await _budgetFilterService.calculateBudgetSpent(budget);
        spentAmounts[budget.id!] = spent;
        dailyAllowances[budget.id!] =
            _calculateDailyAllowance(budget, spent);
      }

      emit(BudgetsLoaded(
        budgets: budgets,
        realTimeSpentAmounts: spentAmounts,
        dailySpendingAllowances: dailyAllowances,
      ));
      
      add(StartRealTimeUpdates());
    } catch (e) {
      emit(BudgetsError('Failed to load budgets: $e'));
    }
  }

  Future<void> _onLoadBudgetDetails(
      LoadBudgetDetails event, Emitter<BudgetsState> emit) async {
    emit(BudgetDetailsLoading());
    try {
      final budget = await _budgetRepository.getBudgetById(event.budgetId);
      if (budget == null) {
        throw Exception('Budget not found');
      }

      final spentAmount =
          await _budgetFilterService.calculateBudgetSpent(budget);
      final dailyAllowance =
          _calculateDailyAllowance(budget, spentAmount);

      // TODO: Implement budget history calculation in BudgetFilterService
      // This will provide data for the "History" tab showing past period performance
      // Expected method: _budgetFilterService.getBudgetHistory(event.budgetId)
      // 
      // IMPLEMENTATION NEEDED:
      // - For automatic budgets: Calculate historical periods based on budget.period
      // - For manual budgets: Calculate based on manually-linked transaction dates  
      // - Return List<BudgetHistoryEntry> with periodName, totalSpent, totalBudgeted
      // 
      // Example usage after implementation:
      // final history = await _budgetFilterService.getBudgetHistory(budget);
      final history = <BudgetHistoryEntry>[]; // Placeholder until service is updated

      emit(BudgetDetailsLoaded(
        budget: budget,
        history: history,
        dailySpendingAllowance: dailyAllowance,
      ));
    } catch (e) {
      emit(BudgetDetailsError('Failed to load budget details: $e'));
    }
  }

  Future<void> _onCreateBudget(
      CreateBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetRepository.createBudget(event.budget);

      // Ensure the real-time update stream is immediately aware of the newly
      // created budget. Otherwise, the first emission from
      // BudgetUpdateService after we subscribe in [_onStartRealTimeUpdates]
      // could contain an outdated list that would overwrite our freshly
      // loaded state and make the new budget disappear from the UI.
      //
      // Re-calculating all budget spent amounts will also push an updated
      // budget list through the service's internal stream, keeping the BLoC
      // in sync without waiting for an external transaction event.
      await _budgetUpdateService.recalculateAllBudgetSpentAmounts();

      add(LoadAllBudgets());
    } catch (e) {
      emit(BudgetsError('Failed to create budget: $e'));
    }
  }

  Future<void> _onUpdateBudget(
      UpdateBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetRepository.updateBudget(event.budget);
      add(LoadAllBudgets());
    } catch (e) {
      emit(BudgetsError('Failed to update budget: $e'));
    }
  }

  Future<void> _onDeleteBudget(
      DeleteBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetRepository.deleteBudget(event.budgetId);
      add(LoadAllBudgets());
    } catch (e) {
      emit(BudgetsError('Failed to delete budget: $e'));
    }
  }

  Future<void> _onStartRealTimeUpdates(
      StartRealTimeUpdates event, Emitter<BudgetsState> emit) async {
    if (state is! BudgetsLoaded) return;
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;

      await _budgetUpdatesSubscription?.cancel();
      await _spentAmountsSubscription?.cancel();

      _budgetUpdatesSubscription =
          _budgetUpdateService.watchAllBudgetUpdates().listen(
                (budgets) => add(BudgetRealTimeUpdateReceived(budgets)),
              );

      _spentAmountsSubscription =
          _budgetUpdateService.watchBudgetSpentAmounts().listen(
                (spentAmounts) =>
                    add(BudgetSpentAmountUpdateReceived(spentAmounts)),
              );

      emit(currentState.copyWith(isRealTimeActive: true));
    }
  }

  Future<void> _onStopRealTimeUpdates(
      StopRealTimeUpdates event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;

      await _budgetUpdatesSubscription?.cancel();
      await _spentAmountsSubscription?.cancel();

      emit(currentState.copyWith(isRealTimeActive: false));
    }
  }

  void _onBudgetRealTimeUpdateReceived(
      BudgetRealTimeUpdateReceived event, Emitter<BudgetsState> emit) {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(budgets: event.budgets));
    }
  }

  void _onBudgetSpentAmountUpdateReceived(
      BudgetSpentAmountUpdateReceived event, Emitter<BudgetsState> emit) {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;

      final newAllowances = <int, double>{};
      for (var budget in currentState.budgets) {
        final spentAmount = event.spentAmounts[budget.id!] ??
            currentState.realTimeSpentAmounts[budget.id!] ??
            0;
        newAllowances[budget.id!] =
            _calculateDailyAllowance(budget, spentAmount);
      }

      emit(currentState.copyWith(
        realTimeSpentAmounts: event.spentAmounts,
        dailySpendingAllowances: newAllowances,
      ));
    }
  }

  Future<void> _onAuthenticateForBudgetAccess(
      AuthenticateForBudgetAccess event, Emitter<BudgetsState> emit) async {
    try {
      final isAuthenticated =
          await _budgetUpdateService.authenticateForBudgetAccess();

      if (isAuthenticated) {
        if (state is BudgetsLoaded) {
          final currentState = state as BudgetsLoaded;
          final updatedAuth =
              Map<int, bool>.from(currentState.authenticatedBudgets);
          updatedAuth[event.budgetId] = true;
          emit(currentState.copyWith(authenticatedBudgets: updatedAuth));
        }
        emit(BudgetAuthenticationSuccess(event.budgetId));
      } else {
        emit(BudgetAuthenticationFailed(
            event.budgetId, 'Authentication failed'));
      }
    } catch (e) {
      emit(BudgetAuthenticationFailed(
          event.budgetId, 'Authentication error: $e'));
    }
  }

  Future<void> _onRecalculateAllBudgets(
      RecalculateAllBudgets event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetUpdateService.recalculateAllBudgetSpentAmounts();
      add(LoadAllBudgets());
    } catch (e) {
      emit(BudgetsError('Failed to recalculate budgets: $e'));
    }
  }

  Future<void> _onRecalculateBudget(
      RecalculateBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetUpdateService.recalculateBudgetSpentAmount(event.budgetId);
    } catch (e) {
      emit(BudgetsError('Failed to recalculate budget: $e'));
    }
  }

  Future<void> _onExportBudgetData(
      ExportBudgetData event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(
          isExporting: true, exportStatus: 'Exporting budget data...'));

      try {
        await _budgetFilterService.exportMultipleBudgets([event.budget]);
        emit(currentState.copyWith(
            isExporting: false, exportStatus: 'Export completed successfully'));
      } catch (e) {
        emit(currentState.copyWith(
            isExporting: false, exportStatus: 'Export failed: $e'));
      }
    }
  }

  Future<void> _onExportMultipleBudgets(
      ExportMultipleBudgets event, Emitter<BudgetsState> emit) async {
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;
      emit(currentState.copyWith(
          isExporting: true,
          exportStatus: 'Exporting ${event.budgets.length} budgets...'));

      try {
        await _budgetFilterService.exportMultipleBudgets(event.budgets);
        emit(currentState.copyWith(
            isExporting: false, exportStatus: 'Export completed successfully'));
      } catch (e) {
        emit(currentState.copyWith(
            isExporting: false, exportStatus: 'Export failed: $e'));
      }
    }
  }

  // Budget Creation Event Handlers
  void _onBudgetTrackingTypeChanged(
      BudgetTrackingTypeChanged event, Emitter<BudgetsState> emit) {
    if (state is BudgetCreationState) {
      final currentState = state as BudgetCreationState;
      emit(currentState.copyWith(trackingType: event.trackingType));
    } else {
      emit(BudgetCreationState(trackingType: event.trackingType));
    }
  }

  Future<void> _onLoadAccountsForBudget(
      LoadAccountsForBudget event, Emitter<BudgetsState> emit) async {
    BudgetCreationState currentState;
    if (state is BudgetCreationState) {
      currentState = state as BudgetCreationState;
    } else {
      currentState = const BudgetCreationState();
    }

    emit(currentState.copyWith(isAccountsLoading: true));

    try {
      final accounts = await _accountRepository.getAllAccounts();
      emit(currentState.copyWith(
        availableAccounts: accounts,
        isAccountsLoading: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isAccountsLoading: false));
    }
  }

  Future<void> _onLoadCategoriesForBudget(
      LoadCategoriesForBudget event, Emitter<BudgetsState> emit) async {
    BudgetCreationState currentState;
    if (state is BudgetCreationState) {
      currentState = state as BudgetCreationState;
    } else {
      currentState = const BudgetCreationState();
    }

    emit(currentState.copyWith(isCategoriesLoading: true));

    try {
      final categories = await _categoryRepository.getExpenseCategories();
      emit(currentState.copyWith(
        availableCategories: categories,
        isCategoriesLoading: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isCategoriesLoading: false));
    }
  }

  void _onBudgetAccountsSelected(
      BudgetAccountsSelected event, Emitter<BudgetsState> emit) {
    if (state is BudgetCreationState) {
      final currentState = state as BudgetCreationState;
      emit(currentState.copyWith(
        selectedAccounts: event.selectedAccounts,
        isAllAccountsSelected: event.isAllSelected,
      ));
    }
  }

  void _onBudgetIncludeCategoriesSelected(
      BudgetIncludeCategoriesSelected event, Emitter<BudgetsState> emit) {
    if (state is BudgetCreationState) {
      final currentState = state as BudgetCreationState;
      emit(currentState.copyWith(
        includedCategories: event.selectedCategories,
        isAllCategoriesIncluded: event.isAllSelected,
      ));
    }
  }

  void _onBudgetExcludeCategoriesSelected(
      BudgetExcludeCategoriesSelected event, Emitter<BudgetsState> emit) {
    if (state is BudgetCreationState) {
      final currentState = state as BudgetCreationState;
      emit(currentState.copyWith(
        excludedCategories: event.selectedCategories,
      ));
    }
  }

  @override
  Future<void> close() {
    _budgetUpdatesSubscription?.cancel();
    _spentAmountsSubscription?.cancel();
    _budgetUpdateService.dispose();
    return super.close();
  }
}
