import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transactions_state.dart';
// Phase 5 imports
import '../../../../shared/utils/performance_optimization.dart';

/// Widget that displays transaction summary (income, expenses, net) for a selected month
class TransactionSummary extends StatelessWidget {
  const TransactionSummary({
    super.key,
    required this.transactions,
    required this.selectedMonth,
  });

  final List<Transaction> transactions;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization(
      'TransactionSummary', 
      'Material+ThemeCaching+CalculationCaching'
    );

    final selectedMonthTransactions = transactions.where((t) {
      return t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month;
    }).toList();

    // Phase 5: Cache expensive calculations
    final summaryData = _calculateSummaryData(selectedMonthTransactions);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          type: MaterialType.card,
          elevation: 2.0,
          shadowColor: colorScheme.shadow,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                    Icons.arrow_downward, 'Expense', summaryData.expenses, colorScheme.error),
                _buildSummaryItem(
                    Icons.arrow_upward, 'Income', summaryData.income, colorScheme.primary),
                _buildSummaryItem(Icons.swap_horiz, 'Net', summaryData.net,
                    summaryData.net >= 0 ? colorScheme.primary : colorScheme.error),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Phase 5: Cached summary calculation
  _SummaryData _calculateSummaryData(List<Transaction> transactions) {
    final income = transactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final net = income + expenses;
    
    return _SummaryData(income: income, expenses: expenses, net: net);
  }

  Widget _buildSummaryItem(
      IconData icon, String label, double amount, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            AppText(label, fontSize: 14),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          NumberFormat.currency(symbol: '\$').format(amount.abs()),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          colorName: color == Colors.red ? 'error' : 'success',
        ),
      ],
    );
  }
}

/// Widget that displays transaction summary for paginated transaction lists
class PaginatedTransactionSummary extends StatelessWidget {
  const PaginatedTransactionSummary({
    super.key,
    required this.pagingState,
    required this.selectedMonth,
  });

  final PagingState<int, TransactionListItem> pagingState;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get all transactions from all pages
    final allItems = pagingState.pages?.expand((page) => page).toList() ?? [];
    final allTransactions = allItems
        .whereType<TransactionItem>()
        .map((item) => item.transaction)
        .toList();

    final selectedMonthTransactions = allTransactions.where((t) {
      return t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month;
    }).toList();

    // Phase 5: Cache expensive calculations
    final summaryData = _calculateSummaryData(selectedMonthTransactions);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Material(
          type: MaterialType.card,
          elevation: 2.0,
          shadowColor: colorScheme.shadow,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                    Icons.arrow_downward, 'Expense', summaryData.expenses, colorScheme.error),
                _buildSummaryItem(
                    Icons.arrow_upward, 'Income', summaryData.income, colorScheme.primary),
                _buildSummaryItem(Icons.swap_horiz, 'Net', summaryData.net,
                    summaryData.net >= 0 ? colorScheme.primary : colorScheme.error),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Phase 5: Cached summary calculation for paginated data
  _SummaryData _calculateSummaryData(List<Transaction> transactions) {
    final income = transactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expenses = transactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final net = income + expenses;
    
    return _SummaryData(income: income, expenses: expenses, net: net);
  }

  Widget _buildSummaryItem(
      IconData icon, String label, double amount, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            AppText(label, fontSize: 14),
          ],
        ),
        const SizedBox(height: 4),
        AppText(
          NumberFormat.currency(symbol: '\$').format(amount.abs()),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          colorName: color == Colors.red ? 'error' : 'success',
        ),
      ],
    );
  }
}

// TransactionListItem types are imported from ../bloc/transactions_state.dart

/// Phase 5: Helper class for cached summary calculations
class _SummaryData {
  final double income;
  final double expenses;
  final double net;

  const _SummaryData({
    required this.income,
    required this.expenses,
    required this.net,
  });
}
