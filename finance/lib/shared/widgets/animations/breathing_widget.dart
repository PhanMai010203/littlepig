import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that provides smooth breathing/pulsing scale animations
/// Part of the Phase 2 Animation Widget Library
class BreathingWidget extends StatefulWidget {
  const BreathingWidget({
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.curve = Curves.easeInOut,
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.autoStart = true,
    this.breathingSpeed = 1.0, // Multiplier for breathing speed
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double minScale;
  final double maxScale;
  final bool autoStart;
  final double breathingSpeed;

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    final adjustedDuration = Duration(
      milliseconds: (widget.duration.inMilliseconds / widget.breathingSpeed).round(),
    );
    
    _controller = AnimationUtils.createController(
      vsync: this,
      duration: adjustedDuration,
      debugLabel: 'BreathingWidget',
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart && AnimationUtils.shouldAnimate()) {
      _startBreathing();
    }
  }

  void _startBreathing() {
    if (!mounted || !AnimationUtils.shouldAnimate()) return;
    
    // Start continuous breathing animation
    _controller.repeat(reverse: true);
  }

  /// Public method to start breathing manually
  void startBreathing() {
    if (!AnimationUtils.shouldAnimate()) return;
    _startBreathing();
  }

  /// Public method to stop breathing
  void stopBreathing() {
    _controller.stop();
  }

  /// Public method to pause breathing
  void pauseBreathing() {
    _controller.stop();
  }

  /// Public method to resume breathing
  void resumeBreathing() {
    if (!AnimationUtils.shouldAnimate()) return;
    _controller.repeat(reverse: true);
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

/// Extension to easily add breathing functionality to any widget
extension BreathingWidgetExtension on Widget {
  /// Wraps this widget with BreathingWidget
  Widget breathing({
    Duration duration = const Duration(milliseconds: 2000),
    Curve curve = Curves.easeInOut,
    double minScale = 0.95,
    double maxScale = 1.05,
    bool autoStart = true,
    double breathingSpeed = 1.0,
  }) {
    return BreathingWidget(
      duration: duration,
      curve: curve,
      minScale: minScale,
      maxScale: maxScale,
      autoStart: autoStart,
      breathingSpeed: breathingSpeed,
      child: this,
    );
  }
} 