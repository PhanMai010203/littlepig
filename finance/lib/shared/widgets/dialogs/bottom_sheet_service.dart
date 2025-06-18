import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/platform_service.dart';
import '../animations/slide_in.dart';
import '../animations/fade_in.dart';
import '../animations/animation_utils.dart';
import '../../../core/settings/app_settings.dart';

/// BottomSheetService - Phase 3.3 Implementation
/// 
/// A service for showing bottom sheets with:
/// - Smart snapping behavior
/// - Responsive content sizing
/// - Keyboard handling
/// - Animation framework integration
/// - Platform-aware design
class BottomSheetService {
  BottomSheetService._();

  /// Show a custom bottom sheet with smart snapping
  /// 
  /// Returns a Future that completes with the result when the sheet is dismissed.
  /// [T] is the type of value that can be returned from the sheet.
  static Future<T?> showCustomBottomSheet<T>(
    BuildContext context,
    Widget child, {
    String? title,
    String? subtitle,
    Widget? customTitleWidget,
    List<double>? snapSizes,
    double? initialSize,
    double? minSize,
    double? maxSize,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool useSafeArea = true,
    bool isScrollControlled = true,
    Color? backgroundColor,
    Color? surfaceTintColor,
    double? elevation,
    ShapeBorder? shape,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
    bool showCloseButton = false,
    IconData? closeButtonIcon,
    VoidCallback? onClosePressed,
    String? semanticLabel,
    BottomSheetAnimationType animationType = BottomSheetAnimationType.slideUp,
    Duration? animationDuration,
    Curve? animationCurve,
    // Keyboard handling
    bool avoidKeyboard = true,
    EdgeInsets? keyboardPadding,
    // Scrolling
    bool expandToFillViewport = false,
    ScrollController? scrollController,
    // Callbacks
    VoidCallback? onOpened,
    VoidCallback? onClosed,
    void Function(double)? onSizeChanged,
  }) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate effective sizes
    final effectiveSnapSizes = snapSizes ?? _getDefaultSnapSizes();
    final effectiveInitialSize = initialSize ?? effectiveSnapSizes.first;
    final effectiveMinSize = minSize ?? effectiveSnapSizes.first;
    final effectiveMaxSize = maxSize ?? effectiveSnapSizes.last;
    
    // Create the bottom sheet content
    Widget sheetContent = _buildBottomSheetContent(
      context,
      child: child,
      title: title,
      subtitle: subtitle,
      customTitleWidget: customTitleWidget,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      closeButtonIcon: closeButtonIcon,
      onClosePressed: onClosePressed,
      padding: padding,
      theme: theme,
      colorScheme: colorScheme,
    );
    
    // Apply animation if enabled
    if (AnimationUtils.shouldAnimate() && animationType != BottomSheetAnimationType.none) {
      sheetContent = _applyBottomSheetAnimation(
        sheetContent,
        animationType,
        animationDuration,
        animationCurve,
      );
    }
    
    // Handle keyboard avoidance
    if (avoidKeyboard) {
      sheetContent = _wrapWithKeyboardAvoidance(
        context,
        sheetContent,
        keyboardPadding,
      );
    }
    
    // Handle scrolling if needed
    if (expandToFillViewport) {
      sheetContent = _wrapWithScrolling(sheetContent, scrollController);
    }
    
    // Apply constraints if provided
    if (constraints != null) {
      sheetContent = ConstrainedBox(
        constraints: constraints,
        child: sheetContent,
      );
    }
    
    // Apply semantics
    if (semanticLabel != null) {
      sheetContent = Semantics(
        label: semanticLabel,
        child: sheetContent,
      );
    }
    
