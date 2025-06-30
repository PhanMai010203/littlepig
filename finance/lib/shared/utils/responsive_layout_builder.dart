import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ResponsiveLayoutBuilder - Phase 2 MediaQuery Optimization
/// 
/// Provides efficient alternatives to direct MediaQuery.of(context) usage
/// by leveraging LayoutBuilder for size-dependent layouts and implementing
/// smart caching for MediaQuery data.
class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({
    super.key,
    required this.builder,
    this.debugLabel,
  });
  
  /// Builder function that receives constraints instead of MediaQuery data
  final Widget Function(BuildContext context, BoxConstraints constraints, ResponsiveLayoutData data) builder;
  
  /// Optional debug label for performance tracking
  final String? debugLabel;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Create responsive layout data from constraints
        final layoutData = ResponsiveLayoutData.fromConstraints(
          constraints: constraints,
          context: context,
        );
        
        if (kDebugMode && debugLabel != null) {
          debugPrint('📐 ResponsiveLayoutBuilder: $debugLabel using LayoutBuilder optimization');
        }
        
        return builder(context, constraints, layoutData);
      },
    );
  }
}

/// Cached MediaQuery data with smart invalidation
class CachedMediaQueryData {
  static final Map<String, _MediaQueryCacheEntry> _cache = {};
  static int _accessCounter = 0;
  
  /// Get cached MediaQuery data or create new entry
  static MediaQueryData get(BuildContext context, {String? cacheKey}) {
    final key = cacheKey ?? context.hashCode.toString();
    final cached = _cache[key];
    
    if (cached != null) {
      cached.lastAccessed = ++_accessCounter;
      return cached.data;
    }
    
    // Create new cache entry
    final mediaQuery = MediaQuery.of(context);
    _cache[key] = _MediaQueryCacheEntry(
      data: mediaQuery,
      lastAccessed: ++_accessCounter,
    );
    
    // Clean cache if it gets too large
    if (_cache.length > 20) {
      _cleanCache();
    }
    
    return mediaQuery;
  }
  
  /// Invalidate cached MediaQuery data
  static void invalidate(String? cacheKey) {
    if (cacheKey != null) {
      _cache.remove(cacheKey);
    } else {
      _cache.clear();
    }
  }
  
  /// Clean old cache entries
  static void _cleanCache() {
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));
    
    // Remove oldest 50% of entries
    final toRemove = (_cache.length * 0.5).ceil();
    for (int i = 0; i < toRemove && i < sortedEntries.length; i++) {
      _cache.remove(sortedEntries[i].key);
    }
  }
}

/// Responsive layout data calculated from constraints
class ResponsiveLayoutData {
  final double width;
  final double height;
  final bool isLandscape;
  final bool isTablet;
  final bool isDesktop;
  final bool isCompact;
  final ResponsiveBreakpoint breakpoint;
  
  const ResponsiveLayoutData({
    required this.width,
    required this.height,
    required this.isLandscape,
    required this.isTablet,
    required this.isDesktop,
    required this.isCompact,
    required this.breakpoint,
  });
  
  /// Create responsive data from LayoutBuilder constraints
  factory ResponsiveLayoutData.fromConstraints({
    required BoxConstraints constraints,
    required BuildContext context,
  }) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final isLandscape = width > height;
    
    // Define breakpoints
    final isCompact = width < 600;
    final isTablet = width >= 600 && width < 1200;
    final isDesktop = width >= 1200;
    
    // Determine breakpoint
    ResponsiveBreakpoint breakpoint;
    if (width < 480) {
      breakpoint = ResponsiveBreakpoint.small;
    } else if (width < 768) {
      breakpoint = ResponsiveBreakpoint.medium;
    } else if (width < 1024) {
      breakpoint = ResponsiveBreakpoint.large;
    } else {
      breakpoint = ResponsiveBreakpoint.extraLarge;
    }
    
