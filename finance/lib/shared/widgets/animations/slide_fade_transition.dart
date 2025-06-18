import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// Direction for slide-fade transitions
enum SlideFadeDirection {
  up,
  down,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// A widget that combines slide and fade transitions
/// Part of the Phase 2 Animation Widget Library
class SlideFadeTransition extends StatefulWidget {
  const SlideFadeTransition({
    required this.child,
    required this.animation,
    this.direction = SlideFadeDirection.up,
    this.offset = 0.3,
    this.curve = Curves.easeOutCubic,
    this.fadeInPoint = 0.0, // When fade starts (0.0 = immediately, 0.5 = halfway)
    this.slideDistance = 30.0, // Distance in logical pixels
    super.key,
  });

  final Widget child;
  final Animation<double> animation;
  final SlideFadeDirection direction;
  final double offset;
  final Curve curve;
  final double fadeInPoint;
  final double slideDistance;

  @override
  State<SlideFadeTransition> createState() => _SlideFadeTransitionState();
}

class _SlideFadeTransitionState extends State<SlideFadeTransition> {
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _updateAnimations();
  }

  @override
  void didUpdateWidget(SlideFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.curve != widget.curve ||
        oldWidget.fadeInPoint != widget.fadeInPoint) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final curvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: AnimationUtils.getCurve(widget.curve),
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(curvedAnimation);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.animation,
      curve: Interval(
        widget.fadeInPoint,
        1.0,
        curve: AnimationUtils.getCurve(widget.curve),
      ),
    ));
  }

  Offset _getSlideOffset() {
    final progress = _slideAnimation.value;
    final distance = widget.slideDistance * progress;

    switch (widget.direction) {
      case SlideFadeDirection.up:
        return Offset(0.0, distance);
      case SlideFadeDirection.down:
        return Offset(0.0, -distance);
      case SlideFadeDirection.left:
        return Offset(distance, 0.0);
      case SlideFadeDirection.right:
        return Offset(-distance, 0.0);
      case SlideFadeDirection.topLeft:
        return Offset(distance, distance);
      case SlideFadeDirection.topRight:
        return Offset(-distance, distance);
      case SlideFadeDirection.bottomLeft:
        return Offset(distance, -distance);
      case SlideFadeDirection.bottomRight:
        return Offset(-distance, -distance);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skip animation wrapper if animations are disabled
    if (!AnimationUtils.shouldAnimate()) {
      return widget.child;
    }

    return AnimationUtils.animatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: _getSlideOffset(),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Extension to easily add slide-fade transitions to any widget
extension SlideFadeTransitionExtension on Widget {
  /// Wraps this widget with SlideFadeTransition
  Widget slideFadeTransition({
    required Animation<double> animation,
    SlideFadeDirection direction = SlideFadeDirection.up,
    double offset = 0.3,
    Curve curve = Curves.easeOutCubic,
    double fadeInPoint = 0.0,
    double slideDistance = 30.0,
  }) {
    return SlideFadeTransition(
      animation: animation,
      direction: direction,
      offset: offset,
      curve: curve,
      fadeInPoint: fadeInPoint,
      slideDistance: slideDistance,
      child: this,
    );
  }
} 