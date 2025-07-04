import 'package:injectable/injectable.dart';
import '../../domain/services/currency_intelligence_service.dart';
import '../../../../services/currency_service.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import 'dart:math';

@LazySingleton(as: CurrencyIntelligenceService)
class CurrencyIntelligenceServiceImpl implements CurrencyIntelligenceService {
  final CurrencyService _currencyService;
  final AccountRepository _accountRepository;

  CurrencyIntelligenceServiceImpl(
    this._currencyService,
    this._accountRepository,
  );

  /// Language to currency mappings with confidence scores
  static const Map<String, Map<String, dynamic>> _languageCurrencyMap = {
    // Vietnamese
    'vi': {'currency': 'VND', 'confidence': 0.95},
    'vi_VN': {'currency': 'VND', 'confidence': 0.95},
    'vietnamese': {'currency': 'VND', 'confidence': 0.95},
    
    // English - context dependent, medium confidence
    'en': {'currency': 'USD', 'confidence': 0.6},
    'en_US': {'currency': 'USD', 'confidence': 0.9},
    'en_GB': {'currency': 'GBP', 'confidence': 0.9},
    'en_AU': {'currency': 'AUD', 'confidence': 0.9},
    'en_CA': {'currency': 'CAD', 'confidence': 0.9},
    
    // Auto detection
    'auto': {'currency': null, 'confidence': 0.0},
  };

  /// Currency symbols and patterns for amount analysis
  static const Map<String, String> _currencySymbolMap = {
    '\$': 'USD',
    '€': 'EUR',
    '£': 'GBP',
    '¥': 'JPY',
    '₫': 'VND',
    '₹': 'INR',
    '₩': 'KRW',
    'USD': 'USD',
    'EUR': 'EUR',
    'GBP': 'GBP',
    'JPY': 'JPY',
    'VND': 'VND',
    'INR': 'INR',
    'KRW': 'KRW',
  };

  /// Keywords that suggest specific currencies
  static const Map<String, String> _contextKeywords = {
    // Vietnamese context
    'phở': 'VND',
    'café': 'VND',
    'cà phê': 'VND',
    'bánh mì': 'VND',
    'đồng': 'VND',
    'nghìn': 'VND', // thousand
    'triệu': 'VND', // million
    'k': 'VND', // often used with VND (35k)
    
    // USD context
    'starbucks': 'USD',
    'mcdonalds': 'USD',
    'amazon': 'USD',
    'walmart': 'USD',
    'dollar': 'USD',
    'usd': 'USD',
    
    // EUR context
    'euro': 'EUR',
    'eur': 'EUR',
    
    // GBP context
    'pound': 'GBP',
    'sterling': 'GBP',
    'gbp': 'GBP',
  };

  @override
  Future<CurrencyDetectionResult> guessCurrencyFromLanguage({
    String? voiceLanguage,
    String? appLocale,
  }) async {
    // Priority: voiceLanguage > appLocale > system default
    final language = voiceLanguage ?? 
                    appLocale ?? 
                    AppSettings.voiceLanguage;
    
    final mapping = _languageCurrencyMap[language.toLowerCase()];
    
    if (mapping != null && mapping['currency'] != null) {
      final currency = mapping['currency'] as String;
      final confidence = mapping['confidence'] as double;
      
      return CurrencyDetectionResult(
        currencyCode: currency,
        confidence: confidence,
        reasoning: 'Detected from user language: $language',
        alternatives: _getLanguageAlternatives(language),
      );
    }

    // Fallback: try to extract language prefix (e.g., 'en_US' -> 'en')
    if (language.contains('_')) {
      final prefix = language.split('_')[0];
      final prefixMapping = _languageCurrencyMap[prefix];
      
      if (prefixMapping != null && prefixMapping['currency'] != null) {
        final currency = prefixMapping['currency'] as String;
        final confidence = (prefixMapping['confidence'] as double) * 0.8; // Reduced confidence
        
        return CurrencyDetectionResult(
          currencyCode: currency,
          confidence: confidence,
          reasoning: 'Detected from language prefix: $prefix (from $language)',
          alternatives: _getLanguageAlternatives(prefix),
        );
      }
    }

    // Ultimate fallback
    return const CurrencyDetectionResult(
      currencyCode: 'USD',
      confidence: 0.3,
      reasoning: 'Default fallback - no language mapping found',
      alternatives: ['VND', 'EUR', 'GBP'],
    );
  }

