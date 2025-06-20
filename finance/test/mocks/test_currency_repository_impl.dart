import 'package:finance/features/currencies/domain/entities/exchange_rate.dart';
import 'package:finance/features/currencies/data/datasources/currency_local_data_source.dart';
import 'package:finance/features/currencies/data/datasources/exchange_rate_remote_data_source.dart';
import 'package:finance/features/currencies/data/datasources/exchange_rate_local_data_source.dart';
import 'package:finance/features/currencies/data/repositories/currency_repository_impl.dart';

/// Test-specific repository that provides mock fallback rates
class TestCurrencyRepositoryImpl extends CurrencyRepositoryImpl {
  final Map<String, double> _testFallbackRates = {
    'EUR': 0.8672203,
    'GBP': 0.7382192,
    'JPY': 144.86,
    'CAD': 1.35,
    'AUD': 1.54,
  };

  TestCurrencyRepositoryImpl(
    super.currencyLocalDataSource,
    super.exchangeRateRemoteDataSource,
    super.exchangeRateLocalDataSource,
  );
  @override
  Future<Map<String, ExchangeRate>> getExchangeRates() async {
    // First try to get cached rates
    final cachedRates =
        await exchangeRateLocalDataSource.getCachedExchangeRates();
    final lastUpdate = await exchangeRateLocalDataSource.getLastUpdateTime();

    // Check if cached rates are fresh (less than 6 hours old)
    final isCacheFresh = lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < const Duration(hours: 6);

    // If cache is fresh, use it
    if (cachedRates.isNotEmpty && isCacheFresh) {
      return cachedRates.map((key, value) => MapEntry(key, value.toEntity()));
    }

    // Try to fetch fresh data from remote
    try {
      final remoteRates = await exchangeRateRemoteDataSource.getExchangeRates();

      // Cache the fresh rates
      await exchangeRateLocalDataSource.cacheExchangeRates(remoteRates);

      return remoteRates.map((key, value) => MapEntry(key, value.toEntity()));
    } catch (e) {
      print('Failed to fetch remote exchange rates: $e');

      // Check if cached rates are still usable (less than 7 days old)
      final isCacheUsable = lastUpdate != null &&
          DateTime.now().difference(lastUpdate) < const Duration(days: 7);

      if (cachedRates.isNotEmpty && isCacheUsable) {
        print('Using stale cached rates (offline mode)');
        return cachedRates.map((key, value) => MapEntry(key, value.toEntity()));
      }

      // Last resort: use test fallback rates
      print('Using test fallback exchange rates');
      return _getTestFallbackExchangeRates();
    }
  }

  /// Gets test fallback exchange rates
  Future<Map<String, ExchangeRate>> _getTestFallbackExchangeRates() async {
    final Map<String, ExchangeRate> rates = {};

    for (final entry in _testFallbackRates.entries) {
      rates[entry.key] = ExchangeRate.withCurrentTime(
        fromCurrency: 'USD',
        toCurrency: entry.key,
        rate: entry.value,
        isCustom: false,
      );
    }

    return rates;
  }
}
