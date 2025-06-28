import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance optimization utilities and monitoring for Phase 1 UI optimizations
class PerformanceOptimizations {
  /// Feature flags for Phase 1 optimizations
  static const bool useOptimizedBottomSheets = true;
  static const bool useOptimizedAnimations = true;
  static const bool useOptimizedDialogs = true;
  static const bool useOptimizedCardRendering = true;
  
  /// Debug-only performance monitoring
  static const bool enablePerformanceMonitoring = false; // Enable only in debug mode
  
  /// Track Material elevation usage vs BoxShadow usage
  static void trackRenderingOptimization(String componentName, String optimizationType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('🎯 Performance: $componentName using $optimizationType');
    }
  }
  
  /// Track theme context caching
  static void trackThemeCaching(String componentName, bool wasCached) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final status = wasCached ? 'cached ✅' : 'uncached ❌';
      debugPrint('🎨 Theme: $componentName theme lookup $status');
    }
  }
  
  /// Track haptic feedback optimization
  static void trackHapticOptimization(String componentName, bool wasOptimized) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final status = wasOptimized ? 'optimized ✅' : 'redundant ❌';
      debugPrint('📳 Haptic: $componentName haptic feedback $status');
    }
  }
  
  /// Track animation layer optimization
  static void trackAnimationLayers(String componentName, int layerCount) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final status = layerCount <= 1 ? '✅' : '⚠️';
      debugPrint('🎬 Animation: $componentName has $layerCount layers $status');
    }
  }
}

/// Cached theme utilities for consistent performance patterns
class CachedThemeData {
  final ThemeData theme;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isDarkMode;
  
  const CachedThemeData({
    required this.theme,
    required this.colorScheme,
    required this.textTheme,
    required this.isDarkMode,
  });
  
  /// Create cached theme data from context
  factory CachedThemeData.from(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    
    if (kDebugMode && PerformanceOptimizations.enablePerformanceMonitoring) {
      PerformanceOptimizations.trackThemeCaching('CachedThemeData', true);
    }
    
    return CachedThemeData(
      theme: theme,
      colorScheme: colorScheme,
      textTheme: textTheme,
      isDarkMode: isDarkMode,
    );
  }
}

/// Enhanced Material widget with performance tracking
class OptimizedMaterial extends StatelessWidget {
  const OptimizedMaterial({
    super.key,
    this.type = MaterialType.card,
    this.elevation = 0.0,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.animationDuration = kThemeChangeDuration,
    this.child,
    this.componentName,
  });

  final MaterialType type;
  final double elevation;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final TextStyle? textStyle;
  final BorderRadiusGeometry? borderRadius;
  final ShapeBorder? shape;
  final bool borderOnForeground;
  final Clip clipBehavior;
  final Duration animationDuration;
  final Widget? child;
  final String? componentName;

  @override
  Widget build(BuildContext context) {
    // Track performance optimization usage
    if (componentName != null) {
      PerformanceOptimizations.trackRenderingOptimization(
        componentName!,
        'Material elevation (optimized)',
      );
    }
    
    return Material(
      type: type,
      elevation: elevation,
      color: color,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      textStyle: textStyle,
      borderRadius: borderRadius,
      shape: shape,
      borderOnForeground: borderOnForeground,
      clipBehavior: clipBehavior,
      animationDuration: animationDuration,
      child: child,
    );
  }
}

/// Performance-aware RepaintBoundary helper
class OptimizedRepaintBoundary extends StatelessWidget {
  const OptimizedRepaintBoundary({
    super.key,
    required this.child,
    this.componentName,
  });
  
  final Widget child;
  final String? componentName;
  
  @override
  Widget build(BuildContext context) {
    if (componentName != null && kDebugMode && PerformanceOptimizations.enablePerformanceMonitoring) {
      debugPrint('🎯 RepaintBoundary: $componentName using isolated rendering');
    }
    
    return RepaintBoundary(child: child);
  }
}

/// Phase 1 performance metrics tracking
class Phase1PerformanceTracker {
  static final Map<String, int> _renderingOptimizations = {};
  static final Map<String, int> _themeCacheHits = {};
  static final Map<String, int> _hapticOptimizations = {};
  
  /// Track a rendering optimization
  static void trackRendering(String component) {
    if (kDebugMode) {
      _renderingOptimizations[component] = (_renderingOptimizations[component] ?? 0) + 1;
    }
  }
  
  /// Track a theme cache hit
  static void trackThemeCache(String component) {
    if (kDebugMode) {
      _themeCacheHits[component] = (_themeCacheHits[component] ?? 0) + 1;
    }
  }
  
  /// Track a haptic optimization
  static void trackHaptic(String component) {
    if (kDebugMode) {
      _hapticOptimizations[component] = (_hapticOptimizations[component] ?? 0) + 1;
    }
  }
  
  /// Print performance summary
  static void printSummary() {
    if (kDebugMode && PerformanceOptimizations.enablePerformanceMonitoring) {
      debugPrint('\n📊 Phase 1 Performance Summary:');
      debugPrint('🎯 Rendering optimizations: ${_renderingOptimizations.length} components');
      debugPrint('🎨 Theme cache hits: ${_themeCacheHits.values.fold(0, (a, b) => a + b)}');
      debugPrint('📳 Haptic optimizations: ${_hapticOptimizations.length} components');
      debugPrint('');
    }
  }
}

/// Extension for easy performance tracking
extension PerformanceTrackingExtension on Widget {
  /// Wrap with performance tracking for Material elevation
  Widget trackMaterialOptimization(String componentName) {
    if (kDebugMode) {
      Phase1PerformanceTracker.trackRendering(componentName);
    }
    return this;
  }
  
  /// Wrap with RepaintBoundary for performance isolation
  Widget isolateRepaints(String componentName) {
    return OptimizedRepaintBoundary(
      componentName: componentName,
      child: this,
    );
  }
}