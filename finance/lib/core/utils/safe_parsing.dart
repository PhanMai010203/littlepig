import 'package:flutter/foundation.dart';

/// Utility class for safely parsing values that might cause FormatException
class SafeParsing {
  /// Safely parse an integer from a dynamic value
  /// Returns defaultValue if parsing fails
  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) {
      debugPrint('🔢 SafeParsing.parseInt: null value, using default: $defaultValue');
      return defaultValue;
    }
    
    if (value is int) {
      return value;
    }
    
    if (value is double) {
      return value.toInt();
    }
    
    if (value is String) {
      if (value.isEmpty) {
        debugPrint('🔢 SafeParsing.parseInt: empty string, using default: $defaultValue');
        return defaultValue;
      }
      
      try {
        return int.parse(value);
      } catch (e) {
        debugPrint('❌ SafeParsing.parseInt: Failed to parse "$value" as int: $e, using default: $defaultValue');
        return defaultValue;
      }
    }
    
    debugPrint('❌ SafeParsing.parseInt: Unsupported type ${value.runtimeType} for value "$value", using default: $defaultValue');
    return defaultValue;
  }
  
  /// Safely parse a double from a dynamic value
  /// Returns defaultValue if parsing fails
  static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) {
      debugPrint('🔢 SafeParsing.parseDouble: null value, using default: $defaultValue');
      return defaultValue;
    }
    
    if (value is double) {
      return value;
    }
    
    if (value is int) {
      return value.toDouble();
    }
    
    if (value is String) {
      if (value.isEmpty) {
        debugPrint('🔢 SafeParsing.parseDouble: empty string, using default: $defaultValue');
        return defaultValue;
      }
      
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('❌ SafeParsing.parseDouble: Failed to parse "$value" as double: $e, using default: $defaultValue');
        return defaultValue;
      }
    }
    
    debugPrint('❌ SafeParsing.parseDouble: Unsupported type ${value.runtimeType} for value "$value", using default: $defaultValue');
    return defaultValue;
  }
  
  /// Safely parse a DateTime from a dynamic value
  /// Returns defaultValue if parsing fails
  static DateTime parseDateTime(dynamic value, {DateTime? defaultValue}) {
    final fallback = defaultValue ?? DateTime.now();
    
    if (value == null) {
      debugPrint('🔢 SafeParsing.parseDateTime: null value, using default: $fallback');
      return fallback;
    }
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is String) {
      if (value.isEmpty) {
        debugPrint('🔢 SafeParsing.parseDateTime: empty string, using default: $fallback');
        return fallback;
      }
      
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('❌ SafeParsing.parseDateTime: Failed to parse "$value" as DateTime: $e, using default: $fallback');
        return fallback;
      }
    }
    
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        debugPrint('❌ SafeParsing.parseDateTime: Failed to parse timestamp $value as DateTime: $e, using default: $fallback');
        return fallback;
      }
    }
    
    debugPrint('❌ SafeParsing.parseDateTime: Unsupported type ${value.runtimeType} for value "$value", using default: $fallback');
    return fallback;
  }
  
  /// Safely parse a boolean from a dynamic value
  /// Returns defaultValue if parsing fails
  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) {
      return defaultValue;
    }
    
    if (value is bool) {
      return value;
    }
    
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
      debugPrint('❌ SafeParsing.parseBool: Failed to parse "$value" as bool, using default: $defaultValue');
      return defaultValue;
    }
    
    if (value is int) {
      return value != 0;
    }
    
    debugPrint('❌ SafeParsing.parseBool: Unsupported type ${value.runtimeType} for value "$value", using default: $defaultValue');
    return defaultValue;
  }
}