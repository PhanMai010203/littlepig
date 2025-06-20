import 'package:finance/features/currencies/data/datasources/currency_local_data_source.dart';
import 'package:finance/features/currencies/data/models/currency_model.dart';

class MockCurrencyLocalDataSource implements CurrencyLocalDataSource {
  static final Map<String, CurrencyModel> _mockCurrencies = {
    'USD': const CurrencyModel(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      decimalDigits: 2,
      isKnown: true,
      countryName: 'United States',
      countryCode: 'US',
    ),
    'EUR': const CurrencyModel(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      decimalDigits: 2,
      isKnown: true,
      countryName: 'European Union',
      countryCode: 'EU',
    ),
    'GBP': const CurrencyModel(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      decimalDigits: 2,
      isKnown: true,
      countryName: 'United Kingdom',
      countryCode: 'GB',
    ),
    'VND': const CurrencyModel(
      code: 'VND',
      name: 'Vietnamese Dong',
      symbol: '₫',
      decimalDigits: 0,
      isKnown: true,
      countryName: 'Vietnam',
      countryCode: 'VN',
    ),
  };

  @override
  Future<List<CurrencyModel>> getAllCurrencies() async {
    return _mockCurrencies.values.toList();
  }

  @override
  Future<Map<String, CurrencyModel>> getCurrencyMap() async {
    return Map.from(_mockCurrencies);
  }
}
