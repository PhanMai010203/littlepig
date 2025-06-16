import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/currency_model.dart';

/// Data source for loading currency data from local assets
abstract class CurrencyLocalDataSource {
  Future<List<CurrencyModel>> getAllCurrencies();
  Future<Map<String, CurrencyModel>> getCurrencyMap();
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  static const String _currenciesPath = 'assets/data/currencies.json';
  static const String _currenciesInfoPath = 'assets/data/currenciesInfo.json';
  static const String _currenciesInfo2Path = 'assets/data/currenciesInfo2.json';

  Map<String, CurrencyModel>? _cachedCurrencies;

  @override
  Future<List<CurrencyModel>> getAllCurrencies() async {
    final currencyMap = await getCurrencyMap();
    return currencyMap.values.toList();
  }

  @override
  Future<Map<String, CurrencyModel>> getCurrencyMap() async {
    if (_cachedCurrencies != null) {
      return _cachedCurrencies!;
    }

    final Map<String, CurrencyModel> currencies = {};

    try {
      // Load main currencies file
      await _loadMainCurrencies(currencies);
      
      // Load additional currency info
      await _loadCurrencyInfo(currencies);
      
      // Load detailed info
      await _loadDetailedInfo(currencies);
      
      _cachedCurrencies = currencies;
      return currencies;
    } catch (e) {
      // If loading fails, return empty map
      print('Error loading currencies: $e');
      return {};
    }
  }

  Future<void> _loadMainCurrencies(Map<String, CurrencyModel> currencies) async {
    try {
      final String jsonString = await rootBundle.loadString(_currenciesPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      for (final entry in json.entries) {
        final code = entry.key.toLowerCase();
        final data = entry.value as Map<String, dynamic>;
        
        final currency = CurrencyModel.fromJson(code, data);
        currencies[currency.code] = currency;
      }
    } catch (e) {
      print('Error loading main currencies: $e');
    }
  }

  Future<void> _loadCurrencyInfo(Map<String, CurrencyModel> currencies) async {
    try {
      final String jsonString = await rootBundle.loadString(_currenciesInfoPath);
      final List<dynamic> json = jsonDecode(jsonString);
      
      for (final item in json) {
        if (item is Map<String, dynamic>) {
          final currency = CurrencyModel.fromCurrencyInfo(item);
          if (currency.code.isNotEmpty) {
            // Merge with existing or add new
            final existing = currencies[currency.code];
            if (existing != null) {
              currencies[currency.code] = CurrencyModel(
                code: currency.code,
                name: currency.name.isNotEmpty ? currency.name : existing.name,
                symbol: currency.symbol.isNotEmpty ? currency.symbol : existing.symbol,
                symbolNative: existing.symbolNative,
                countryName: currency.countryName ?? existing.countryName,
                countryCode: existing.countryCode,
                flag: currency.flag ?? existing.flag,
                decimalDigits: existing.decimalDigits,
                rounding: existing.rounding,
                namePlural: existing.namePlural,
                isKnown: existing.isKnown,
              );
            } else {
              currencies[currency.code] = currency;
            }
          }
        }
      }
    } catch (e) {
      print('Error loading currency info: $e');
    }
  }

  Future<void> _loadDetailedInfo(Map<String, CurrencyModel> currencies) async {
    try {
      final String jsonString = await rootBundle.loadString(_currenciesInfo2Path);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      
      for (final entry in json.entries) {
        final code = entry.key.toUpperCase();
        final data = entry.value as Map<String, dynamic>;
        
        final currency = CurrencyModel.fromDetailedInfo(code, data);
        final existing = currencies[code];
        
        if (existing != null) {
          // Merge detailed information
          currencies[code] = CurrencyModel(
            code: code,
            name: currency.name.isNotEmpty ? currency.name : existing.name,
            symbol: currency.symbol.isNotEmpty ? currency.symbol : existing.symbol,
            symbolNative: currency.symbolNative ?? existing.symbolNative,
            countryName: existing.countryName,
            countryCode: existing.countryCode,
            flag: existing.flag,
            decimalDigits: currency.decimalDigits,
            rounding: currency.rounding,
            namePlural: currency.namePlural ?? existing.namePlural,
            isKnown: existing.isKnown,
          );
        } else {
          currencies[code] = currency;
        }
      }
    } catch (e) {
      print('Error loading detailed info: $e');
    }
  }

  /// Clears the cache to force reload
  void clearCache() {
    _cachedCurrencies = null;
  }
}
