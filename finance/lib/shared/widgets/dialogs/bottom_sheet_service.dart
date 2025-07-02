import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/platform_service.dart';
import '../../utils/snap_size_cache.dart';
import '../../utils/responsive_layout_builder.dart';
import '../../utils/performance_optimization.dart';
import '../../utils/no_overscroll_behavior.dart';

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
    // Phase 3: Animation parameters removed - DraggableScrollableSheet handles animations
    // Keyboard handling
    bool avoidKeyboard = true,
    EdgeInsets? keyboardPadding,
    // Scrolling
    bool expandToFillViewport = false,
    ScrollController? scrollController,
    // Smart snapping (from budget app)
    bool popupWithKeyboard = false,
    bool fullSnap = false,
    bool resizeForKeyboard = true,
    // Theme context preservation (from budget app)
    bool useParentContextForTheme = true,
    // Callbacks
    VoidCallback? onOpened,
    VoidCallback? onClosed,
    void Function(double)? onSizeChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Minimize keyboard when opening bottom sheet (budget app logic)
    // Only minimize if we don't expect to use the keyboard immediately
    if (!popupWithKeyboard) {
      minimizeKeyboard(context);
    } else {
      // For popup with keyboard, ensure any existing focus is properly handled
      // but don't unfocus as we want the keyboard to appear
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Small delay to ensure sheet is properly rendered before keyboard appears
        Future.delayed(const Duration(milliseconds: 50), () {
          if (context.mounted) {
            // Let the sheet settle before allowing keyboard to appear
          }
        });
      });
    }

    // Theme context preservation (from budget app logic)
    BuildContext? themeContext = useParentContextForTheme && 
        PlatformService.isContextValidForTheme(context)
      ? context
      : null;

    // Calculate effective sizes with smart snapping and caching
    final effectiveSnapSizes = snapSizes ?? _getOptimizedSnapSizes(
      context: context,
      popupWithKeyboard: popupWithKeyboard,
      fullSnap: fullSnap,
    );
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

    // Phase 3: Remove competing animation layers
    // Let DraggableScrollableSheet handle all animations
    // No additional animation wrappers to prevent conflicts
    PerformanceOptimizations.trackAnimationLayerConsolidation(
      'BottomSheetService', 
      'DraggableScrollableSheet single owner'
    );
    PerformanceOptimizations.trackAnimationOwnership(
      'BottomSheetService', 
      true // Single animation owner
    );

    // Handle keyboard avoidance
    // We apply keyboard padding **inside** the bottom-sheet builders so that it
    // reacts to future MediaQuery updates (e.g. when the keyboard is toggled
    // after the sheet is already visible).  Applying it here would create a
    // fixed padding which does not update and could duplicate the padding that
    // the modal-bottom-sheet route itself adds when `isScrollControlled` is
    // false.
    //
    // Therefore we no longer wrap the `sheetContent` here. The builders below
    // will take care of keyboard avoidance when `resizeForKeyboard` is true.

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
        themeContext: themeContext,
        resizeForKeyboard: resizeForKeyboard,
        popupWithKeyboard: popupWithKeyboard,
        onOpened: onOpened,
        onClosed: onClosed,
        onSizeChanged: onSizeChanged,
        cachedTheme: theme,
        cachedColorScheme: colorScheme,
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
        themeContext: themeContext,
        resizeForKeyboard: resizeForKeyboard,
        popupWithKeyboard: popupWithKeyboard,
        onOpened: onOpened,
        onClosed: onClosed,
        cachedTheme: theme,
        cachedColorScheme: colorScheme,
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
    // Phase 3: Animation handled by DraggableScrollableSheet
  }) {
    return showCustomBottomSheet<T>(
      context,
      child,
      title: title,
      showCloseButton: showCloseButton,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
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
    // Phase 3: Animation handled by DraggableScrollableSheet
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
    // Phase 3: Animation handled by DraggableScrollableSheet
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
    );
  }

  /// Get optimized snap sizes with caching (Phase 2 optimization)
  static List<double> _getOptimizedSnapSizes({
    BuildContext? context,
    bool popupWithKeyboard = false,
    bool fullSnap = false,
  }) {
    // If no context provided, return standard sizes
    if (context == null) {
      return [0.25, 0.5, 0.9];
    }

    // Use cached MediaQuery data to avoid repeated lookups
    final mediaQuery = CachedMediaQueryData.get(context, cacheKey: 'bottom_sheet_sizing');
    final size = mediaQuery.size;
    final isFullScreen = PlatformService.getIsFullScreen(context);
    final isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
    
    // Use SnapSizeCache for performance optimization
    return SnapSizeCache.getSnapSizes(
      screenSize: size,
      isKeyboardVisible: isKeyboardVisible,
      fullSnap: fullSnap,
      popupWithKeyboard: popupWithKeyboard,
      isFullScreen: isFullScreen,
    );
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
      final hasHeader =
          title != null || subtitle != null || customTitleWidget != null;
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
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
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
    if (title == null &&
        subtitle == null &&
        customTitleWidget == null &&
        !showCloseButton) {
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
                    onPressed:
                        onClosePressed ?? () => Navigator.of(context).pop(),
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

  /// Phase 3: Removed _applyBottomSheetAnimation method
  /// DraggableScrollableSheet now handles all animations directly
  /// This eliminates competing animation layers

  /// Wrap content with scrolling capability
  static Widget _wrapWithScrolling(
      Widget content, ScrollController? scrollController) {
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
    BuildContext? themeContext,
    bool resizeForKeyboard = true,
    bool popupWithKeyboard = false,
    VoidCallback? onOpened,
    VoidCallback? onClosed,
    void Function(double)? onSizeChanged,
    ThemeData? cachedTheme,
    ColorScheme? cachedColorScheme,
  }) {
    final theme = cachedTheme ?? Theme.of(context);
    final colorScheme = cachedColorScheme ?? theme.colorScheme;

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

        // Check for default theme data and reset context if needed
        BuildContext? effectiveThemeContext = themeContext;
        if (_isDefaultThemeData(effectiveThemeContext)) {
          effectiveThemeContext = null;
        }

        // Removed complex keyboard timing logic - let Flutter handle keyboard animations natively

        // Phase 4: Enhanced DraggableScrollableSheet with custom snap physics
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _handleSnapNotification(notification, snapSizes);
            return false; // Allow other listeners to receive the notification
          },
          child: DraggableScrollableSheet(
            initialChildSize: initialSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            snap: true,
            snapSizes: snapSizes,
            builder: (context, scrollController) {
              // The modal bottom sheet route already handles keyboard insets via
              // AnimatedPadding. To avoid applying them twice we do NOT wrap the
              // content with an additional Padding here.
              Widget sheetContainer = Material(
                type: MaterialType.card,
                color: backgroundColor ?? colorScheme.surface,
                elevation: elevation ?? 8.0,
                shadowColor: colorScheme.shadow,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                ),
                // Apply a dynamic Padding that follows MediaQuery.viewInsets so
                // the content is always positioned above the keyboard.  This
                // is necessary because we call `showModalBottomSheet` with
                // `isScrollControlled: true`, which disables the built-in
                // AnimatedPadding the framework normally adds.
                child: resizeForKeyboard
                    ? Padding(
                        padding: MediaQuery.of(context).viewInsets,
                        child: content,
                      )
                    : content,
              );

              // Phase 4: Apply NoOverscrollBehavior to prevent rubber-band jank
              if (PerformanceOptimizations.useOverscrollOptimization) {
                sheetContainer = sheetContainer.withNoOverscroll(
                  componentName: 'BottomSheetService',
                );
              }

              // Apply theme context if available
              if (effectiveThemeContext != null) {
                return Material(
                  type: MaterialType.transparency,
                  child: Theme(
                    data: Theme.of(effectiveThemeContext),
                    child: sheetContainer,
                  ),
                );
              }

              return sheetContainer;
            },
          ),
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
    BuildContext? themeContext,
    bool resizeForKeyboard = true,
    bool popupWithKeyboard = false,
    VoidCallback? onOpened,
    VoidCallback? onClosed,
    ThemeData? cachedTheme,
    ColorScheme? cachedColorScheme,
  }) {
    final theme = cachedTheme ?? Theme.of(context);
    final colorScheme = cachedColorScheme ?? theme.colorScheme;

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: useSafeArea,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
      builder: (context) {
        onOpened?.call();

        // Check for default theme data and reset context if needed
        BuildContext? effectiveThemeContext = themeContext;
        if (_isDefaultThemeData(effectiveThemeContext)) {
          effectiveThemeContext = null;
        }

        // If `isScrollControlled` is true (which it usually is for our custom
        // sheets), the framework will NOT add its own AnimatedPadding, so we
        // need to handle keyboard insets ourselves.  For the non-scroll-
        // controlled case we leave the padding to the framework to avoid
        // double insets.

        Widget wrappedContent = content;
        if (resizeForKeyboard && isScrollControlled) {
          wrappedContent = Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: content,
          );
        }

        // Phase 4: Apply NoOverscrollBehavior to prevent rubber-band jank
        if (PerformanceOptimizations.useOverscrollOptimization) {
          wrappedContent = wrappedContent.withNoOverscroll(
            componentName: 'BottomSheetService',
          );
        }

        // Apply theme context if available
        if (effectiveThemeContext != null) {
          return Material(
            type: MaterialType.transparency,
            child: Theme(
              data: Theme.of(effectiveThemeContext),
              child: wrappedContent,
            ),
          );
        }

        return wrappedContent;
      },
    ).then((result) {
      onClosed?.call();
      return result;
    });
  }

  /// Phase 3: Removed defaultBottomSheetAnimation - animations handled by DraggableScrollableSheet

  /// Check if theme context has default theme data (budget app logic)
  static bool _isDefaultThemeData(BuildContext? context) {
    try {
      if (context == null) return true;
      
      final theme = Theme.of(context);
      final defaultTheme = ThemeData();
      
      return theme.primaryColor == defaultTheme.primaryColor &&
          theme.cardColor == defaultTheme.cardColor &&
          theme.colorScheme.surface == defaultTheme.colorScheme.surface;
    } catch (e) {
      return true;
    }
  }

  /// Minimize keyboard before showing bottom sheet (budget app logic)
  static void minimizeKeyboard(BuildContext context) {
    FocusNode? currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
    currentFocus?.unfocus();
  }

  /// Get width constraint for bottom sheet based on platform
  static double getBottomSheetWidth(BuildContext context) {
    return PlatformService.getWidthConstraint(context);
  }

  /// Phase 4: Handle snap notifications for custom physics and haptic feedback
  static void _handleSnapNotification(
    DraggableScrollableNotification notification,
    List<double> snapSizes,
  ) {
    if (!PerformanceOptimizations.useCustomSnapPhysics) return;

    // Track snap physics usage
    PerformanceOptimizations.trackSnapPhysics(
      'BottomSheetService',
      'NotificationListener',
    );

    // Detect snap completion - when sheet settles at a snap size
    final currentExtent = notification.extent;
    
    // Check if we're at or very close to a snap size
    const snapTolerance = 0.02; // 2% tolerance for snap detection
    
    for (final snapSize in snapSizes) {
      final isAtSnapSize = (currentExtent - snapSize).abs() < snapTolerance;
      
      if (isAtSnapSize) {
        _triggerSnapFeedback(currentExtent);
        
        // Track snap completion
        PerformanceOptimizations.trackSnapCompletion(
          'BottomSheetService',
          currentExtent,
          PlatformService.getPlatform() == PlatformOS.isIOS, // Haptic feedback only on iOS
        );
        break; // Only trigger once per snap
      }
    }
  }

  /// Phase 4: Trigger haptic feedback for snap completion
  static void _triggerSnapFeedback(double snapPosition) {
    // Only provide haptic feedback on iOS for natural feel
    if (PlatformService.getPlatform() == PlatformOS.isIOS) {
      // Use different haptic intensity based on snap position
      if (snapPosition >= 0.9) {
        // Strong feedback for full expansion
        HapticFeedback.heavyImpact();
      } else if (snapPosition <= 0.3) {
        // Light feedback for minimal expansion
        HapticFeedback.lightImpact();
      } else {
        // Medium feedback for mid-range snaps
        HapticFeedback.mediumImpact();
      }
      
      // Track haptic optimization
      PerformanceOptimizations.trackHapticOptimization(
        'BottomSheetService',
        true,
      );
    }
  }

  /// Phase 2: Removed _keyboardVisibilityNotifier - now using AnimatedPadding approach
  /// Phase 3: Removed BottomSheetAnimationType enum - animations handled by DraggableScrollableSheet
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
    // Phase 3: Animation handled by DraggableScrollableSheet
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
