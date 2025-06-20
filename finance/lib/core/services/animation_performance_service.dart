import 'package:flutter/material.dart';
import '../settings/app_settings.dart';

/// AnimationPerformanceService - Phase 6.2 Implementation
///
/// A service for optimizing animation performance based on:
/// - User preferences and settings
/// - Device capabilities and power state
/// - Platform-specific optimizations
/// - Battery saver mode integration
/// - Real-time performance monitoring
class AnimationPerformanceService {
  AnimationPerformanceService._();

  static int _totalAnimationsCreated = 0;
  static int _currentActiveAnimations = 0;
  static final List<Duration> _recentFrameTimes = [];
  static const int _maxFrameTimeHistory = 60; // Keep last 60 frame times
  static final List<VoidCallback> _listeners = [];

  /// Check if complex animations should be used
  ///
  /// Complex animations include:
  /// - Multiple simultaneous animations
  /// - Physics-based animations
  /// - High-framerate animations
  /// - Resource-intensive effects
  static bool get shouldUseComplexAnimations {
    final level =
        AppSettings.getWithDefault<String>('animationLevel', 'normal');
    return !AppSettings.getWithDefault<bool>('batterySaver', false) &&
        level != 'none' &&
        AppSettings.getWithDefault<bool>('appAnimations', true) &&
        _isPerformanceGood();
  }

  /// Get optimized animation duration based on settings and performance
  ///
  /// Applies performance scaling based on animation level:
  /// - none: Duration.zero (no animation)
  /// - reduced: 50% of standard duration
  /// - normal: Standard duration (100%)
  /// - enhanced: 120% of standard duration for more polished feel
  static Duration getOptimizedDuration(Duration standard) {
    final level =
        AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final appAnimations =
        AppSettings.getWithDefault<bool>('appAnimations', true);
    final batterySaver =
        AppSettings.getWithDefault<bool>('batterySaver', false);

    // Disable animations entirely if needed
    if (!appAnimations || batterySaver) {
      return Duration.zero;
    }

    // Apply performance-based scaling
    final performanceScale = _getPerformanceScale();

    switch (level) {
      case 'none':
        return Duration.zero;
      case 'reduced':
        return Duration(
            milliseconds:
                (standard.inMilliseconds * 0.5 * performanceScale).round());
      case 'enhanced':
        return Duration(
            milliseconds:
                (standard.inMilliseconds * 1.2 * performanceScale).round());
      case 'normal':
      default:
        return Duration(
            milliseconds: (standard.inMilliseconds * performanceScale).round());
    }
  }

  /// Get optimized curve based on animation level and platform
  ///
  /// Returns appropriate curves for different performance levels
  static Curve getOptimizedCurve(Curve defaultCurve) {
    final level =
        AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final performanceGood = _isPerformanceGood();

    switch (level) {
      case 'none':
        return Curves.linear; // Won't be used but safe fallback
      case 'reduced':
        return Curves
            .easeInOut; // Simple, fast curve matching test expectations
      case 'enhanced':
        return Curves.elasticOut; // Enhanced curve matching test expectations
      case 'normal':
      default:
        if (performanceGood) {
          return defaultCurve;
        } else {
          return Curves.easeInOut; // Fallback to simpler curve
        }
    }
  }

  /// Check if staggered animations should be used
  ///
  /// Staggered animations can be performance-intensive with many items
  static bool get shouldUseStaggeredAnimations {
    final level =
        AppSettings.getWithDefault<String>('animationLevel', 'normal');
    return shouldUseComplexAnimations &&
        (level == 'normal' || level == 'enhanced') &&
        _currentActiveAnimations <
            maxSimultaneousAnimations ~/ 2; // Reserve capacity
  }

  /// Get maximum number of simultaneous animations based on performance
  ///
  /// Limits concurrent animations to prevent performance issues
  static int get maxSimultaneousAnimations {
    final level =
        AppSettings.getWithDefault<String>('animationLevel', 'normal');
    final batterySaver =
        AppSettings.getWithDefault<bool>('batterySaver', false);

    if (batterySaver) return 1;

    // Adjust based on current performance
    final performanceMultiplier = _isPerformanceGood() ? 1.0 : 0.5;

    switch (level) {
      case 'none':
        return 0;
      case 'reduced':
        return (2 * performanceMultiplier).round();
      case 'enhanced':
        return (8 * performanceMultiplier).round();
      case 'normal':
      default:
        return (4 * performanceMultiplier).round();
    }
  }

