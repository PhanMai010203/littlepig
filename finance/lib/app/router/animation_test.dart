import 'package:flutter/material.dart';

class AppTransitions {
  // Cashew-style subtle slide + fade
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

  // Modal/bottom sheet style
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

  // Horizontal slide (for tab-like navigation)
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