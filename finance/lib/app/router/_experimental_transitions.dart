import 'package:flutter/material.dart';

/// EXPERIMENTAL ANIMATION REFERENCE - DO NOT USE IN PRODUCTION
/// 
/// This file contains experimental animation transitions that were used for testing.
/// These transitions have been properly integrated into the main animation system
/// at `lib/app/router/page_transitions.dart` as part of the `AppPageTransitions` class.
/// 
/// Use `AppPageTransitions.modalSlideTransitionPage()` instead of `AppTransitions.modalSlide()`
/// Use `AppPageTransitions.subtleSlideTransitionPage()` instead of `AppTransitions.slideUpFade()`
/// Use `AppPageTransitions.horizontalSlideTransitionPage()` instead of `AppTransitions.horizontalSlide()`
/// 
/// This file is kept for reference purposes only.
/// 
/// @deprecated Use AppPageTransitions methods instead
class ExperimentalAppTransitions {
  /// @deprecated Use AppPageTransitions.subtleSlideTransitionPage() instead
  static Widget slideUpFade({
    required Animation<double> animation,
    required Widget child,
    double slideOffset = 0.05,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: Offset(0, slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /// @deprecated Use AppPageTransitions.modalSlideTransitionPage() instead
  static Widget modalSlide({
    required Animation<double> animation,
    required Widget child,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.7),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }

  /// @deprecated Use AppPageTransitions.horizontalSlideTransitionPage() instead
  static Widget horizontalSlide({
    required Animation<double> animation,
    required Widget child,
    bool fromRight = true,
  }) {
    final slideAnimation = Tween<Offset>(
      begin: Offset(fromRight ? 0.3 : -0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}