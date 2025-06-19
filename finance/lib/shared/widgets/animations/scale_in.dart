import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that scales in its child with customizable curves
/// Part of the Phase 2 Animation Widget Library
class ScaleIn extends StatefulWidget {
  const ScaleIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.elasticOut,
    this.begin = 0.0,
    this.end = 1.0,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double begin;
  final double end;
  final Alignment alignment;

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'ScaleIn',
    );

    _scaleAnimation = Tween<double>(
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: widget.alignment,
          child: child,
        );
      },
      child: widget.child,
    );
  }
} 