    return ResponsiveLayoutData(
      width: width,
      height: height,
      isLandscape: isLandscape,
      isTablet: isTablet,
      isDesktop: isDesktop,
      isCompact: isCompact,
      breakpoint: breakpoint,
    );
  }
  
  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding {
    if (isDesktop) {
      return const EdgeInsets.all(32.0);
    } else if (isTablet) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }
  
  /// Get responsive margin based on screen size
  EdgeInsets get responsiveMargin {
    if (isDesktop) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet) {
      return const EdgeInsets.all(12.0);
    } else {
      return const EdgeInsets.all(8.0);
    }
  }
  
  /// Get content width constraint based on screen size
  double get contentWidth {
    if (isDesktop) {
      return (width * 0.8).clamp(600, 1200);
    } else if (isTablet) {
      return width * 0.85;
    } else {
      return width;
    }
  }
}

/// Responsive breakpoint enumeration
enum ResponsiveBreakpoint {
  small,    // < 480px
  medium,   // 480px - 768px
  large,    // 768px - 1024px
  extraLarge, // > 1024px
}

/// Internal cache entry for MediaQuery data
class _MediaQueryCacheEntry {
  final MediaQueryData data;
  int lastAccessed;
  
  _MediaQueryCacheEntry({
    required this.data,
    required this.lastAccessed,
  });
}

/// Optimized MediaQuery widget that uses caching
class OptimizedMediaQuery extends StatelessWidget {
  const OptimizedMediaQuery({
    super.key,
    required this.builder,
    this.cacheKey,
    this.debugLabel,
  });
  
  /// Builder function that receives cached MediaQuery data
  final Widget Function(BuildContext context, MediaQueryData mediaQuery) builder;
  
  /// Optional cache key for persistent caching
  final String? cacheKey;
  
  /// Optional debug label for performance tracking
  final String? debugLabel;
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = CachedMediaQueryData.get(context, cacheKey: cacheKey);
    
    if (kDebugMode && debugLabel != null) {
      debugPrint('📱 OptimizedMediaQuery: $debugLabel using cached MediaQuery data');
    }
    
    return builder(context, mediaQuery);
  }
}

/// Extension methods for easy responsive layouts
extension ResponsiveContextExtension on BuildContext {
  /// Get responsive layout data using LayoutBuilder optimization
  Widget responsiveLayout(Widget Function(BuildContext context, ResponsiveLayoutData data) builder) {
    return ResponsiveLayoutBuilder(
      builder: (context, constraints, data) => builder(context, data),
    );
  }
  
  /// Get cached MediaQuery data
  MediaQueryData get cachedMediaQuery => CachedMediaQueryData.get(this);
}

/// Smart alternatives to common MediaQuery patterns
class MediaQueryAlternatives {
  /// Use LayoutBuilder instead of MediaQuery for width-dependent layouts
  static Widget responsiveWidth({
    required Widget Function(double width) builder,
    String? debugLabel,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (kDebugMode && debugLabel != null) {
          debugPrint('📐 MediaQueryAlternatives: $debugLabel using LayoutBuilder for width');
        }
        return builder(constraints.maxWidth);
      },
    );
  }
  
  /// Use LayoutBuilder instead of MediaQuery for size-dependent layouts
  static Widget responsiveSize({
    required Widget Function(Size size) builder,
    String? debugLabel,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (kDebugMode && debugLabel != null) {
          debugPrint('📐 MediaQueryAlternatives: $debugLabel using LayoutBuilder for size');
        }
        return builder(Size(constraints.maxWidth, constraints.maxHeight));
      },
    );
  }
  
  /// Optimized keyboard padding that only updates when needed
  static Widget keyboardPadding({
    required Widget child,
    bool animated = true,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOutQuart,
  }) {
    return Builder(
      builder: (context) {
        final viewInsets = MediaQuery.of(context).viewInsets;
        
        if (animated) {
          return AnimatedPadding(
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            duration: duration,
            curve: curve,
            child: child,
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(bottom: viewInsets.bottom),
            child: child,
          );
        }
      },
    );
  }
}