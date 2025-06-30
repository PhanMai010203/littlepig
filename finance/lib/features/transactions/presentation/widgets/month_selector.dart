import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/widgets/animations/animated_scale_opacity.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/utils/responsive_layout_builder.dart';

class MonthSelector extends StatefulWidget {
  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthSelected,
    this.firstMonth,
    this.lastMonth,
    this.scrollController,
    this.showScrollButtons = true,
  });

  final DateTime selectedMonth;
  final Function(DateTime) onMonthSelected;
  final DateTime? firstMonth;
  final DateTime? lastMonth;
  final ScrollController? scrollController;
  final bool showScrollButtons;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late ScrollController _scrollController;
  bool _showScrollLeft = false;
  bool _showScrollRight = false;
  bool _ownsController = false;

  double _currentMonthOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _ownsController = widget.scrollController == null;

    _scrollController.addListener(_onScroll);

    // Auto-scroll to selected month after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth(animate: false);
      if (_scrollController.hasClients) {
        _calculateCurrentMonthOffset();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _scrollToSelectedMonth();
    }
  }

  void _calculateCurrentMonthOffset() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    final months = _generateMonthsList();
    final currentIndex = months.indexWhere((month) =>
        month.year == currentMonth.year && month.month == currentMonth.month);

    if (currentIndex == -1) {
      _currentMonthOffset = 0;
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const itemWidth = 80.0;
    final targetOffset =
        (currentIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    final maxScroll = _scrollController.position.maxScrollExtent;
    _currentMonthOffset =
        targetOffset.clamp(0.0, maxScroll > 0 ? maxScroll : double.infinity);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _currentMonthOffset == 0) return;

    final position = _scrollController.offset;
    final deviation = position - _currentMonthOffset;
    const threshold = 100.0; // An item and a half

    bool newShowLeft = false;
    bool newShowRight = false;

    if (deviation > threshold) {
      // Scrolled far to the right of current month -> show left button to go back
      newShowLeft = true;
    } else if (deviation < -threshold) {
      // Scrolled far to the left of current month -> show right button to go back
      newShowRight = true;
    }

    if (newShowLeft != _showScrollLeft || newShowRight != _showScrollRight) {
      setState(() {
        _showScrollLeft = newShowLeft;
        _showScrollRight = newShowRight;
      });
    }
  }

  void _scrollToSelectedMonth({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final months = _generateMonthsList();
    final selectedIndex = months.indexWhere((month) =>
        month.year == widget.selectedMonth.year &&
        month.month == widget.selectedMonth.month);

    if (selectedIndex == -1) return;

    final screenWidth = CachedMediaQueryData.get(context, cacheKey: 'month_selector').size.width;
    const itemWidth = 80.0;
    final targetOffset =
        (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  List<DateTime> _generateMonthsList() {
    final now = DateTime.now();
    final firstMonth = widget.firstMonth ?? DateTime(now.year - 2, 1);
    final lastMonth = widget.lastMonth ?? DateTime(now.year + 1, 12);

    final months = <DateTime>[];
    DateTime tempMonth = DateTime(firstMonth.year, firstMonth.month);

    while (tempMonth.isBefore(lastMonth) ||
        tempMonth.isAtSameMomentAs(lastMonth)) {
      months.add(tempMonth);
      tempMonth = DateTime(tempMonth.year, tempMonth.month + 1);
    }

    return months;
  }

  void _scrollToCurrentMonth() {
    if (!_scrollController.hasClients) return;

    final now = DateTime.now();
    final todayMonth = DateTime(now.year, now.month);

    _scrollController.animateTo(
      _currentMonthOffset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.ease,
    );
    widget.onMonthSelected(todayMonth);
  }

  @override
  Widget build(BuildContext context) {
    final months = _generateMonthsList();

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Stack(
        children: [
          // Main horizontal list
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month.year == widget.selectedMonth.year &&
                  month.month == widget.selectedMonth.month;
              final isCurrentMonth = month.year == DateTime.now().year &&
                  month.month == DateTime.now().month;
              final showYear = month.year != DateTime.now().year;

              return SizedBox(
                width: 80,
                child: TappableWidget(
                  onTap: () => widget.onMonthSelected(month),
                  animationType: TapAnimationType.scale,
                  scaleFactor: 0.9,
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Month name
                        AppText(
                          DateFormat.MMM().format(month),
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          colorName: isSelected ? "text" : "textLight",
                        ),

                        // Year (if different from current year)
                        if (showYear)
                          AppText(
                            DateFormat.y().format(month),
                            fontSize: 12,
                            colorName:
                                isSelected ? "textSecondary" : "textLight",
                          ),

                        // Current month indicator (small dot when not selected)
                        if (isCurrentMonth && !isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.6),
                            ),
                          ),

                        // Selection indicator (bottom line when selected)
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            height: 2,
                            width: 20,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Left button to scroll to current month
          if (widget.showScrollButtons)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedScaleOpacity(
                visible: _showScrollLeft,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 8, bottom: 8, start: 2),
                  child: TappableWidget(
                    onTap: _scrollToCurrentMonth,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Transform.scale(
                        scale: 1.5,
                        child: Icon(Icons.arrow_left_rounded,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Right button to scroll to current month
          if (widget.showScrollButtons)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedScaleOpacity(
                visible: _showScrollRight,
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 8, bottom: 8, end: 2),
                  child: TappableWidget(
                    onTap: _scrollToCurrentMonth,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Transform.scale(
                        scale: 1.5,
                        child: Icon(Icons.arrow_right_rounded,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
