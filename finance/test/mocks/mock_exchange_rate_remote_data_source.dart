import 'package:finance/features/currencies/data/datasources/exchange_rate_remote_data_source.dart';
import 'package:finance/features/currencies/data/models/exchange_rate_model.dart';

class MockExchangeRateRemoteDataSource implements ExchangeRateRemoteDataSource {
  final bool shouldThrowError;

  MockExchangeRateRemoteDataSource({this.shouldThrowError = true});

  @override
  Future<Map<String, ExchangeRateModel>> getExchangeRates() async {
    if (shouldThrowError) {
      throw Exception('Mock network error for testing offline behavior');
    }

    // Return mock exchange rates
    return {
      'EUR': ExchangeRateModel(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        rate: 0.8672203,
        lastUpdated: DateTime.now(),
      ),
      'GBP': ExchangeRateModel(
        fromCurrency: 'USD',
        toCurrency: 'GBP',
        rate: 0.7382192,
        lastUpdated: DateTime.now(),
      ),
    };
  }

  @override
  Future<ExchangeRateModel?> getExchangeRate(
      String fromCurrency, String toCurrency) async {
    if (shouldThrowError) {
      throw Exception('Mock network error for testing offline behavior');
    }

    // Return mock exchange rate for specific pair
    if (fromCurrency == 'USD' && toCurrency == 'EUR') {
      return ExchangeRateModel(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        rate: 0.8672203,
        lastUpdated: DateTime.now(),
      );
    } else if (fromCurrency == 'USD' && toCurrency == 'GBP') {
      return ExchangeRateModel(
        fromCurrency: 'USD',
        toCurrency: 'GBP',
        rate: 0.7382192,
        lastUpdated: DateTime.now(),
      );
    }

    return null;
  }
}
