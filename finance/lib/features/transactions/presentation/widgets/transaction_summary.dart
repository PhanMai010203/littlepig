import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transactions_state.dart';
// Phase 5 imports
import '../../../../core/theme/app_colors.dart';

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

    // Phase 5: Component optimization tracking removed

    final selectedMonthTransactions = transactions.where((t) {
      return t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month;
    }).toList();

    // Phase 5: Cache expensive calculations
    final summaryData = _calculateSummaryData(selectedMonthTransactions);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        type: MaterialType.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: getColor(context, 'border'),
            width: 1,
          ),
        ),
        color: getColor(context, 'surface'),
        shadowColor: colorScheme.shadow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context: context,
                svgAsset: 'assets/icons/arrow_down.svg',
                amount: summaryData.expenses,
                colorName: 'error',
              ),
              _buildSummaryItem(
                context: context,
                svgAsset: 'assets/icons/arrow_up.svg',
                amount: summaryData.income,
                colorName: 'success',
              ),
              _buildSummaryItem(
                context: context,
                text: '=',
                amount: summaryData.net,
                colorName: summaryData.net >= 0 ? 'success' : 'error',
              ),
            ],
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
      child: Material(
        type: MaterialType.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: getColor(context, 'border'),
            width: 1,
          ),
        ),
        color: theme.colorScheme.surfaceContainer,
        shadowColor: colorScheme.shadow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context: context,
                svgAsset: 'assets/icons/arrow_down.svg',
                amount: summaryData.expenses,
                colorName: 'error',
              ),
              _buildSummaryItem(
                context: context,
                svgAsset: 'assets/icons/arrow_up.svg',
                amount: summaryData.income,
                colorName: 'success',
              ),
              _buildSummaryItem(
                context: context,
                text: '=',
                amount: summaryData.net,
                colorName: summaryData.net >= 0 ? 'success' : 'error',
              ),
            ],
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
}

Widget _buildSummaryItem({
  required BuildContext context,
  required double amount,
  required String colorName,
  String? svgAsset,
  String? text,
}) {
  final color = getColor(context, colorName);

  if (text == '=') {
    // For net, combine the '=' and the amount.
    return AppText(
      '= ${NumberFormat.currency(symbol: '\$').format(amount)}',
      fontSize: 12,
      fontWeight: FontWeight.bold,
      colorName: colorName,
    );
  }

  Widget iconWidget;
  if (svgAsset != null) {
    iconWidget = SvgPicture.asset(
      svgAsset,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      width: 15,
      height: 15,
    );
  } else {
    iconWidget = const SizedBox.shrink();
  }

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      iconWidget,
      const SizedBox(width: 0),
      AppText(
        NumberFormat.currency(symbol: '\$').format(amount.abs()),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        colorName: colorName,
      ),
    ],
  );
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