    if (snapSizes != null && snapSizes.length > 1) {
      // Use DraggableScrollableSheet for snapping behavior
      return _showDraggableBottomSheet<T>(
        context,
        sheetContent,
        snapSizes: effectiveSnapSizes,
        initialSize: effectiveInitialSize,
        minSize: effectiveMinSize,
        maxSize: effectiveMaxSize,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useSafeArea: useSafeArea,
        backgroundColor: backgroundColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shape: shape,
        onOpened: onOpened,
        onClosed: onClosed,
        onSizeChanged: onSizeChanged,
      );
    } else {
      // Use standard modal bottom sheet
      return _showStandardBottomSheet<T>(
        context,
        sheetContent,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useSafeArea: useSafeArea,
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        shape: shape,
        onOpened: onOpened,
        onClosed: onClosed,
      );
    }
  }

  /// Show a simple bottom sheet with just content
  static Future<T?> showSimpleBottomSheet<T>(
    BuildContext context,
    Widget child, {
    String? title,
    bool showCloseButton = false,
    bool isDismissible = true,
    bool enableDrag = true,
    BottomSheetAnimationType animationType = BottomSheetAnimationType.slideUp,
  }) {
    return showCustomBottomSheet<T>(
      context,
      child,
      title: title,
      showCloseButton: showCloseButton,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      animationType: animationType,
    );
  }

  /// Show a bottom sheet with a list of options
  static Future<T?> showOptionsBottomSheet<T>(
    BuildContext context, {
    String? title,
    String? subtitle,
    required List<BottomSheetOption<T>> options,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
    BottomSheetAnimationType animationType = BottomSheetAnimationType.slideUp,
  }) {
    return showCustomBottomSheet<T>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            leading: option.icon != null ? Icon(option.icon) : null,
            title: Text(option.title),
            subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
            trailing: option.trailing,
            enabled: option.enabled,
            onTap: option.enabled 
                ? () => Navigator.of(context).pop(option.value) 
                : null,
          );
        }).toList(),
      ),
      title: title,
      subtitle: subtitle,
      showCloseButton: showCloseButton,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      animationType: animationType,
    );
  }

  /// Show a confirmation bottom sheet
  static Future<bool?> showConfirmationBottomSheet(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? confirmColor,
    bool isDangerous = false,
    BottomSheetAnimationType animationType = BottomSheetAnimationType.slideUp,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveConfirmText = confirmText ?? 'Confirm';
    final effectiveCancelText = cancelText ?? 'Cancel';
    final effectiveConfirmColor = isDangerous 
        ? (confirmColor ?? colorScheme.error)
        : (confirmColor ?? colorScheme.primary);
    
    return showCustomBottomSheet<bool>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 48.0,
              color: isDangerous ? colorScheme.error : colorScheme.primary,
            ),
            const SizedBox(height: 16.0),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(effectiveCancelText),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: effectiveConfirmColor,
                    foregroundColor: isDangerous 
                        ? colorScheme.onError 
                        : colorScheme.onPrimary,
                  ),
                  child: Text(effectiveConfirmText),
                ),
              ),
            ],
          ),
        ],
      ),
      title: title,
      isDismissible: true,
      enableDrag: true,
      animationType: animationType,
    );
  }

  /// Get default snap sizes based on screen height
  static List<double> _getDefaultSnapSizes() {
    // Standard snap points: 25%, 50%, 90% of screen height
    return [0.25, 0.5, 0.9];
  }

  /// Build the main bottom sheet content
  static Widget _buildBottomSheetContent(
    BuildContext context, {
    required Widget child,
    String? title,
    String? subtitle,
    Widget? customTitleWidget,
    bool showDragHandle = true,
    bool showCloseButton = false,
    IconData? closeButtonIcon,
    VoidCallback? onClosePressed,
    EdgeInsetsGeometry? padding,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final List<Widget> contentChildren = [];
    
    // Drag handle
    if (showDragHandle) {
      contentChildren.add(_buildDragHandle(theme, colorScheme));
    }
    
    // Header
    final headerWidget = _buildHeader(
      context,
      title: title,
      subtitle: subtitle,
      customTitleWidget: customTitleWidget,
      showCloseButton: showCloseButton,
      closeButtonIcon: closeButtonIcon,
      onClosePressed: onClosePressed,
      theme: theme,
      colorScheme: colorScheme,
    );
    if (headerWidget != null) {
      contentChildren.add(headerWidget);
    }
    
    // Main content
    Widget mainContent = child;
    if (padding != null) {
      mainContent = Padding(
        padding: padding,
        child: mainContent,
      );
    } else {
      // Default padding
      final hasHeader = title != null || subtitle != null || customTitleWidget != null;
      final defaultPadding = EdgeInsets.fromLTRB(
        24.0,
        hasHeader ? 0.0 : (showDragHandle ? 8.0 : 24.0),
        24.0,
        24.0,
      );
      mainContent = Padding(
        padding: defaultPadding,
        child: mainContent,
      );
    }
    
    contentChildren.add(Flexible(child: mainContent));
    
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: contentChildren,
      ),
    );
  }

  /// Build the drag handle widget
  static Widget _buildDragHandle(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        width: 32.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

  /// Build the header section
  static Widget? _buildHeader(
    BuildContext context, {
    String? title,
    String? subtitle,
    Widget? customTitleWidget,
    bool showCloseButton = false,
    IconData? closeButtonIcon,
    VoidCallback? onClosePressed,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    if (title == null && subtitle == null && customTitleWidget == null && !showCloseButton) {
      return null;
    }
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with optional close button
          if (title != null || customTitleWidget != null || showCloseButton)
            Row(
              children: [
                if (customTitleWidget != null)
                  Expanded(child: customTitleWidget)
                else if (title != null)
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                
                if (showCloseButton)
                  IconButton(
                    onPressed: onClosePressed ?? () => Navigator.of(context).pop(),
                    icon: Icon(closeButtonIcon ?? Icons.close),
                    iconSize: 20.0,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          
          // Subtitle
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Apply animation to bottom sheet content
  static Widget _applyBottomSheetAnimation(
    Widget content,
    BottomSheetAnimationType animationType,
    Duration? animationDuration,
    Curve? animationCurve,
  ) {
    final duration = animationDuration ?? AnimationUtils.getDuration(
      const Duration(milliseconds: 300)
    );
    final curve = animationCurve ?? AnimationUtils.getCurve(Curves.easeOutCubic);
    
    switch (animationType) {
      case BottomSheetAnimationType.slideUp:
        return SlideIn(
          direction: SlideDirection.up,
          distance: 1.0,
          duration: duration,
          curve: curve,
          child: content,
        );
        
      case BottomSheetAnimationType.fadeIn:
        return FadeIn(
          duration: duration,
          curve: curve,
          child: content,
        );
        
      case BottomSheetAnimationType.none:
        return content;
    }
  }

  /// Wrap content with keyboard avoidance
  static Widget _wrapWithKeyboardAvoidance(
    BuildContext context,
    Widget content,
    EdgeInsets? keyboardPadding,
  ) {
    return AnimatedPadding(
      padding: keyboardPadding ?? MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: content,
    );
  }

  /// Wrap content with scrolling capability
  static Widget _wrapWithScrolling(Widget content, ScrollController? scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: content,
    );
  }

  /// Show draggable bottom sheet with snap points
  static Future<T?> _showDraggableBottomSheet<T>(
    BuildContext context,
    Widget content, {
    required List<double> snapSizes,
    required double initialSize,
    required double minSize,
    required double maxSize,
    required bool isDismissible,
    required bool enableDrag,
    required bool useSafeArea,
    Color? backgroundColor,
    Color? surfaceTintColor,
    double? elevation,
    ShapeBorder? shape,
    VoidCallback? onOpened,
    VoidCallback? onClosed,
    void Function(double)? onSizeChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        onOpened?.call();
        
        return DraggableScrollableSheet(
          initialChildSize: initialSize,
          minChildSize: minSize,
          maxChildSize: maxSize,
          snap: true,
          snapSizes: snapSizes,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: elevation ?? 8.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: content,
            );
          },
        );
      },
    ).then((result) {
      onClosed?.call();
      return result;
    });
  }

  /// Show standard modal bottom sheet
  static Future<T?> _showStandardBottomSheet<T>(
    BuildContext context,
    Widget content, {
    required bool isDismissible,
    required bool enableDrag,
    required bool useSafeArea,
    required bool isScrollControlled,
    Color? backgroundColor,
    Color? surfaceTintColor,
    double? elevation,
    ShapeBorder? shape,
    VoidCallback? onOpened,
    VoidCallback? onClosed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        onOpened?.call();
        return content;
      },
    ).then((result) {
      onClosed?.call();
      return result;
    });
  }

  /// Get the default bottom sheet animation type based on platform and settings
  static BottomSheetAnimationType get defaultBottomSheetAnimation {
    if (!AppSettings.appAnimations || 
        AppSettings.reduceAnimations || 
        AppSettings.batterySaver ||
        AppSettings.animationLevel == 'none') {
      return BottomSheetAnimationType.none;
    }
    
    switch (AppSettings.animationLevel) {
      case 'reduced':
        return BottomSheetAnimationType.fadeIn;
      case 'enhanced':
      case 'normal':
      default:
        return BottomSheetAnimationType.slideUp;
    }
  }
}

