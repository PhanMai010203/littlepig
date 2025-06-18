import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that provides elastic bouncing effects
/// Part of the Phase 2 Animation Widget Library
class BouncingWidget extends StatefulWidget {
  const BouncingWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.elasticOut,
    this.scaleFactor = 0.05, // How much the widget shrinks/expands during bounce
    this.autoStart = true,
    this.repeat = false,
    this.reverse = false,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double scaleFactor;
  final bool autoStart;
  final bool repeat;
  final bool reverse;

  @override
  State<BouncingWidget> createState() => _BouncingWidgetState();
}

class _BouncingWidgetState extends State<BouncingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'BouncingWidget',
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0 + widget.scaleFactor,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart && AnimationUtils.shouldAnimate()) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    if (!mounted || !AnimationUtils.shouldAnimate()) return;

    if (widget.repeat) {
      _controller.repeat(reverse: widget.reverse);
    } else {
      if (widget.reverse) {
        await _controller.forward();
        if (mounted) {
          await _controller.reverse();
        }
      } else {
        _controller.forward();
      }
    }
  }

  /// Public method to trigger bounce manually
  void bounce() {
    if (!AnimationUtils.shouldAnimate()) return;
    
    _controller.reset();
    _startAnimation();
  }

  /// Public method to stop bouncing
  void stop() {
    _controller.stop();
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Extension to easily add bounce functionality to any widget
extension BouncingWidgetExtension on Widget {
  /// Wraps this widget with BouncingWidget
  Widget bouncing({
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.elasticOut,
    double scaleFactor = 0.05,
    bool autoStart = true,
    bool repeat = false,
    bool reverse = false,
  }) {
    return BouncingWidget(
      duration: duration,
      curve: curve,
      scaleFactor: scaleFactor,
      autoStart: autoStart,
      repeat: repeat,
      reverse: reverse,
      child: this,
    );
  }
} 