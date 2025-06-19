import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exchange_rate_model.dart';

/// Data source for persisting exchange rates locally
abstract class ExchangeRateLocalDataSource {
  Future<Map<String, ExchangeRateModel>> getCachedExchangeRates();
  Future<void> cacheExchangeRates(Map<String, ExchangeRateModel> rates);
  Future<List<ExchangeRateModel>> getCustomExchangeRates();
  Future<void> saveCustomExchangeRate(ExchangeRateModel rate);
  Future<void> removeCustomExchangeRate(String fromCurrency, String toCurrency);
  Future<DateTime?> getLastUpdateTime();
  Future<void> setLastUpdateTime(DateTime time);
  Future<void> clearCache();
}

class ExchangeRateLocalDataSourceImpl implements ExchangeRateLocalDataSource {
  static const String _exchangeRatesKey = 'cached_exchange_rates';
  static const String _customRatesKey = 'custom_exchange_rates';
  static const String _lastUpdateKey = 'exchange_rates_last_update';

  @override
  Future<Map<String, ExchangeRateModel>> getCachedExchangeRates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_exchangeRatesKey);

    if (jsonString == null) return {};

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final Map<String, ExchangeRateModel> rates = {};

      for (final entry in json.entries) {
        rates[entry.key] = ExchangeRateModel.fromJson(entry.value);
      }

      return rates;
    } catch (e) {
      print('Error loading cached exchange rates: $e');
      return {};
    }
  }

  @override
  Future<void> cacheExchangeRates(Map<String, ExchangeRateModel> rates) async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> json = {};
    for (final entry in rates.entries) {
      json[entry.key] = entry.value.toJson();
    }

    await prefs.setString(_exchangeRatesKey, jsonEncode(json));
    await setLastUpdateTime(DateTime.now());
  }

  @override
  Future<List<ExchangeRateModel>> getCustomExchangeRates() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_customRatesKey);

    if (jsonString == null) return [];

    try {
      final List<dynamic> json = jsonDecode(jsonString);
      return json.map((item) => ExchangeRateModel.fromJson(item)).toList();
    } catch (e) {
      print('Error loading custom exchange rates: $e');
      return [];
    }
  }

  @override
  Future<void> saveCustomExchangeRate(ExchangeRateModel rate) async {
    final customRates = await getCustomExchangeRates();

    // Remove existing rate for the same currency pair
    customRates.removeWhere((r) =>
        r.fromCurrency == rate.fromCurrency && r.toCurrency == rate.toCurrency);

    // Add the new rate
    customRates.add(rate);

    final prefs = await SharedPreferences.getInstance();
    final json = customRates.map((r) => r.toJson()).toList();
    await prefs.setString(_customRatesKey, jsonEncode(json));
  }

  @override
  Future<void> removeCustomExchangeRate(
      String fromCurrency, String toCurrency) async {
    final customRates = await getCustomExchangeRates();
    customRates.removeWhere((rate) =>
        rate.fromCurrency == fromCurrency && rate.toCurrency == toCurrency);

    final prefs = await SharedPreferences.getInstance();
    final json = customRates.map((r) => r.toJson()).toList();
    await prefs.setString(_customRatesKey, jsonEncode(json));
  }

  @override
  Future<DateTime?> getLastUpdateTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timeString = prefs.getString(_lastUpdateKey);

    if (timeString == null) return null;

    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setLastUpdateTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUpdateKey, time.toIso8601String());
  }

  @override
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_exchangeRatesKey);
    await prefs.remove(_lastUpdateKey);
  }
}
