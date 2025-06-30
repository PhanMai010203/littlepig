import 'package:flutter/material.dart';

/// A reusable implicit animation that counts smoothly between two numeric
/// values and lets you decide how to render each frame.
///
/// Typical usage – simple text:
/// ```dart
/// AnimatedCount(
///   from: 0,
///   to: 1500,
///   duration: const Duration(milliseconds: 600),
///   builder: (context, value) => Text(
///     '4${value.toStringAsFixed(0)}',
///     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
///   ),
/// )
/// ```
///
/// Advanced usage – wrap inside `RichText` to combine with other spans:
/// ```dart
/// AnimatedCount(
///   from: budget.amount,
///   to: remaining,
///   builder: (context, value) {
///     final isOverspent = value < 0;
///     return RichText(
///       text: TextSpan(
///         style: Theme.of(context).textTheme.bodyMedium,
///         children: [
///           TextSpan(
///             text: '4${value.abs().toStringAsFixed(0)}',
///             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
///           ),
///           TextSpan(
///             text: isOverspent ? ' overspent' : ' left',
///           ),
///         ],
///       ),
///     );
///   },
/// )
/// ```
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.from,
    required this.to,
    required this.builder,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.linear,
  });

  /// Starting value for the tween.
  final double from;

  /// Target/end value for the tween.
  final double to;

  /// Widget builder that receives the intermediate `value` on every frame and
  /// returns the widget to paint.
  final Widget Function(BuildContext context, double value) builder;

  /// How long the animation should last.
  final Duration duration;

  /// Easing curve for the tween.
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: from, end: to),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) => builder(context, animatedValue),
    );
  }
} 