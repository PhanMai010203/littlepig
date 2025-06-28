import 'package:flutter/material.dart';
import 'performance_optimization.dart';

/// Phase 4: Custom scroll behavior that eliminates overscroll effects
/// 
/// This behavior prevents rubber-band jank by:
/// - Removing overscroll indicators
/// - Using ClampingScrollPhysics instead of bouncing physics
/// - Providing controlled scroll boundaries
class NoOverscrollBehavior extends ScrollBehavior {
  const NoOverscrollBehavior({
    this.componentName,
  });

  final String? componentName;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Track overscroll optimization usage
    if (componentName != null) {
      PerformanceOptimizations.trackOverscrollOptimization(
        componentName!,
        'NoOverscrollIndicator',
      );
    }

    // Return child without overscroll indicator
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Track physics optimization usage
    if (componentName != null) {
      PerformanceOptimizations.trackPhysicsOptimization(
        componentName!,
        'ClampingScrollPhysics',
      );
    }

    // Use clamping physics to prevent bounce/rubber-band effects
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Keep default scrollbar behavior
    return super.buildScrollbar(context, child, details);
  }
}

/// Wrapper widget that applies NoOverscrollBehavior to its child
class NoOverscrollWrapper extends StatelessWidget {
  const NoOverscrollWrapper({
    super.key,
    required this.child,
    this.componentName,
  });

  final Widget child;
  final String? componentName;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoOverscrollBehavior(componentName: componentName),
      child: child,
    );
  }
}

/// Extension for easily applying no-overscroll behavior
extension NoOverscrollExtension on Widget {
  /// Wrap this widget with NoOverscrollBehavior
  Widget withNoOverscroll({String? componentName}) {
    return NoOverscrollWrapper(
      componentName: componentName,
      child: this,
    );
  }
}