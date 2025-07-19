
/// Result of intelligent currency detection with confidence and reasoning
class CurrencyDetectionResult {
  final String currencyCode;
  final double confidence; // 0.0 to 1.0
  final String reasoning;
  final List<String> alternatives;

  const CurrencyDetectionResult({
    required this.currencyCode,
    required this.confidence,
    required this.reasoning,
    this.alternatives = const [],
  });

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.5;
}

/// Context for currency conversion with user feedback
class CurrencyConversionContext {
  final double originalAmount;
  final String originalCurrency;
  final double convertedAmount;
  final String targetCurrency;
  final String conversionReason;
  final bool wasConverted;

  const CurrencyConversionContext({
    required this.originalAmount,
    required this.originalCurrency,
    required this.convertedAmount,
    required this.targetCurrency,
    required this.conversionReason,
    required this.wasConverted,
  });

  String get formattedConversionNote {
    if (!wasConverted) return '';
    return 'Converted from $originalAmount $originalCurrency to $convertedAmount $targetCurrency ($conversionReason)';
  }
}

/// Smart currency detection and conversion service
abstract class CurrencyIntelligenceService {
  /// Detect currency based on user language settings
  Future<CurrencyDetectionResult> guessCurrencyFromLanguage({
    String? voiceLanguage,
    String? appLocale,
  });

  /// Detect currency from transaction context (description, amount patterns)
  Future<CurrencyDetectionResult> guessCurrencyFromTransactionContext({
    required String description,
    required double amount,
    String? existingCurrency,
  });

  /// Get user's preferred currency based on account usage and settings
  Future<CurrencyDetectionResult> getUserPreferredCurrency();

  /// Get currently selected account currency from home page context
  Future<String?> getCurrentSelectedAccountCurrency();

  /// Intelligent currency detection combining all available signals
  Future<CurrencyDetectionResult> detectOptimalCurrency({
    String? description,
    double? amount,
    String? voiceLanguage,
    String? appLocale,
    bool preferAccountCurrency = true,
  });

  /// Convert amount with intelligent context and user feedback
  Future<CurrencyConversionContext> convertAmountWithContext({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    String? conversionReason,
  });

  /// Get smart currency suggestions for account creation
  Future<List<CurrencyDetectionResult>> getSuggestedCurrenciesForAccount({
    String? voiceLanguage,
    String? appLocale,
  });

  /// Analyze amount patterns to suggest currency (e.g., amounts ending in 000 suggest VND)
  Future<CurrencyDetectionResult> analyzeCurrencyFromAmountPattern(double amount);

  /// Check if currency code is valid and supported
  Future<bool> isCurrencySupported(String currencyCode);

  /// Get formatted amount with intelligent currency display
  Future<String> formatAmountWithIntelligentCurrency({
    required double amount,
    String? detectedCurrency,
    String? targetCurrency,
    bool showConversion = false,
  });
}