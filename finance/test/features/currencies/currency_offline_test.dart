import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/services/currency_service.dart';

void main() {
  setUpAll(() {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock SharedPreferences for testing environment
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{}; // Return empty preferences
      }
      if (methodCall.method == 'setBool' || methodCall.method == 'setString' || 
          methodCall.method == 'setInt' || methodCall.method == 'setDouble' ||
          methodCall.method == 'setStringList') {
        return true; // Return success for set operations
      }
      if (methodCall.method == 'remove' || methodCall.method == 'clear') {
        return true; // Return success for remove operations
      }
      return null;
    });
    
    // Mock path_provider for testing environment
    const MethodChannel pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_documents';
      }
      if (methodCall.method == 'getTemporaryDirectory') {
        return '/tmp/test_temp';
      }
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '/tmp/test_support';
      }
      return null;
    });
    
    // Mock device_info_plus for testing environment  
    const MethodChannel deviceInfoChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(deviceInfoChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAndroidDeviceInfo') {
        return <String, dynamic>{
          'id': 'test-device-id',
          'host': 'test-host',
          'tags': 'test-tags',
          'type': 'test-type',
          'model': 'test-model',
          'board': 'test-board',
          'brand': 'test-brand',
          'device': 'test-device',
          'product': 'test-product',
          'display': 'test-display',
          'hardware': 'test-hardware',
          'bootloader': 'test-bootloader',
          'fingerprint': 'test-fingerprint',
          'manufacturer': 'test-manufacturer',
          'supportedAbis': <String>[],
          'supported32BitAbis': <String>[],
          'supported64BitAbis': <String>[],
          'systemFeatures': <String>[],
          'version': <String, dynamic>{
            'baseOS': '',
            'codename': 'test',
            'incremental': 'test',
            'previewSdkInt': null,
            'release': '11',
            'sdkInt': 30,
            'securityPatch': 'test',
          },
          'isPhysicalDevice': true,
          'serialNumber': 'test-serial',
        };
      }
      return null;
    });
  });

  tearDownAll(() {
    // Clear method channel handlers
    const MethodChannel('plugins.flutter.io/shared_preferences').setMockMethodCallHandler(null);
    const MethodChannel('plugins.flutter.io/path_provider').setMockMethodCallHandler(null);
    const MethodChannel('dev.fluttercommunity.plus/device_info').setMockMethodCallHandler(null);
  });

  group('Currency Offline Support Tests', () {
    setUp(() async {
      await resetDependencies();
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
