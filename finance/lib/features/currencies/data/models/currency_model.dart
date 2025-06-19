import '../../domain/entities/currency.dart';

/// Data model for currency information loaded from JSON
class CurrencyModel extends Currency {
  const CurrencyModel({
    required super.code,
    required super.name,
    required super.symbol,
    super.symbolNative,
    super.countryName,
    super.countryCode,
    super.flag,
    super.decimalDigits,
    super.rounding,
    super.namePlural,
    super.isKnown,
  });

  /// Creates a CurrencyModel from the currencies.json format
  factory CurrencyModel.fromJson(String code, Map<String, dynamic> json) {
    return CurrencyModel(
      code: code.toUpperCase(),
      name: json['Currency'] ?? json['name'] ?? '',
      symbol: json['Symbol'] ?? json['symbol'] ?? '',
      symbolNative: json['symbol_native'],
      countryName: json['CountryName'] ?? json['country_name'],
      countryCode: json['CountryCode'] ?? json['country_code'],
      flag: json['Flag'] ?? json['flag'],
      decimalDigits: json['decimal_digits'] ?? 2,
      rounding: json['rounding'] ?? 0,
      namePlural: json['name_plural'],
      isKnown: json['NotKnown'] != true,
    );
  }

  /// Creates a CurrencyModel from the currenciesInfo.json format
  factory CurrencyModel.fromCurrencyInfo(Map<String, dynamic> json) {
    return CurrencyModel(
      code: (json['Code'] ?? '').toUpperCase(),
      name: json['Currency'] ?? '',
      symbol: json['Symbol'] ?? '',
      countryName: json['CountryName'],
      flag: json['Flag'],
      decimalDigits: 2,
      rounding: 0,
      isKnown: true,
    );
  }

  /// Creates a CurrencyModel from the currenciesInfo2.json format
  factory CurrencyModel.fromDetailedInfo(
      String code, Map<String, dynamic> json) {
    return CurrencyModel(
      code: code.toUpperCase(),
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      symbolNative: json['symbol_native'],
      decimalDigits: json['decimal_digits'] ?? 2,
      rounding: json['rounding'] ?? 0,
      namePlural: json['name_plural'],
      isKnown: true,
    );
  }

  /// Converts to entity
  Currency toEntity() {
    return Currency(
      code: code,
      name: name,
      symbol: symbol,
      symbolNative: symbolNative,
      countryName: countryName,
      countryCode: countryCode,
      flag: flag,
      decimalDigits: decimalDigits,
      rounding: rounding,
      namePlural: namePlural,
      isKnown: isKnown,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'symbol_native': symbolNative,
      'country_name': countryName,
      'country_code': countryCode,
      'flag': flag,
      'decimal_digits': decimalDigits,
      'rounding': rounding,
      'name_plural': namePlural,
      'is_known': isKnown,
    };
  }
}
