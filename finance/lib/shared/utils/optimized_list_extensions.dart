/// Phase 5: Universal List Optimization Extensions
/// 
/// Provides convenient extension methods for applying Phase 1-4 optimization
/// patterns to any scrollable widget.
library;

import 'package:flutter/material.dart';
import 'no_overscroll_behavior.dart';

/// Universal optimization extensions for any widget
extension OptimizedListExtensions on Widget {
  /// Apply Phase 4 overscroll optimization
  Widget withOptimizedScrolling({
    String? debugLabel,
    ScrollPhysics? physics,
  }) {
    return ScrollConfiguration(
      behavior: NoOverscrollBehavior(componentName: debugLabel),
      child: this,
    );
  }
  
  /// Apply Phase 4 RepaintBoundary for performance isolation
  Widget withRepaintBoundary({
    String? keyPrefix,
    bool isAnimatedContent = false,
  }) {
    // Don't apply RepaintBoundary to animated content as it can cause issues
    if (isAnimatedContent) {
      return this;
    }
    
    return RepaintBoundary(
      key: keyPrefix != null ? ValueKey('repaint_$keyPrefix') : null,
      child: this,
    );
  }
  
  /// Apply Phase 4 overscroll optimization (alias for convenience)
  Widget withNoOverscroll() {
    return withOptimizedScrolling();
  }
}

/// Universal SliverList builder with Phase 5 optimizations
class OptimizedSliverList<T> extends StatelessWidget {
  const OptimizedSliverList({
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.keyBuilder,
    this.hasAnimatedItems = false,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final String Function(T item)? keyBuilder;
  final bool hasAnimatedItems;

  @override
  Widget build(BuildContext context) {
    if (separatorBuilder != null) {
      return SliverList.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final child = itemBuilder(context, item, index);
          
          // Only apply RepaintBoundary to non-animated content
          if (!hasAnimatedItems) {
            return RepaintBoundary(
              key: keyBuilder != null ? ValueKey(keyBuilder!(item)) : ValueKey(index),
              child: child,
            );
          }
          
          return child;
        },
        separatorBuilder: separatorBuilder!,
      );
    }
    
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final child = itemBuilder(context, item, index);
        
        // Only apply RepaintBoundary to static content
        if (!hasAnimatedItems) {
          return RepaintBoundary(
            key: keyBuilder != null ? ValueKey(keyBuilder!(item)) : ValueKey(index),
            child: child,
          );
        }
        
        return child;
      },
    );
  }
}