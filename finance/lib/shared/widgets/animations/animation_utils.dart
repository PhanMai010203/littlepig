import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/services/platform_service.dart';
import '../../../core/services/animation_performance_service.dart';

/// Core animation utilities for the Finance app animation framework
/// Phase 6.2 implementation with AnimationPerformanceService integration
class AnimationUtils {
  static int _activeAnimationCount = 0;
  static final Map<String, int> _animationMetrics = {};
  
  /// Check if animations should be enabled based on user settings and platform
  static bool shouldAnimate() {
    // Check user preferences first
    if (!AppSettings.appAnimations) return false;
    if (AppSettings.reduceAnimations) return false;
    if (AppSettings.batterySaver) return false;
    if (AppSettings.animationLevel == 'none') return false;
    
    // Check platform capabilities
    if (PlatformService.isWeb && !PlatformService.supportsComplexAnimations) {
      return AppSettings.animationLevel == 'enhanced'; // Only if explicitly enabled
    }
    
    return true;
  }

  /// Get animation duration based on settings and platform with performance optimization
  static Duration getDuration([Duration? fallback]) {
    if (!shouldAnimate()) return Duration.zero;
    
    // Get base duration
    final baseDuration = fallback ?? PlatformService.platformAnimationDuration;
    
    // Use AnimationPerformanceService for optimization
    return AnimationPerformanceService.getOptimizedDuration(baseDuration);
  }

  /// Get animation curve based on platform and settings with performance optimization
  static Curve getCurve([Curve? fallback]) {
    if (!shouldAnimate()) return Curves.linear;
    
    final platformCurve = fallback ?? PlatformService.platformCurve;
    
    // Use AnimationPerformanceService for optimization
    return AnimationPerformanceService.getOptimizedCurve(platformCurve);
  }

  /// Check if complex animations should be used
  static bool shouldUseComplexAnimations() {
    return AnimationPerformanceService.shouldUseComplexAnimations && 
           PlatformService.supportsComplexAnimations;
  }

  /// Check if staggered animations should be used with performance consideration
  static bool shouldUseStaggeredAnimations() {
    return AnimationPerformanceService.shouldUseStaggeredAnimations;
  }

  /// Get delay for staggered animations with performance optimization
  static Duration getStaggerDelay(int index, {Duration? baseDelay}) {
    if (!shouldAnimate() || !shouldUseStaggeredAnimations()) return Duration.zero;
    
    final base = baseDelay ?? const Duration(milliseconds: 50);
    return AnimationPerformanceService.getOptimizedDuration(
      Duration(milliseconds: base.inMilliseconds * index),
    );
  }

  /// Check if we can start a new animation (respects max concurrent limit)
  static bool canStartAnimation() {
    final maxConcurrent = AnimationPerformanceService.maxSimultaneousAnimations;
    return _activeAnimationCount < maxConcurrent;
  }

  /// Register animation start for performance tracking
  static void registerAnimationStart(String? debugLabel) {
    _activeAnimationCount++;
    if (debugLabel != null) {
      _animationMetrics[debugLabel] = (_animationMetrics[debugLabel] ?? 0) + 1;
    }
  }

  /// Register animation end for performance tracking
  static void registerAnimationEnd(String? debugLabel) {
    if (_activeAnimationCount > 0) {
      _activeAnimationCount--;
    }
  }

  /// Create an optimized AnimationController with performance tracking
  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    final animDuration = getDuration(duration);
    final reverseAnimDuration = getDuration(reverseDuration ?? animDuration);
    
    final controller = AnimationController(
      duration: animDuration,
      reverseDuration: reverseAnimDuration,
      vsync: vsync,
      debugLabel: debugLabel,
    );

