import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/budget.dart';

import '../../../../shared/widgets/app_text.dart';
import 'budget_progress_bar.dart';

/// A horizontal timeline row displaying the current budget period
/// with an animated progress bar in the centre.
///
/// Layout:   start-date  ──  [progress bar]  ──  end-date
class BudgetTimeline extends StatelessWidget {
  const BudgetTimeline({super.key, required this.budget});

  final Budget budget;

  Color _pickAccentColor(BuildContext context) {
    // This logic is consistent with how BudgetTile picks its color.
    final palette = getSelectableColors();
    return palette[budget.name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = DateTimeRange(start: budget.startDate, end: budget.endDate);
    final accent = _pickAccentColor(context);
    return GestureDetector(
      onTap: () {
        // Optional: show detailed timeline popup (placeholder)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Timeline details coming soon')),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Start date
          AppText(_formatShort(dateRange.start), fontSize: 12),
          const SizedBox(width: 8),
          // Progress bar expands to fill remaining space
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: BudgetProgressBar(budget: budget, accent: accent),
            ),
          ),
          const SizedBox(width: 8),
          // End date
          AppText(_formatShort(dateRange.end), fontSize: 12),
        ],
      ),
    );
  }

  String _formatShort(DateTime date) {
    return DateFormat.MMMd().format(date);
  }
} 