import '../features/currencies/domain/entities/currency.dart';
import '../features/currencies/domain/entities/exchange_rate.dart';
import '../features/currencies/domain/repositories/currency_repository.dart';
import '../features/accounts/domain/repositories/account_repository.dart';
import '../shared/utils/currency_formatter.dart';

/// High-level service for currency operations across the application
class CurrencyService {
  final CurrencyRepository _currencyRepository;
  final AccountRepository _accountRepository;

  CurrencyService(this._currencyRepository, this._accountRepository);

  /// Gets all available currencies
  Future<List<Currency>> getAllCurrencies() async {
    return await _currencyRepository.getAllCurrencies();
  }

  /// Gets popular/commonly used currencies
  Future<List<Currency>> getPopularCurrencies() async {
    return await _currencyRepository.getPopularCurrencies();
  }

  /// Searches currencies by query
  Future<List<Currency>> searchCurrencies(String query) async {
    return await _currencyRepository.searchCurrencies(query);
  }

  /// Gets a currency by its code
  Future<Currency?> getCurrency(String code) async {
    return await _currencyRepository.getCurrencyByCode(code);
  }

  /// Gets all currencies currently used by accounts
  Future<List<Currency>> getAccountCurrencies() async {
    final accounts = await _accountRepository.getAllAccounts();
    final currencyCodes = accounts.map((a) => a.currency).toSet();
    
    final List<Currency> currencies = [];
    for (final code in currencyCodes) {
      final currency = await getCurrency(code);
      if (currency != null) {
        currencies.add(currency);
      }
    }
    
    return currencies;
  }

  /// Converts amount between currencies
  Future<double> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    return await _currencyRepository.convertAmount(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
  }

  /// Formats an amount with currency
  Future<String> formatAmount({
    required double amount,
    required String currencyCode,
    bool showSymbol = true,
    bool showCode = false,
    bool compact = false,
    bool forceSign = false,
  }) async {
    final currency = await getCurrency(currencyCode);
    
    if (currency == null) {
      // Fallback formatting
      String formatted = amount.toStringAsFixed(2);
      if (forceSign && amount > 0) formatted = '+$formatted';
      return showCode ? '$formatted $currencyCode' : formatted;
    }

    return CurrencyFormatter.formatAmount(
      amount: amount,
      currency: currency,
      showSymbol: showSymbol,
      showCode: showCode,
      compact: compact,
      forceSign: forceSign,
    );
  }

  /// Gets exchange rates for all account currencies relative to a base currency
  Future<Map<String, ExchangeRate?>> getAccountExchangeRates({
    String baseCurrency = 'USD',
  }) async {
    final accounts = await _accountRepository.getAllAccounts();
    final currencyCodes = accounts.map((a) => a.currency).toSet();
    
    final Map<String, ExchangeRate?> rates = {};
    for (final code in currencyCodes) {
      rates[code] = await _currencyRepository.getExchangeRate(code, baseCurrency);
    }
    
    return rates;
  }

  /// Gets total balance across all accounts in a specific currency
  Future<double> getTotalBalanceInCurrency(String targetCurrency) async {
    final accounts = await _accountRepository.getAllAccounts();
    double total = 0.0;
    
    for (final account in accounts) {
      final convertedBalance = await convertAmount(
        amount: account.balance,
        fromCurrency: account.currency,
        toCurrency: targetCurrency,
      );
      total += convertedBalance;
    }
    
    return total;
  }

  /// Gets formatted total balance across all accounts
  Future<String> getFormattedTotalBalance({
    String targetCurrency = 'USD',
    bool showSymbol = true,
    bool showCode = false,
    bool compact = false,
  }) async {
    final total = await getTotalBalanceInCurrency(targetCurrency);
    return await formatAmount(
      amount: total,
      currencyCode: targetCurrency,
      showSymbol: showSymbol,
      showCode: showCode,
      compact: compact,
    );
  }

  /// Sets a custom exchange rate
  Future<void> setCustomExchangeRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  }) async {
    await _currencyRepository.setCustomExchangeRate(fromCurrency, toCurrency, rate);
  }

  /// Gets custom exchange rates
  Future<List<ExchangeRate>> getCustomExchangeRates() async {
    return await _currencyRepository.getCustomExchangeRates();
  }

  /// Removes a custom exchange rate
  Future<void> removeCustomExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    await _currencyRepository.removeCustomExchangeRate(fromCurrency, toCurrency);
  }

  /// Refreshes exchange rates from remote source
  Future<bool> refreshExchangeRates() async {
    return await _currencyRepository.refreshExchangeRates();
  }

  /// Gets the last time exchange rates were updated
  Future<DateTime?> getLastExchangeRateUpdate() async {
    return await _currencyRepository.getLastExchangeRateUpdate();
  }

  /// Validates if a currency code is supported
  Future<bool> isCurrencySupported(String currencyCode) async {
    final currency = await getCurrency(currencyCode);
    return currency != null;
  }

  /// Gets exchange rate between two currencies
  Future<ExchangeRate?> getExchangeRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    return await _currencyRepository.getExchangeRate(fromCurrency, toCurrency);
  }

  /// Gets all current exchange rates
  Future<Map<String, ExchangeRate>> getAllExchangeRates() async {
    return await _currencyRepository.getExchangeRates();
  }

  /// Parses a currency amount string and returns the numeric value
  Future<double?> parseAmount(String text, String currencyCode) async {
    final currency = await getCurrency(currencyCode);
    if (currency == null) return null;
    
    return CurrencyFormatter.parseAmount(text, currency);
  }

  /// Gets currency display information (symbol and code)
  Future<String> getCurrencyDisplay({
    required String currencyCode,
    bool showCode = true,
    bool useNativeSymbol = true,
  }) async {
    final currency = await getCurrency(currencyCode);
    if (currency == null) return currencyCode;
    
    return CurrencyFormatter.formatCurrencyDisplay(
      currency: currency,
      showCode: showCode,
      useNativeSymbol: useNativeSymbol,
    );
  }
}
