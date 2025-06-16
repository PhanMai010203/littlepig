import '../../domain/entities/exchange_rate.dart';

/// Data model for exchange rate information
class ExchangeRateModel extends ExchangeRate {
  const ExchangeRateModel({
    required super.fromCurrency,
    required super.toCurrency,
    required super.rate,
    required super.lastUpdated,
    super.isCustom,
  });

  /// Creates from JSON representation
  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      fromCurrency: json['from_currency'],
      toCurrency: json['to_currency'],
      rate: (json['rate'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated']),
      isCustom: json['is_custom'] ?? false,
    );
  }

  /// Creates from API response (fawazahmed0 format)
  factory ExchangeRateModel.fromApiResponse({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
  }) {
    return ExchangeRateModel(
      fromCurrency: baseCurrency.toUpperCase(),
      toCurrency: targetCurrency.toUpperCase(),
      rate: rate,
      lastUpdated: DateTime.now(),
      isCustom: false,
    );
  }

  /// Converts to entity
  ExchangeRate toEntity() {
    return ExchangeRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      lastUpdated: lastUpdated,
      isCustom: isCustom,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'rate': rate,
      'last_updated': lastUpdated.toIso8601String(),
      'is_custom': isCustom,
    };
  }
}
