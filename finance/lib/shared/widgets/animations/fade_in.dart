import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that fades in its child with customizable delay and curves
/// Part of the Phase 2 Animation Widget Library
class FadeIn extends StatefulWidget {
  const FadeIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.begin = 0.0,
    this.end = 1.0,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'FadeIn',
    );

    _animation = Tween<double>(
      begin: widget.begin,
      end: widget.end,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation after delay
    _startAnimation();
  }

  void _startAnimation() async {
    // Check if we can start an animation based on concurrent limits
    if (!AnimationUtils.canStartAnimation()) {
      // If we can't start an animation, just show the final state immediately
      if (mounted) {
        _controller.value = 1.0; // Jump to end state
      }
      return;
    }

    // Respect delay only if animations are enabled
    if (AnimationUtils.shouldAnimate() && widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }

    if (mounted && AnimationUtils.canStartAnimation()) {
      _controller.forward();
    } else if (mounted) {
      // If we can't start during delay, show final state
      _controller.value = 1.0;
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
      return widget.child;
    }

    return AnimationUtils.animatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
