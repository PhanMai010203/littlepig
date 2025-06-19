import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animation_utils.dart';
import '../../../core/services/platform_service.dart';
import '../../../core/services/animation_performance_service.dart';

/// A widget that provides customizable tap feedback with animations
/// Phase 6.2 implementation with performance optimization
class TappableWidget extends StatefulWidget {
  const TappableWidget({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.animationType = TapAnimationType.scale,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeInOut,
    this.hapticFeedback = true,
    this.borderRadius,
    this.splashColor,
    this.highlightColor,
    this.enableFeedback = true,
    this.bounceOnTap = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final TapAnimationType animationType;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;
  final bool hapticFeedback;
  final BorderRadius? borderRadius;
  final Color? splashColor;
  final Color? highlightColor;
  final bool enableFeedback;
  final bool bounceOnTap;

  @override
  State<TappableWidget> createState() => _TappableWidgetState();
}

class _TappableWidgetState extends State<TappableWidget>
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
      debugLabel: 'TappableWidget',
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  void _handleTapDown(TapDownDetails details) {
    if (!AnimationUtils.shouldAnimate() || !AnimationUtils.canStartAnimation()) return;
    
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!AnimationUtils.shouldAnimate()) return;
    
    _controller.reverse();
  }

  void _handleTapCancel() {
    if (!AnimationUtils.shouldAnimate()) return;
    
    _controller.reverse();
  }

  void _handleTap() {
    // Use performance service to determine if haptic feedback should be used
    if (widget.hapticFeedback && 
        PlatformService.supportsHaptics &&
        AnimationPerformanceService.shouldUseHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    // Only animate bounce if performance allows
    if (widget.bounceOnTap && AnimationUtils.canStartAnimation()) {
      _animateBounce();
    }
    
    widget.onTap?.call();
  }

  void _handleLongPress() {
    // Use performance service to determine if haptic feedback should be used
    if (widget.hapticFeedback && 
        PlatformService.supportsHaptics &&
        AnimationPerformanceService.shouldUseHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    
    widget.onLongPress?.call();
  }

  void _handleDoubleTap() {
    // Use performance service to determine if haptic feedback should be used
    if (widget.hapticFeedback && 
        PlatformService.supportsHaptics &&
        AnimationPerformanceService.shouldUseHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    
    widget.onDoubleTap?.call();
  }

  void _animateBounce() async {
    if (!AnimationUtils.shouldAnimate() || !AnimationUtils.canStartAnimation()) return;
    
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // Apply animation based on type
    if (AnimationUtils.shouldAnimate()) {
      switch (widget.animationType) {
        case TapAnimationType.scale:
          child = AnimationUtils.animatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: child,
          );
          break;
        case TapAnimationType.opacity:
          child = AnimationUtils.animatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              );
            },
            child: child,
          );
          break;
        case TapAnimationType.both:
          child = AnimationUtils.animatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: child,
                ),
              );
            },
            child: child,
          );
          break;
        case TapAnimationType.none:
          break;
      }
    }

    // Wrap with appropriate gesture detector
    if (widget.onTap != null || widget.onLongPress != null || widget.onDoubleTap != null) {
      return GestureDetector(
        onTapDown: widget.animationType != TapAnimationType.none ? _handleTapDown : null,
        onTapUp: widget.animationType != TapAnimationType.none ? _handleTapUp : null,
        onTapCancel: widget.animationType != TapAnimationType.none ? _handleTapCancel : null,
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
        child: child,
      );
    }

    return child;
  }
}

/// Types of tap animations
enum TapAnimationType {
  none,
  scale,
  opacity,
  both,
}

/// Extension to easily add tappable functionality to any widget
extension TappableWidgetExtension on Widget {
  /// Wraps this widget with TappableWidget
  Widget tappable({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
    TapAnimationType animationType = TapAnimationType.scale,
    double scaleFactor = 0.95,
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeInOut,
    bool hapticFeedback = true,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
    bool enableFeedback = true,
    bool bounceOnTap = false,
  }) {
    return TappableWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      animationType: animationType,
      scaleFactor: scaleFactor,
      duration: duration,
      curve: curve,
      hapticFeedback: hapticFeedback,
      borderRadius: borderRadius,
      splashColor: splashColor,
      highlightColor: highlightColor,
      enableFeedback: enableFeedback,
      bounceOnTap: bounceOnTap,
      child: this,
    );
  }
} 