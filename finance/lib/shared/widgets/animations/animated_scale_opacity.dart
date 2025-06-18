import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that combines scale and opacity animations
/// Part of the Phase 2 Animation Widget Library
class AnimatedScaleOpacity extends StatefulWidget {
  const AnimatedScaleOpacity({
    required this.child,
    required this.visible,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.reverseCurve,
    this.scaleBegin = 0.8,
    this.scaleEnd = 1.0,
    this.opacityBegin = 0.0,
    this.opacityEnd = 1.0,
    this.alignment = Alignment.center,
    this.maintainState = false,
    this.maintainAnimation = false,
    this.maintainSize = false,
    this.maintainSemantics = false,
    this.maintainInteractivity = false,
    super.key,
  });

  final Widget child;
  final bool visible;
  final Duration duration;
  final Curve curve;
  final Curve? reverseCurve;
  final double scaleBegin;
  final double scaleEnd;
  final double opacityBegin;
  final double opacityEnd;
  final Alignment alignment;
  final bool maintainState;
  final bool maintainAnimation;
  final bool maintainSize;
  final bool maintainSemantics;
  final bool maintainInteractivity;

  @override
  State<AnimatedScaleOpacity> createState() => _AnimatedScaleOpacityState();
}

class _AnimatedScaleOpacityState extends State<AnimatedScaleOpacity>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'AnimatedScaleOpacity',
    );

    _scaleAnimation = Tween<double>(
      begin: widget.scaleBegin,
      end: widget.scaleEnd,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    ));

    _opacityAnimation = Tween<double>(
      begin: widget.opacityBegin,
      end: widget.opacityEnd,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    ));

    // Set initial state
    if (widget.visible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedScaleOpacity oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.visible != widget.visible) {
      if (widget.visible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  /// Public method to show the widget
  void show() {
    if (!AnimationUtils.shouldAnimate()) {
      _controller.value = 1.0;
      return;
    }
    _controller.forward();
  }

  /// Public method to hide the widget
  void hide() {
    if (!AnimationUtils.shouldAnimate()) {
      _controller.value = 0.0;
      return;
    }
    _controller.reverse();
  }

  /// Public method to toggle visibility
  void toggle() {
    if (_controller.status == AnimationStatus.completed ||
        _controller.status == AnimationStatus.forward) {
      hide();
    } else {
      show();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Skip animation wrapper if animations are disabled
    if (!AnimationUtils.shouldAnimate()) {
      return widget.visible 
          ? widget.child 
          : Visibility(
              visible: false,
              maintainState: widget.maintainState,
              maintainAnimation: widget.maintainAnimation,
              maintainSize: widget.maintainSize,
              maintainSemantics: widget.maintainSemantics,
              maintainInteractivity: widget.maintainInteractivity,
              child: widget.child,
            );
    }

    return AnimationUtils.animatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Visibility(
          visible: _controller.value > 0.0,
          maintainState: widget.maintainState,
          maintainAnimation: widget.maintainAnimation,
          maintainSize: widget.maintainSize,
          maintainSemantics: widget.maintainSemantics,
          maintainInteractivity: widget.maintainInteractivity,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            alignment: widget.alignment,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Extension to easily add animated scale-opacity to any widget
extension AnimatedScaleOpacityExtension on Widget {
  /// Wraps this widget with AnimatedScaleOpacity
  Widget animatedScaleOpacity({
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Curve? reverseCurve,
    double scaleBegin = 0.8,
    double scaleEnd = 1.0,
    double opacityBegin = 0.0,
    double opacityEnd = 1.0,
    Alignment alignment = Alignment.center,
    bool maintainState = false,
    bool maintainAnimation = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
  }) {
    return AnimatedScaleOpacity(
      visible: visible,
      duration: duration,
      curve: curve,
      reverseCurve: reverseCurve,
      scaleBegin: scaleBegin,
      scaleEnd: scaleEnd,
      opacityBegin: opacityBegin,
      opacityEnd: opacityEnd,
      alignment: alignment,
      maintainState: maintainState,
      maintainAnimation: maintainAnimation,
      maintainSize: maintainSize,
      maintainSemantics: maintainSemantics,
      maintainInteractivity: maintainInteractivity,
      child: this,
    );
  }
} 