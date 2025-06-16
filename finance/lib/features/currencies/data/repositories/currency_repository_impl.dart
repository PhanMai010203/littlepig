import '../../domain/entities/currency.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_local_data_source.dart';
import '../datasources/exchange_rate_remote_data_source.dart';
import '../datasources/exchange_rate_local_data_source.dart';
import '../models/exchange_rate_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyLocalDataSource _currencyLocalDataSource;
  final ExchangeRateRemoteDataSource _exchangeRateRemoteDataSource;
  final ExchangeRateLocalDataSource _exchangeRateLocalDataSource;

  CurrencyRepositoryImpl(
    this._currencyLocalDataSource,
    this._exchangeRateRemoteDataSource,
    this._exchangeRateLocalDataSource,
  );

  @override
  Future<List<Currency>> getAllCurrencies() async {
    final currencies = await _currencyLocalDataSource.getAllCurrencies();
    return currencies.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Currency?> getCurrencyByCode(String code) async {
    final currencyMap = await _currencyLocalDataSource.getCurrencyMap();
    final model = currencyMap[code.toUpperCase()];
    return model?.toEntity();
  }

  @override
  Future<List<Currency>> getPopularCurrencies() async {
    final currencies = await getAllCurrencies();
    
    // Filter for well-known currencies with complete information
    final popular = currencies.where((currency) {
      return currency.isKnown && 
             currency.symbol.isNotEmpty && 
             currency.name.isNotEmpty &&
             _isPopularCurrency(currency.code);
    }).toList();

    // Sort by code for consistent ordering
    popular.sort((a, b) => a.code.compareTo(b.code));
    
    return popular;
  }

  @override
  Future<List<Currency>> searchCurrencies(String query) async {
    final currencies = await getAllCurrencies();
    final lowercaseQuery = query.toLowerCase();
    
    return currencies.where((currency) {
      return currency.code.toLowerCase().contains(lowercaseQuery) ||
             currency.name.toLowerCase().contains(lowercaseQuery) ||
             (currency.countryName?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  @override
  Future<Map<String, ExchangeRate>> getExchangeRates() async {
    // First try to get cached rates
    final cachedRates = await _exchangeRateLocalDataSource.getCachedExchangeRates();
    final lastUpdate = await _exchangeRateLocalDataSource.getLastUpdateTime();
    
    // Check if cached rates are still fresh (less than 1 hour old)
    final isCacheFresh = lastUpdate != null && 
        DateTime.now().difference(lastUpdate).inHours < 1;
    
    if (cachedRates.isNotEmpty && isCacheFresh) {
      return cachedRates.map((key, value) => MapEntry(key, value.toEntity()));
    }
    
    // If cache is stale or empty, try to refresh from remote
    try {
      final remoteRates = await _exchangeRateRemoteDataSource.getExchangeRates();
      
      // Cache the fresh rates
      await _exchangeRateLocalDataSource.cacheExchangeRates(remoteRates);
      
      return remoteRates.map((key, value) => MapEntry(key, value.toEntity()));
    } catch (e) {
      // If remote fails but we have cached data, use it
      if (cachedRates.isNotEmpty) {
        return cachedRates.map((key, value) => MapEntry(key, value.toEntity()));
      }
      rethrow;
    }
  }

  @override
  Future<ExchangeRate?> getExchangeRate(String fromCurrency, String toCurrency) async {
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();
    
    if (from == to) {
      return ExchangeRate.withCurrentTime(
        fromCurrency: from,
        toCurrency: to,
        rate: 1.0,
      );
    }
    
    // Check for custom rates first
    final customRates = await getCustomExchangeRates();
    final customRate = customRates.firstWhere(
      (rate) => rate.fromCurrency == from && rate.toCurrency == to,
      orElse: () => throw StateError('Not found'),
    );
    
    try {
      return customRate;
    } catch (_) {
      // No custom rate found, continue with market rates
    }
    
    // Get market rates via USD as base
    if (from == 'USD') {
      final rates = await getExchangeRates();
      return rates[to];
    } else if (to == 'USD') {
      final rates = await getExchangeRates();
      final rate = rates[from];
      return rate?.inverse;
    } else {
      // Convert via USD: from -> USD -> to
      final rates = await getExchangeRates();
      final fromToUsd = rates[from]?.inverse;
      final usdToTarget = rates[to];
      
      if (fromToUsd != null && usdToTarget != null) {
        final combinedRate = fromToUsd.rate * usdToTarget.rate;
        return ExchangeRate.withCurrentTime(
          fromCurrency: from,
          toCurrency: to,
          rate: combinedRate,
        );
      }
    }
    
    return null;
  }

  @override
  Future<void> setCustomExchangeRate(String fromCurrency, String toCurrency, double rate) async {
    final exchangeRate = ExchangeRateModel(
      fromCurrency: fromCurrency.toUpperCase(),
      toCurrency: toCurrency.toUpperCase(),
      rate: rate,
      lastUpdated: DateTime.now(),
      isCustom: true,
    );
    
    await _exchangeRateLocalDataSource.saveCustomExchangeRate(exchangeRate);
  }

  @override
  Future<void> removeCustomExchangeRate(String fromCurrency, String toCurrency) async {
    await _exchangeRateLocalDataSource.removeCustomExchangeRate(
      fromCurrency.toUpperCase(),
      toCurrency.toUpperCase(),
    );
  }

  @override
  Future<List<ExchangeRate>> getCustomExchangeRates() async {
    final models = await _exchangeRateLocalDataSource.getCustomExchangeRates();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> refreshExchangeRates() async {
    try {
      final remoteRates = await _exchangeRateRemoteDataSource.getExchangeRates();
      await _exchangeRateLocalDataSource.cacheExchangeRates(remoteRates);
      return true;
    } catch (e) {
      print('Failed to refresh exchange rates: $e');
      return false;
    }
  }

  @override
  Future<double> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    final exchangeRate = await getExchangeRate(fromCurrency, toCurrency);
    
    if (exchangeRate == null) {
      throw Exception('Exchange rate not available for $fromCurrency to $toCurrency');
    }
    
    return exchangeRate.convert(amount);
  }

  @override
  Future<DateTime?> getLastExchangeRateUpdate() async {
    return await _exchangeRateLocalDataSource.getLastUpdateTime();
  }

  /// Helper method to determine if a currency is popular/commonly used
  bool _isPopularCurrency(String code) {
    const popularCurrencies = {
      'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD',
      'MXN', 'SGD', 'HKD', 'NOK', 'KRW', 'TRY', 'RUB', 'INR', 'BRL', 'ZAR',
      'PLN', 'THB', 'IDR', 'HUF', 'CZK', 'ILS', 'CLP', 'PHP', 'AED', 'COP',
      'SAR', 'MYR', 'RON', 'VND', 'EGP', 'BGN', 'HRK', 'DKK', 'NGN', 'PKR',
    };
    
    return popularCurrencies.contains(code.toUpperCase());
  }
}