  /// Check if haptic feedback should be used with animations
  ///
  /// Combines haptic setting with animation settings for consistent experience
  static bool get shouldUseHapticFeedback {
    final hapticFeedback =
        AppSettings.getWithDefault<bool>('hapticFeedback', true);
    final batterySaver =
        AppSettings.getWithDefault<bool>('batterySaver', false);

    // Independent haptic control with battery saver override
    return hapticFeedback && !batterySaver;
  }

  /// Register animation creation for tracking
  static void registerAnimationCreated() {
    _totalAnimationsCreated++;
  }

  /// Register animation start for tracking
  static void registerAnimationStart() {
    _currentActiveAnimations++;
    _notifyListeners();
  }

  /// Register animation end for tracking
  static void registerAnimationEnd() {
    if (_currentActiveAnimations > 0) {
      _currentActiveAnimations--;
      _notifyListeners();
    }
  }

  /// Record frame time for performance monitoring
  static void recordFrameTime(Duration frameTime) {
    _recentFrameTimes.add(frameTime);
    if (_recentFrameTimes.length > _maxFrameTimeHistory) {
      _recentFrameTimes.removeAt(0);
    }
    _notifyListeners();
  }

  /// Get average frame time for performance assessment
  static Duration get averageFrameTime {
    if (_recentFrameTimes.isEmpty)
      return const Duration(milliseconds: 16); // 60fps

    final totalMs = _recentFrameTimes.fold<int>(
        0, (sum, time) => sum + time.inMicroseconds);
    return Duration(microseconds: totalMs ~/ _recentFrameTimes.length);
  }

  /// Check if performance is currently good
  static bool _isPerformanceGood() {
    // Consider performance good if average frame time is under 20ms (50fps)
    // Use a default limit of 4 to avoid circular dependency with maxSimultaneousAnimations
    return averageFrameTime.inMilliseconds < 20 && _currentActiveAnimations < 4;
  }

  /// Get performance scale factor based on current performance
  static double _getPerformanceScale() {
    if (!_isPerformanceGood()) {
      return 0.8; // Reduce duration by 20% when performance is poor
    }
    return 1.0;
  }

  /// Get current performance metrics
  static Map<String, dynamic> get performanceMetrics {
    return {
      'totalAnimationsCreated': _totalAnimationsCreated,
      'currentActiveAnimations': _currentActiveAnimations,
      'averageFrameTimeMs': averageFrameTime.inMilliseconds,
      'isPerformanceGood': _isPerformanceGood(),
      'performanceScale': _getPerformanceScale(),
      'frameTimeHistory':
          _recentFrameTimes.map((t) => t.inMilliseconds).toList(),
    };
  }

  /// Get performance profile for debugging
  static Map<String, dynamic> getPerformanceProfile() {
    return {
      'animationLevel':
          AppSettings.getWithDefault<String>('animationLevel', 'normal'),
      'appAnimations': AppSettings.getWithDefault<bool>('appAnimations', true),
      'batterySaver': AppSettings.getWithDefault<bool>('batterySaver', false),
      'reduceAnimations':
          AppSettings.getWithDefault<bool>('reduceAnimations', false),
      'hapticFeedback': AppSettings.hapticFeedback,
      'shouldUseComplexAnimations': shouldUseComplexAnimations,
      'shouldUseStaggeredAnimations': shouldUseStaggeredAnimations,
      'maxSimultaneousAnimations': maxSimultaneousAnimations,
      'shouldUseHapticFeedback': shouldUseHapticFeedback,
      'performanceMetrics': performanceMetrics,
    };
  }

  /// Reset performance metrics (for testing or debugging)
  static void resetPerformanceMetrics() {
    _totalAnimationsCreated = 0;
    _currentActiveAnimations = 0;
    _recentFrameTimes.clear();
    _notifyListeners();
  }

  /// Add listener to performance updates
  static void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in List<VoidCallback>.from(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }

  /// Public method to manually notify listeners (e.g., when settings change)
  static void notifyListeners() {
    _notifyListeners();
  }
}
