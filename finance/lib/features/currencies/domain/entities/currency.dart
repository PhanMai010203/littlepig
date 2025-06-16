import 'package:equatable/equatable.dart';

/// Represents a currency with its properties and formatting information
class Currency extends Equatable {
  final String code;
  final String name;
  final String symbol;
  final String? symbolNative;
  final String? countryName;
  final String? countryCode;
  final String? flag;
  final int decimalDigits;
  final int rounding;
  final String? namePlural;
  final bool isKnown;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.symbolNative,
    this.countryName,
    this.countryCode,
    this.flag,
    this.decimalDigits = 2,
    this.rounding = 0,
    this.namePlural,
    this.isKnown = true,
  });

  /// Returns the preferred symbol for display (native if available, otherwise international)
  String get displaySymbol => symbolNative ?? symbol;

  /// Returns the appropriate currency name (plural if specified, otherwise regular name)
  String getDisplayName({bool plural = false}) {
    if (plural && namePlural != null) {
      return namePlural!;
    }
    return name;
  }

  /// Checks if this currency has complete information
  bool get isComplete => countryName != null && symbol.isNotEmpty;

  /// Creates a copy of this currency with updated values
  Currency copyWith({
    String? code,
    String? name,
    String? symbol,
    String? symbolNative,
    String? countryName,
    String? countryCode,
    String? flag,
    int? decimalDigits,
    int? rounding,
    String? namePlural,
    bool? isKnown,
  }) {
    return Currency(
      code: code ?? this.code,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      symbolNative: symbolNative ?? this.symbolNative,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      decimalDigits: decimalDigits ?? this.decimalDigits,
      rounding: rounding ?? this.rounding,
      namePlural: namePlural ?? this.namePlural,
      isKnown: isKnown ?? this.isKnown,
    );
  }

  @override
  List<Object?> get props => [
        code,
        name,
        symbol,
        symbolNative,
        countryName,
        countryCode,
        flag,
        decimalDigits,
        rounding,
        namePlural,
        isKnown,
      ];

  @override
  String toString() {
    return 'Currency(code: $code, name: $name, symbol: $symbol)';
  }
}
