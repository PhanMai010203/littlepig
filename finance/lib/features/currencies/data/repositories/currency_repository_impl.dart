import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/currency.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../datasources/currency_local_data_source.dart';
import '../datasources/exchange_rate_remote_data_source.dart';
import '../datasources/exchange_rate_local_data_source.dart';
import '../models/exchange_rate_model.dart';
import '../../../../core/repositories/cacheable_repository_mixin.dart';

/// Enhanced cache durations for better offline support
class CacheStrategy {
  static const Duration exchangeRateFresh =
      Duration(hours: 6); // Consider fresh
  static const Duration exchangeRateStale =
      Duration(days: 7); // Use if no internet
  static const Duration exchangeRateExpiry =
      Duration(days: 30); // Absolute expiry
}

class CurrencyRepositoryImpl with CacheableRepositoryMixin implements CurrencyRepository {
  final CurrencyLocalDataSource _currencyLocalDataSource;
  final ExchangeRateRemoteDataSource _exchangeRateRemoteDataSource;
  final ExchangeRateLocalDataSource _exchangeRateLocalDataSource;

  CurrencyRepositoryImpl(
    this._currencyLocalDataSource,
    this._exchangeRateRemoteDataSource,
    this._exchangeRateLocalDataSource,
  );

  /// Cache for fallback exchange rates
  Map<String, double>? _fallbackRates;

  /// Protected getter for data sources (for testing)
  @protected
  CurrencyLocalDataSource get currencyLocalDataSource =>
      _currencyLocalDataSource;

  @protected
  ExchangeRateRemoteDataSource get exchangeRateRemoteDataSource =>
      _exchangeRateRemoteDataSource;

  @protected
  ExchangeRateLocalDataSource get exchangeRateLocalDataSource =>
      _exchangeRateLocalDataSource;

  /// Loads fallback exchange rates from assets
  Future<Map<String, double>> _loadFallbackRates() async {
    if (_fallbackRates != null) return _fallbackRates!;

    try {
      final jsonString = await rootBundle
          .loadString('assets/data/fallback_exchange_rates.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final Map<String, dynamic> rates = data['rates'] as Map<String, dynamic>;

      _fallbackRates =
          rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
      return _fallbackRates!;
    } catch (e) {
      print('Failed to load fallback rates: $e');
      return {};
    }
  }

  @override
  Future<List<Currency>> getAllCurrencies() async {
    return cacheRead('getAllCurrencies', () async {
      final currencies = await _currencyLocalDataSource.getAllCurrencies();
      return currencies.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Currency?> getCurrencyByCode(String code) async {
    return cacheReadSingle('getCurrencyByCode', () async {
      final currencyMap = await _currencyLocalDataSource.getCurrencyMap();
      final model = currencyMap[code.toUpperCase()];
      return model?.toEntity();
    }, params: {'code': code});
  }

  @override
  Future<List<Currency>> getPopularCurrencies() async {
    return cacheRead('getPopularCurrencies', () async {
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
    });
  }

  @override
  Future<List<Currency>> searchCurrencies(String query) async {
    return cacheRead('searchCurrencies', () async {
      final currencies = await getAllCurrencies();
      final lowercaseQuery = query.toLowerCase();

      return currencies.where((currency) {
        return currency.code.toLowerCase().contains(lowercaseQuery) ||
            currency.name.toLowerCase().contains(lowercaseQuery) ||
            (currency.countryName?.toLowerCase().contains(lowercaseQuery) ??
                false);
      }).toList();
    }, params: {'query': query});
  }

  @override
  Future<Map<String, ExchangeRate>> getExchangeRates() async {
    // First try to get cached rates
    final cachedRates =
        await _exchangeRateLocalDataSource.getCachedExchangeRates();
    final lastUpdate = await _exchangeRateLocalDataSource.getLastUpdateTime();

    // Check if cached rates are fresh (less than 6 hours old)
    final isCacheFresh = lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < CacheStrategy.exchangeRateFresh;

    // If cache is fresh, use it
    if (cachedRates.isNotEmpty && isCacheFresh) {
      return cachedRates.map((key, value) => MapEntry(key, value.toEntity()));
    }

    // Try to fetch fresh data from remote
    try {
      final remoteRates =
          await _exchangeRateRemoteDataSource.getExchangeRates();

      // Cache the fresh rates
      await _exchangeRateLocalDataSource.cacheExchangeRates(remoteRates);

      return remoteRates.map((key, value) => MapEntry(key, value.toEntity()));
    } catch (e) {
      print('Failed to fetch remote exchange rates: $e');

      // Check if cached rates are still usable (less than 7 days old)
      final isCacheUsable = lastUpdate != null &&
          DateTime.now().difference(lastUpdate) <
              CacheStrategy.exchangeRateStale;

      if (cachedRates.isNotEmpty && isCacheUsable) {
        print('Using stale cached rates (offline mode)');
        return cachedRates.map((key, value) => MapEntry(key, value.toEntity()));
      }

      // Last resort: use fallback rates
      print('Using fallback exchange rates');
      return await _getFallbackExchangeRates();
    }
  }

  /// Gets fallback exchange rates from assets
  Future<Map<String, ExchangeRate>> _getFallbackExchangeRates() async {
    final fallbackRates = await _loadFallbackRates();
    final Map<String, ExchangeRate> rates = {};

    for (final entry in fallbackRates.entries) {
      rates[entry.key] = ExchangeRate.withCurrentTime(
        fromCurrency: 'USD',
        toCurrency: entry.key,
        rate: entry.value,
        isCustom: false,
      );
    }

    return rates;
  }

  @override
  Future<ExchangeRate?> getExchangeRate(
      String fromCurrency, String toCurrency) async {
    final from = fromCurrency.toUpperCase();
    final to = toCurrency.toUpperCase();

    if (from == to) {
      return ExchangeRate.withCurrentTime(
        fromCurrency: from,
        toCurrency: to,
        rate: 1.0,
      );
    } // Check for custom rates first
    final customRates = await getCustomExchangeRates();
    final matchingRates = customRates.where(
      (rate) => rate.fromCurrency == from && rate.toCurrency == to,
    );

    if (matchingRates.isNotEmpty) {
      return matchingRates.first;
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
  Future<void> setCustomExchangeRate(
      String fromCurrency, String toCurrency, double rate) async {
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
  Future<void> removeCustomExchangeRate(
      String fromCurrency, String toCurrency) async {
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
      final remoteRates =
          await _exchangeRateRemoteDataSource.getExchangeRates();
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
      throw Exception(
          'Exchange rate not available for $fromCurrency to $toCurrency');
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
      'USD',
      'EUR',
      'GBP',
      'JPY',
      'AUD',
      'CAD',
      'CHF',
      'CNY',
      'SEK',
      'NZD',
      'MXN',
      'SGD',
      'HKD',
      'NOK',
      'KRW',
      'TRY',
      'RUB',
      'INR',
      'BRL',
      'ZAR',
      'PLN',
      'THB',
      'IDR',
      'HUF',
      'CZK',
      'ILS',
      'CLP',
      'PHP',
      'AED',
      'COP',
      'SAR',
      'MYR',
      'RON',
      'VND',
      'EGP',
      'BGN',
      'HRK',
      'DKK',
      'NGN',
      'PKR',
    };

    return popularCurrencies.contains(code.toUpperCase());
  }
}
