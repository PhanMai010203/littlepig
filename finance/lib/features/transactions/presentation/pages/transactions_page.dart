import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/app_routes.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../widgets/month_selector_wrapper.dart';
import '../widgets/transaction_summary.dart';
import '../widgets/transaction_list.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🔄 TransactionsPage initState - Loading transactions with categories');
    // The BlocProvider is now in app.dart, so we just use the bloc.
    // We initiate the first event load here.
    context.read<TransactionsBloc>().add(LoadTransactionsWithCategories());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('🔄 TransactionsPage didChangeDependencies - Checking if refresh needed');
    
    // Check if we need to refresh due to navigation or AI service changes
    final shouldRefresh = ModalRoute.of(context)?.isCurrent == true;
    debugPrint('🔄 Should refresh transactions: $shouldRefresh');
    
    if (shouldRefresh) {
      debugPrint('🔄 Triggering transaction refresh...');
      context.read<TransactionsBloc>().add(RefreshTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const _TransactionsView();
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
          context.push(AppRoutes.transactionCreate);
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
                        Icon(Icons.error,
                            size: 64,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        AppText(state.message, colorName: 'error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<TransactionsBloc>()
                              .add(RefreshTransactions()),
                          child: const AppText('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is TransactionsPaginated) {
              debugPrint('📊 Transactions loaded (Paginated) for ${state.selectedMonth != null ? DateFormat('MMMM yyyy').format(state.selectedMonth!) : 'All time'}');
              debugPrint('🗓️ Selected month filter: ${DateFormat('yyyy-MM').format(state.selectedMonth)}');
              final allItems = state.pagingState.pages?.expand((page) => page).toList() ?? [];
              final transactionItems = allItems.whereType<TransactionItem>().toList();
              debugPrint('📄 Total transaction items loaded: ${transactionItems.length}');
              debugPrint('📄 Total items (including headers): ${allItems.length}');
              debugPrint('🔢 Has more pages: ${state.pagingState.hasNextPage}');
              if (transactionItems.isNotEmpty) {
                debugPrint('💰 Recent transaction details:');
                for (int i = 0; i < transactionItems.length && i < 5; i++) {
                  final transaction = transactionItems[i].transaction;
                  debugPrint('  ${i + 1}. ${transaction.title} - \$${transaction.amount} (${DateFormat('MMM dd').format(transaction.date)})');
                }
                if (transactionItems.length > 5) {
                  debugPrint('  ... and ${transactionItems.length - 5} more transactions');
                }
              } else {
                debugPrint('📭 No transaction items found');
              }
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: MonthSelectorWrapper(
                      selectedMonth: state.selectedMonth,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: PaginatedTransactionSummary(
                      pagingState: state.pagingState,
                      selectedMonth: state.selectedMonth,
                    ),
                  ),
                  PaginatedTransactionList(
                    pagingState: state.pagingState,
                    categories: state.categories,
                    selectedMonth: state.selectedMonth,
                  ),
                ],
              );
            }

            if (state is TransactionsLoaded) {
              debugPrint('📊 Transactions loaded for ${state.selectedMonth != null ? DateFormat('MMMM yyyy').format(state.selectedMonth!) : 'All time'}');
              debugPrint('🗓️ Selected month filter: ${DateFormat('yyyy-MM').format(state.selectedMonth)}');
              debugPrint('📄 Total transactions: ${state.transactions.length}');
              if (state.transactions.isNotEmpty) {
                debugPrint('💰 Transaction details:');
                for (int i = 0; i < state.transactions.length; i++) {
                  final transaction = state.transactions[i];
                  debugPrint('  ${i + 1}. ${transaction.title} - \$${transaction.amount} (${transaction.date})');
                }
              } else {
                debugPrint('📭 No transactions found for the selected period');
              }
              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: MonthSelectorWrapper(
                      selectedMonth: state.selectedMonth,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: TransactionSummary(
                      transactions: state.transactions,
                      selectedMonth: state.selectedMonth,
                    ),
                  ),
                  TransactionList(
                    transactions: state.transactions,
                    categories: state.categories,
                    selectedMonth: state.selectedMonth,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
