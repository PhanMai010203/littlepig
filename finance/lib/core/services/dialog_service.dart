import 'package:flutter/material.dart';
import '../../shared/widgets/dialogs/popup_framework.dart';
import 'platform_service.dart';
import '../settings/app_settings.dart';

/// DialogService - Phase 3.2 Implementation
/// 
/// A service for showing dialogs and popups with:
/// - Type-safe generic support
/// - Integration with PopupFramework
/// - Animation and settings integration
/// - Platform-aware behavior
/// - Consistent API across the app
class DialogService {
  DialogService._();
  
  /// Show a popup using PopupFramework
  /// 
  /// Returns a Future that completes with the result when the dialog is dismissed.
  /// [T] is the type of value that can be returned from the dialog.
  static Future<T?> showPopup<T>(
    BuildContext context,
    Widget child, {
    String? title,
    String? subtitle,
    Widget? customSubtitleWidget,
    bool hasPadding = true,
    bool underTitleSpace = true,
    bool showCloseButton = false,
    IconData? icon,
    Widget? outsideExtraWidget,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    // PopupFramework specific properties
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
    // Create the popup using PopupFramework
    final popup = PopupFramework(
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
      child: child,
    );
    
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: true,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
      builder: (context) => popup,
    );
  }

  /// Show a confirmation dialog with Yes/No buttons
  /// 
  /// Returns true if user confirms, false if they cancel, null if dismissed
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? confirmColor,
    Color? cancelColor,
    bool isDangerous = false,
    PopupAnimationType animationType = PopupAnimationType.scaleIn,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final effectiveConfirmText = confirmText ?? 'Confirm';
    final effectiveCancelText = cancelText ?? 'Cancel';
    final effectiveConfirmColor = isDangerous 
        ? (confirmColor ?? colorScheme.error)
        : (confirmColor ?? colorScheme.primary);
    
    return showPopup<bool>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: PlatformService.getPlatform() == PlatformOS.isIOS 
                ? TextAlign.center 
                : TextAlign.start,
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: cancelColor ?? colorScheme.onSurfaceVariant,
                ),
                child: Text(effectiveCancelText),
              ),
              const SizedBox(width: 8.0),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: effectiveConfirmColor,
                  foregroundColor: isDangerous 
                      ? colorScheme.onError 
                      : colorScheme.onPrimary,
                ),
                child: Text(effectiveConfirmText),
              ),
            ],
          ),
        ],
      ),
      title: title,
      icon: icon,
      animationType: animationType,
      barrierDismissible: true,
    );
  }

  /// Show an information dialog with OK button
  /// 
  /// Returns true when dismissed
  static Future<bool?> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    IconData? icon,
    PopupAnimationType animationType = PopupAnimationType.fadeIn,
  }) {
    final theme = Theme.of(context);
    final effectiveButtonText = buttonText ?? 'OK';
    
    return showPopup<bool>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyMedium,
            textAlign: PlatformService.getPlatform() == PlatformOS.isIOS 
                ? TextAlign.center 
                : TextAlign.start,
          ),
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(effectiveButtonText),
              ),
            ],
          ),
        ],
      ),
      title: title,
      icon: icon,
      animationType: animationType,
      barrierDismissible: true,
    );
  }

  /// Show an error dialog with OK button
  /// 
  /// Returns true when dismissed
  static Future<bool?> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    String? details,
    bool showDetails = false,
    PopupAnimationType animationType = PopupAnimationType.scaleIn,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveButtonText = buttonText ?? 'OK';
    
    return showPopup<bool>(
      context,
      StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                style: theme.textTheme.bodyMedium,
                textAlign: PlatformService.getPlatform() == PlatformOS.isIOS 
                    ? TextAlign.center 
                    : TextAlign.start,
              ),
              if (details != null) ...[
                const SizedBox(height: 12.0),
                TextButton.icon(
                  onPressed: () => setState(() => showDetails = !showDetails),
                  icon: Icon(
                    showDetails ? Icons.expand_less : Icons.expand_more,
                    size: 18.0,
                  ),
                  label: Text(showDetails ? 'Hide Details' : 'Show Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    textStyle: theme.textTheme.bodySmall,
                  ),
                ),
                if (showDetails) ...[
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      details,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: Text(effectiveButtonText),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      title: title,
      icon: Icons.error_outline,
      iconColor: colorScheme.error,
      animationType: animationType,
      barrierDismissible: true,
    );
  }

  /// Show a loading dialog
  /// 
  /// Returns a function that can be called to dismiss the dialog
  static VoidCallback showLoadingDialog(
    BuildContext context, {
    String? title,
    String? message,
    bool barrierDismissible = false,
    PopupAnimationType animationType = PopupAnimationType.fadeIn,
  }) {
    bool isDismissed = false;
    
    showPopup<void>(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16.0),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      title: title,
      animationType: animationType,
      barrierDismissible: barrierDismissible,
      showCloseButton: false,
    ).then((_) => isDismissed = true);
    
    return () {
      if (!isDismissed && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        isDismissed = true;
      }
    };
  }

  /// Show a custom dialog with optional action buttons
  /// 
  /// Returns the result from the dialog
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    required Widget content,
    String? title,
    String? subtitle,
    IconData? icon,
    List<DialogAction>? actions,
    MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
    PopupAnimationType animationType = PopupAnimationType.scaleIn,
    bool barrierDismissible = true,
    bool showCloseButton = false,
  }) {
    Widget dialogContent = content;
    
    // Add actions if provided
    if (actions != null && actions.isNotEmpty) {
      dialogContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          content,
          const SizedBox(height: 24.0),
          Row(
            mainAxisAlignment: actionsAlignment,
            children: actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: action.isDestructive 
                    ? TextButton(
                        onPressed: () {
                          final result = action.onPressed?.call();
                          if (action.closesDialog) {
                            Navigator.of(context).pop(result);
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: Text(action.label),
                      )
                    : action.isPrimary
                        ? FilledButton(
                            onPressed: () {
                              final result = action.onPressed?.call();
                              if (action.closesDialog) {
                                Navigator.of(context).pop(result);
                              }
                            },
                            child: Text(action.label),
                          )
                        : TextButton(
                            onPressed: () {
                              final result = action.onPressed?.call();
                              if (action.closesDialog) {
                                Navigator.of(context).pop(result);
                              }
                            },
                            child: Text(action.label),
                          ),
              );
            }).toList(),
          ),
        ],
      );
    }
    
    return showPopup<T>(
      context,
      dialogContent,
      title: title,
      subtitle: subtitle,
      icon: icon,
      animationType: animationType,
      barrierDismissible: barrierDismissible,
      showCloseButton: showCloseButton,
    );
  }

  /// Check if animations are enabled for dialogs
  static bool get areDialogAnimationsEnabled {
    return AppSettings.appAnimations && 
           !AppSettings.reduceAnimations && 
           !AppSettings.batterySaver &&
           AppSettings.animationLevel != 'none';
  }

  /// Get the default popup animation type based on platform and settings
  static PopupAnimationType get defaultPopupAnimation {
    if (!areDialogAnimationsEnabled) {
      return PopupAnimationType.none;
    }
    
    switch (AppSettings.animationLevel) {
      case 'reduced':
        return PopupAnimationType.fadeIn;
      case 'enhanced':
        return PopupAnimationType.scaleIn;
      default:
        return PlatformService.getPlatform() == PlatformOS.isIOS 
            ? PopupAnimationType.scaleIn 
            : PopupAnimationType.slideUp;
    }
  }
}

