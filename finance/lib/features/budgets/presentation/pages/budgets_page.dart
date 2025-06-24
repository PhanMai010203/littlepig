import 'package:finance/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/page_template.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';
import '../bloc/budgets_state.dart';

/// The main page for the Budgets feature.
///
/// This widget serves as the entry point for the budget management UI.
/// It provides the [BudgetsBloc] to its widget tree and uses a [BlocBuilder]
/// to react to state changes, displaying a loading indicator, an error message,
/// or the list of budgets.
class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create and provide the BudgetsBloc, and immediately trigger the event to load all budgets.
      create: (context) => getIt<BudgetsBloc>()..add(LoadAllBudgets()),
      child: PageTemplate(
        title: 'navigation.budgets'.tr(),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget settings (coming soon)')),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create new budget (coming soon)')),
            );
          },
          child: const Icon(Icons.add),
        ),
        // The main content is built using a BlocBuilder to react to state changes.
        slivers: [
          BlocBuilder<BudgetsBloc, BudgetsState>(
            builder: (context, state) {
              if (state is BudgetsLoading || state is BudgetsInitial) {
                // Show a loading indicator while budgets are being fetched.
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is BudgetsError) {
                // Show an error message if something went wrong.
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${state.message}')),
                );
              }
              if (state is BudgetsLoaded) {
                if (state.budgets.isEmpty) {
                  // Show a message if there are no budgets to display.
                  return const SliverFillRemaining(
                    child: Center(child: Text('No budgets found. Create one!')),
                  );
                }
                // If budgets are loaded, display them in a list.
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.builder(
                    itemCount: state.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = state.budgets[index];
                      // Placeholder for the detailed budget card widget.
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(budget.name),
                          subtitle: Text(
                              'Amount: ${budget.amount.toStringAsFixed(2)}'),
                        ),
                      );
                    },
                  ),
                );
              }
              // Fallback for any other unhandled state.
              return const SliverFillRemaining(
                child: Center(child: Text('Something went wrong.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
