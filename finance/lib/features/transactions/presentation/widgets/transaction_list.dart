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

/// Widget that displays a list of transactions grouped by date
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.selectedMonth,
  });

  final List<Transaction> transactions;
  final Map<int, Category> categories;
  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
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

    // Group transactions by date
    final groupedTransactions = <DateTime, List<Transaction>>{};
    for (final transaction in selectedMonthTransactions) {
      final day = DateTime(
          transaction.date.year, transaction.date.month, transaction.date.day);
      if (groupedTransactions[day] == null) {
        groupedTransactions[day] = [];
      }
      groupedTransactions[day]!.add(transaction);
    }

    final sortedKeys = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final date = sortedKeys[index];
          final transactionsOnDate = groupedTransactions[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                child: AppText(
                  DateFormat.yMMMMd().format(date),
                  fontWeight: FontWeight.bold,
                  colorName: "textSecondary",
                ),
              ),
              ...transactionsOnDate.map((t) => TransactionTile(
                    transaction: t,
                    category: categories[t.categoryId],
                  )),
            ],
          );
        },
        childCount: sortedKeys.length,
      ),
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
            return TransactionTile(
              transaction: item.transaction,
              category: categories[item.transaction.categoryId],
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
    final double amount = transaction.amount;
    final bool isIncome = amount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: ListTile(
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
            // Transaction note button
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              Builder(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final position = renderBox.localToGlobal(Offset.zero);
                    final size = renderBox.size;
                    _showNotePopup(context, transaction.note!, position, size);
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
        onTap: () {
          // TODO: Navigate to transaction details
        },
      ),
    );
  }

  void _showNotePopup(
      BuildContext context, String note, Offset position, Size size) {
    final screenSize = MediaQuery.of(context).size;
    const double popupMaxWidth = 250.0;
    const double popupPadding = 16.0;
    const double verticalOffset = 8.0; // Distance below the SVG

    // Calculate initial position right below the tapped SVG
    double left = position.dx + (size.width / 2) - (popupMaxWidth / 2);
    double top = position.dy + size.height + verticalOffset;

    // Prevent clipping off the right edge
    if (left + popupMaxWidth + popupPadding > screenSize.width) {
      left = screenSize.width - popupMaxWidth - popupPadding;
    }

    // Prevent clipping off the left edge
    if (left < popupPadding) {
      left = popupPadding;
    }

    // Prevent clipping off the bottom edge
    if (top + 100 > screenSize.height - popupPadding) {
      // Estimated popup height
      top = position.dy - 100 - verticalOffset; // Show above the SVG instead
    }

    // Prevent clipping off the top edge
    if (top < popupPadding) {
      top = popupPadding;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: left,
              top: top,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: popupMaxWidth,
                    minWidth: 120.0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: AppText(
                    note,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Create smooth fade in/out animation with easing
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }
}
