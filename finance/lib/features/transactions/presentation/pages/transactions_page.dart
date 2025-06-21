import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final DateTime _firstMonth;
  late final DateTime _lastMonth;
  late DateTime _selectedMonth;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _transactions = [
    // 2025 Data (current year for example)
    {
      'title': 'Groceries',
      'amount': -700.00,
      'date': DateTime.now().subtract(const Duration(days: 0)),
      'category_icon': Icons.shopping_cart
    },
    {
      'title': 'Movie streaming service',
      'amount': -15.00,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'category_icon': Icons.movie
    },
    {
      'title': 'Salary',
      'amount': 3500.00,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'category_icon': Icons.work
    },
    // 2024 Data
    {
      'title': 'Rent for Dec 2024',
      'amount': -1250.00,
      'date': DateTime(2024, 12, 5),
      'category_icon': Icons.home
    },
    {
      'title': 'Freelance Project (Dec 2024)',
      'amount': 800.00,
      'date': DateTime(2024, 12, 20),
      'category_icon': Icons.code
    },
    {
      'title': 'Christmas Gifts',
      'amount': -250.50,
      'date': DateTime(2024, 12, 22),
      'category_icon': Icons.card_giftcard
    },
    {
      'title': 'Utilities (Nov 2024)',
      'amount': -85.00,
      'date': DateTime(2024, 11, 15),
      'category_icon': Icons.receipt
    },
    {
      'title': 'Car Maintenance',
      'amount': -320.00,
      'date': DateTime(2024, 8, 18),
      'category_icon': Icons.car_repair
    },
  ];

  @override
  void initState() {
    super.initState();
    _transactions.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    _firstMonth = _transactions.isNotEmpty
        ? DateTime(
            _transactions.last['date'].year, _transactions.last['date'].month)
        : DateTime.now();

    _lastMonth = DateTime(DateTime.now().year, DateTime.now().month + 12);
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedMonth({bool animate = true}) {
    if (!_scrollController.hasClients) {
      return;
    }
    final months = <DateTime>[];
    DateTime tempMonth = _firstMonth;
    while (tempMonth.isBefore(_lastMonth) ||
        tempMonth.isAtSameMomentAs(_lastMonth)) {
      months.add(tempMonth);
      tempMonth = DateTime(tempMonth.year, tempMonth.month + 1);
    }

    final selectedIndex = months.indexWhere((month) =>
        month.year == _selectedMonth.year &&
        month.month == _selectedMonth.month);
    if (selectedIndex == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 80.0;
    final targetOffset =
        (selectedIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    final maxScroll = _scrollController.position.maxScrollExtent;
    final clampedOffset = targetOffset.clamp(0.0, maxScroll);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

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
        SliverToBoxAdapter(child: _buildMonthSelector()),
        SliverToBoxAdapter(child: _buildSummary()),
        _buildTransactionList(),
      ],
    );
  }

  Widget _buildSummary() {
    final selectedMonthTransactions = _transactions.where((t) {
      final date = t['date'] as DateTime;
      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();

    final income = selectedMonthTransactions
        .where((t) => t['amount'] > 0)
        .fold<double>(0, (sum, t) => sum + t['amount']);
    final expenses = selectedMonthTransactions
        .where((t) => t['amount'] < 0)
        .fold<double>(0, (sum, t) => sum + t['amount']);
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

  Widget _buildTransactionList() {
    final selectedMonthTransactions = _transactions.where((t) {
      final date = t['date'] as DateTime;
      return date.year == _selectedMonth.year &&
          date.month == _selectedMonth.month;
    }).toList();

    if (selectedMonthTransactions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: AppText('No transactions for this month.'),
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = <DateTime, List<Map<String, dynamic>>>{};
    for (final transaction in selectedMonthTransactions) {
      final date = transaction['date'] as DateTime;
      final day = DateTime(date.year, date.month, date.day);
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
              ...transactionsOnDate.map((t) => _buildTransactionTile(t)),
            ],
          );
        },
        childCount: sortedKeys.length,
      ),
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    final double amount = transaction['amount'];
    final bool isIncome = amount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            transaction['category_icon'] as IconData? ??
                (isIncome ? Icons.arrow_upward : Icons.arrow_downward),
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: AppText(transaction['title']),
        trailing: AppText(
          '${isIncome ? '+' : ''}${NumberFormat.currency(symbol: '\$').format(amount)}',
          fontWeight: FontWeight.bold,
          colorName: isIncome ? 'success' : 'error',
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildMonthSelector() {
    final months = <DateTime>[];
    DateTime tempMonth = _firstMonth;
    while (tempMonth.isBefore(_lastMonth) ||
        tempMonth.isAtSameMomentAs(_lastMonth)) {
      months.add(tempMonth);
      tempMonth = DateTime(tempMonth.year, tempMonth.month + 1);
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month.year == _selectedMonth.year &&
              month.month == _selectedMonth.month;
          final bool showYear = month.year != DateTime.now().year;

          return SizedBox(
            width: 80,
            child: TappableWidget(
              onTap: () {
                setState(() {
                  _selectedMonth = month;
                });
                _scrollToSelectedMonth();
              },
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      DateFormat.MMM().format(month),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    if (showYear)
                      AppText(
                        DateFormat.y().format(month),
                        fontSize: 12,
                        colorName: "textLight",
                      ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        width: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
