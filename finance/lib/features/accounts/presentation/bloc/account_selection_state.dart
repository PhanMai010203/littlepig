part of 'account_selection_bloc.dart';

@freezed
class AccountSelectionState with _$AccountSelectionState {
  const factory AccountSelectionState({
    required List<Account> availableAccounts,
    Account? selectedAccount,
    required int selectedIndex,
    required bool isLoading,
    String? errorMessage,
  }) = _AccountSelectionState;
}

extension AccountSelectionStateX on AccountSelectionState {
  static AccountSelectionState get initial => const AccountSelectionState(
        availableAccounts: [],
        selectedAccount: null,
        selectedIndex: -1,
        isLoading: false,
      );

  /// Check if we have a valid selection
  bool get hasSelection => selectedAccount != null && selectedIndex >= 0;

  /// Get the selected account's currency, fallback to USD
  String get selectedCurrency => selectedAccount?.currency ?? 'USD';

  /// Check if the provided account ID is currently selected
  bool isAccountSelected(String accountId) {
    return selectedAccount?.id?.toString() == accountId;
  }

  /// Get account by index safely
  Account? getAccountByIndex(int index) {
    if (index >= 0 && index < availableAccounts.length) {
      return availableAccounts[index];
    }
    return null;
  }

  /// Find index of account by ID
  int findAccountIndex(String accountId) {
    return availableAccounts.indexWhere(
      (account) => account.id?.toString() == accountId,
    );
  }
}