import 'package:flutter/material.dart';

/// A reusable collapsible app bar title widget that responds to scroll position
///
/// This widget creates a title that fades in/out and changes its background
/// opacity based on the scroll position. It's designed to be used within
/// SliverAppBar's flexibleSpace property.
///
/// Features:
/// - Scroll-responsive background opacity
/// - Customizable title styling
/// - Smooth transitions based on scroll offset
/// - Follows Material You theming patterns
class CollapsibleAppBarTitle extends StatelessWidget {
  const CollapsibleAppBarTitle({
    required this.title,
    required this.scrollController,
    required this.expandedHeight,
    required this.toolbarHeight,
    this.titleTextStyle,
    this.backgroundColor,
    this.titlePadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    this.centerTitle = false,
    super.key,
  });

  /// The title text to display
  final String title;

  /// The scroll controller to listen to for scroll position changes
  final ScrollController scrollController;

  /// The expanded height of the app bar
  final double expandedHeight;

  /// The collapsed toolbar height of the app bar
  final double toolbarHeight;

  /// Optional custom text style for the title
  final TextStyle? titleTextStyle;

  /// Optional background color. If null, uses theme's primaryContainer
  final Color? backgroundColor;

  /// Padding around the title text
  final EdgeInsetsGeometry titlePadding;

  /// Whether to center the title horizontally
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceColor = theme.colorScheme.onSurface;
    final primaryColor = backgroundColor ?? theme.colorScheme.primaryContainer;

    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final double heightDelta = (expandedHeight - toolbarHeight).abs();
        // Prevent division-by-zero when expandedHeight == toolbarHeight.
        final safeDelta = heightDelta == 0 ? 1 : heightDelta;

        final appBarOpacity = scrollController.hasClients
            ? (scrollController.offset / safeDelta).clamp(0.0, 1.0)
            : 0.0;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Background that fades in/out with scroll
            Container(
              color: primaryColor.withAlpha((255 * appBarOpacity).toInt()),
            ),
            // Title with flexible positioning
            FlexibleSpaceBar(
              titlePadding: titlePadding,
              centerTitle: centerTitle,
              title: Text(
                title,
                style: titleTextStyle ??
                    theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onSurfaceColor,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
} 