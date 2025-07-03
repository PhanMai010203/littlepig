import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Enhanced error handling for AI service operations
class AIErrorHandler {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  /// Handle API errors with appropriate user messages
  static String handleError(dynamic error) {
    if (error is GenerativeAIException) {
      return _handleGeminiError(error);
    }
    
    if (error is Exception) {
      return _handleGeneralException(error);
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
  
  /// Handle Gemini-specific errors
  static String _handleGeminiError(GenerativeAIException error) {
    final message = error.message;
    
    if (message.contains('API key') || message.contains('authentication')) {
      return 'Invalid API key. Please check your Gemini API configuration.';
    } else if (message.contains('quota') || message.contains('billing')) {
      return 'API quota exceeded. Please try again later or upgrade your plan.';
    } else if (message.contains('safety') || message.contains('blocked')) {
      return 'Request denied. The content may violate safety guidelines.';
    } else if (message.contains('too many requests') || message.contains('rate limit')) {
      return 'Too many requests. Please wait a moment before trying again.';
    } else if (message.contains('server') || message.contains('internal')) {
      return 'Server temporarily unavailable. Please try again in a few moments.';
    } else if (message.contains('network') || message.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (message.contains('timeout')) {
      return 'Request timed out. Please try again with a shorter query.';
    } else {
      debugPrint('Unhandled Gemini error: $message');
      return 'AI service error: $message';
    }
  }
  
  /// Handle general exceptions
  static String _handleGeneralException(Exception error) {
    final message = error.toString();
    
    if (message.contains('network') || message.contains('connection')) {
      return 'Network connection error. Please check your internet connection.';
    }
    
    if (message.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (message.contains('permission') || message.contains('auth')) {
      return 'Authentication error. Please check your API key configuration.';
    }
    
    debugPrint('Unhandled exception: $message');
    return 'Service temporarily unavailable. Please try again.';
  }
  
  /// Execute with retry logic
  static Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxRetries,
    Duration delay = retryDelay,
  }) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxAttempts) {
          rethrow;
        }
        
        // Don't retry certain errors
        if (e is GenerativeAIException) {
          final message = e.message;
          if (message.contains('API key') || 
              message.contains('authentication') ||
              message.contains('safety') ||
              message.contains('blocked')) {
            rethrow; // Don't retry these errors
          }
        }
        
        debugPrint('Retrying operation (attempt $attempts/$maxAttempts): $e');
        await Future.delayed(delay * attempts); // Exponential backoff
      }
    }
    
    throw Exception('Maximum retry attempts exceeded');
  }
  
  /// Check if error is retryable
  static bool isRetryableError(dynamic error) {
    if (error is GenerativeAIException) {
      final message = error.message;
      return message.contains('too many requests') ||
             message.contains('rate limit') ||
             message.contains('server') ||
             message.contains('network') ||
             message.contains('timeout');
    }
    
    return true; // Retry other errors by default
  }
  
  /// Validate API configuration
  static List<String> validateConfiguration({
    required String apiKey,
    required String model,
    required double temperature,
    required int maxTokens,
  }) {
    final errors = <String>[];
    
    if (apiKey.isEmpty) {
      errors.add('API key is required');
    } else if (!apiKey.startsWith('AIza')) {
      errors.add('Invalid API key format');
    }
    
    if (model.isEmpty) {
      errors.add('Model name is required');
    }
    
    if (temperature < 0.0 || temperature > 1.0) {
      errors.add('Temperature must be between 0.0 and 1.0');
    }
    
    if (maxTokens < 1 || maxTokens > 100000) {
      errors.add('Max tokens must be between 1 and 100,000');
    }
    
    return errors;
  }
  
  /// Rate limiting helper
  static final Map<String, DateTime> _lastRequestTimes = {};
  static const Duration minRequestInterval = Duration(milliseconds: 100);
  
  static Future<void> checkRateLimit(String operation) async {
    final lastTime = _lastRequestTimes[operation];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime);
      if (elapsed < minRequestInterval) {
        await Future.delayed(minRequestInterval - elapsed);
      }
    }
    _lastRequestTimes[operation] = DateTime.now();
  }
}