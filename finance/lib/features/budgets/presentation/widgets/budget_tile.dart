import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animations/animated_count_text.dart';
import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_state.dart';
import 'animated_goo_background.dart';
import 'budget_timeline.dart';
import 'daily_allowance_label.dart';

class BudgetTile extends StatelessWidget {
  const BudgetTile({super.key, required this.budget});

  final Budget budget;

  Color _pickColor(BuildContext context) {
    // Attempt to derive color from budget.colour if available via reflection
    try {
      final colourField = budget as dynamic;
      final colourValue = colourField.colour as String?;
      if (colourValue != null) {
        return HexColor(colourValue);
      }
    } catch (_) {
      // Ignore if field not present
    }
    final palette = getSelectableColors();
    return palette[budget.name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool expensiveMotion =
        AppSettings.reduceAnimations || AppSettings.batterySaver ||
            MediaQuery.of(context).disableAnimations;

    final Color budgetColor = _pickColor(context);

    return TappableWidget(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'budgets.details_coming'
                  .tr(namedArgs: {'name': budget.name}),
            ),
          ),
        );
      },
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Material(
          type: MaterialType.card,
          color: getColor(context, "surfaceContainer"),
          elevation: 4.0,
          shadowColor: getColor(context, "shadowLight"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (!expensiveMotion)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedGooBackground(
                            baseColor: budgetColor,
                            randomOffset: budget.name.length,
                          ),
                        ),
                        const Expanded(child: SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: budget.manualAddMode ? 20.0 : 56.0, // Extra space for history button
                      ),
                      child: _BudgetHeaderContent(budget: budget, accent: budgetColor),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: _BudgetFooterContent(budget: budget, accent: budgetColor),
                    ),
                  ),
                ],
              ),
              // History button - only for automatic budgets
              if (!budget.manualAddMode)
                _buildHistoryButton(context, budgetColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context, Color budgetColor) {
    // Use dynamic pastel for theme-aware button color
    final buttonColor = dynamicPastel(
      context, 
      budgetColor, 
      amountLight: 0.75, // Light theme: more transparent
      amountDark: 0.2,   // Dark theme: less transparent
    );
    
    final iconColor = getColor(context, "text");

    return Positioned(
      top: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHistorySnackBar(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/icon_history.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHistorySnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('History for ${budget.name} coming soon'),
      ),
    );
  }
}

class _BudgetHeaderContent extends StatelessWidget {
  const _BudgetHeaderContent({required this.budget, required this.accent});
  final Budget budget;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<BudgetsBloc, BudgetsState, double>(
      selector: (state) =>
          state is BudgetsLoaded ? (state.realTimeSpentAmounts[budget.id] ?? 0.0) : 0.0,
      builder: (context, spent) {
        final remaining = budget.amount - spent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              budget.name,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AnimatedCount(
              from: budget.amount,
              to: remaining,
              duration: const Duration(milliseconds: 600),
              builder: (context, animatedRemaining) {
                final isOverspent = animatedRemaining < 0;
                final trailing = isOverspent
                    ? 'budgets.overspent_of'.tr(namedArgs: {
                        'amount': budget.amount.toStringAsFixed(0),
                      })
                    : 'budgets.left_of'.tr(namedArgs: {
                        'amount': budget.amount.toStringAsFixed(0),
                      });

                return RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '\$${animatedRemaining.abs().toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $trailing',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _BudgetFooterContent extends StatelessWidget {
  const _BudgetFooterContent({required this.budget, required this.accent});
  final Budget budget;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BudgetTimeline(budget: budget),
          const SizedBox(height: 12),
          DailyAllowanceLabel(budget: budget),
        ],
      ),
    );
  }
} 