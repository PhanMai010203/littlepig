import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../models/exchange_rate_model.dart';

/// Data source for fetching exchange rates from remote API
abstract class ExchangeRateRemoteDataSource {
  Future<Map<String, ExchangeRateModel>> getExchangeRates();
  Future<ExchangeRateModel?> getExchangeRate(
      String fromCurrency, String toCurrency);
}

@LazySingleton(as: ExchangeRateRemoteDataSource)
class ExchangeRateRemoteDataSourceImpl implements ExchangeRateRemoteDataSource {
  static const String _baseUrl =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1';
  static const String _baseCurrency = 'usd';

  final http.Client _httpClient;

  ExchangeRateRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Map<String, ExchangeRateModel>> getExchangeRates() async {
    try {
      final url = Uri.parse('$_baseUrl/currencies/$_baseCurrency.min.json');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> rates =
            data[_baseCurrency] as Map<String, dynamic>;

        final Map<String, ExchangeRateModel> exchangeRates = {};

        for (final entry in rates.entries) {
          final targetCurrency = entry.key.toUpperCase();
          final rate = (entry.value as num).toDouble();

          exchangeRates[targetCurrency] = ExchangeRateModel.fromApiResponse(
            baseCurrency: _baseCurrency.toUpperCase(),
            targetCurrency: targetCurrency,
            rate: rate,
          );
        }

        return exchangeRates;
      } else {
        throw ExchangeRateException(
            'Failed to fetch exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ExchangeRateException) rethrow;
      throw ExchangeRateException('Network error: $e');
    }
  }

  @override
  Future<ExchangeRateModel?> getExchangeRate(
      String fromCurrency, String toCurrency) async {
    try {
      final from = fromCurrency.toLowerCase();
      final to = toCurrency.toLowerCase();

      final url = Uri.parse('$_baseUrl/currencies/$from/$to.min.json');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final rate = (data[to] as num).toDouble();

        return ExchangeRateModel.fromApiResponse(
          baseCurrency: fromCurrency.toUpperCase(),
          targetCurrency: toCurrency.toUpperCase(),
          rate: rate,
        );
      } else if (response.statusCode == 404) {
        // Currency pair not found
        return null;
      } else {
        throw ExchangeRateException(
            'Failed to fetch exchange rate: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ExchangeRateException) rethrow;
      throw ExchangeRateException('Network error: $e');
    }
  }
}

/// Exception thrown when exchange rate operations fail
class ExchangeRateException implements Exception {
  final String message;

  const ExchangeRateException(this.message);

  @override
  String toString() => 'ExchangeRateException: $message';
}
