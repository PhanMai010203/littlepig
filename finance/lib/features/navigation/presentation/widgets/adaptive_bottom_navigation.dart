import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

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

class _AdaptiveBottomNavigationState extends State<AdaptiveBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animations for bounce effect
    _scaleControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );

    _scaleAnimations = _scaleControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Sliding indicator animation
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _indicatorAnimation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AdaptiveBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items.length != widget.items.length) {
      // Dispose old controllers and reinitialize
      _disposeControllers();
      _initializeAnimations();
    }

    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateIndicator(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _animateIndicator(int from, int to) {
    _previousIndex = from;
    _indicatorAnimation = Tween<double>(
      begin: from.toDouble(),
      end: to.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOutCubic,
    ));

    _indicatorController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final controller in _scaleControllers) {
      controller.dispose();
    }
    _indicatorController.dispose();
  }

  void _handleTap(int index) {
    // Call onTap immediately for instant response
    widget.onTap(index);

    // Trigger bounce animation asynchronously
    _playBounceAnimation(index);
  }

  void _playBounceAnimation(int index) async {
    await _scaleControllers[index].forward();
    _scaleControllers[index].reverse();
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
                  // Sliding indicator
                  AnimatedBuilder(
                    animation: _indicatorAnimation,
                    builder: (context, child) {
                      final itemWidth =
                          constraints.maxWidth / widget.items.length;
                      final indicatorWidth =
                          itemWidth * 0.7; // 70% of item width
                      final indicatorHeight = 40.0;
                      final leftPosition =
                          (_indicatorAnimation.value * itemWidth) +
                              (itemWidth - indicatorWidth) / 2;

                      return Positioned(
                        left: leftPosition,
                        top: 8,
                        child: Container(
                          width: indicatorWidth,
                          height: indicatorHeight,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                  ),
                  // Navigation items
                  Row(
                    children: widget.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = index == widget.currentIndex;

                      return Expanded(
                        child: _AnimatedNavigationItem(
                          item: item,
                          isSelected: isSelected,
                          scaleAnimation: _scaleAnimations[index],
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
    required this.scaleAnimation,
    required this.onTap,
    this.onLongPress,
  });

  final NavigationItem item;
  final bool isSelected;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: TappableWidget(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon container (no background - indicator handles it)
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
          ),
        );
      },
    );
  }
}
