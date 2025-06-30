import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../domain/entities/budget.dart';
import '../bloc/budgets_state.dart';
import '../bloc/budgets_bloc.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/shake_animation.dart';
import '../../../../core/theme/app_colors.dart';

/// Internal data object holding progress values.
class _ProgressData {
  const _ProgressData(this.spent, this.ghost);

  const _ProgressData.empty() : spent = 0, ghost = 0;

  final double spent;
  final double ghost;
}

/// A horizontal progress bar representing the budget utilisation.
/// Shows main spent amount, optional ghost (pending) amount and a today marker.
/// Features intelligent percentage placement with dual display system.
class BudgetProgressBar extends StatefulWidget {
  const BudgetProgressBar({super.key, required this.budget, required this.accent});

  final Budget budget;
  final Color accent;

  @override
  State<BudgetProgressBar> createState() => _BudgetProgressBarState();
}

class _BudgetProgressBarState extends State<BudgetProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  bool _fadeInInsideText = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BudgetsBloc, BudgetsState, _ProgressData>(
      selector: (state) {
        if (state is! BudgetsLoaded) return const _ProgressData.empty();
        final spent = state.realTimeSpentAmounts[widget.budget.id] ?? 0;
        // pendingAmounts not yet implemented – use 0
        final pending = 0.0; // state.pendingAmounts?[widget.budget.id] ?? 0.0;
        final ghost = spent + pending;
        return _ProgressData(spent, ghost);
      },
      builder: (context, data) {
        // Guard against division by zero when budget amount is 0
        final amount = widget.budget.amount;
        final pctMain = amount <= 0
            ? 0.0
            : (data.spent / amount).clamp(0.0, 1.0);
        final pctGhost = amount <= 0
            ? 0.0
            : (data.ghost / amount).clamp(0.0, 1.0);
        final overspent = data.spent > widget.budget.amount;

        String percentageText;
        final percentage = pctMain * 100;
        if (percentage > 0 && percentage < 1) {
          percentageText = '<1%';
        } else {
          percentageText = '${percentage.toStringAsFixed(0)}%';
        }

        // Manage fade transition for inside text
        if (pctMain > 0.4 && !_fadeInInsideText) {
          _fadeInInsideText = true;
          _fadeController.forward();
        } else if (pctMain <= 0.4 && _fadeInInsideText) {
          _fadeInInsideText = false;
          _fadeController.reverse();
        }

        return SizedBox(
          height: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final mainW = width * pctMain;
              final ghostW = width * pctGhost;

              Widget barStack = Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  _Track(width: width),
                  if (ghostW > mainW)
                    _Bar(
                      width: ghostW,
                      color: dynamicPastel(
                        context,
                        widget.accent,
                        amountLight: 0.75, // Lighter in light theme
                        amountDark: 0.6,   // A bit more solid in dark theme
                      ),
                    ),
                  // Animated main bar
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: mainW),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, animatedWidth, child) {
                      return _Bar(width: animatedWidth, color: widget.accent);
                    },
                  ),
                  // Dual percentage display system
                  _DualPercentageDisplay(
                    percentage: pctMain,
                    percentageText: percentageText,
                    accent: widget.accent,
                    fadeController: _fadeController,
                    width: width,
                  ),
                  _TodayIndicator(budget: widget.budget, barWidth: width),
                ],
              );

              if (overspent) {
                barStack = ShakeAnimation(child: barStack);
              }

              return barStack;
            },
          ),
        );
      },
    );
  }
}

/// Intelligent dual percentage display with smart color contrast
class _DualPercentageDisplay extends StatelessWidget {
  const _DualPercentageDisplay({
    required this.percentage,
    required this.percentageText,
    required this.accent,
    required this.fadeController,
    required this.width,
  });

  final double percentage;
  final String percentageText;
  final Color accent;
  final AnimationController fadeController;
  final double width;

  /// Generate text widget with appropriate color
  Widget _getPercentText(BuildContext context, Color textColor) {
    return AppText(
      percentageText,
      textColor: textColor,
      fontSize: 13,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  Widget build(BuildContext context) {
            const double threshold = 0.4; // 40% threshold for switching display mode

    return Positioned.fill(
      child: Stack(
        children: [
          // Outside percentage (shows when progress ≤ 40%)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: percentage <= threshold ? 1 : 0,
            child: Center(
              child: _getPercentText(
                context,
                lightenPastel(
                  dynamicPastel(
                    context,
                    accent,
                    inverse: true,
                    amountLight: 0.7,
                    amountDark: 0.7,
                  ),
                  amount: 0.3,
                ),
              ),
            ),
          ),
          // Inside percentage (shows when progress > 40%)
          AnimatedBuilder(
            animation: fadeController,
            builder: (context, child) {
              return AnimatedOpacity(
                opacity: percentage > threshold
                    ? fadeController.value
                    : 0,
                duration: const Duration(milliseconds: 500),
                child: Center(
                  child: _getPercentText(
                    context,
                    darkenPastel(accent, amount: 0.6),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        color: getColor(context, "surfaceContainerHigh"),
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(11),
      ),
    );
  }
}

/// Vertical today marker inside the bar
class _TodayIndicator extends StatelessWidget {
  const _TodayIndicator({required this.budget, required this.barWidth});

  final Budget budget;
  final double barWidth;

  double _percentOfPeriod(DateTime now) {
    final total = budget.endDate.difference(budget.startDate).inSeconds.toDouble();
    if (total <= 0) return 0;
    final elapsed = now.difference(budget.startDate).inSeconds.toDouble().clamp(0, total);
    return elapsed / total;
  }

  @override
  Widget build(BuildContext context) {
    final percent = _percentOfPeriod(DateTime.now());
    final indicatorColor = getColor(context, "text");

    return Positioned(
      left: percent * barWidth - 18, // Center label on the line
      top: -17,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: AppText(
              'budgets.today'.tr(),
              fontSize: 9,
              textColor: getColor(context, "white"),
            ),
          ),
          Container(
            width: 3,
            height: 24,
            color: getColor(context, "textSecondary").withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
} 