/// Represents an action button in a dialog
class DialogAction {
  const DialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.closesDialog = true,
  });

  /// The text label for the action button
  final String label;
  
  /// Callback when the action is pressed
  /// The return value will be passed to Navigator.pop() if closesDialog is true
  final dynamic Function()? onPressed;
  
  /// Whether this action should be styled as a primary button
  final bool isPrimary;
  
  /// Whether this action should be styled as destructive/dangerous
  final bool isDestructive;
  
  /// Whether pressing this action should close the dialog
  final bool closesDialog;
}

/// Extension methods for easier dialog usage
extension DialogServiceExtension on BuildContext {
  /// Show a popup dialog using the current context
  Future<T?> showPopup<T>(
    Widget child, {
    String? title,
    String? subtitle,
    Widget? customSubtitleWidget,
    bool hasPadding = true,
    bool underTitleSpace = true,
    bool showCloseButton = false,
    IconData? icon,
    Widget? outsideExtraWidget,
    bool barrierDismissible = true,
    PopupAnimationType? animationType,
  }) {
    return DialogService.showPopup<T>(
      this,
      child,
      title: title,
      subtitle: subtitle,
      customSubtitleWidget: customSubtitleWidget,
      hasPadding: hasPadding,
      underTitleSpace: underTitleSpace,
      showCloseButton: showCloseButton,
      icon: icon,
      outsideExtraWidget: outsideExtraWidget,
      barrierDismissible: barrierDismissible,
      animationType: animationType ?? DialogService.defaultPopupAnimation,
    );
  }

  /// Show a confirmation dialog using the current context
  Future<bool?> showConfirmation({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    bool isDangerous = false,
  }) {
    return DialogService.showConfirmationDialog(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      isDangerous: isDangerous,
    );
  }

  /// Show an info dialog using the current context
  Future<bool?> showInfo({
    required String title,
    required String message,
    String? buttonText,
    IconData? icon,
  }) {
    return DialogService.showInfoDialog(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: icon,
    );
  }

  /// Show an error dialog using the current context
  Future<bool?> showError({
    required String title,
    required String message,
    String? buttonText,
    String? details,
  }) {
    return DialogService.showErrorDialog(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
      details: details,
    );
  }

  /// Show a loading dialog using the current context
  VoidCallback showLoading({
    String? title,
    String? message,
    bool barrierDismissible = false,
  }) {
    return DialogService.showLoadingDialog(
      this,
      title: title,
      message: message,
      barrierDismissible: barrierDismissible,
    );
  }
} 