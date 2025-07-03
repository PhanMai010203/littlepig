import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/navigation_item.dart';
// Phase 5 import
import '../../../../shared/widgets/animations/tappable_widget.dart';

/// Flag to allow tests to disable all animations for this widget tree.
///
/// Set to `true` in tests to prevent pending timers and speed up WidgetTester.
@visibleForTesting
bool kDisableAnimations = false;

class AdaptiveBottomNavigation extends StatefulWidget {
  const AdaptiveBottomNavigation({
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;
  final ValueChanged<int>? onLongPress;

  @override
  State<AdaptiveBottomNavigation> createState() =>
      _AdaptiveBottomNavigationState();
}

class _AdaptiveBottomNavigationState extends State<AdaptiveBottomNavigation> {
  int _tappedIndex = -1;

  double _calculateIndicatorPosition(double totalWidth) {
    final itemWidth = totalWidth / widget.items.length;
    final indicatorWidth = itemWidth * 0.7;
    return (widget.currentIndex * itemWidth) + (itemWidth - indicatorWidth) / 2;
  }

  void _handleTap(int index) {
    // Skip animation logic entirely when animations are disabled (e.g., in tests)
    if (kDisableAnimations) {
      widget.onTap(index);
      return;
    }

    // Call onTap immediately for instant response
    widget.onTap(index);

    // Trigger bounce animation by setting the tapped index
    setState(() => _tappedIndex = index);

    // Reset the tapped index after animation completes
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _tappedIndex = -1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // When animations are disabled (usually in tests), wrap the entire widget
    // tree in [TickerMode] so that any implicit or explicit animations cease
    // ticking, eliminating "Timer is still pending" test failures.
    return TickerMode(
      enabled: !kDisableAnimations,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withValues(alpha: 0.1),
          //     blurRadius: 8,
          //     offset: const Offset(0, -2),
          //   ),
          // ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Sliding indicator with smooth animation (only for non-bulge items)
                    if (!widget.items[widget.currentIndex].hasBulge)
                      AnimatedPositioned(
                        left: _calculateIndicatorPosition(constraints.maxWidth),
                        top: 8,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: Container(
                          width: (constraints.maxWidth / widget.items.length) * 0.7,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                    // Navigation items
                    Row(
                      children: widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = index == widget.currentIndex;
                        final isTapped = index == _tappedIndex;

                        return Expanded(
                          child: _NavigationItemWrapper(
                            item: item,
                            isSelected: isSelected,
                            isTapped: isTapped,
                            onTap: () => _handleTap(index),
                            onLongPress: widget.onLongPress != null
                                ? () => widget.onLongPress!(index)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapper that handles both regular and bulge navigation items
class _NavigationItemWrapper extends StatelessWidget {
  const _NavigationItemWrapper({
    required this.item,
    required this.isSelected,
    required this.isTapped,
    required this.onTap,
    this.onLongPress,
  });

  final NavigationItem item;
  final bool isSelected;
  final bool isTapped;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (item.hasBulge) {
      return _BulgeNavigationItem(
        item: item,
        isSelected: isSelected,
        isTapped: isTapped,
        onTap: onTap,
        onLongPress: onLongPress,
      );
    } else {
      return _AnimatedNavigationItem(
        item: item,
        isSelected: isSelected,
        isTapped: isTapped,
        onTap: onTap,
        onLongPress: onLongPress,
      );
    }
  }
}

/// Special bulge navigation item for AI agent
class _BulgeNavigationItem extends StatelessWidget {
  const _BulgeNavigationItem({
    required this.item,
    required this.isSelected,
    required this.isTapped,
    required this.onTap,
    this.onLongPress,
  });

  final NavigationItem item;
  final bool isSelected;
  final bool isTapped;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TappableWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: 56, // Set a fixed height for the item
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Bulge effect container, positioned to overflow upwards
            Positioned(
              top: -20, // Adjust this value to control the bulge amount
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildBulgeIcon(context, item, isSelected, isTapped),
              ),
            ),

            // Label positioned at the bottom of the fixed-height container
            Positioned(
              bottom: 0,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ) ??
                    TextStyle(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.6),
                    ),
                child: Text(
                  item.label.tr(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulgeIcon(BuildContext context, NavigationItem item, bool isSelected, bool isTapped) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Widget iconWidget;
    
    if (item.iconPath.endsWith('.png')) {
      // Handle PNG images
      iconWidget = Image.asset(
        item.iconPath,
        width: 32,
        height: 32,
        color: isSelected 
            ? colorScheme.onPrimary 
            : colorScheme.onPrimaryContainer,
        colorBlendMode: BlendMode.srcIn,
      );
    } else {
      // Handle SVG icons
      iconWidget = SvgPicture.asset(
        item.iconPath,
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(
          isSelected 
              ? colorScheme.onPrimary 
              : colorScheme.onPrimaryContainer,
          BlendMode.srcIn,
        ),
      );
    }

    Widget iconContainer = Container(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: iconWidget,
      ),
    );

    if (!kDisableAnimations) {
      iconContainer = iconContainer.animate().scaleXY(
            begin: isTapped ? 0.85 : 1.0,
            end: 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          );
    }

    return iconContainer;
  }
}

class _AnimatedNavigationItem extends StatelessWidget {
  const _AnimatedNavigationItem({
    required this.item,
    required this.isSelected,
    required this.isTapped,
    required this.onTap,
    this.onLongPress,
  });

  final NavigationItem item;
  final bool isSelected;
  final bool isTapped;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return TappableWidget(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: Colors.transparent,
        // Fill the entire available space
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with flutter_animate bounce effect
            _buildIcon(context, item, isSelected, isTapped),

            const SizedBox(height: 2),

            // Animated text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ) ??
                  TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                  ),
              child: Text(
                item.label.tr(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, NavigationItem item, bool isSelected, bool isTapped) {
    Widget iconWidget;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.6);

    if (item.iconPath.endsWith('.png')) {
      iconWidget = Image.asset(
        item.iconPath,
        key: ValueKey('${item.iconPath}_$isSelected'),
        width: 24,
        height: 24,
        color: color,
        colorBlendMode: BlendMode.srcIn,
      );
    } else {
      iconWidget = SvgPicture.asset(
        item.iconPath,
        key: ValueKey('${item.iconPath}_$isSelected'),
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          color,
          BlendMode.srcIn,
        ),
      );
    }

    Widget iconContainer = Container(
      padding: const EdgeInsets.all(8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: iconWidget,
      ),
    );

    if (!kDisableAnimations) {
      iconContainer = iconContainer.animate().scaleXY(
            begin: isTapped ? 0.85 : 1.0,
            end: 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
          );
    }

    return iconContainer;
  }
}
