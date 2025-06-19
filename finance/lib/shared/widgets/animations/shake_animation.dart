import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that provides horizontal shake effects for errors
/// Part of the Phase 2 Animation Widget Library
class ShakeAnimation extends StatefulWidget {
  const ShakeAnimation({
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.elasticInOut,
    this.shakeCount = 3,
    this.shakeOffset = 10.0,
    this.autoStart = false,
    this.trigger, // Change this to trigger shake
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final int shakeCount;
  final double shakeOffset;
  final bool autoStart;
  final dynamic trigger; // Any object, when changed triggers shake

  @override
  State<ShakeAnimation> createState() => _ShakeAnimationState();
}

class _ShakeAnimationState extends State<ShakeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'ShakeAnimation',
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart && AnimationUtils.shouldAnimate()) {
      _startShake();
    }
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger shake when trigger value changes
    if (widget.trigger != oldWidget.trigger && widget.trigger != null) {
      shake();
    }
  }

  void _startShake() {
    if (!mounted || !AnimationUtils.shouldAnimate()) return;

    _controller.forward(from: 0.0);
  }

  /// Public method to trigger shake manually
  void shake() {
    if (!AnimationUtils.shouldAnimate()) return;

    _controller.forward(from: 0.0);
  }

  /// Public method to stop shaking
  void stop() {
    _controller.stop();
    _controller.reset();
  }

  double _getShakeValue() {
    final progress = _shakeAnimation.value;

    // Create a shake pattern based on sine wave
    final shakePhase = progress * widget.shakeCount * 2 * 3.14159;
    final shakeDecay = 1.0 - progress; // Fade out the shake

    return widget.shakeOffset *
        shakeDecay *
        (progress * 4 * (1 - progress)) *
        (progress < 1 ? 1 : 0) *
        (shakePhase.abs() < 3.14159 ? 1 : -1);
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
      return widget.child;
    }

    return AnimationUtils.animatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_getShakeValue(), 0.0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Extension to easily add shake functionality to any widget
extension ShakeAnimationExtension on Widget {
  /// Wraps this widget with ShakeAnimation
  Widget shake({
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.elasticInOut,
    int shakeCount = 3,
    double shakeOffset = 10.0,
    bool autoStart = false,
    dynamic trigger,
  }) {
    return ShakeAnimation(
      duration: duration,
      curve: curve,
      shakeCount: shakeCount,
      shakeOffset: shakeOffset,
      autoStart: autoStart,
      trigger: trigger,
      child: this,
    );
  }
}
