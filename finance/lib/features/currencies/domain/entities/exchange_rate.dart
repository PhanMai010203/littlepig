import 'package:equatable/equatable.dart';

/// Represents exchange rate information for currency conversion
class ExchangeRate extends Equatable {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime lastUpdated;
  final bool isCustom;

  const ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.lastUpdated,
    this.isCustom = false,
  });

  /// Creates an exchange rate with current timestamp
  factory ExchangeRate.withCurrentTime({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
    bool isCustom = false,
  }) {
    return ExchangeRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      lastUpdated: DateTime.now(),
      isCustom: isCustom,
    );
  }

  /// Converts an amount using this exchange rate
  double convert(double amount) {
    return amount * rate;
  }

  /// Returns the inverse exchange rate
  ExchangeRate get inverse {
    return ExchangeRate(
      fromCurrency: toCurrency,
      toCurrency: fromCurrency,
      rate: 1.0 / rate,
      lastUpdated: lastUpdated,
      isCustom: isCustom,
    );
  }

  /// Checks if the exchange rate is stale (older than specified hours)
  bool isStale({int maxAgeHours = 24}) {
    return DateTime.now().difference(lastUpdated).inHours > maxAgeHours;
  }

  /// Creates a copy of this exchange rate with updated values
  ExchangeRate copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? rate,
    DateTime? lastUpdated,
    bool? isCustom,
  }) {
    return ExchangeRate(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rate: rate ?? this.rate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  List<Object?> get props => [
        fromCurrency,
        toCurrency,
        rate,
        lastUpdated,
        isCustom,
      ];

  @override
  String toString() {
    return 'ExchangeRate($fromCurrency -> $toCurrency: $rate, updated: $lastUpdated)';
  }
}
