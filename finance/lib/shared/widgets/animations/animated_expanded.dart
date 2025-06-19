import 'package:flutter/material.dart';
import 'animation_utils.dart';

/// A widget that smoothly expands and collapses its child with fade effect
/// Part of the Phase 2 Animation Widget Library
class AnimatedExpanded extends StatefulWidget {
  const AnimatedExpanded({
    required this.child,
    required this.expand,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.reverseCurve,
    this.fadeInOut = true,
    this.axis = Axis.vertical,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final bool expand;
  final Duration duration;
  final Curve curve;
  final Curve? reverseCurve;
  final bool fadeInOut;
  final Axis axis;
  final Alignment alignment;

  @override
  State<AnimatedExpanded> createState() => _AnimatedExpandedState();
}

class _AnimatedExpandedState extends State<AnimatedExpanded>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationUtils.createController(
      vsync: this,
      duration: widget.duration,
      debugLabel: 'AnimatedExpanded',
    );

    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _controller,
      curve: widget.curve,
      reverseCurve: widget.reverseCurve,
    ));

    if (widget.fadeInOut) {
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(AnimationUtils.createCurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ));
    } else {
      _fadeAnimation = AlwaysStoppedAnimation(1.0);
    }

    // Set initial state
    if (widget.expand) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedExpanded oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.expand != widget.expand) {
      if (widget.expand) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
      return widget.expand ? widget.child : const SizedBox.shrink();
    }

    return AnimationUtils.animatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: widget.alignment,
            heightFactor:
                widget.axis == Axis.vertical ? _sizeAnimation.value : null,
            widthFactor:
                widget.axis == Axis.horizontal ? _sizeAnimation.value : null,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Extension to easily add animated expansion to any widget
extension AnimatedExpandedExtension on Widget {
  /// Wraps this widget with AnimatedExpanded
  Widget animatedExpanded({
    required bool expand,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Curve? reverseCurve,
    bool fadeInOut = true,
    Axis axis = Axis.vertical,
    Alignment alignment = Alignment.center,
  }) {
    return AnimatedExpanded(
      expand: expand,
      duration: duration,
      curve: curve,
      reverseCurve: reverseCurve,
      fadeInOut: fadeInOut,
      axis: axis,
      alignment: alignment,
      child: this,
    );
  }
}
