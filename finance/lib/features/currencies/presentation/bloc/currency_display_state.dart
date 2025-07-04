part of 'currency_display_bloc.dart';

@freezed
class CurrencyDisplayState with _$CurrencyDisplayState {
  const factory CurrencyDisplayState({
    required String displayCurrency,
    required bool isLoading,
    required Map<String, double> conversionRatesCache,
    required DateTime? lastRateUpdate,
    String? selectedAccountId,
    String? errorMessage,
  }) = _CurrencyDisplayState;
}

extension CurrencyDisplayStateX on CurrencyDisplayState {
  static CurrencyDisplayState get initial => const CurrencyDisplayState(
        displayCurrency: 'USD',
        isLoading: false,
        conversionRatesCache: {},
        lastRateUpdate: null,
      );

  /// Check if conversion rates are fresh (less than 1 hour old)
  bool get hasValidRates {
    if (lastRateUpdate == null) return false;
    return DateTime.now().difference(lastRateUpdate!).inHours < 1;
  }

  /// Get conversion rate for a specific currency
  double? getConversionRate(String fromCurrency) {
    if (fromCurrency == displayCurrency) return 1.0;
    return conversionRatesCache[fromCurrency];
  }
}
