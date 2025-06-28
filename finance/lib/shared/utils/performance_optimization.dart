import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance optimization utilities and monitoring for Phase 1 & 2 UI optimizations
class PerformanceOptimizations {
  /// Feature flags for Phase 1 optimizations
  static const bool useOptimizedBottomSheets = true;
  static const bool useOptimizedAnimations = true;
  static const bool useOptimizedDialogs = true;
  static const bool useOptimizedCardRendering = true;
  
  /// Feature flags for Phase 2 optimizations (Keyboard & Rebuild Optimization)
  static const bool useKeyboardOptimizations = true;
  static const bool useSnapSizeCache = true;
  static const bool useResponsiveLayoutBuilder = true;
  static const bool useMediaQueryCaching = true;
  
  /// Feature flags for Phase 3 optimizations (Animation Layer Consolidation)
  static const bool useAnimationLayerConsolidation = true;
  static const bool usePlatformOptimizedTappables = true;
  static const bool useConsolidatedBottomSheetAnimations = true;
  
  /// Feature flags for Phase 4 optimizations (Physics & Snap Optimization)
  static const bool useCustomSnapPhysics = true;
  static const bool useOverscrollOptimization = true;
  static const bool useOptimizedScrollBehavior = true;
  
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
  
  /// Phase 2: Track keyboard optimization usage
  static void trackKeyboardOptimization(String componentName, String optimizationType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('⌨️ Keyboard: $componentName using $optimizationType');
    }
  }
  
  /// Phase 2: Track snap size cache performance
  static void trackSnapSizeCache(String component, bool cacheHit) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final status = cacheHit ? 'HIT ✅' : 'MISS ❌';
      debugPrint('📊 SnapCache: $component - $status');
    }
  }
  
  /// Phase 2: Track MediaQuery optimization
  static void trackMediaQueryOptimization(String componentName, String optimizationType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('📱 MediaQuery: $componentName using $optimizationType');
    }
  }
  
  /// Phase 2: Track widget rebuild optimization
  static void trackRebuildOptimization(String componentName, int rebuildCount) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final status = rebuildCount <= 1 ? '✅' : '⚠️';
      debugPrint('🔄 Rebuild: $componentName rebuilt $rebuildCount times $status');
    }
  }
  
  /// Phase 3: Track animation layer consolidation
  static void trackAnimationLayerConsolidation(String componentName, String optimizationType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('🎭 Animation: $componentName using $optimizationType');
    }
  }
  
  /// Phase 3: Track platform optimization usage
  static void trackPlatformOptimization(String componentName, String platform, String optimizationType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('🔧 Platform: $componentName on $platform using $optimizationType');
    }
  }
  
  /// Phase 3: Track single vs multiple animation ownership
  static void trackAnimationOwnership(String componentName, bool hasSingleOwner) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final status = hasSingleOwner ? 'single owner ✅' : 'multiple owners ⚠️';
      debugPrint('🎪 Ownership: $componentName has $status');
    }
  }
  
  /// Phase 4: Track custom snap physics usage
  static void trackSnapPhysics(String componentName, String physicsType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('🎯 Snap: $componentName using $physicsType');
    }
  }
  
  /// Phase 4: Track overscroll optimization
  static void trackOverscrollOptimization(String componentName, String optimizationType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('📜 Overscroll: $componentName using $optimizationType');
    }
  }
  
  /// Phase 4: Track physics optimization
  static void trackPhysicsOptimization(String componentName, String physicsType) {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('⚙️ Physics: $componentName using $physicsType');
    }
  }
  
  /// Phase 4: Track snap completion events
  static void trackSnapCompletion(String componentName, double snapPosition, bool hadHapticFeedback) {
    if (kDebugMode && enablePerformanceMonitoring) {
      final hapticStatus = hadHapticFeedback ? 'with haptic ✅' : 'no haptic ❌';
      debugPrint('🎪 Snap: $componentName snapped to $snapPosition $hapticStatus');
    }
  }
  
  /// Comprehensive performance summary for all phases
  static void printPerformanceSummary() {
    if (kDebugMode && enablePerformanceMonitoring) {
      debugPrint('');
      debugPrint('🚀 Performance Optimization Summary:');
      debugPrint('   Phase 1: Material elevation, theme caching, haptic optimization');
      debugPrint('   Phase 2: Keyboard handling, snap caching, MediaQuery optimization');
      debugPrint('   Phase 3: Animation consolidation, platform optimization');
      debugPrint('   Phase 4: Custom snap physics, overscroll optimization');
      debugPrint('');
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

/// Phase 1 & 2 performance metrics tracking
class PerformanceTracker {
  // Phase 1 metrics
  static final Map<String, int> _renderingOptimizations = {};
  static final Map<String, int> _themeCacheHits = {};
  static final Map<String, int> _hapticOptimizations = {};
  
  // Phase 2 metrics
  static final Map<String, int> _keyboardOptimizations = {};
  static final Map<String, int> _snapCacheHits = {};
  static final Map<String, int> _mediaQueryOptimizations = {};
  static final Map<String, int> _rebuildOptimizations = {};
  
  // Phase 3 metrics
  static final Map<String, int> _animationConsolidations = {};
  static final Map<String, int> _platformOptimizations = {};
  
  // Phase 4 metrics
  static final Map<String, int> _snapPhysicsOptimizations = {};
  static final Map<String, int> _overscrollOptimizations = {};
  static final Map<String, int> _physicsOptimizations = {};
  static final Map<String, int> _snapCompletions = {};
  
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
  
  /// Phase 2: Track keyboard optimization
  static void trackKeyboard(String component) {
    if (kDebugMode) {
      _keyboardOptimizations[component] = (_keyboardOptimizations[component] ?? 0) + 1;
    }
  }
  
  /// Phase 2: Track snap cache hit
  static void trackSnapCache(String component) {
    if (kDebugMode) {
      _snapCacheHits[component] = (_snapCacheHits[component] ?? 0) + 1;
    }
  }
  
  /// Phase 2: Track MediaQuery optimization
  static void trackMediaQuery(String component) {
    if (kDebugMode) {
      _mediaQueryOptimizations[component] = (_mediaQueryOptimizations[component] ?? 0) + 1;
    }
  }
  
  /// Phase 2: Track rebuild optimization
  static void trackRebuild(String component) {
    if (kDebugMode) {
      _rebuildOptimizations[component] = (_rebuildOptimizations[component] ?? 0) + 1;
    }
  }
  
  /// Print comprehensive performance summary
  static void printSummary() {
    if (kDebugMode && PerformanceOptimizations.enablePerformanceMonitoring) {
      debugPrint('\n📊 Performance Optimization Summary:');
      debugPrint('--- Phase 1 (Foundation) ---');
      debugPrint('🎯 Rendering optimizations: ${_renderingOptimizations.length} components');
      debugPrint('🎨 Theme cache hits: ${_themeCacheHits.values.fold(0, (a, b) => a + b)}');
      debugPrint('📳 Haptic optimizations: ${_hapticOptimizations.length} components');
      debugPrint('--- Phase 2 (Keyboard & Rebuild) ---');
      debugPrint('⌨️ Keyboard optimizations: ${_keyboardOptimizations.length} components');
      debugPrint('📊 Snap cache hits: ${_snapCacheHits.values.fold(0, (a, b) => a + b)}');
      debugPrint('📱 MediaQuery optimizations: ${_mediaQueryOptimizations.length} components');
      debugPrint('🔄 Rebuild optimizations: ${_rebuildOptimizations.length} components');
      debugPrint('');
    }
  }
}

/// Legacy alias for backward compatibility
typedef Phase1PerformanceTracker = PerformanceTracker;

/// Extension for easy performance tracking
extension PerformanceTrackingExtension on Widget {
  /// Wrap with performance tracking for Material elevation
  Widget trackMaterialOptimization(String componentName) {
    if (kDebugMode) {
      PerformanceTracker.trackRendering(componentName);
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