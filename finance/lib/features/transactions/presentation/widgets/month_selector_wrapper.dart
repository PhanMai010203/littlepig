import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'month_selector.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
// Phase 5 imports
import '../../../../shared/utils/responsive_layout_builder.dart';
import '../../../../shared/utils/performance_optimization.dart';

/// Wrapper widget that connects the MonthSelector to the TransactionsBloc
class MonthSelectorWrapper extends StatelessWidget {
  const MonthSelectorWrapper({
    super.key,
    required this.selectedMonth,
  });

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization(
      'MonthSelectorWrapper', 
      'ResponsiveLayoutBuilder+BlocIntegration'
    );

    // Phase 5: Use ResponsiveLayoutBuilder for consistent responsive patterns (Phase 2)
    return ResponsiveLayoutBuilder(
      debugLabel: 'MonthSelectorWrapper',
      builder: (context, constraints, layoutData) {
        return MonthSelector(
          selectedMonth: selectedMonth,
          onMonthSelected: (month) {
            context.read<TransactionsBloc>().add(ChangeSelectedMonth(month));
          },
        );
      },
    );
  }
}
