import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import '../../../test/mocks/test_di_config.dart';
import 'package:finance/services/currency_service.dart';

void main() {
  group('Currency Offline Support Tests', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await configureTestDependencies();
    });

    tearDown(() async {
      await GetIt.instance.reset();
    });

    test('should load currencies completely offline', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // This should work even without internet since currencies are stored in mocks
      final currencies = await currencyService.getAllCurrencies();
      
      expect(currencies, isNotEmpty);
      expect(currencies.any((c) => c.code == 'USD'), true);
      expect(currencies.any((c) => c.code == 'EUR'), true);
      
      print('✅ Successfully loaded ${currencies.length} currencies offline');
    });    test('should handle exchange rate fallbacks when API fails', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // This should fail to get remote rates but succeed with fallbacks
      final exchangeRates = await currencyService.getAllExchangeRates();
      
      expect(exchangeRates, isNotEmpty);
      expect(exchangeRates.containsKey('EUR'), true);
      expect(exchangeRates.containsKey('GBP'), true);
      
      print('✅ Successfully loaded ${exchangeRates.length} exchange rates with fallback');
    });

    test('should convert currencies using fallback rates', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // Should work with fallback rates even when API fails
      final converted = await currencyService.convertAmount(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      
      expect(converted, greaterThan(0));
      expect(converted, lessThan(100)); // EUR should be less than USD in our mock data
      
      print('✅ Successfully converted \$100 USD = €${converted.toStringAsFixed(2)} EUR');
    });

    test('should handle custom exchange rates offline', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // Set a custom exchange rate
      await currencyService.setCustomExchangeRate(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        rate: 0.9,
      );
      
      // Convert using the custom rate
      final converted = await currencyService.convertAmount(
        amount: 100,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      
      expect(converted, equals(90.0));
      
      print('✅ Successfully used custom exchange rate: \$100 USD = €${converted.toStringAsFixed(2)} EUR');
    });

    test('should format currencies offline', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // Currency formatting should work offline since it doesn't need exchange rates
      final usdFormatted = await currencyService.formatAmount(amount: 1234.56, currencyCode: 'USD');
      final eurFormatted = await currencyService.formatAmount(amount: 1234.56, currencyCode: 'EUR');
      
      expect(usdFormatted, isNotEmpty);
      expect(eurFormatted, isNotEmpty);
      
      print('✅ Successfully formatted currencies offline:');
      print('   USD: $usdFormatted');
      print('   EUR: $eurFormatted');
    });

    test('should search currencies offline', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // Search should work offline with cached data
      final searchResults = await currencyService.searchCurrencies('dollar');
      
      expect(searchResults, isNotEmpty);
      expect(searchResults.any((c) => c.code == 'USD'), true);
      
      print('✅ Successfully found ${searchResults.length} currencies matching "dollar"');
    });

    test('should provide popular currencies offline', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // Popular currencies should be available offline
      final popularCurrencies = await currencyService.getPopularCurrencies();
      
      expect(popularCurrencies, isNotEmpty);
      expect(popularCurrencies.any((c) => c.code == 'USD'), true);
      expect(popularCurrencies.any((c) => c.code == 'EUR'), true);
      
      print('✅ Successfully loaded ${popularCurrencies.length} popular currencies offline');
    });

    test('should handle cross-currency conversion with fallback rates', () async {
      final currencyService = GetIt.instance<CurrencyService>();
      
      // Convert EUR to GBP via USD (cross-currency conversion)
      final converted = await currencyService.convertAmount(
        amount: 100,
        fromCurrency: 'EUR',
        toCurrency: 'GBP',
      );
      
      expect(converted, greaterThan(0));
      
      print('✅ Successfully converted €100 EUR = £${converted.toStringAsFixed(2)} GBP via USD');
    });
  });
}
