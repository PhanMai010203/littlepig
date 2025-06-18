import 'package:flutter/material.dart';
import '../settings/app_settings.dart';

/// AnimationPerformanceService - Phase 6.2 Implementation
/// 
/// A service for optimizing animation performance based on:
/// - User preferences and settings
/// - Device capabilities and power state
/// - Platform-specific optimizations
/// - Battery saver mode integration
class AnimationPerformanceService {
  AnimationPerformanceService._();
  
  /// Check if complex animations should be used
  /// 
  /// Complex animations include:
  /// - Multiple simultaneous animations
  /// - Physics-based animations  
  /// - High-framerate animations
  /// - Resource-intensive effects
  static bool get shouldUseComplexAnimations {
    return !AppSettings.getWithDefault<bool>('batterySaver', false) &&
           AppSettings.getWithDefault<String>('animationLevel', 'normal') != 'none' &&
           AppSettings.getWithDefault<bool>('appAnimations', true);
  }
  
  /// Get optimized animation duration based on settings
  /// 
  /// Applies performance scaling based on animation level:
  /// - none: Duration.zero (no animation)
  /// - reduced: 50% of standard duration
  /// - normal: Standard duration (100%)
  /// - enhanced: 120% of standard duration for more polished feel
  static Duration getOptimizedDuration(Duration standard) {
    final level = AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final appAnimations = AppSettings.getWithDefault<bool>('appAnimations', true);
    final batterySaver = AppSettings.getWithDefault<bool>('batterySaver', false);
    
    // Disable animations entirely if needed
    if (!appAnimations || batterySaver) {
      return Duration.zero;
    }
    
    switch (level) {
      case 'none':
        return Duration.zero;
      case 'reduced':
        return Duration(milliseconds: (standard.inMilliseconds * 0.5).round());
      case 'enhanced':
        return Duration(milliseconds: (standard.inMilliseconds * 1.2).round());
      case 'normal':
      default:
        return standard;
    }
  }
  
  /// Get optimized curve based on animation level and platform
  /// 
  /// Returns appropriate curves for different performance levels
  static Curve getOptimizedCurve(Curve defaultCurve) {
    final level = AppSettings.getWithDefault<String>('animationLevel', 'normal');
    
    switch (level) {
      case 'none':
        return Curves.linear; // Won't be used but safe fallback
      case 'reduced':
        return Curves.easeOut; // Simple, fast curve
      case 'enhanced':
        return Curves.easeInOutCubicEmphasized; // Material 3 enhanced curve
      case 'normal':
      default:
        return defaultCurve;
    }
  }
  
  /// Check if staggered animations should be used
  /// 
  /// Staggered animations can be performance-intensive with many items
  static bool get shouldUseStaggeredAnimations {
    final level = AppSettings.getWithDefault<String>('animationLevel', 'normal');
    return shouldUseComplexAnimations && (level == 'normal' || level == 'enhanced');
  }
  
  /// Get maximum number of simultaneous animations based on performance
  /// 
  /// Limits concurrent animations to prevent performance issues
  static int get maxSimultaneousAnimations {
    final level = AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final batterySaver = AppSettings.getWithDefault<bool>('batterySaver', false);
    
    if (batterySaver) return 1;
    
    switch (level) {
      case 'none':
        return 0;
      case 'reduced':
        return 2;
      case 'enhanced':
        return 8;
      case 'normal':
      default:
        return 4;
    }
  }
  
  /// Check if haptic feedback should be used with animations
  /// 
  /// Combines with animation settings for consistent experience
  static bool get shouldUseHapticFeedback {
    final level = AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final appAnimations = AppSettings.getWithDefault<bool>('appAnimations', true);
    final batterySaver = AppSettings.getWithDefault<bool>('batterySaver', false);
    
    return appAnimations && !batterySaver && (level == 'normal' || level == 'enhanced');
  }
  
  /// Get performance profile summary for debugging
  /// 
  /// Returns current performance settings for troubleshooting
  static Map<String, dynamic> getPerformanceProfile() {
    return {
      'animationLevel': AppSettings.getWithDefault<String>('animationLevel', 'normal'),
      'appAnimations': AppSettings.getWithDefault<bool>('appAnimations', true),
      'batterySaver': AppSettings.getWithDefault<bool>('batterySaver', false),
      'reduceAnimations': AppSettings.getWithDefault<bool>('reduceAnimations', false),
      'shouldUseComplexAnimations': shouldUseComplexAnimations,
      'shouldUseStaggeredAnimations': shouldUseStaggeredAnimations,
      'maxSimultaneousAnimations': maxSimultaneousAnimations,
      'shouldUseHapticFeedback': shouldUseHapticFeedback,
    };
  }
} 