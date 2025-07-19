part of 'account_selection_bloc.dart';

@freezed
class AccountSelectionEvent with _$AccountSelectionEvent {
  /// Event to load all available accounts
  const factory AccountSelectionEvent.loadAccounts() = _LoadAccounts;

  /// Event to select a specific account by ID
  const factory AccountSelectionEvent.selectAccount({
    required String accountId,
  }) = _SelectAccount;

  /// Event to select an account by index (for UI convenience)
  const factory AccountSelectionEvent.selectAccountByIndex({
    required int index,
  }) = _SelectAccountByIndex;

  /// Event to initialize with the default account (usually the first or default marked account)
  const factory AccountSelectionEvent.initializeWithDefault() = _InitializeWithDefault;

  /// Event to clear the current selection
  const factory AccountSelectionEvent.clearSelection() = _ClearSelection;

  /// Event to refresh accounts from repository
  const factory AccountSelectionEvent.refreshAccounts() = _RefreshAccounts;
}