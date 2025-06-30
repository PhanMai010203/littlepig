import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that animates between different child sizes smoothly
/// Part of the Phase 2 Animation Widget Library
class AnimatedSizeSwitcher extends StatefulWidget {
  const AnimatedSizeSwitcher({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.enabled = true,
    this.curve = Curves.easeInOut,
    this.reverseCurve,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Curve? reverseCurve;
  final Alignment alignment;
  final Clip clipBehavior;
  final bool enabled;

  @override
  State<AnimatedSizeSwitcher> createState() => _AnimatedSizeSwitcherState();
}

class _AnimatedSizeSwitcherState extends State<AnimatedSizeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'AnimatedSizeSwitcher',
    );
  }

  @override
  void didUpdateWidget(AnimatedSizeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger animation when child changes
    if (widget.child.key != oldWidget.child.key ||
        widget.child.runtimeType != oldWidget.child.runtimeType) {
      _controller.forward(from: 0.0);
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
    if (!widget.enabled || !AnimationUtils.shouldAnimate()) {
      return widget.child;
    }

    return AnimatedSize(
      duration: AnimationUtils.getDuration(widget.duration),
      curve: AnimationUtils.getCurve(widget.curve),
      alignment: widget.alignment,
      clipBehavior: widget.clipBehavior,
      child: AnimatedSwitcher(
        duration: AnimationUtils.getDuration(widget.duration),
        reverseDuration: AnimationUtils.getDuration(widget.duration),
        switchInCurve: AnimationUtils.getCurve(widget.curve),
        switchOutCurve:
            AnimationUtils.getCurve(widget.reverseCurve ?? widget.curve),
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: widget.alignment,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Extension to easily add animated size switching to any widget
extension AnimatedSizeSwitcherExtension on Widget {
  /// Wraps this widget with AnimatedSizeSwitcher
  Widget animatedSizeSwitcher({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Curve? reverseCurve,
    Alignment alignment = Alignment.center,
    Clip clipBehavior = Clip.hardEdge,
    bool enabled = true,
  }) {
    return AnimatedSizeSwitcher(
      duration: duration,
      curve: curve,
      reverseCurve: reverseCurve,
      alignment: alignment,
      clipBehavior: clipBehavior,
      enabled: enabled,
      child: this,
    );
  }
}
