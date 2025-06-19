import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../animations/animation_utils.dart';
import '../../../core/services/platform_service.dart';

/// Material 3 OpenContainer navigation widget
/// Phase 4 implementation for smooth container transitions
class OpenContainerNavigation extends StatelessWidget {
  const OpenContainerNavigation({
    required this.openPage,
    required this.closedBuilder,
    this.onOpen,
    this.transitionType = ContainerTransitionType.fade,
    this.closedElevation = 0.0,
    this.openElevation = 0.0,
    this.closedShape,
    this.openShape,
    this.closedColor,
    this.openColor,
    this.middleColor,
    this.useRootNavigator = false,
    this.routeSettings,
    super.key,
  });

  /// The page to open when the container is tapped
  final Widget openPage;

  /// Builder for the closed container
  final Widget Function(VoidCallback openContainer) closedBuilder;

  /// Callback when the container is opened
  final VoidCallback? onOpen;

  /// Type of transition animation
  final ContainerTransitionType transitionType;

  /// Elevation for the closed container
  final double closedElevation;

  /// Elevation for the open container
  final double openElevation;

  /// Shape for the closed container
  final ShapeBorder? closedShape;

  /// Shape for the open container
  final ShapeBorder? openShape;

  /// Background color for the closed container
  final Color? closedColor;

  /// Background color for the open container
  final Color? openColor;

  /// Color used during the transition
  final Color? middleColor;

  /// Whether to use the root navigator
  final bool useRootNavigator;

  /// Route settings for the opened page
  final RouteSettings? routeSettings;

  @override
  Widget build(BuildContext context) {
    // Skip container transition if animations are disabled
    if (!AnimationUtils.shouldAnimate()) {
      return _buildFallbackNavigation(context);
    }

    // Use simpler transition for reduced animations
    final effectiveTransitionType = _getEffectiveTransitionType();

    return OpenContainer(
      transitionType: effectiveTransitionType,
      transitionDuration: AnimationUtils.getDuration(
        const Duration(milliseconds: 300),
      ),
      openBuilder: (context, _) => openPage,
      closedBuilder: (context, openContainer) {
        return closedBuilder(() {
          onOpen?.call();
          openContainer();
        });
      },
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedShape: closedShape ?? _getDefaultClosedShape(context),
      openShape: openShape ?? _getDefaultOpenShape(context),
      closedColor: closedColor ?? _getDefaultClosedColor(context),
      openColor: openColor ?? _getDefaultOpenColor(context),
      middleColor: middleColor ?? _getDefaultMiddleColor(context),
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
    );
  }

  /// Build fallback navigation when animations are disabled
  Widget _buildFallbackNavigation(BuildContext context) {
    return closedBuilder(() {
      onOpen?.call();
      Navigator.of(
        context,
        rootNavigator: useRootNavigator,
      ).push(
        MaterialPageRoute(
          builder: (context) => openPage,
          settings: routeSettings,
        ),
      );
    });
  }

  /// Get effective transition type based on animation settings
  ContainerTransitionType _getEffectiveTransitionType() {
    // Use fade for reduced animations
    if (!AnimationUtils.shouldUseComplexAnimations()) {
      return ContainerTransitionType.fade;
    }

    return transitionType;
  }

  /// Get default closed shape based on platform
  ShapeBorder _getDefaultClosedShape(BuildContext context) {
    if (PlatformService.getPlatform() == PlatformOS.isIOS) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      );
    }

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  /// Get default open shape (typically no border radius for full screen)
  ShapeBorder _getDefaultOpenShape(BuildContext context) {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    );
  }

  /// Get default closed color from theme
  Color _getDefaultClosedColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get default open color from theme
  Color _getDefaultOpenColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get default middle color for transition
  Color _getDefaultMiddleColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary.withOpacity(0.1);
  }
}

/// Card-to-page navigation using OpenContainer
class OpenContainerCard extends StatelessWidget {
  const OpenContainerCard({
    required this.child,
    required this.openPage,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.elevation = 2.0,
    this.shape,
    this.backgroundColor,
    super.key,
  });

  /// Content of the card
  final Widget child;

  /// Page to navigate to when card is tapped
  final Widget openPage;

  /// Additional tap callback
  final VoidCallback? onTap;

  /// Padding inside the card
  final EdgeInsets padding;

  /// Margin around the card
  final EdgeInsets margin;

  /// Elevation of the card
  final double elevation;

  /// Shape of the card
  final ShapeBorder? shape;

  /// Background color of the card
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: OpenContainerNavigation(
        openPage: openPage,
        onOpen: onTap,
        closedElevation: elevation,
        closedShape: shape,
        closedColor: backgroundColor,
        closedBuilder: (openContainer) {
          return Material(
            clipBehavior: Clip.antiAlias,
            shape: shape ?? _getDefaultShape(context),
            color: backgroundColor ?? Theme.of(context).colorScheme.surface,
            elevation: elevation,
            child: InkWell(
              onTap: openContainer,
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  ShapeBorder _getDefaultShape(BuildContext context) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    );
  }
}

/// List item to page navigation using OpenContainer
class OpenContainerListTile extends StatelessWidget {
  const OpenContainerListTile({
    required this.openPage,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    super.key,
  });

  /// Page to navigate to when list tile is tapped
  final Widget openPage;

  /// Leading widget
  final Widget? leading;

  /// Title widget
  final Widget? title;

  /// Subtitle widget
  final Widget? subtitle;

  /// Trailing widget
  final Widget? trailing;

  /// Additional tap callback
  final VoidCallback? onTap;

  /// Content padding
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    return OpenContainerNavigation(
      openPage: openPage,
      onOpen: onTap,
      closedBuilder: (openContainer) {
        return ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          contentPadding: contentPadding,
          onTap: openContainer,
        );
      },
    );
  }
}

/// Extension methods for easy OpenContainer usage
extension OpenContainerExtension on Widget {
  /// Wrap this widget in an OpenContainer navigation
  Widget openContainerNavigation({
    required Widget openPage,
    VoidCallback? onOpen,
    ContainerTransitionType transitionType = ContainerTransitionType.fade,
    double closedElevation = 0.0,
    double openElevation = 0.0,
    ShapeBorder? closedShape,
    ShapeBorder? openShape,
    Color? closedColor,
    Color? openColor,
    Color? middleColor,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
  }) {
    return OpenContainerNavigation(
      openPage: openPage,
      onOpen: onOpen,
      transitionType: transitionType,
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedShape: closedShape,
      openShape: openShape,
      closedColor: closedColor,
      openColor: openColor,
      middleColor: middleColor,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      closedBuilder: (openContainer) {
        return GestureDetector(
          onTap: openContainer,
          child: this,
        );
      },
    );
  }

  /// Wrap this widget in an OpenContainer card
  Widget openContainerCard({
    required Widget openPage,
    VoidCallback? onTap,
    EdgeInsets padding = const EdgeInsets.all(16.0),
    EdgeInsets margin = const EdgeInsets.all(8.0),
    double elevation = 2.0,
    ShapeBorder? shape,
    Color? backgroundColor,
  }) {
    return OpenContainerCard(
      child: this,
      openPage: openPage,
      onTap: onTap,
      padding: padding,
      margin: margin,
      elevation: elevation,
      shape: shape,
      backgroundColor: backgroundColor,
    );
  }
}
