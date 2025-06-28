import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'animation_utils.dart';
import 'faded_button.dart';
import '../../../core/services/platform_service.dart';
import '../../../core/services/animation_performance_service.dart';
import '../../utils/performance_optimization.dart';

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
  
  // Phase 3: Cache platform detection for performance
  late final bool _isIOS;
  late final bool _isAndroid;
  late final bool _isDesktop;

  @override
  void initState() {
    super.initState();

    // Phase 3: Cache platform detection once at initialization
    final platform = PlatformService.getPlatform();
    _isIOS = platform == PlatformOS.isIOS;
    _isAndroid = platform == PlatformOS.isAndroid;
    _isDesktop = PlatformService.isDesktop;
    
    // Track platform optimization usage
    PerformanceOptimizations.trackPlatformOptimization(
      'TappableWidget', 
      platform.toString(), 
      'cached platform detection'
    );

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
    if (!AnimationUtils.shouldAnimate() ||
        !AnimationUtils.canStartAnimation()) {
      return;
    }

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
    if (!AnimationUtils.shouldAnimate() ||
        !AnimationUtils.canStartAnimation()) {
      return;
    }

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
    // Phase 3: Use cached platform detection for better performance
    if (_isIOS) {
      PerformanceOptimizations.trackPlatformOptimization(
        'TappableWidget', 
        'iOS', 
        'FadedButton'
      );
      return FadedButton(
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        pressedOpacity: _getIOSPressedOpacity(),
        borderRadius: widget.borderRadius,
        hapticFeedback: widget.hapticFeedback,
        disabled: false,
        child: widget.child,
      );
    }

    // Use Material implementation for Android and other platforms
    return _buildMaterialTappable(context);
  }

  /// Get appropriate pressed opacity for iOS based on animation type
  double _getIOSPressedOpacity() {
    switch (widget.animationType) {
      case TapAnimationType.opacity:
      case TapAnimationType.both:
        return 0.7; // Match the opacity animation value
      case TapAnimationType.scale:
      case TapAnimationType.none:
        return 0.5; // Default iOS pressed opacity
    }
  }

  /// Build Material Design tappable widget for Android and other platforms
  /// Phase 3: Enhanced with platform-specific optimizations
  Widget _buildMaterialTappable(BuildContext context) {
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

    // Phase 3: Use platform-optimized interaction widgets
    Widget gestureChild = child;
    if (widget.onTap != null ||
        widget.onLongPress != null ||
        widget.onDoubleTap != null) {
      
      if (_isAndroid) {
        // Use InkWell with InkSparkle for optimal Android performance
        PerformanceOptimizations.trackPlatformOptimization(
          'TappableWidget', 
          'Android', 
          'InkWell with InkSparkle'
        );
        gestureChild = Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap != null ? _handleTap : null,
            onLongPress: widget.onLongPress != null ? _handleLongPress : null,
            onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
            splashFactory: InkSparkle.splashFactory, // More efficient splash
            splashColor: widget.splashColor,
            highlightColor: widget.highlightColor,
            borderRadius: widget.borderRadius,
            enableFeedback: widget.enableFeedback,
            child: child,
          ),
        );
      } else {
        // Use GestureDetector for other platforms
        gestureChild = GestureDetector(
          onTapDown: widget.animationType != TapAnimationType.none
              ? _handleTapDown
              : null,
          onTapUp:
              widget.animationType != TapAnimationType.none ? _handleTapUp : null,
          onTapCancel: widget.animationType != TapAnimationType.none
              ? _handleTapCancel
              : null,
          onTap: widget.onTap != null ? _handleTap : null,
          onLongPress: widget.onLongPress != null ? _handleLongPress : null,
          onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
          child: child,
        );
      }
    }

    // Phase 3: Use cached platform detection for web/desktop
    if (kIsWeb || _isDesktop) {
      return _addMouseSupport(gestureChild);
    }

    return gestureChild;
  }

  /// Add mouse support with right-click handling for web/desktop
  Widget _addMouseSupport(Widget child) {
    if (widget.onLongPress == null) {
      return child;
    }

    void onPointerDown(PointerDownEvent event) {
      // Check if right mouse button clicked
      if (event.kind == PointerDeviceKind.mouse &&
          event.buttons == kSecondaryMouseButton) {
        _handleLongPress();
      }
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: child,
    );
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
