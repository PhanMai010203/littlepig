import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that provides scale + fade transitions when switching between children
/// Part of the Phase 2 Animation Widget Library
class ScaledAnimatedSwitcher extends StatefulWidget {
  const ScaledAnimatedSwitcher({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.switchInCurve = Curves.easeIn,
    this.switchOutCurve = Curves.easeOut,
    this.transitionBuilder,
    this.layoutBuilder,
    this.scaleIn = 0.8,
    this.scaleOut = 1.2,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final AnimatedSwitcherLayoutBuilder? layoutBuilder;
  final double scaleIn;
  final double scaleOut;
  final Alignment alignment;

  @override
  State<ScaledAnimatedSwitcher> createState() => _ScaledAnimatedSwitcherState();
}

class _ScaledAnimatedSwitcherState extends State<ScaledAnimatedSwitcher> {
  Widget _defaultTransitionBuilder(Widget child, Animation<double> animation) {
    final scaleAnimation = Tween<double>(
      begin: widget.scaleIn,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: widget.switchInCurve,
    ));

    return ScaleTransition(
      scale: scaleAnimation,
      alignment: widget.alignment,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  Widget _defaultLayoutBuilder(
      Widget? currentChild, List<Widget> previousChildren) {
    return Stack(
      alignment: widget.alignment,
      children: <Widget>[
        ...previousChildren,
        if (currentChild != null) currentChild,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Skip animation wrapper if animations are disabled
    if (!AnimationUtils.shouldAnimate()) {
      return widget.child;
    }

    return AnimatedSwitcher(
      duration: AnimationUtils.getDuration(widget.duration),
      reverseDuration: AnimationUtils.getDuration(widget.reverseDuration),
      switchInCurve: AnimationUtils.getCurve(widget.switchInCurve),
      switchOutCurve: AnimationUtils.getCurve(widget.switchOutCurve),
      transitionBuilder: widget.transitionBuilder ?? _defaultTransitionBuilder,
      layoutBuilder: widget.layoutBuilder ?? _defaultLayoutBuilder,
      child: widget.child,
    );
  }
}

/// Extension to easily add scaled animated switching to any widget
extension ScaledAnimatedSwitcherExtension on Widget {
  /// Wraps this widget with ScaledAnimatedSwitcher
  Widget scaledAnimatedSwitcher({
    Duration duration = const Duration(milliseconds: 300),
    Duration? reverseDuration,
    Curve switchInCurve = Curves.easeIn,
    Curve switchOutCurve = Curves.easeOut,
    AnimatedSwitcherTransitionBuilder? transitionBuilder,
    AnimatedSwitcherLayoutBuilder? layoutBuilder,
    double scaleIn = 0.8,
    double scaleOut = 1.2,
    Alignment alignment = Alignment.center,
  }) {
    return ScaledAnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder,
      layoutBuilder: layoutBuilder,
      scaleIn: scaleIn,
      scaleOut: scaleOut,
      alignment: alignment,
      child: this,
    );
  }
}
