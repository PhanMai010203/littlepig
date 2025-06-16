import 'package:finance/features/currencies/data/datasources/exchange_rate_local_data_source.dart';
import 'package:finance/features/currencies/data/models/exchange_rate_model.dart';

class MockExchangeRateLocalDataSource implements ExchangeRateLocalDataSource {
  final Map<String, ExchangeRateModel> _cachedRates = {};
  final List<ExchangeRateModel> _customRates = [];
  DateTime? _lastUpdateTime;

  @override
  Future<Map<String, ExchangeRateModel>> getCachedExchangeRates() async {
    // Mock fallback rates for testing
    if (_cachedRates.isEmpty) {
      _cachedRates['EUR'] = ExchangeRateModel(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        rate: 0.8672203,
        lastUpdated: DateTime.now(),
      );
      _cachedRates['GBP'] = ExchangeRateModel(
        fromCurrency: 'USD',
        toCurrency: 'GBP',
        rate: 0.7382192,
        lastUpdated: DateTime.now(),
      );
    }
    return Map.from(_cachedRates);
  }

  @override
  Future<void> cacheExchangeRates(Map<String, ExchangeRateModel> rates) async {
    _cachedRates.clear();
    _cachedRates.addAll(rates);
    _lastUpdateTime = DateTime.now();
  }

  @override
  Future<DateTime?> getLastUpdateTime() async {
    return _lastUpdateTime;
  }

  @override
  Future<void> setLastUpdateTime(DateTime time) async {
    _lastUpdateTime = time;
  }

  @override
  Future<void> clearCache() async {
    _cachedRates.clear();
    _lastUpdateTime = null;
  }

  @override
  Future<void> saveCustomExchangeRate(ExchangeRateModel rate) async {
    // Remove existing custom rate for the same pair
    _customRates.removeWhere((r) => 
        r.fromCurrency == rate.fromCurrency && r.toCurrency == rate.toCurrency);
    _customRates.add(rate);
  }

  @override
  Future<void> removeCustomExchangeRate(String fromCurrency, String toCurrency) async {
    _customRates.removeWhere((r) => 
        r.fromCurrency == fromCurrency && r.toCurrency == toCurrency);
  }

  @override
  Future<List<ExchangeRateModel>> getCustomExchangeRates() async {
    return List.from(_customRates);
  }
}
