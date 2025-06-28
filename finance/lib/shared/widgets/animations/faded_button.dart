import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'animation_utils.dart';
import '../../../core/services/platform_service.dart';

/// iOS-specific faded button implementation with precise animation timing
/// Port from budget app for platform-appropriate interactions
class FadedButton extends StatefulWidget {
  const FadedButton({
    super.key,
    required this.child,
    this.pressedOpacity = 0.5,
    required this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.color,
    this.hapticFeedback = true,
    this.disabled = false,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedOpacity;
  final Widget child;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool hapticFeedback;
  final bool disabled;

  @override
  State<FadedButton> createState() => _FadedButtonState();
}

class _FadedButtonState extends State<FadedButton>
    with SingleTickerProviderStateMixin {
  // iOS-specific timing constants from budget app
  static const Duration kFadeOutDuration = Duration(milliseconds: 150);
  static const Duration kFadeInDuration = Duration(milliseconds: 230);
  
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationUtils.createController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      debugLabel: 'FadedButton',
    );
    
    _animationController.value = 0.0;
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity;
  }

  @override
  void didUpdateWidget(FadedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pressedOpacity != widget.pressedOpacity) {
      _setTween();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (widget.disabled) return;
    
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (widget.disabled) return;
    
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
    }
    if (_animationController.value >= 1) {
      _animationController.animateTo(
        0.0,
        duration: kFadeInDuration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleTapCancel() {
    if (widget.disabled) return;
    
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTap() {
    if (widget.disabled) return;
    
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.disabled) return;
    
    // iOS-specific heavy haptic feedback for long press
    if (widget.hapticFeedback && PlatformService.supportsHaptics) {
      HapticFeedback.heavyImpact();
    }
    
    _animate();
    widget.onLongPress?.call();
  }

  void _animate() {
    if (!AnimationUtils.shouldAnimate() || !AnimationUtils.canStartAnimation()) {
      return;
    }

    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(
            1.0,
            duration: kFadeOutDuration,
            curve: Curves.easeInOutCubicEmphasized,
          )
        : _animationController.animateTo(
            0.0,
            duration: kFadeInDuration,
            curve: Curves.easeOutCubic,
          );
    
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) {
        _animate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget tappable = MouseRegion(
      cursor: kIsWeb && !widget.disabled 
          ? SystemMouseCursors.click 
          : MouseCursor.defer,
      child: IgnorePointer(
        ignoring: widget.disabled || 
                 (widget.onLongPress == null && widget.onTap == null),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap != null ? _handleTap : null,
          onLongPress: widget.onLongPress != null ? _handleLongPress : null,
          child: Semantics(
            button: true,
            enabled: !widget.disabled,
            child: AnimationUtils.animatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: child,
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.zero,
                  color: widget.color ?? Colors.transparent,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );

    // Add right-click support for web/desktop
    if (!kIsWeb && widget.onLongPress != null) {
      return tappable;
    }

    void onPointerDown(PointerDownEvent event) {
      if (widget.disabled) return;
      
      // Check if right mouse button clicked
      if (event.kind == PointerDeviceKind.mouse &&
          event.buttons == kSecondaryMouseButton) {
        if (widget.onLongPress != null) {
          widget.onLongPress!();
        }
      }
    }

    return Listener(
      onPointerDown: onPointerDown,
      child: tappable,
    );
  }
}