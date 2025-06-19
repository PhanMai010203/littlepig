import '../entities/currency.dart';
import '../entities/exchange_rate.dart';

/// Repository interface for currency data management
abstract class CurrencyRepository {
  /// Gets all available currencies
  Future<List<Currency>> getAllCurrencies();

  /// Gets a specific currency by its code
  Future<Currency?> getCurrencyByCode(String code);

  /// Gets currencies that are commonly used (have complete information)
  Future<List<Currency>> getPopularCurrencies();

  /// Searches currencies by name or code
  Future<List<Currency>> searchCurrencies(String query);

  /// Gets current exchange rates from base currency (usually USD)
  Future<Map<String, ExchangeRate>> getExchangeRates();

  /// Gets exchange rate between two specific currencies
  Future<ExchangeRate?> getExchangeRate(String fromCurrency, String toCurrency);

  /// Sets a custom exchange rate for a currency pair
  Future<void> setCustomExchangeRate(
      String fromCurrency, String toCurrency, double rate);

  /// Removes a custom exchange rate
  Future<void> removeCustomExchangeRate(String fromCurrency, String toCurrency);

  /// Gets all custom exchange rates
  Future<List<ExchangeRate>> getCustomExchangeRates();

  /// Refreshes exchange rates from remote source
  Future<bool> refreshExchangeRates();

  /// Converts amount between currencies
  Future<double> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  });

  /// Gets the last time exchange rates were updated
  Future<DateTime?> getLastExchangeRateUpdate();
}