  @override
  Future<CurrencyDetectionResult> guessCurrencyFromTransactionContext({
    required String description,
    required double amount,
    String? existingCurrency,
  }) async {
    final descLower = description.toLowerCase();
    
    // Check for currency symbols in description
    for (final entry in _currencySymbolMap.entries) {
      if (descLower.contains(entry.key.toLowerCase())) {
        return CurrencyDetectionResult(
          currencyCode: entry.value,
          confidence: 0.9,
          reasoning: 'Currency symbol "${entry.key}" found in description',
          alternatives: [],
        );
      }
    }

    // Check for context keywords
    for (final entry in _contextKeywords.entries) {
      if (descLower.contains(entry.key)) {
        return CurrencyDetectionResult(
          currencyCode: entry.value,
          confidence: 0.8,
          reasoning: 'Context keyword "${entry.key}" suggests ${entry.value}',
          alternatives: [],
        );
      }
    }

    // Analyze amount patterns
    final amountPattern = await analyzeCurrencyFromAmountPattern(amount);
    if (amountPattern.confidence > 0.6) {
      return amountPattern;
    }

    // If no context clues, use existing currency or language-based detection
    if (existingCurrency != null && await isCurrencySupported(existingCurrency)) {
      return CurrencyDetectionResult(
        currencyCode: existingCurrency,
        confidence: 0.7,
        reasoning: 'Using existing currency context',
        alternatives: [],
      );
    }

    // Fallback to language detection
    return await guessCurrencyFromLanguage();
  }

  @override
  Future<CurrencyDetectionResult> getUserPreferredCurrency() async {
    try {
      final accounts = await _accountRepository.getAllAccounts();
      
      if (accounts.isEmpty) {
        // No accounts yet, use language detection
        return await guessCurrencyFromLanguage();
      }

      // Count currency usage across accounts
      final currencyUsage = <String, int>{};
      for (final account in accounts) {
        currencyUsage[account.currency] = (currencyUsage[account.currency] ?? 0) + 1;
      }

      // Find most common currency
      final sortedCurrencies = currencyUsage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final mostUsedCurrency = sortedCurrencies.first.key;
      final usageCount = sortedCurrencies.first.value;
      final totalAccounts = accounts.length;
      
      final confidence = min(0.95, (usageCount / totalAccounts) * 0.8 + 0.4);

      return CurrencyDetectionResult(
        currencyCode: mostUsedCurrency,
        confidence: confidence,
        reasoning: 'Most used currency across $usageCount of $totalAccounts accounts',
        alternatives: sortedCurrencies.skip(1).take(2).map((e) => e.key).toList(),
      );
    } catch (e) {
      // Fallback to language detection if account access fails
      return await guessCurrencyFromLanguage();
    }
  }

