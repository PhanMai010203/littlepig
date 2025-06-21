import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../widgets/month_selector.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../../../core/di/injection.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final TransactionRepository _transactionRepository;
  late DateTime _selectedMonth;
  final ScrollController _monthScrollController = ScrollController();
  
  List<Transaction> _allTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _transactionRepository = getIt<TransactionRepository>();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadTransactions();
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions = await _transactionRepository.getAllTransactions();
      
      // Sort transactions by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _allTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  void _onMonthSelected(DateTime month) {
    setState(() {
      _selectedMonth = month;
    });
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
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
          )
        else ...[
          SliverToBoxAdapter(child: _buildMonthSelector()),
          SliverToBoxAdapter(child: _buildSummary()),
          _buildTransactionList(),
        ],
      ],
    );
  }

  Widget _buildSummary() {
    final selectedMonthTransactions = _allTransactions.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
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

  Widget _buildTransactionList() {
    final selectedMonthTransactions = _allTransactions.where((t) {
      return t.date.year == _selectedMonth.year &&
          t.date.month == _selectedMonth.month;
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
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
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

  Widget _buildTransactionTile(Transaction transaction) {
    final double amount = transaction.amount;
    final bool isIncome = amount > 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          child: Icon(
            isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
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
        trailing: AppText(
          '${isIncome ? '+' : ''}${NumberFormat.currency(symbol: '\$').format(amount)}',
          fontWeight: FontWeight.bold,
          colorName: isIncome ? 'success' : 'error',
        ),
        onTap: () {
          // TODO: Navigate to transaction details
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return MonthSelector(
      selectedMonth: _selectedMonth,
      onMonthSelected: _onMonthSelected,
      scrollController: _monthScrollController,
    );
  }
}
