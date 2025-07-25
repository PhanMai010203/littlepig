import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../app/router/app_routes.dart';

import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';
import '../bloc/budgets_state.dart';
import '../widgets/budget_tile.dart';

/// The main page for the Budgets feature.
///
/// This widget serves as the entry point for the budget management UI.
/// It uses a [BlocBuilder] to react to state changes, displaying a loading
/// indicator, an error message, or the list of budgets.
class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  @override
  void initState() {
    super.initState();
    // Initiate the first event load. The BlocProvider is now in app.dart.
    context.read<BudgetsBloc>().add(LoadAllBudgets());
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'navigation.budgets'.tr(),
      actions: [_buildSettingsButton(context)],
      floatingActionButton: _buildFab(context),
      slivers: [
        BlocBuilder<BudgetsBloc, BudgetsState>(
          builder: (context, state) {
            debugPrint('BlocBuilder rebuilding with state: ${state.runtimeType}');
            return _buildBody(state);
          },
        ),
      ],
    );
  }

  /// Builds the appropriate sliver based on the current [BudgetsState].
  Widget _buildBody(BudgetsState state) {
    debugPrint('_buildBody called with state: ${state.runtimeType}');
    
    if (state is BudgetsLoading || state is BudgetsInitial) {
      return _buildLoading();
    }

    if (state is BudgetsError) {
      return _buildError(state.message);
    }

    if (state is BudgetsLoaded) {
      debugPrint('BudgetsLoaded: ${state.budgets.length} budgets with IDs: ${state.budgets.map((b) => b.id).toList()}');
      if (state.budgets.isEmpty) return _buildEmpty();
      return _buildBudgetList(state.budgets);
    }

    // Fallback – should rarely be reached.
    return _buildError('Unhandled state: $state');
  }

  // ───────────────────────────────── UI Helpers ──────────────────────────────────

  Widget _buildSettingsButton(BuildContext context) => IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () =>
            _showComingSoonSnackBar(context, 'budgets.settings'.tr()),
        tooltip: 'budgets.settings'.tr(),
      );

  Widget _buildFab(BuildContext context) => FloatingActionButton(
        onPressed: () => context.push(AppRoutes.budgetCreate),
        tooltip: 'budgets.create'.tr(),
        child: const Icon(Icons.add),
      );

  Widget _buildLoading() => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildError(String message) => SliverFillRemaining(
        child: Center(
            child: Text('common.error'.tr(namedArgs: {'message': message}))),
      );

  Widget _buildEmpty() => SliverFillRemaining(
        child: Center(child: Text('budgets.empty'.tr())),
      );

  Widget _buildBudgetList(List<Budget> budgets) {
    debugPrint('_buildBudgetList called with ${budgets.length} budgets: ${budgets.map((b) => b.id).toList()}');
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          debugPrint('Building BudgetTile for index $index, budget ID: ${budgets[index].id}');
          return BudgetTile(
            key: ValueKey(budgets[index].id),
            budget: budgets[index],
          );
        },
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
