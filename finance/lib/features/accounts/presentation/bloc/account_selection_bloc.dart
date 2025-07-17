import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../../../currencies/presentation/bloc/currency_display_bloc.dart';

part 'account_selection_event.dart';
part 'account_selection_state.dart';
part 'account_selection_bloc.freezed.dart';

/// BLoC for managing global account selection state
/// 
/// This manages which account is currently selected across the app
/// and automatically triggers currency display updates when account changes.
@injectable
class AccountSelectionBloc extends Bloc<AccountSelectionEvent, AccountSelectionState> {
  final AccountRepository _accountRepository;
  final CurrencyDisplayBloc _currencyDisplayBloc;

  AccountSelectionBloc(
    this._accountRepository,
    this._currencyDisplayBloc,
  ) : super(AccountSelectionStateX.initial) {
    on<_LoadAccounts>(_onLoadAccounts);
    on<_SelectAccount>(_onSelectAccount);
    on<_SelectAccountByIndex>(_onSelectAccountByIndex);
    on<_InitializeWithDefault>(_onInitializeWithDefault);
    on<_ClearSelection>(_onClearSelection);
    on<_RefreshAccounts>(_onRefreshAccounts);
  }

  /// Handle loading all available accounts
  Future<void> _onLoadAccounts(
    _LoadAccounts event,
    Emitter<AccountSelectionState> emit,
  ) async {
    print('DEBUG: _onLoadAccounts called');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final accounts = await _accountRepository.getAllAccounts();
      print('DEBUG: Loaded ${accounts.length} accounts');
      emit(state.copyWith(
        isLoading: false,
        availableAccounts: accounts,
        errorMessage: null,
      ));
    } catch (e) {
      print('DEBUG: Error loading accounts: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load accounts: ${e.toString()}',
      ));
    }
  }

  /// Handle selecting account by ID
  Future<void> _onSelectAccount(
    _SelectAccount event,
    Emitter<AccountSelectionState> emit,
  ) async {
    print('DEBUG: _onSelectAccount called with accountId: ${event.accountId}');
    final index = state.findAccountIndex(event.accountId);
    print('DEBUG: Found index: $index for accountId: ${event.accountId}');
    if (index >= 0) {
      final account = state.availableAccounts[index];
      print('DEBUG: Found account: ${account.name} at index: $index');
      await _updateSelection(account, index, emit);
    } else {
      print('DEBUG: No account found for accountId: ${event.accountId}');
    }
  }

  /// Handle selecting account by index
  Future<void> _onSelectAccountByIndex(
    _SelectAccountByIndex event,
    Emitter<AccountSelectionState> emit,
  ) async {
    print('DEBUG: _onSelectAccountByIndex called with index: ${event.index}');
    print('DEBUG: Available accounts count: ${state.availableAccounts.length}');
    
    final account = state.getAccountByIndex(event.index);
    if (account != null) {
      print('DEBUG: Found account: ${account.name} (ID: ${account.id})');
      await _updateSelection(account, event.index, emit);
    } else {
      print('DEBUG: No account found at index: ${event.index}');
    }
  }

  /// Handle initialization with default account
  Future<void> _onInitializeWithDefault(
    _InitializeWithDefault event,
    Emitter<AccountSelectionState> emit,
  ) async {
    print('DEBUG: _onInitializeWithDefault called, accounts count: ${state.availableAccounts.length}');
    if (state.availableAccounts.isNotEmpty) {
      // Try to find the default account first
      int defaultIndex = state.availableAccounts.indexWhere((account) => account.isDefault);
      
      // If no default account found, use the first one
      if (defaultIndex == -1) {
        defaultIndex = 0;
      }

      print('DEBUG: Selecting default account at index: $defaultIndex');
      final defaultAccount = state.availableAccounts[defaultIndex];
      await _updateSelection(defaultAccount, defaultIndex, emit);
    } else {
      print('DEBUG: No accounts available for default selection');
    }
  }

  /// Handle clearing selection
  Future<void> _onClearSelection(
    _ClearSelection event,
    Emitter<AccountSelectionState> emit,
  ) async {
    emit(state.copyWith(
      selectedAccount: null,
      selectedIndex: -1,
    ));
  }

  /// Handle refreshing accounts
  Future<void> _onRefreshAccounts(
    _RefreshAccounts event,
    Emitter<AccountSelectionState> emit,
  ) async {
    // Reload accounts and maintain selection if possible
    await _onLoadAccounts(const _LoadAccounts(), emit);
    
    // Try to restore the previous selection if it still exists
    if (state.selectedAccount != null) {
      final currentAccountId = state.selectedAccount!.id?.toString();
      if (currentAccountId != null) {
        final newIndex = state.findAccountIndex(currentAccountId);
        if (newIndex >= 0) {
          final account = state.availableAccounts[newIndex];
          emit(state.copyWith(
            selectedAccount: account,
            selectedIndex: newIndex,
          ));
        } else {
          // Account no longer exists, clear selection
          emit(state.copyWith(
            selectedAccount: null,
            selectedIndex: -1,
          ));
        }
      }
    }
  }

  /// Core method to update account selection and trigger currency display update
  Future<void> _updateSelection(
    Account account,
    int index,
    Emitter<AccountSelectionState> emit,
  ) async {
    print('DEBUG: _updateSelection called for account: ${account.name} at index: $index');
    
    // Update local state
    emit(state.copyWith(
      selectedAccount: account,
      selectedIndex: index,
    ));

    print('DEBUG: State updated, selected index: ${state.selectedIndex}');

    // Trigger currency display update
    _currencyDisplayBloc.add(
      CurrencyDisplayEvent.accountCurrencyChanged(
        accountCurrency: account.currency,
        accountId: account.id?.toString() ?? '',
      ),
    );
    
    print('DEBUG: Currency display event dispatched for currency: ${account.currency}');
  }

  /// Initialize the bloc with account loading and default selection
  Future<void> initialize() async {
    print('DEBUG: initialize() called');
    add(const AccountSelectionEvent.loadAccounts());
    
    // Wait a bit for accounts to load, then select default
    await Future.delayed(const Duration(milliseconds: 100));
    add(const AccountSelectionEvent.initializeWithDefault());
  }
}