import 'package:flutter/material.dart';
import '../../../core/services/platform_service.dart';
import '../animations/fade_in.dart';
import '../animations/scale_in.dart';
import '../animations/slide_in.dart';
import '../animations/animation_utils.dart';
import '../../utils/responsive_layout_builder.dart';

/// PopupFramework Widget - Phase 3.1 Implementation
///
/// A reusable template for dialogs and popups with:
/// - Material 3 design integration
/// - Platform-aware layouts (iOS centered vs Android left-aligned)
/// - Consistent spacing and typography
/// - Animation framework integration
/// - Flexible content structure
class PopupFramework extends StatelessWidget {
  const PopupFramework({
    required this.child,
    this.title,
    this.subtitle,
    this.customSubtitleWidget,
    this.hasPadding = true,
    this.underTitleSpace = true,
    this.showCloseButton = false,
    this.icon,
    this.outsideExtraWidget,
    this.backgroundColor,
    this.surfaceTintColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.alignment,
    this.constraints,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.iconColor,
    this.closeButtonIcon,
    this.onClosePressed,
    this.semanticLabel,
    this.animationType = PopupAnimationType.scaleIn,
    this.animationDelay = Duration.zero,
    this.animationDuration,
    this.animationCurve,
    super.key,
  });

  /// Main content widget
  final Widget child;

  /// Dialog title text
  final String? title;

  /// Dialog subtitle text
  final String? subtitle;

  /// Custom subtitle widget (overrides subtitle text)
  final Widget? customSubtitleWidget;

  /// Whether to apply padding to the child content
  final bool hasPadding;

  /// Whether to add space under the title/subtitle section
  final bool underTitleSpace;

  /// Whether to show a close button in the top-right
  final bool showCloseButton;

  /// Optional icon to display before the title
  final IconData? icon;

  /// Extra widget to display outside the main content area
  final Widget? outsideExtraWidget;

  /// Background color (defaults to theme surface)
  final Color? backgroundColor;

  /// Surface tint color for Material 3
  final Color? surfaceTintColor;

  /// Shadow color
  final Color? shadowColor;

  /// Dialog elevation
  final double? elevation;

  /// Dialog shape
  final ShapeBorder? shape;

  /// Dialog alignment on screen
  final Alignment? alignment;

  /// Size constraints for the dialog
  final BoxConstraints? constraints;

  /// Custom text style for title
  final TextStyle? titleTextStyle;

  /// Custom text style for subtitle
  final TextStyle? subtitleTextStyle;

  /// Icon color
  final Color? iconColor;

  /// Custom close button icon
  final IconData? closeButtonIcon;

  /// Callback when close button is pressed
  final VoidCallback? onClosePressed;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Animation type for popup entrance
  final PopupAnimationType animationType;

  /// Animation delay
  final Duration animationDelay;

  /// Animation duration (overrides AnimationUtils)
  final Duration? animationDuration;

  /// Animation curve (overrides AnimationUtils)
  final Curve? animationCurve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Platform-aware dialog properties
    final isIOS = PlatformService.getPlatform() == PlatformOS.isIOS;
    final isMobile = PlatformService.isMobile;

    // Default dialog alignment based on platform
    final dialogAlignment = alignment ??
        (PlatformService.prefersCenteredDialogs
            ? Alignment.center
            : Alignment.bottomCenter);

    // Build the dialog content
    Widget dialogContent = _buildDialogContent(
        context, theme, colorScheme, textTheme, isIOS, isMobile);

    // Apply animation wrapper
    dialogContent = _applyAnimation(dialogContent);