    // Add performance tracking listeners
    controller.addStatusListener((status) {
      if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
        registerAnimationStart(debugLabel);
      } else if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        registerAnimationEnd(debugLabel);
      }
    });
    
    return controller;
  }

  /// Create an optimized CurvedAnimation
  static CurvedAnimation createCurvedAnimation({
    required AnimationController parent,
    Curve? curve,
    Curve? reverseCurve,
  }) {
    return CurvedAnimation(
      parent: parent,
      curve: getCurve(curve),
      reverseCurve: reverseCurve != null ? getCurve(reverseCurve) : null,
    );
  }

  /// Wrapper for AnimatedBuilder that respects animation settings
  static Widget animatedBuilder({
    required Animation<double> animation,
    required Widget Function(BuildContext context, Widget? child) builder,
    Widget? child,
  }) {
    if (!shouldAnimate()) {
      // Return the final state immediately
      return Builder(
        builder: (context) => builder(context, child),
      );
    }
    
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }

  /// Wrapper for AnimatedContainer that respects settings
  static Widget animatedContainer({
    Key? key,
    Widget? child,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    Duration? duration,
    Curve? curve,
    VoidCallback? onEnd,
  }) {
    return AnimatedContainer(
      key: key,
      child: child,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      duration: getDuration(duration),
      curve: getCurve(curve),
      onEnd: onEnd,
    );
  }

  /// Wrapper for AnimatedOpacity that respects settings
  static Widget animatedOpacity({
    Key? key,
    required Widget child,
    required double opacity,
    Duration? duration,
    Curve? curve,
    VoidCallback? onEnd,
  }) {
    return AnimatedOpacity(
      key: key,
      child: child,
      opacity: opacity,
      duration: getDuration(duration),
      curve: getCurve(curve),
      onEnd: onEnd,
    );
  }

  /// Wrapper for AnimatedScale that respects settings
  static Widget animatedScale({
    Key? key,
    required Widget child,
    required double scale,
    Duration? duration,
    Curve? curve,
    Alignment alignment = Alignment.center,
    VoidCallback? onEnd,
  }) {
    return AnimatedScale(
      key: key,
      child: child,
      scale: scale,
      duration: getDuration(duration),
      curve: getCurve(curve),
      alignment: alignment,
      onEnd: onEnd,
    );
  }

  /// Wrapper for AnimatedPositioned that respects settings
  static Widget animatedPositioned({
    Key? key,
    required Widget child,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
    Duration? duration,
    Curve? curve,
    VoidCallback? onEnd,
  }) {
    return AnimatedPositioned(
      key: key,
      child: child,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      duration: getDuration(duration),
      curve: getCurve(curve),
      onEnd: onEnd,
    );
  }

  /// Get current performance metrics for debugging
  static Map<String, dynamic> getPerformanceMetrics() {
    return {
      'activeAnimations': _activeAnimationCount,
      'maxSimultaneousAnimations': AnimationPerformanceService.maxSimultaneousAnimations,
      'animationMetrics': Map.from(_animationMetrics),
      'performanceProfile': AnimationPerformanceService.getPerformanceProfile(),
      'shouldUseComplexAnimations': shouldUseComplexAnimations(),
      'shouldUseStaggeredAnimations': shouldUseStaggeredAnimations(),
    };
  }

  /// Reset performance metrics (for testing or debugging)
  static void resetPerformanceMetrics() {
    _activeAnimationCount = 0;
    _animationMetrics.clear();
  }

  /// Debug method to get animation status with performance info
  static Map<String, dynamic> getAnimationDebugInfo() {
    return {
      'shouldAnimate': shouldAnimate(),
      'animationLevel': AppSettings.animationLevel,
      'appAnimations': AppSettings.appAnimations,
      'reduceAnimations': AppSettings.reduceAnimations,
      'batterySaver': AppSettings.batterySaver,
      'shouldUseComplexAnimations': shouldUseComplexAnimations(),
      'shouldUseStaggeredAnimations': shouldUseStaggeredAnimations(),
      'platformInfo': PlatformService.getPlatformInfo(),
      'defaultDuration': getDuration().inMilliseconds,
      'defaultCurve': getCurve().toString(),
      'performanceMetrics': getPerformanceMetrics(),
    };
  }
} 