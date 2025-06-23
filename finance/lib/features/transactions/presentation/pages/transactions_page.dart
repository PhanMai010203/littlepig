import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../widgets/month_selector.dart';
import '../../domain/entities/transaction.dart';
import '../../../../features/categories/domain/entities/category.dart';
import '../../../../core/di/injection.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TransactionsBloc>()
        ..add(LoadTransactionsWithCategories()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'navigation.transactions'.tr(),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter transactions')),
            );
          },
          icon: const Icon(Icons.filter_list),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Search transactions')),
            );
          },
          icon: const Icon(Icons.search),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new transaction')),
          );
        },
        child: const Icon(Icons.add),
      ),
      slivers: [
        BlocConsumer<TransactionsBloc, TransactionsState>(
          listener: (context, state) {
            if (state is TransactionsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is TransactionsLoading) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            if (state is TransactionsError) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        AppText(state.message, colorName: 'error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<TransactionsBloc>().add(RefreshTransactions()),
                          child: const AppText('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is TransactionsLoaded) {
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: _MonthSelectorWrapper(
                      selectedMonth: state.selectedMonth,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SummaryWrapper(
                      transactions: state.transactions,
                      selectedMonth: state.selectedMonth,
                    ),
                  ),
                  _TransactionListWrapper(
                    transactions: state.transactions,
                    categories: state.categories,
                    selectedMonth: state.selectedMonth,
                  ),
                ],
              );
            }

            return const SliverToBoxAdapter(child: SizedBox.shrink());
          },
        ),
      ],
    );
  }
}

class _MonthSelectorWrapper extends StatelessWidget {
  const _MonthSelectorWrapper({
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

class _SummaryWrapper extends StatelessWidget {
  const _SummaryWrapper({
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

class _TransactionListWrapper extends StatelessWidget {
  const _TransactionListWrapper({
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
              ...transactionsOnDate.map((t) => _buildTransactionTile(t, context)),
            ],
          );
        },
        childCount: sortedKeys.length,
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction, BuildContext context) {
    final double amount = transaction.amount;
    final bool isIncome = amount > 0;
    final category = categories[transaction.categoryId];

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
                  ? Text(category.icon, style: const TextStyle(fontSize: 24))
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
        subtitle: transaction.note != null && transaction.note!.isNotEmpty
            ? AppText(
                transaction.note!,
                fontSize: 12,
                colorName: "textLight",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
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
    if (top + 100 > screenSize.height - popupPadding) { // Estimated popup height
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