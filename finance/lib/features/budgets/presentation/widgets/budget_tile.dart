import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animations/animated_count_text.dart';
import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_state.dart';
import '../bloc/budgets_event.dart';
import '../../../currencies/presentation/bloc/currency_display_bloc.dart';
import 'animated_goo_background.dart';
import 'budget_timeline.dart';
import 'daily_allowance_label.dart';
import '../../../../shared/widgets/dialogs/note_popup.dart';

class BudgetTile extends StatelessWidget {
  const BudgetTile({super.key, required this.budget});

  final Budget budget;

  @override
  Widget build(BuildContext context) {
    final bool expensiveMotion =
        AppSettings.reduceAnimations || AppSettings.batterySaver ||
            MediaQuery.of(context).disableAnimations;

    final Color budgetColor = _pickColor(context);

    return GestureDetector(
      onTap: () => _handleTap(context),
      onLongPressStart: (details) => _handleLongPressStart(context, details),
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: getColor(context, "surfaceContainer"),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
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
        child: GestureDetector(
          onTap: () => _showHistorySnackBar(context),
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

  // ────────────────────────────── Interaction Handlers ─────────────────────────────

  void _handleLongPressStart(BuildContext context, LongPressStartDetails details) {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show floating "Delete" note popup at fingertip position
    NotePopup.show(
      context,
      'Delete',
      details.globalPosition,
      const Size(50, 50), // Approximate finger size
      textColor: Colors.red,
      onTap: () => _showDeleteConfirmation(context),
    );
  }

  void _handleTap(BuildContext context) {
    // Default tap behaviour – show stub toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'budgets.details_coming'.tr(namedArgs: {'name': budget.name}),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: AppText('Delete Budget'),
            content: AppText(
              'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: AppText('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: AppText(
                  'Delete',
                  textColor: Colors.red,
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed && budget.id != null) {
      debugPrint('Dispatching DeleteBudget event for ID: ${budget.id!}');
      context.read<BudgetsBloc>().add(DeleteBudget(budget.id!));
    }
  }

  Color _pickColor(BuildContext context) {
    // Use the budget's color if available, otherwise fall back to hash-based selection
    if (budget.colour != null && budget.colour!.isNotEmpty) {
      return HexColor(budget.colour!);
    }
    final palette = getSelectableColors();
    return palette[budget.name.hashCode.abs() % palette.length];
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
                return BlocBuilder<CurrencyDisplayBloc, CurrencyDisplayState>(
                  builder: (context, currencyState) {
                    return FutureBuilder<String>(
                      future: context.read<CurrencyDisplayBloc>()
                          .formatInDisplayCurrency(budget.amount, 'USD'),
                      builder: (context, budgetSnapshot) {
                        final budgetAmountFormatted = budgetSnapshot.data ?? budget.amount.toStringAsFixed(0);
                        final trailing = isOverspent
                            ? 'budgets.overspent_of'.tr(namedArgs: {
                                'amount': budgetAmountFormatted,
                              })
                            : 'budgets.left_of'.tr(namedArgs: {
                                'amount': budgetAmountFormatted,
                              });

                        return FutureBuilder<String>(
                          future: context.read<CurrencyDisplayBloc>()
                              .formatInDisplayCurrency(animatedRemaining.abs(), 'USD'),
                          builder: (context, snapshot) {
                            final formattedAmount = snapshot.data ?? '\$${animatedRemaining.abs().toStringAsFixed(0)}';
                            return RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: formattedAmount,
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
                        );
                      },
                    );
                  },
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