import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/animations/animation_utils.dart';
import '../../core/services/platform_service.dart';

/// Enhanced page transitions for the Finance app
/// Phase 4 implementation following the animation framework plan
class AppPageTransitions {
  /// Slide transition with platform-aware curves and animation settings
  static Page<T> slideTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    SlideDirection direction = SlideDirection.fromRight,
    LocalKey? key,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: _getSlideBeginOffset(direction),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AnimationUtils.getCurve(Curves.easeInOutCubicEmphasized),
          )),
          child: child,
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 300),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 200),
      ),
    );
  }

  /// Fade transition with customizable opacity curve
  static Page<T> fadeTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AnimationUtils.getCurve(Curves.easeInOutQuart),
          ),
          child: child,
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 250),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 200),
      ),
    );
  }

  /// Scale transition with elastic curves for enhanced animation level
  static Page<T> scaleTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
    Alignment alignment = Alignment.center,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curve = AnimationUtils.shouldUseComplexAnimations()
            ? Curves.elasticOut
            : Curves.easeInOutBack;

        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: AnimationUtils.getCurve(curve),
          ),
          alignment: alignment,
          child: child,
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 400),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 300),
      ),
    );
  }

  /// Slide and fade combination for modal-like transitions
  static Page<T> slideFadeTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
    SlideDirection direction = SlideDirection.fromBottom,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: _getSlideBeginOffset(direction),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: AnimationUtils.getCurve(Curves.easeOutCubic),
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 350),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 250),
      ),
    );
  }

  /// Modal slide transition - ideal for fullscreen dialogs and bottom sheets
  /// Features: subtle slide from bottom with staggered fade effect
  static Page<T> modalSlideTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
    bool fullscreenDialog = true,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      fullscreenDialog: fullscreenDialog,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AnimationUtils.getCurve(Curves.easeOutCubic),
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
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 300),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 125),
      ),
    );
  }

  /// Subtle slide transition - gentle slide with fade for elegant page changes
  /// Features: small slide offset (5% of screen) with fade
  static Page<T> subtleSlideTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
    SlideDirection direction = SlideDirection.fromBottom,
    double slideOffset = 0.05,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: _getSubtleSlideOffset(direction, slideOffset),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AnimationUtils.getCurve(Curves.easeOut),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 250),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 200),
      ),
    );
  }

  /// Horizontal slide transition - optimized for tab-like navigation
  /// Features: smooth horizontal slide with fade, reduced distance for fluid feel
  static Page<T> horizontalSlideTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
    bool fromRight = true,
    double slideDistance = 0.3,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: Offset(fromRight ? slideDistance : -slideDistance, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AnimationUtils.getCurve(Curves.easeOutCubic),
        ));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 275),
      ),
      reverseTransitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 200),
      ),
    );
  }

  /// No transition page (for shell routes and performance)
  static Page<T> noTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
  }) {
    return NoTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
    );
  }

  /// Platform-aware default transition
  /// Uses platform preferences to select the most appropriate transition
  static Page<T> platformTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    LocalKey? key,
  }) {
    // Return no transition if animations are disabled
    if (!AnimationUtils.shouldAnimate()) {
      return noTransitionPage(
        child: child,
        name: name,
        arguments: arguments,
        key: key,
      );
    }

    // Select platform-appropriate transition
    switch (PlatformService.getPlatform()) {
      case PlatformOS.isIOS:
        return slideTransitionPage(
          child: child,
          name: name,
          arguments: arguments,
          key: key,
          direction: SlideDirection.fromRight,
        );
      case PlatformOS.isAndroid:
        return slideFadeTransitionPage(
          child: child,
          name: name,
          arguments: arguments,
          key: key,
          direction: SlideDirection.fromBottom,
        );
      case PlatformOS.isWeb:
        return fadeTransitionPage(
          child: child,
          name: name,
          arguments: arguments,
          key: key,
        );
      default:
        return scaleTransitionPage(
          child: child,
          name: name,
          arguments: arguments,
          key: key,
        );
    }
  }

  /// Get slide begin offset based on direction
  static Offset _getSlideBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
    }
  }

  /// Get subtle slide offset based on direction and offset amount
  static Offset _getSubtleSlideOffset(SlideDirection direction, double offset) {
    switch (direction) {
      case SlideDirection.fromLeft:
        return Offset(-offset, 0.0);
      case SlideDirection.fromRight:
        return Offset(offset, 0.0);
      case SlideDirection.fromTop:
        return Offset(0.0, -offset);
      case SlideDirection.fromBottom:
        return Offset(0.0, offset);
    }
  }
}

/// Slide direction for page transitions
enum SlideDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Extension methods for easy page transition usage
extension PageTransitionExtension on Widget {
  /// Wrap this widget in a slide transition page
  Page<T> slideTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
    SlideDirection direction = SlideDirection.fromRight,
  }) {
    return AppPageTransitions.slideTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
      direction: direction,
    );
  }

  /// Wrap this widget in a fade transition page
  Page<T> fadeTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
  }) {
    return AppPageTransitions.fadeTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
    );
  }

  /// Wrap this widget in a scale transition page
  Page<T> scaleTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
    Alignment alignment = Alignment.center,
  }) {
    return AppPageTransitions.scaleTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
      alignment: alignment,
    );
  }

  /// Wrap this widget in a modal slide transition page
  Page<T> modalSlideTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
    bool fullscreenDialog = true,
  }) {
    return AppPageTransitions.modalSlideTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// Wrap this widget in a subtle slide transition page
  Page<T> subtleSlideTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
    SlideDirection direction = SlideDirection.fromBottom,
    double slideOffset = 0.05,
  }) {
    return AppPageTransitions.subtleSlideTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
      direction: direction,
      slideOffset: slideOffset,
    );
  }

  /// Wrap this widget in a horizontal slide transition page
  Page<T> horizontalSlideTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
    bool fromRight = true,
    double slideDistance = 0.3,
  }) {
    return AppPageTransitions.horizontalSlideTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
      fromRight: fromRight,
      slideDistance: slideDistance,
    );
  }

  /// Wrap this widget in a platform-aware transition page
  Page<T> platformTransition<T extends Object?>({
    String? name,
    Object? arguments,
    LocalKey? key,
  }) {
    return AppPageTransitions.platformTransitionPage<T>(
      child: this,
      name: name,
      arguments: arguments,
      key: key,
    );
  }
}
