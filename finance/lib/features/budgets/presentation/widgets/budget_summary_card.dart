import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/budget_card_data.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetCardData budgetData;
  final VoidCallback? onTap;
  final bool enableAnimations;

  const BudgetSummaryCard({
    super.key,
    required this.budgetData,
    this.onTap,
    this.enableAnimations = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TappableWidget(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? () => _showBudgetDetails(context),
      child: Container(
        width: 180,
        height: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Material(
          type: MaterialType.card,
          color: getColor(context, "surfaceContainer"),
          elevation: 2.0,
          shadowColor: getColor(context, "shadowLight"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with budget name and color indicator
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        budgetData.budget.name,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: budgetData.budgetColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Amount information
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: budgetData.formattedRemaining,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: budgetData.isOverspent 
                            ? theme.colorScheme.error 
                            : theme.colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: budgetData.isOverspent
                          ? ' ${'budgets.overspent'.tr()}'
                          : ' ${'budgets.left'.tr()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: budgetData.spentPercentage,
                    backgroundColor: budgetData.budgetColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetData.isOverspent 
                        ? theme.colorScheme.error
                        : budgetData.budgetColor,
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                
                // Daily allowance or status
                Text(
                  budgetData.dailyAllowanceText,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'budgets.details_coming'
              .tr(namedArgs: {'name': budgetData.budget.name}),
        ),
      ),
    );
  }
}

class AddBudgetCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddBudgetCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TappableWidget(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 250,
        height: 145,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF6A6A6A).withValues(alpha: 0.7),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          type: MaterialType.card,
          color: Theme.of(context).cardColor,
          elevation: 1.0,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'budgets.title'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}