import 'dart:math';
import 'package:intl/intl.dart';
import '../../features/currencies/domain/entities/currency.dart';

/// Utility class for formatting currency amounts and symbols
class CurrencyFormatter {
  /// Formats an amount with the given currency
  static String formatAmount({
    required double amount,
    required Currency currency,
    bool showSymbol = true,
    bool showCode = false,
    bool compact = false,
    bool forceSign = false,
    bool useCodeWithSymbol = false,
  }) {
    // Handle absolute zero if needed
    if (amount.abs() < pow(10, -currency.decimalDigits)) {
      amount = 0.0;
    }

    // Create number formatter based on currency settings
    final formatter = _createNumberFormatter(
      currency: currency,
      compact: compact,
    );

    String formattedNumber = formatter.format(amount);

    // Add positive sign if forced
    if (forceSign && amount > 0 && !formattedNumber.startsWith('+')) {
      formattedNumber = '+$formattedNumber';
    }

    String result = formattedNumber;

    if (useCodeWithSymbol) {
      // Custom format: Symbol - Amount - Code
      result = '${currency.displaySymbol} $formattedNumber ${currency.code}';
    } else {
      if (showSymbol && currency.symbol.isNotEmpty) {
        // Determine symbol placement (typically before for most currencies)
        if (_shouldPlaceSymbolAfter(currency.code)) {
          result = '$formattedNumber ${currency.displaySymbol}';
        } else {
          result = '${currency.displaySymbol}$formattedNumber';
        }
      }

      if (showCode) {
        result = '$result ${currency.code}';
      }
    }

    return result;
  }

  /// Creates a number formatter for the given currency
  static NumberFormat _createNumberFormatter({
    required Currency currency,
    bool compact = false,
  }) {
    final locale = _getLocaleForCurrency(currency.code);

    if (compact) {
      return NumberFormat.compactCurrency(
        locale: locale,
        symbol: '', // We'll add symbol manually
        decimalDigits: currency.decimalDigits,
      );
    } else {
      return NumberFormat.currency(
        locale: locale,
        symbol: '', // We'll add symbol manually
        decimalDigits: currency.decimalDigits,
      );
    }
  }

  /// Gets the appropriate locale for a currency code
  static String _getLocaleForCurrency(String currencyCode) {
    // Map some currencies to their preferred locales
    const Map<String, String> currencyLocales = {
      'USD': 'en_US',
      'EUR': 'en_EU',
      'GBP': 'en_GB',
      'JPY': 'ja_JP',
      'CNY': 'zh_CN',
      'CAD': 'en_CA',
      'AUD': 'en_AU',
      'CHF': 'de_CH',
      'SEK': 'sv_SE',
      'NOK': 'nb_NO',
      'DKK': 'da_DK',
      'PLN': 'pl_PL',
      'CZK': 'cs_CZ',
      'HUF': 'hu_HU',
      'RUB': 'ru_RU',
      'INR': 'hi_IN',
      'KRW': 'ko_KR',
      'THB': 'th_TH',
      'VND': 'vi_VN',
      'TRY': 'tr_TR',
      'BRL': 'pt_BR',
      'MXN': 'es_MX',
      'ARS': 'es_AR',
      'CLP': 'es_CL',
      'COP': 'es_CO',
      'PEN': 'es_PE',
      'ZAR': 'af_ZA',
      'NGN': 'ha_NG',
      'EGP': 'ar_EG',
      'SAR': 'ar_SA',
      'AED': 'ar_AE',
      'QAR': 'ar_QA',
      'KWD': 'ar_KW',
      'BHD': 'ar_BH',
      'OMR': 'ar_OM',
      'JOD': 'ar_JO',
      'LBP': 'ar_LB',
      'ILS': 'he_IL',
    };

    return currencyLocales[currencyCode.toUpperCase()] ?? 'en_US';
  }

  /// Determines if currency symbol should be placed after the amount
  static bool _shouldPlaceSymbolAfter(String currencyCode) {
    // Some currencies traditionally place symbol after the amount
    const Set<String> symbolAfterCurrencies = {
      'EUR',
      'PLN',
      'CZK',
      'HUF',
      'RON',
      'BGN',
      'HRK',
      'RSD',
      'MKD',
      'ALL',
      'BAM',
      'TRY',
      'UAH',
      'BYN',
      'MDL',
      'GEL',
      'AMD',
      'AZN',
      'KZT',
      'UZS',
      'KGS',
      'TJS',
      'TMT',
      'MNT',
      'VND',
      'LAK',
      'KHR',
      'MMK',
      'IDR',
      'MYR',
      'PHP',
      'THB',
      'SGD',
      'BND',
      'KRW',
      'JPY',
      'CNY',
      'TWD',
      'HKD',
      'MOP',
      'INR',
      'PKR',
      'LKR',
      'NPR',
      'BTN',
      'BDT',
      'MVR',
      'AFN',
      'IRR',
      'IQD',
      'SYP',
      'LBP',
      'JOD',
      'PSE',
      'KWD',
      'BHD',
      'QAR',
      'AED',
      'OMR',
      'YER',
      'SAR',
    };

    return symbolAfterCurrencies.contains(currencyCode.toUpperCase());
  }

  /// Formats just the currency symbol and code
  static String formatCurrencyDisplay({
    required Currency currency,
    bool showCode = true,
    bool useNativeSymbol = true,
  }) {
    final symbol = useNativeSymbol ? currency.displaySymbol : currency.symbol;

    if (showCode && symbol.isNotEmpty) {
      return '$symbol (${currency.code})';
    } else if (showCode) {
      return currency.code;
    } else if (symbol.isNotEmpty) {
      return symbol;
    } else {
      return currency.code;
    }
  }

  /// Parses a currency amount string back to double
  static double? parseAmount(String text, Currency currency) {
    try {
      // Remove currency symbols and codes
      String cleanText = text
          .replaceAll(currency.symbol, '')
          .replaceAll(currency.displaySymbol, '')
          .replaceAll(currency.code, '')
          .replaceAll(RegExp(r'[^\d.,+-]'), '')
          .trim();

      // Handle different decimal separators
      if (cleanText.contains(',') && cleanText.contains('.')) {
        // Assume European format: 1.234,56
        if (cleanText.lastIndexOf('.') < cleanText.lastIndexOf(',')) {
          cleanText = cleanText.replaceAll('.', '').replaceAll(',', '.');
        }
        // Otherwise assume US format: 1,234.56
        else {
          cleanText = cleanText.replaceAll(',', '');
        }
      } else if (cleanText.contains(',')) {
        // Could be either decimal separator or thousands separator
        final parts = cleanText.split(',');
        if (parts.length == 2 && parts[1].length <= 2) {
          // Likely decimal separator
          cleanText = cleanText.replaceAll(',', '.');
        } else {
          // Likely thousands separator
          cleanText = cleanText.replaceAll(',', '');
        }
      }

      return double.parse(cleanText);
    } catch (e) {
      return null;
    }
  }
}
