import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/currencies/domain/entities/currency.dart';
import 'package:finance/features/currencies/data/models/currency_model.dart';
import 'package:finance/shared/utils/currency_formatter.dart';

void main() {
  group('Currency System Unit Tests', () {
    test('Currency entity should work correctly', () {
      const currency = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      expect(currency.code, 'USD');
      expect(currency.name, 'US Dollar');
      expect(currency.symbol, '\$');
      expect(currency.decimalDigits, 2);
    });

    test('CurrencyModel should work correctly', () {
      const model = CurrencyModel(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
      );

      expect(model.code, 'EUR');
      expect(model.name, 'Euro');
      expect(model.symbol, '€');
    });

    test('CurrencyFormatter should format amounts correctly', () {
      const usdCurrency = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      final formatted = CurrencyFormatter.formatAmount(
        amount: 1234.56,
        currency: usdCurrency,
      );
      expect(formatted, contains('1,234.56'));
      expect(formatted, contains('\$'));
    });
    test('CurrencyFormatter should parse amounts correctly', () {
      const amount = 1234.56;
      const formatted = '\$1,234.56';

      const currency = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      final parsed = CurrencyFormatter.parseAmount(formatted, currency);
      expect(parsed, closeTo(amount, 0.01));
    });

    test('CurrencyFormatter should handle different locales', () {
      const eurCurrency = Currency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      final formatted = CurrencyFormatter.formatAmount(
        amount: 1234.56,
        currency: eurCurrency,
      );
      expect(formatted, isNotEmpty);
      expect(formatted, contains('€'));
    });

    test('Currency should support equality comparison', () {
      const currency1 = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      const currency2 = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      const currency3 = Currency(
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      expect(currency1, equals(currency2));
      expect(currency1, isNot(equals(currency3)));
    });

    test('Currency should support toString', () {
      const currency = Currency(
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        decimalDigits: 2,
        rounding: 0,
        isKnown: true,
      );

      final stringRepresentation = currency.toString();
      expect(stringRepresentation, contains('USD'));
    });
  });
}
