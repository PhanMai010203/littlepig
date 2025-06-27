import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/budget.dart';
import '../bloc/budgets_state.dart';
import '../bloc/budgets_bloc.dart';

import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/app_text.dart';

extension _BudgetRemainingDays on Budget {
  int remainingDays(DateTime now) {
    final diff = endDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }
}

class DailyAllowanceLabel extends StatelessWidget {
  const DailyAllowanceLabel({super.key, required this.budget});

  final Budget budget;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BudgetsBloc, BudgetsState, double>(
      selector: (state) {
        if (state is BudgetsLoaded) {
          return state.dailySpendingAllowances[budget.id] ?? 0;
        }
        return 0;
      },
      builder: (context, allowance) {
        final remainingDays = budget.remainingDays(DateTime.now());
        final message = 'You can spend \$${allowance.toStringAsFixed(0)}/day for $remainingDays more days';
        return FadeIn(
          delay: const Duration(milliseconds: 100),
          child: AppText(
            message,
            fontSize: 11,
          ),
        );
      },
    );
  }
} 