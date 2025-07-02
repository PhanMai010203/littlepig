import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/transaction.dart';
import '../../../../features/categories/domain/entities/category.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart'; // Import for TransactionListItem types
// Phase 5 imports
import '../../../../shared/utils/responsive_layout_builder.dart';
import '../../../../shared/utils/performance_optimization.dart';
import '../../../../shared/utils/no_overscroll_behavior.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/dialogs/note_popup.dart';

/// Widget that displays a list of transactions grouped by date
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.selectedMonth,
    this.contentPadding,
  });

  final List<Transaction> transactions;
  final Map<int, Category> categories;
  final DateTime selectedMonth;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization(
      'TransactionList', 
      'SliverList+RepaintBoundary+ThemeCaching'
    );

    final selectedMonthTransactions = transactions.where((t) {
      return t.date.year == selectedMonth.year &&
          t.date.month == selectedMonth.month;
    }).toList();

    if (selectedMonthTransactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: AppText('No transactions for this month.'),
        ),
      );
    }

    // Phase 5: Group transactions efficiently
    final groupedTransactions = _groupTransactionsByDate(selectedMonthTransactions);
    final sortedKeys = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Phase 5: Use optimized SliverList.builder with RepaintBoundary (Phase 4 pattern)
    return SliverList.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final date = sortedKeys[index];
        final transactionsOnDate = groupedTransactions[date]!;
        
        return Padding(
          padding: contentPadding ?? EdgeInsets.zero,
          child: RepaintBoundary(
            key: ValueKey('transaction_group_${date.millisecondsSinceEpoch}'),
            child: _TransactionGroupWidget(
              date: date,
              transactions: transactionsOnDate,
              categories: categories,
              colorScheme: colorScheme, // Pass cached theme
            ),
          ),
        );
      },
    );
  }

  /// Phase 5: Efficient transaction grouping helper
  Map<DateTime, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final groupedTransactions = <DateTime, List<Transaction>>{};
    for (final transaction in transactions) {
      final day = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      if (groupedTransactions[day] == null) {
        groupedTransactions[day] = [];
      }
      groupedTransactions[day]!.add(transaction);
    }
    return groupedTransactions;
  }
}

/// Phase 5: Optimized transaction group widget with cached theme
class _TransactionGroupWidget extends StatelessWidget {
  const _TransactionGroupWidget({
    required this.date,
    required this.transactions,
    required this.categories,
    required this.colorScheme,
  });

  final DateTime date;
  final List<Transaction> transactions;
  final Map<int, Category> categories;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: AppText(
            DateFormat.yMMMMd().format(date),
            fontWeight: FontWeight.bold,
            colorName: "textSecondary",
          ),
        ),
        ...transactions.map((t) => TransactionTile(
              transaction: t,
              category: categories[t.categoryId],
            )),
      ],
    );
  }
}

/// Widget that displays a paginated list of transactions
class PaginatedTransactionList extends StatelessWidget {
  const PaginatedTransactionList({
    super.key,
    required this.pagingState,
    required this.categories,
    required this.selectedMonth,
  });

  final PagingState<int, TransactionListItem> pagingState;
  final Map<int, Category> categories;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, TransactionListItem>(
      state: pagingState,
      fetchNextPage: () =>
          context.read<TransactionsBloc>().add(FetchNextTransactionPage()),
      builderDelegate: PagedChildBuilderDelegate<TransactionListItem>(
        itemBuilder: (context, item, index) {
          if (item is DateHeaderItem) {
            return _buildDateHeader(item);
          }
          if (item is TransactionItem) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TransactionTile(
                transaction: item.transaction,
                category: categories[item.transaction.categoryId],
              ),
            );
          }
          return const SizedBox.shrink();
        },
        firstPageErrorIndicatorBuilder: (context) =>
            _buildErrorIndicator(context),
        newPageErrorIndicatorBuilder: (context) =>
            _buildErrorIndicator(context),
        firstPageProgressIndicatorBuilder: (context) => const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
        newPageProgressIndicatorBuilder: (context) => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: AppText('No transactions for this month.'),
          ),
        ),
        noMoreItemsIndicatorBuilder: (context) => const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: AppText('No more transactions'),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateHeaderItem item) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            DateFormat('EEEE, MMMM d').format(item.date),
            fontWeight: FontWeight.bold,
            colorName: "textSecondary",
          ),
          if (item.transactionCount > 1)
            AppText(
              NumberFormat.currency(symbol: '\$').format(item.totalAmount),
              fontWeight: FontWeight.bold,
              colorName: "textSecondary",
            ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.error,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            AppText('Error loading transactions', colorName: 'error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<TransactionsBloc>()
                  .add(FetchNextTransactionPage()),
              child: const AppText('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable widget for displaying individual transaction tiles
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
  });

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final double amount = transaction.amount;
    final bool isIncome = amount > 0;

    // Phase 5: Use Material elevation instead of Container (Phase 1 pattern)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: Material(
        type: MaterialType.card,
        elevation: 2.0,
        shadowColor: Colors.transparent,
        child: TappableWidget(
          onTap: () {
            // TODO: Navigate to transaction details
          },
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category circle
                CircleAvatar(
                  radius: 28,
                  backgroundColor: category?.color.withOpacity(0.15) ??
                      (isIncome
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1)),
                  child: category != null
                      ? Text(category!.icon, style: const TextStyle(fontSize: 24))
                      : Icon(
                          // Fallback if category is none
                          isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isIncome ? Colors.green : Colors.red,
                          size: 18,
                        ),
                ),
                const SizedBox(width: 5),
                // Special button
                CircleAvatar(
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      // TODO: Handle button press
                    },
                  ),
                ),
              ],
            ),
            // Text (title and note)
            title: AppText(transaction.title),
            // Amount
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                  Builder(builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        final RenderBox renderBox =
                            context.findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(Offset.zero);
                        final size = renderBox.size;
                        NotePopup.show(context, transaction.note!, position, size);
                      },
                      child: SvgPicture.asset(
                        'assets/icons/icon_note.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                ],
                SvgPicture.asset(
                  isIncome
                      ? 'assets/icons/arrow_up.svg'
                      : 'assets/icons/arrow_down.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    isIncome ? Colors.green : Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                AppText(
                  '${isIncome ? '+' : ''}${NumberFormat.currency(symbol: '\$').format(amount)}',
                  fontWeight: FontWeight.bold,
                  colorName: isIncome ? 'success' : 'error',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
