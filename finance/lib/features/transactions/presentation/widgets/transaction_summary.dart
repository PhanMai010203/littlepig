import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transactions_state.dart';

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
    final selectedMonthTransactions = transactions.where((t) {
      return t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month;
    }).toList();

    final income = selectedMonthTransactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expenses = selectedMonthTransactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final net = income + expenses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                  Icons.arrow_downward, 'Expense', expenses, Colors.red),
              _buildSummaryItem(
                  Icons.arrow_upward, 'Income', income, Colors.green),
              _buildSummaryItem(Icons.swap_horiz, 'Net', net,
                  net >= 0 ? Colors.green : Colors.red),
            ],
          ),
        ),
      ),
    );
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

    final income = selectedMonthTransactions
        .where((t) => t.amount > 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final expenses = selectedMonthTransactions
        .where((t) => t.amount < 0)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final net = income + expenses;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                  Icons.arrow_downward, 'Expense', expenses, Colors.red),
              _buildSummaryItem(
                  Icons.arrow_upward, 'Income', income, Colors.green),
              _buildSummaryItem(Icons.swap_horiz, 'Net', net,
                  net >= 0 ? Colors.green : Colors.red),
            ],
          ),
        ),
      ),
    );
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
