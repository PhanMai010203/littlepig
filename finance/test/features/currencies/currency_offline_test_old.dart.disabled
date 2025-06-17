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
      final currencyService = getIt<CurrencyService>();
      
      // This should work even without internet since currencies are stored in assets
      final currencies = await currencyService.getAllCurrencies();
      
      expect(currencies, isNotEmpty);
      expect(currencies.any((c) => c.code == 'USD'), true);
      expect(currencies.any((c) => c.code == 'EUR'), true);
      expect(currencies.any((c) => c.code == 'VND'), true);
      
      print('✅ Successfully loaded ${currencies.length} currencies offline');
    });

    test('should handle exchange rate fallbacks when API fails', () async {
      final currencyRepository = getIt<CurrencyRepository>();
      
      // This should use fallback rates when remote API is unavailable
      final exchangeRates = await currencyRepository.getExchangeRates();
      
      expect(exchangeRates, isNotEmpty);
      expect(exchangeRates['EUR'], isNotNull);
      expect(exchangeRates['GBP'], isNotNull);
      expect(exchangeRates['JPY'], isNotNull);
      
      print('✅ Successfully loaded ${exchangeRates.length} exchange rates with fallback');
    });

    test('should convert currencies using fallback rates', () async {
      final currencyRepository = getIt<CurrencyRepository>();
        // Test conversion using fallback rates
      final convertedAmount = await currencyRepository.convertAmount(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      
      expect(convertedAmount, greaterThan(0));
      expect(convertedAmount, lessThan(100)); // EUR typically worth more than USD
      
      print('✅ Successfully converted \$100 USD = €${convertedAmount.toStringAsFixed(2)} EUR');
    });

    test('should handle custom exchange rates offline', () async {
      final currencyRepository = getIt<CurrencyRepository>();
      
      // Set a custom rate (this should always work offline)
      await currencyRepository.setCustomExchangeRate('USD', 'EUR', 0.90);
      
      // Get the custom rate
      final exchangeRate = await currencyRepository.getExchangeRate('USD', 'EUR');
      
      expect(exchangeRate, isNotNull);
      expect(exchangeRate!.rate, 0.90);
      expect(exchangeRate.isCustom, true);
        // Convert using the custom rate
      final convertedAmount = await currencyRepository.convertAmount(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      expect(convertedAmount, closeTo(90.0, 0.01));
      
      print('✅ Successfully used custom exchange rate: \$100 USD = €90.00 EUR');
    });    test('should format currencies offline', () async {
      final currencyService = getIt<CurrencyService>();
      
      // Currency formatting should work offline since it doesn't need exchange rates
      final usdFormatted = await currencyService.formatAmount(amount: 1234.56, currencyCode: 'USD');
      final eurFormatted = await currencyService.formatAmount(amount: 1234.56, currencyCode: 'EUR');
      final vndFormatted = await currencyService.formatAmount(amount: 25000000, currencyCode: 'VND');
      
      expect(usdFormatted, contains('1,234.56'));
      expect(eurFormatted, contains('1,234.56'));
      expect(vndFormatted, contains('25,000,000'));
      
      print('✅ Successfully formatted currencies offline:');
      print('   USD: $usdFormatted');
      print('   EUR: $eurFormatted');
      print('   VND: $vndFormatted');
    });

    test('should search currencies offline', () async {
      final currencyService = getIt<CurrencyService>();
      
      // Search should work offline since currency data is local
      final dollarCurrencies = await currencyService.searchCurrencies('Dollar');
      final europeanCurrencies = await currencyService.searchCurrencies('Euro');
      
      expect(dollarCurrencies, isNotEmpty);
      expect(europeanCurrencies, isNotEmpty);
      expect(dollarCurrencies.any((c) => c.code == 'USD'), true);
      expect(europeanCurrencies.any((c) => c.code == 'EUR'), true);
      
      print('✅ Successfully searched currencies offline:');
      print('   Found ${dollarCurrencies.length} dollar currencies');
      print('   Found ${europeanCurrencies.length} euro currencies');
    });

    test('should provide popular currencies offline', () async {
      final currencyService = getIt<CurrencyService>();
      
      // Popular currencies should be available offline
      final popularCurrencies = await currencyService.getPopularCurrencies();
      
      expect(popularCurrencies, isNotEmpty);
      expect(popularCurrencies.any((c) => c.code == 'USD'), true);
      expect(popularCurrencies.any((c) => c.code == 'EUR'), true);
      expect(popularCurrencies.any((c) => c.code == 'GBP'), true);
      
      print('✅ Successfully loaded ${popularCurrencies.length} popular currencies offline');
    });

    test('should handle cross-currency conversion with fallback rates', () async {
      final currencyRepository = getIt<CurrencyRepository>();
        // Test EUR to GBP conversion (both non-USD currencies)
      final convertedAmount = await currencyRepository.convertAmount(
        amount: 100.0,
        fromCurrency: 'EUR',
        toCurrency: 'GBP',
      );
      
      expect(convertedAmount, greaterThan(0));
      // This conversion should work via USD as intermediate currency
      
      print('✅ Successfully converted €100 EUR = £${convertedAmount.toStringAsFixed(2)} GBP via USD');
    });
  });
}
