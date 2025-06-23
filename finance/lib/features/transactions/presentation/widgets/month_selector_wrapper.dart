import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'month_selector.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';

/// Wrapper widget that connects the MonthSelector to the TransactionsBloc
class MonthSelectorWrapper extends StatelessWidget {
  const MonthSelectorWrapper({
    super.key,
    required this.selectedMonth,
  });

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    return MonthSelector(
      selectedMonth: selectedMonth,
      onMonthSelected: (month) {
        context.read<TransactionsBloc>().add(ChangeSelectedMonth(month));
      },
    );
  }
} 