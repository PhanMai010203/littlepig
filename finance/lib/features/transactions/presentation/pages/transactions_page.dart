import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

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
    // The BlocProvider is now in app.dart, so we just use the bloc.
    // We initiate the first event load here.
    context.read<TransactionsBloc>().add(LoadTransactionsWithCategories());
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
