import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/navigation_item.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/animations/slide_in.dart';

/// Phase 5 Implementation: NavigationCustomizationContent
///
/// A custom content widget for navigation customization dialog that provides:
/// - Better visual design with animation integration
/// - Enhanced user experience with TappableWidget
/// - List of available navigation items to replace current item
/// - Smooth animations using the animation framework
class NavigationCustomizationContent extends StatelessWidget {
  const NavigationCustomizationContent({
    required this.currentIndex,
    required this.currentItem,
    required this.availableItems,
    required this.onItemSelected,
    super.key,
  });

  /// Index of the navigation item being customized
  final int currentIndex;

  /// Current navigation item at this index
  final NavigationItem currentItem;

  /// List of available items that can replace the current item
  final List<NavigationItem> availableItems;

  /// Callback when a new item is selected
  final void Function(NavigationItem newItem) onItemSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (availableItems.isEmpty) {
      return FadeIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'navigation.all_items_active'.tr(),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'navigation.all_items_active_message'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Current item display
        FadeIn(
          delay: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  currentItem.iconPath,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'navigation.current_item'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        currentItem.label.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Available items title
        FadeIn(
          delay: const Duration(milliseconds: 200),
          child: Text(
            'navigation.available_items'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Available items list
        ...availableItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return SlideIn(
            delay: Duration(milliseconds: 300 + (index * 50)),
            direction: SlideDirection.left,
            distance: 0.3,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TappableWidget(
                onTap: () => onItemSelected(item),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        item.iconPath,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onSurfaceVariant,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 8),

        // Help text
        FadeIn(
          delay: Duration(milliseconds: 400 + (availableItems.length * 50)),
          child: Text(
            'navigation.tap_to_replace'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
