import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/entities/navigation_item.dart';
// Phase 5 import
import '../../../../shared/widgets/animations/tappable_widget.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Sliding indicator with smooth animation
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
                        child: _AnimatedNavigationItem(
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
    );
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
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with flutter_animate bounce effect
            Container(
              padding: const EdgeInsets.all(8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: SvgPicture.asset(
                  item.iconPath,
                  key: ValueKey('${item.iconPath}_$isSelected'),
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            )
            .animate()
            .scaleXY(
              begin: isTapped ? 0.85 : 1.0,
              end: 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
            ),
            
            const SizedBox(height: 4),
            
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
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
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
}
