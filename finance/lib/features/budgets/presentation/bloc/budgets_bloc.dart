import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/budget_repository.dart';
import '../../domain/services/budget_update_service.dart';
import '../../domain/services/budget_filter_service.dart';
import '../../domain/entities/budget.dart';
import 'budgets_event.dart';
import 'budgets_state.dart';

class BudgetsBloc extends Bloc<BudgetsEvent, BudgetsState> {
  final BudgetRepository _budgetRepository;
  final BudgetUpdateService _budgetUpdateService;
  final BudgetFilterService _budgetFilterService;

  StreamSubscription<List<Budget>>? _budgetUpdatesSubscription;
  StreamSubscription<Map<int, double>>? _spentAmountsSubscription;

  BudgetsBloc(
    this._budgetRepository,
    this._budgetUpdateService,
    this._budgetFilterService,
  ) : super(BudgetsInitial()) {
    on<LoadAllBudgets>(_onLoadAllBudgets);
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
  }

  Future<void> _onLoadAllBudgets(
      LoadAllBudgets event, Emitter<BudgetsState> emit) async {
    emit(BudgetsLoading());
    try {
      final budgets = await _budgetRepository.getAllBudgets();
      emit(BudgetsLoaded(budgets: budgets));
    } catch (e) {
      emit(BudgetsError('Failed to load budgets: $e'));
    }
  }

  Future<void> _onCreateBudget(
      CreateBudget event, Emitter<BudgetsState> emit) async {
    try {
      await _budgetRepository.createBudget(event.budget);
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
    if (state is BudgetsLoaded) {
      final currentState = state as BudgetsLoaded;

      // Cancel existing subscriptions
      await _budgetUpdatesSubscription?.cancel();
      await _spentAmountsSubscription?.cancel();

      // Subscribe to real-time updates
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

      // Cancel subscriptions
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
      emit(currentState.copyWith(realTimeSpentAmounts: event.spentAmounts));
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
        await _budgetFilterService.exportBudgetData(event.budget, '');
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

  @override
  Future<void> close() {
    _budgetUpdatesSubscription?.cancel();
    _spentAmountsSubscription?.cancel();
    _budgetUpdateService.dispose();
    return super.close();
  }
}
