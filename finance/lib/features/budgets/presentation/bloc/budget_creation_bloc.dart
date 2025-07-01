import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../domain/entities/budget_enums.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/domain/entities/category.dart';
import 'budgets_event.dart';
import 'budgets_state.dart';

/// Bloc dedicated to the budget creation flow.
///
/// It only exposes the subset of events & states that the creation screen
/// needs, so it does not interfere with [BudgetsBloc] that powers the list
/// screen.
@injectable
class BudgetCreationBloc extends Bloc<BudgetsEvent, BudgetsState> {
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  BudgetCreationBloc(
    this._accountRepository,
    this._categoryRepository,
  ) : super(const BudgetCreationState()) {
    on<BudgetTrackingTypeChanged>(_onTrackingTypeChanged);
    on<LoadAccountsForBudget>(_onLoadAccounts);
    on<LoadCategoriesForBudget>(_onLoadCategories);
    on<BudgetAccountsSelected>(_onAccountsSelected);
    on<BudgetIncludeCategoriesSelected>(_onIncludeCategoriesSelected);
    on<BudgetExcludeCategoriesSelected>(_onExcludeCategoriesSelected);
  }

  // ─────────────────────────── Event handlers ────────────────────────────

  void _onTrackingTypeChanged(
      BudgetTrackingTypeChanged event, Emitter<BudgetsState> emit) {
    if (state is BudgetCreationState) {
      final current = state as BudgetCreationState;
      emit(current.copyWith(trackingType: event.trackingType));
    }
  }

  Future<void> _onLoadAccounts(
      LoadAccountsForBudget event, Emitter<BudgetsState> emit) async {
    final current = state is BudgetCreationState
        ? state as BudgetCreationState
        : const BudgetCreationState();

    emit(current.copyWith(isAccountsLoading: true));

    try {
      final accounts = await _accountRepository.getAllAccounts();
      emit(current.copyWith(
        availableAccounts: accounts,
        isAccountsLoading: false,
      ));
    } catch (_) {
      emit(current.copyWith(isAccountsLoading: false));
    }
  }

  Future<void> _onLoadCategories(
      LoadCategoriesForBudget event, Emitter<BudgetsState> emit) async {
    final current = state is BudgetCreationState
        ? state as BudgetCreationState
        : const BudgetCreationState();

    emit(current.copyWith(isCategoriesLoading: true));

    try {
      final categories = await _categoryRepository.getExpenseCategories();
      emit(current.copyWith(
        availableCategories: categories,
        isCategoriesLoading: false,
      ));
    } catch (_) {
      emit(current.copyWith(isCategoriesLoading: false));
    }
  }

  void _onAccountsSelected(
      BudgetAccountsSelected event, Emitter<BudgetsState> emit) {
    if (state is! BudgetCreationState) return;
    final current = state as BudgetCreationState;
    emit(current.copyWith(
      selectedAccounts: event.selectedAccounts,
      isAllAccountsSelected: event.isAllSelected,
    ));
  }

  void _onIncludeCategoriesSelected(
      BudgetIncludeCategoriesSelected event, Emitter<BudgetsState> emit) {
    if (state is! BudgetCreationState) return;
    final current = state as BudgetCreationState;
    emit(current.copyWith(
      includedCategories: event.selectedCategories,
      isAllCategoriesIncluded: event.isAllSelected,
    ));
  }

  void _onExcludeCategoriesSelected(
      BudgetExcludeCategoriesSelected event, Emitter<BudgetsState> emit) {
    if (state is! BudgetCreationState) return;
    final current = state as BudgetCreationState;
    emit(current.copyWith(excludedCategories: event.selectedCategories));
  }
} 