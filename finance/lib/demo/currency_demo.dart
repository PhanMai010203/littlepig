import 'package:flutter/material.dart';
import '../services/currency_service.dart';

/// Demonstration script showing the currency system functionality
/// This can be run as part of the main app to demonstrate real asset loading
class CurrencyDemo {
  static Future<void> runDemo({required CurrencyService currencyService}) async {
    print('=== Currency System Demo ===');

    try {
      print('\n1. Loading all currencies...');
      final allCurrencies = await currencyService.getAllCurrencies();
      print('Found ${allCurrencies.length} currencies');

      if (allCurrencies.isNotEmpty) {
        print('Sample currencies:');
        for (final currency in allCurrencies.take(5)) {
          print('  ${currency.code} - ${currency.name} (${currency.symbol})');
        }
      }

      print('\n2. Searching for US currencies...');
      final usCurrencies = await currencyService.searchCurrencies('US');
      print('Found ${usCurrencies.length} US-related currencies:');
      for (final currency in usCurrencies.take(3)) {
        print('  ${currency.code} - ${currency.name}');
      }

      print('\n3. Getting popular currencies...');
      final popularCurrencies = await currencyService.getPopularCurrencies();
      print('Found ${popularCurrencies.length} popular currencies:');
      for (final currency in popularCurrencies.take(5)) {
        print('  ${currency.code} - ${currency.name}');
      }

      print('\n4. Currency formatting tests...');
      const testAmount = 1234.56;

      final usd = await currencyService.getCurrency('USD');
      if (usd != null) {
        final formatted = currencyService.formatAmount(
            amount: testAmount, currencyCode: 'USD');
        print('USD: $formatted');
      }

      final eur = await currencyService.getCurrency('EUR');
      if (eur != null) {
        final formatted = currencyService.formatAmount(
            amount: testAmount, currencyCode: 'EUR');
        print('EUR: $formatted');
      }

      final vnd = await currencyService.getCurrency('VND');
      if (vnd != null) {
        final formatted = currencyService.formatAmount(
            amount: testAmount, currencyCode: 'VND');
        print('VND: $formatted');
      }
      print('\n5. Exchange rate operations...');
      await currencyService.setCustomExchangeRate(
          fromCurrency: 'USD', toCurrency: 'EUR', rate: 0.85);
      print('Set custom USD -> EUR rate: 0.85');

      final rate = await currencyService.getExchangeRate(
          fromCurrency: 'USD', toCurrency: 'EUR');
      if (rate != null) {
        print('Retrieved rate: ${rate.rate} (custom: ${rate.isCustom})');

        final converted = await currencyService.convertAmount(
            amount: 100.0, fromCurrency: 'USD', toCurrency: 'EUR');
        print('Converted 100 USD to EUR: $converted');
      }

      print('\n=== Demo completed successfully! ===');
    } catch (e, stackTrace) {
      print('Error during demo: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Widget that can be added to the app to run the demo
  static Widget buildDemoWidget({required CurrencyService currencyService}) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency System Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currency System Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await runDemo(currencyService: currencyService);
              },
              child: const Text('Run Currency Demo'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Check the console for demo output.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'This demo will:\n'
                  '• Load all available currencies from assets\n'
                  '• Search for currencies\n'
                  '• Get popular currencies\n'
                  '• Format currency amounts\n'
                  '• Test exchange rate operations\n'
                  '• Convert between currencies\n\n'
                  'The currency system includes:\n'
                  '• 170+ world currencies from JSON assets\n'
                  '• Currency formatting with proper symbols\n'
                  '• Exchange rate management (API + custom rates)\n'
                  '• Currency conversion utilities\n'
                  '• Clean Architecture implementation\n'
                  '• Dependency injection integration\n\n'
                  'All functionality follows best practices and is ready for UI integration.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