    // Wrap in Dialog widget
    return Dialog(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      surfaceTintColor: surfaceTintColor ?? colorScheme.surfaceTint,
      shadowColor: shadowColor ?? colorScheme.shadow,
      elevation: elevation ?? (isMobile ? 24.0 : 6.0),
      shape: shape ?? _getDefaultShape(context, isIOS),
      alignment: dialogAlignment,
      child: ConstrainedBox(
        constraints: constraints ?? _getDefaultConstraints(context, isMobile),
        child: Semantics(
          label: semanticLabel ?? title,
          child: dialogContent,
        ),
      ),
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isIOS,
    bool isMobile,
  ) {
    final List<Widget> contentChildren = [];

    // Header section (title, subtitle, icon, close button)
    final headerWidget =
        _buildHeader(context, theme, colorScheme, textTheme, isIOS, isMobile);
    if (headerWidget != null) {
      contentChildren.add(headerWidget);

      if (underTitleSpace) {
        contentChildren.add(SizedBox(height: isMobile ? 16.0 : 12.0));
      }
    }

    // Main content
    Widget mainContent = child;
    if (hasPadding) {
      final padding =
          _getContentPadding(isMobile, hasHeader: headerWidget != null);
      mainContent = Padding(
        padding: padding,
        child: mainContent,
      );
    }
    contentChildren.add(Flexible(child: mainContent));

    // Outside extra widget
    if (outsideExtraWidget != null) {
      contentChildren.add(const SizedBox(height: 12.0));
      contentChildren.add(outsideExtraWidget!);
    }

    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: contentChildren,
      ),
    );
  }

  Widget? _buildHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isIOS,
    bool isMobile,
  ) {
    if (title == null &&
        subtitle == null &&
        customSubtitleWidget == null &&
        icon == null &&
        !showCloseButton) {
      return null;
    }

    final headerPadding = _getHeaderPadding(isMobile);

    return Padding(
      padding: headerPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            isIOS ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Title row with optional icon and close button
          if (title != null || icon != null || showCloseButton)
            _buildTitleRow(context, colorScheme, textTheme, isIOS),

          // Subtitle
          if (subtitle != null || customSubtitleWidget != null)
            Padding(
              padding: EdgeInsets.only(top: isMobile ? 8.0 : 6.0),
              child: customSubtitleWidget ??
                  _buildSubtitle(context, textTheme, colorScheme, isIOS),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isIOS,
  ) {
    final List<Widget> titleRowChildren = [];

    // Icon
    if (icon != null) {
      titleRowChildren.add(
        Icon(
          icon,
          color: iconColor ?? colorScheme.primary,
          size: 24.0,
        ),
      );
      if (title != null) {
        titleRowChildren.add(const SizedBox(width: 12.0));
      }
    }

    // Title
    if (title != null) {
      final titleWidget = Text(
        title!,
        style: titleTextStyle ??
            textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
        textAlign: isIOS ? TextAlign.center : TextAlign.start,
      );

      if (showCloseButton && !isIOS) {
        titleRowChildren.add(Expanded(child: titleWidget));
      } else {
        titleRowChildren.add(titleWidget);
      }
    } else if (showCloseButton && !isIOS) {
      titleRowChildren.add(const Spacer());
    }

    // Close button
    if (showCloseButton) {
      titleRowChildren.add(
        IconButton(
          onPressed: onClosePressed ?? () => Navigator.of(context).pop(),
          icon: Icon(closeButtonIcon ?? Icons.close),
          iconSize: 20.0,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (isIOS && showCloseButton) {
      // Center the title content with close button positioned absolutely
      return Stack(
        children: [
          if (title != null || icon != null)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children:
                    titleRowChildren.take(titleRowChildren.length - 1).toList(),
              ),
            ),
          Positioned(
            right: 0,
            child: titleRowChildren.last,
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment:
            isIOS ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: titleRowChildren.map((child) {
          // Wrap text widgets with Flexible to prevent overflow
          if (child is Text) {
            return Flexible(child: child);
          }
          return child;
        }).toList(),
      );
    }
  }

  Widget _buildSubtitle(BuildContext context, TextTheme textTheme, ColorScheme colorScheme, bool isIOS) {
    return Text(
      subtitle!,
      style: subtitleTextStyle ??
          textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
      textAlign: isIOS ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _applyAnimation(Widget content) {
    if (!AnimationUtils.shouldAnimate()) {
      return content;
    }

    final duration = animationDuration ??
        AnimationUtils.getDuration(const Duration(milliseconds: 300));
    final curve =
        animationCurve ?? AnimationUtils.getCurve(Curves.easeOutCubic);

    switch (animationType) {
      case PopupAnimationType.fadeIn:
        return FadeIn(
          delay: animationDelay,
          duration: duration,
          curve: curve,
          child: content,
        );

      case PopupAnimationType.scaleIn:
        return ScaleIn(
          delay: animationDelay,
          duration: duration,
          curve: curve,
          child: content,
        );

      case PopupAnimationType.slideUp:
        return SlideIn(
          delay: animationDelay,
          duration: duration,
          curve: curve,
          direction: SlideDirection.up,
          distance: 0.3,
          child: content,
        );

      case PopupAnimationType.slideDown:
        return SlideIn(
          delay: animationDelay,
          duration: duration,
          curve: curve,
          direction: SlideDirection.down,
          distance: 0.3,
          child: content,
        );

      case PopupAnimationType.none:
        return content;
    }
  }

  ShapeBorder _getDefaultShape(BuildContext context, bool isIOS) {
    final borderRadius = isIOS ? 14.0 : 12.0;
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  BoxConstraints _getDefaultConstraints(BuildContext context, bool isMobile) {
    // Phase 2 optimization: Use cached MediaQuery data instead of direct lookup
    final mediaQuery = CachedMediaQueryData.get(context, cacheKey: 'popup_constraints');
    final screenSize = mediaQuery.size;

    // MediaQuery optimization tracking removed

    if (isMobile) {
      return BoxConstraints(
        maxWidth: screenSize.width * 0.9,
        maxHeight: screenSize.height * 0.8,
        minWidth: 280.0,
      );
    } else {
      return BoxConstraints(
        maxWidth: 400.0,
        maxHeight: screenSize.height * 0.8,
        minWidth: 320.0,
      );
    }
  }

  EdgeInsets _getHeaderPadding(bool isMobile) {
    if (isMobile) {
      return const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0);
    } else {
      return const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0);
    }
  }

  EdgeInsets _getContentPadding(bool isMobile, {required bool hasHeader}) {
    if (isMobile) {
      return EdgeInsets.fromLTRB(
        24.0,
        hasHeader ? 0.0 : 24.0,
        24.0,
        24.0,
      );
    } else {
      return EdgeInsets.fromLTRB(
        20.0,
        hasHeader ? 0.0 : 20.0,
        20.0,
        20.0,
      );
    }
  }
}

/// Animation types for popup entrance
enum PopupAnimationType {
  fadeIn,
  scaleIn,
  slideUp,
  slideDown,
  none,
}

/// Extension methods for easy PopupFramework usage
extension PopupFrameworkExtension on Widget {
  /// Wraps this widget with PopupFramework
  Widget asPopup({
    String? title,
    String? subtitle,
    Widget? customSubtitleWidget,
    bool hasPadding = true,
    bool underTitleSpace = true,
    bool showCloseButton = false,
    IconData? icon,
    Widget? outsideExtraWidget,
    Color? backgroundColor,
    Color? surfaceTintColor,
    Color? shadowColor,
    double? elevation,
    ShapeBorder? shape,
    Alignment? alignment,
    BoxConstraints? constraints,
    TextStyle? titleTextStyle,
    TextStyle? subtitleTextStyle,
    Color? iconColor,
    IconData? closeButtonIcon,
    VoidCallback? onClosePressed,
    String? semanticLabel,
    PopupAnimationType animationType = PopupAnimationType.scaleIn,
    Duration animationDelay = Duration.zero,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return PopupFramework(
      title: title,
      subtitle: subtitle,
      customSubtitleWidget: customSubtitleWidget,
      hasPadding: hasPadding,
      underTitleSpace: underTitleSpace,
      showCloseButton: showCloseButton,
      icon: icon,
      outsideExtraWidget: outsideExtraWidget,
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
      shadowColor: shadowColor,
      elevation: elevation,
      shape: shape,
      alignment: alignment,
      constraints: constraints,
      titleTextStyle: titleTextStyle,
      subtitleTextStyle: subtitleTextStyle,
      iconColor: iconColor,
      closeButtonIcon: closeButtonIcon,
      onClosePressed: onClosePressed,
      semanticLabel: semanticLabel,
      animationType: animationType,
      animationDelay: animationDelay,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      child: this,
    );
  }
}
