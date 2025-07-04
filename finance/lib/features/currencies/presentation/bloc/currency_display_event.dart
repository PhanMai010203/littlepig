part of 'currency_display_bloc.dart';

@freezed
class CurrencyDisplayEvent with _$CurrencyDisplayEvent {
  /// Event triggered when user selects a different account, changing display currency
  const factory CurrencyDisplayEvent.accountCurrencyChanged({
    required String accountCurrency,
    required String accountId,
  }) = _AccountCurrencyChanged;

  /// Event triggered when user manually changes display currency
  const factory CurrencyDisplayEvent.displayCurrencyChanged({
    required String displayCurrency,
  }) = _DisplayCurrencyChanged;

  /// Event to refresh exchange rates for current display currency
  const factory CurrencyDisplayEvent.refreshExchangeRates() = _RefreshExchangeRates;

  /// Event to initialize display currency (typically on app start)
  const factory CurrencyDisplayEvent.initialize({
    String? initialCurrency,
  }) = _Initialize;
}
