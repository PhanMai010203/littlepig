import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// Direction for slide animations
enum SlideDirection {
  left,
  right,
  up,
  down,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// A widget that slides in its child from a specified direction
/// Part of the Phase 2 Animation Widget Library
class SlideIn extends StatefulWidget {
  const SlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.direction = SlideDirection.left,
    this.distance = 1.0,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;
  final double distance; // Multiplier for slide distance (1.0 = full screen width/height)

  @override
  State<SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<SlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'SlideIn',
    );

    _slideAnimation = Tween<Offset>(
      begin: _getBeginOffset(),
      end: Offset.zero,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation after delay
    _startAnimation();
  }

  Offset _getBeginOffset() {
    switch (widget.direction) {
      case SlideDirection.left:
        return Offset(-widget.distance, 0.0);
      case SlideDirection.right:
        return Offset(widget.distance, 0.0);
      case SlideDirection.up:
        return Offset(0.0, -widget.distance);
      case SlideDirection.down:
        return Offset(0.0, widget.distance);
      case SlideDirection.topLeft:
        return Offset(-widget.distance, -widget.distance);
      case SlideDirection.topRight:
        return Offset(widget.distance, -widget.distance);
      case SlideDirection.bottomLeft:
        return Offset(-widget.distance, widget.distance);
      case SlideDirection.bottomRight:
        return Offset(widget.distance, widget.distance);
    }
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

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _slideAnimation.value.dx * MediaQuery.of(context).size.width,
            _slideAnimation.value.dy * MediaQuery.of(context).size.height,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
} 