import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/services/platform_service.dart';

/// Core animation utilities for the Finance app animation framework
/// Phase 1 implementation following the plan specifications
class AnimationUtils {
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

  /// Get animation duration based on settings and platform
  static Duration getDuration([Duration? fallback]) {
    if (!shouldAnimate()) return Duration.zero;
    
    // Get base duration
    final baseDuration = fallback ?? PlatformService.platformAnimationDuration;
    
    // Apply animation level modifications
    return _getOptimizedDuration(baseDuration);
  }

  /// Get optimized duration based on animation level setting
  static Duration _getOptimizedDuration(Duration standard) {
    final level = AppSettings.animationLevel;
    
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

  /// Get animation curve based on platform and settings
  static Curve getCurve([Curve? fallback]) {
    if (!shouldAnimate()) return Curves.linear;
    
    final level = AppSettings.animationLevel;
    final platformCurve = fallback ?? PlatformService.platformCurve;
    
    switch (level) {
      case 'reduced':
        return Curves.easeInOut; // Simpler curve for reduced animations
      case 'enhanced':
        return Curves.elasticOut; // More dramatic curve for enhanced
      case 'normal':
      default:
        return platformCurve;
    }
  }

  /// Check if complex animations should be used
  static bool shouldUseComplexAnimations() {
    return shouldAnimate() && 
           PlatformService.supportsComplexAnimations &&
           AppSettings.animationLevel != 'reduced';
  }

  /// Get delay for staggered animations
  static Duration getStaggerDelay(int index, {Duration? baseDelay}) {
    if (!shouldAnimate()) return Duration.zero;
    
    final base = baseDelay ?? const Duration(milliseconds: 50);
    final level = AppSettings.animationLevel;
    
    switch (level) {
      case 'reduced':
        return Duration(milliseconds: (base.inMilliseconds * 0.5).round());
      case 'enhanced':
        return Duration(milliseconds: (base.inMilliseconds * 1.5).round());
      default:
        return base;
    }
  }

  /// Create an optimized AnimationController
  static AnimationController createController({
    required TickerProvider vsync,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    final animDuration = getDuration(duration);
    final reverseAnimDuration = getDuration(reverseDuration ?? animDuration);
    
    return AnimationController(
      duration: animDuration,
      reverseDuration: reverseAnimDuration,
      vsync: vsync,
      debugLabel: debugLabel,
    );
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

  /// Debug method to get animation status
  static Map<String, dynamic> getAnimationDebugInfo() {
    return {
      'shouldAnimate': shouldAnimate(),
      'animationLevel': AppSettings.animationLevel,
      'appAnimations': AppSettings.appAnimations,
      'reduceAnimations': AppSettings.reduceAnimations,
      'batterySaver': AppSettings.batterySaver,
      'shouldUseComplexAnimations': shouldUseComplexAnimations(),
      'platformInfo': PlatformService.getPlatformInfo(),
      'defaultDuration': getDuration().inMilliseconds,
      'defaultCurve': getCurve().toString(),
    };
  }
} 