  @override
  Future<String?> getCurrentSelectedAccountCurrency() async {
    try {
      // This would need to be enhanced with proper state management
      // For now, we'll use the default account as a proxy
      final defaultAccount = await _accountRepository.getDefaultAccount();
      return defaultAccount?.currency;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<CurrencyDetectionResult> detectOptimalCurrency({
    String? description,
    double? amount,
    String? voiceLanguage,
    String? appLocale,
    bool preferAccountCurrency = true,
  }) async {
    final results = <CurrencyDetectionResult>[];

    // 1. Account-based detection (highest priority if preferAccountCurrency is true)
    if (preferAccountCurrency) {
      final accountResult = await getUserPreferredCurrency();
      if (accountResult.confidence > 0.6) {
        results.add(CurrencyDetectionResult(
          currencyCode: accountResult.currencyCode,
          confidence: accountResult.confidence * 1.1, // Boost account-based detection
          reasoning: 'Account preference: ${accountResult.reasoning}',
          alternatives: accountResult.alternatives,
        ));
      }
    }

    // 2. Transaction context analysis
    if (description != null && amount != null) {
      final contextResult = await guessCurrencyFromTransactionContext(
        description: description,
        amount: amount,
      );
      if (contextResult.confidence > 0.6) {
        results.add(contextResult);
      }
    }

    // 3. Language-based detection
    final languageResult = await guessCurrencyFromLanguage(
      voiceLanguage: voiceLanguage,
      appLocale: appLocale,
    );
    results.add(languageResult);

    // 4. Amount pattern analysis
    if (amount != null) {
      final amountResult = await analyzeCurrencyFromAmountPattern(amount);
      if (amountResult.confidence > 0.5) {
        results.add(amountResult);
      }
    }

    // Find the result with highest confidence
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    if (results.isNotEmpty) {
      final best = results.first;
      final alternatives = results.skip(1).take(3).map((r) => r.currencyCode).toList();
      
      return CurrencyDetectionResult(
        currencyCode: best.currencyCode,
        confidence: best.confidence,
        reasoning: 'Optimal detection: ${best.reasoning}',
        alternatives: alternatives,
      );
    }

    // Ultimate fallback
    return const CurrencyDetectionResult(
      currencyCode: 'USD',
      confidence: 0.2,
      reasoning: 'Ultimate fallback - no reliable detection possible',
      alternatives: ['VND', 'EUR'],
    );
  }

  @override
  Future<CurrencyConversionContext> convertAmountWithContext({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    String? conversionReason,
  }) async {
    if (fromCurrency == toCurrency) {
      return CurrencyConversionContext(
        originalAmount: amount,
        originalCurrency: fromCurrency,
        convertedAmount: amount,
        targetCurrency: toCurrency,
        conversionReason: 'No conversion needed - same currency',
        wasConverted: false,
      );
    }

    try {
      final convertedAmount = await _currencyService.convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );

      return CurrencyConversionContext(
        originalAmount: amount,
        originalCurrency: fromCurrency,
        convertedAmount: convertedAmount,
        targetCurrency: toCurrency,
        conversionReason: conversionReason ?? 'Currency conversion',
        wasConverted: true,
      );
    } catch (e) {
      // Conversion failed, return original amount
      return CurrencyConversionContext(
        originalAmount: amount,
        originalCurrency: fromCurrency,
        convertedAmount: amount,
        targetCurrency: fromCurrency,
        conversionReason: 'Conversion failed: ${e.toString()}',
        wasConverted: false,
      );
    }
  }

  @override
  Future<List<CurrencyDetectionResult>> getSuggestedCurrenciesForAccount({
    String? voiceLanguage,
    String? appLocale,
  }) async {
    final suggestions = <CurrencyDetectionResult>[];

    // Primary suggestion from language
    final languageResult = await guessCurrencyFromLanguage(
      voiceLanguage: voiceLanguage,
      appLocale: appLocale,
    );
    suggestions.add(languageResult);

    // Account-based suggestions
    final accountResult = await getUserPreferredCurrency();
    if (accountResult.currencyCode != languageResult.currencyCode) {
      suggestions.add(CurrencyDetectionResult(
        currencyCode: accountResult.currencyCode,
        confidence: accountResult.confidence * 0.9,
        reasoning: 'Based on existing accounts: ${accountResult.reasoning}',
        alternatives: [],
      ));
    }

    // Popular alternatives
    final popular = ['USD', 'EUR', 'VND', 'GBP'];
    for (final currency in popular) {
      if (!suggestions.any((s) => s.currencyCode == currency)) {
        suggestions.add(CurrencyDetectionResult(
          currencyCode: currency,
          confidence: 0.4,
          reasoning: 'Popular currency option',
          alternatives: [],
        ));
      }
    }

    return suggestions.take(5).toList();
  }

  @override
  Future<CurrencyDetectionResult> analyzeCurrencyFromAmountPattern(double amount) async {
    final absAmount = amount.abs();
    
    // VND patterns: typically large round numbers
    if (absAmount >= 1000 && absAmount % 1000 == 0) {
      if (absAmount >= 10000 && absAmount <= 10000000) {
        return const CurrencyDetectionResult(
          currencyCode: 'VND',
          confidence: 0.8,
          reasoning: 'Large round amount typical of VND (Vietnamese Dong)',
          alternatives: ['KRW', 'JPY'],
        );
      }
    }

    // USD/EUR patterns: typically smaller amounts with decimals
    if (absAmount >= 1 && absAmount <= 1000) {
      return const CurrencyDetectionResult(
        currencyCode: 'USD',
        confidence: 0.6,
        reasoning: 'Small to medium amount typical of USD/EUR',
        alternatives: ['EUR', 'GBP'],
      );
    }

    // JPY/KRW patterns: medium to large round numbers
    if (absAmount >= 100 && absAmount <= 100000 && absAmount % 10 == 0) {
      return const CurrencyDetectionResult(
        currencyCode: 'JPY',
        confidence: 0.5,
        reasoning: 'Round amount in JPY/KRW range',
        alternatives: ['KRW', 'VND'],
      );
    }

    // No clear pattern
    return const CurrencyDetectionResult(
      currencyCode: 'USD',
      confidence: 0.3,
      reasoning: 'No clear amount pattern detected',
      alternatives: ['VND', 'EUR'],
    );
  }

  @override
  Future<bool> isCurrencySupported(String currencyCode) async {
    try {
      final currency = await _currencyService.getCurrency(currencyCode);
      return currency != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> formatAmountWithIntelligentCurrency({
    required double amount,
    String? detectedCurrency,
    String? targetCurrency,
    bool showConversion = false,
  }) async {
    try {
      final currency = detectedCurrency ?? targetCurrency ?? 'USD';
      
      if (showConversion && detectedCurrency != null && targetCurrency != null && detectedCurrency != targetCurrency) {
        final convertedAmount = await _currencyService.convertAmount(
          amount: amount,
          fromCurrency: detectedCurrency,
          toCurrency: targetCurrency,
        );
        
        final originalFormatted = await _currencyService.formatAmount(
          amount: amount,
          currencyCode: detectedCurrency,
          showSymbol: true,
        );
        
        final convertedFormatted = await _currencyService.formatAmount(
          amount: convertedAmount,
          currencyCode: targetCurrency,
          showSymbol: true,
        );
        
        return '$originalFormatted (≈ $convertedFormatted)';
      } else {
        return await _currencyService.formatAmount(
          amount: amount,
          currencyCode: currency,
          showSymbol: true,
        );
      }
    } catch (e) {
      // Fallback formatting
      return '${amount.toStringAsFixed(2)} ${detectedCurrency ?? targetCurrency ?? 'USD'}';
    }
  }

  /// Helper method to get alternative currencies based on language
  List<String> _getLanguageAlternatives(String language) {
    switch (language.toLowerCase()) {
      case 'vi':
      case 'vi_vn':
      case 'vietnamese':
        return ['USD', 'EUR'];
      case 'en':
      case 'en_us':
        return ['VND', 'EUR', 'GBP'];
      case 'en_gb':
        return ['USD', 'EUR', 'VND'];
      default:
        return ['USD', 'VND', 'EUR'];
    }
  }
}