/// Animation types for bottom sheet entrance
enum BottomSheetAnimationType {
  slideUp,
  fadeIn,
  none,
}

/// Represents an option in a bottom sheet menu
class BottomSheetOption<T> {
  const BottomSheetOption({
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.trailing,
    this.enabled = true,
  });

  /// The title text for the option
  final String title;
  
  /// The subtitle text (optional)
  final String? subtitle;
  
  /// The value to return when this option is selected
  final T value;
  
  /// Optional icon to display
  final IconData? icon;
  
  /// Optional trailing widget
  final Widget? trailing;
  
  /// Whether this option is enabled
  final bool enabled;
}

/// Extension methods for easier bottom sheet usage
extension BottomSheetServiceExtension on BuildContext {
  /// Show a bottom sheet using the current context
  Future<T?> showBottomSheet<T>(
    Widget child, {
    String? title,
    String? subtitle,
    Widget? customTitleWidget,
    List<double>? snapSizes,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool showCloseButton = false,
    BottomSheetAnimationType? animationType,
  }) {
    return BottomSheetService.showCustomBottomSheet<T>(
      this,
      child,
      title: title,
      subtitle: subtitle,
      customTitleWidget: customTitleWidget,
      snapSizes: snapSizes,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      showCloseButton: showCloseButton,
      animationType: animationType ?? BottomSheetService.defaultBottomSheetAnimation,
    );
  }

  /// Show a simple bottom sheet using the current context
  Future<T?> showSimpleSheet<T>(
    Widget child, {
    String? title,
    bool showCloseButton = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return BottomSheetService.showSimpleBottomSheet<T>(
      this,
      child,
      title: title,
      showCloseButton: showCloseButton,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Show an options bottom sheet using the current context
  Future<T?> showOptions<T>({
    String? title,
    String? subtitle,
    required List<BottomSheetOption<T>> options,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return BottomSheetService.showOptionsBottomSheet<T>(
      this,
      title: title,
      subtitle: subtitle,
      options: options,
      showCloseButton: showCloseButton,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }

  /// Show a confirmation bottom sheet using the current context
  Future<bool?> showBottomSheetConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? confirmColor,
    bool isDangerous = false,
  }) {
    return BottomSheetService.showConfirmationBottomSheet(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      confirmColor: confirmColor,
      isDangerous: isDangerous,
    );
  }
} 