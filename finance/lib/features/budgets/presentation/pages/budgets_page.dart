import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sa3_liquid/sa3_liquid.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animations/animated_count_text.dart';
import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';

import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';
import '../bloc/budgets_state.dart';
import '../widgets/budget_timeline.dart';
import '../widgets/daily_allowance_label.dart';

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
          builder: (context, state) => _buildBody(state),
        ),
      ],
    );
  }

  /// Builds the appropriate sliver based on the current [BudgetsState].
  Widget _buildBody(BudgetsState state) {
    if (state is BudgetsLoading || state is BudgetsInitial) {
      return _buildLoading();
    }

    if (state is BudgetsError) {
      return _buildError(state.message);
    }

    if (state is BudgetsLoaded) {
      if (state.budgets.isEmpty) return _buildEmpty();
      return _buildBudgetList(state.budgets);
    }

    // Fallback – should rarely be reached.
    return _buildError('Unhandled state: $state');
  }

  // ───────────────────────────────── UI Helpers ──────────────────────────────────

  Widget _buildSettingsButton(BuildContext context) => IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => _showComingSoonSnackBar(context, 'budgets.settings'.tr()),
        tooltip: 'budgets.settings'.tr(),
      );

  Widget _buildFab(BuildContext context) => FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showComingSoonSnackBar(context, 'budgets.create'.tr()),
        tooltip: 'budgets.create'.tr(),
      );

  Widget _buildLoading() => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _buildError(String message) => SliverFillRemaining(
        child: Center(child: Text('common.error'.tr(namedArgs: {'message': message}))),
      );

  Widget _buildEmpty() => SliverFillRemaining(
        child: Center(child: Text('budgets.empty'.tr())),
      );

  Widget _buildBudgetList(List<Budget> budgets) => SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList.builder(
          itemCount: budgets.length,
          itemBuilder: (context, index) => BudgetTile(budget: budgets[index]),
        ),
      );

  void _showComingSoonSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class BudgetTile extends StatelessWidget {
  const BudgetTile({super.key, required this.budget});

  final Budget budget;

  Color _pickColor(BuildContext context) {
    // Attempt to derive color from budget.colour if available via reflection
    try {
      final colourField = budget as dynamic;
      final colourValue = colourField.colour as String?;
      if (colourValue != null) {
        return HexColor(colourValue);
      }
    } catch (_) {
      // Ignore if field not present
    }
    final palette = getSelectableColors();
    return palette[budget.name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Colors.white;

    final bool expensiveMotion =
        AppSettings.reduceAnimations || AppSettings.batterySaver ||
            MediaQuery.of(context).disableAnimations;

    final Color budgetColor = _pickColor(context);

    return TappableWidget(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'budgets.details_coming'
                  .tr(namedArgs: {'name': budget.name}),
            ),
          ),
        );
      },
      child: Container(
        height: 160,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!expensiveMotion)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: AnimatedGooBackground(
                          baseColor: budgetColor,
                          randomOffset: budget.name.length,
                        ),
                      ),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: FadeIn(
                      delay: const Duration(milliseconds: 150),
                      child: _BudgetHeaderContent(budget: budget, accent: budgetColor),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: FadeIn(
                      delay: const Duration(milliseconds: 250),
                      child: _BudgetFooterContent(budget: budget, accent: budgetColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetHeaderContent extends StatelessWidget {
  const _BudgetHeaderContent({required this.budget, required this.accent});
  final Budget budget;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocSelector<BudgetsBloc, BudgetsState, double>(
      selector: (state) =>
          state is BudgetsLoaded ? (state.realTimeSpentAmounts[budget.id] ?? 0.0) : 0.0,
      builder: (context, spent) {
        final remaining = budget.amount - spent;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              budget.name,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AnimatedCount(
              from: budget.amount,
              to: remaining,
              duration: const Duration(milliseconds: 600),
              builder: (context, animatedRemaining) {
                final isOverspent = animatedRemaining < 0;
                final trailing = isOverspent
                    ? 'budgets.overspent_of'.tr(namedArgs: {
                        'amount': budget.amount.toStringAsFixed(0),
                      })
                    : 'budgets.left_of'.tr(namedArgs: {
                        'amount': budget.amount.toStringAsFixed(0),
                      });

                return RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '\$${animatedRemaining.abs().toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' $trailing',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _BudgetFooterContent extends StatelessWidget {
  const _BudgetFooterContent({required this.budget, required this.accent});
  final Budget budget;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BudgetTimeline(budget: budget, accent: accent),
          const SizedBox(height: 12),
          DailyAllowanceLabel(budget: budget),
        ],
      ),
    );
  }
}

class AnimatedGooBackground extends StatelessWidget {
  const AnimatedGooBackground({super.key, required this.baseColor, required this.randomOffset});

  final Color baseColor;
  final int randomOffset;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = brightness == Brightness.light ? baseColor.withOpacity(0.20) : baseColor.withOpacity(0.40);

    return Transform(
      transform: Matrix4.skewX(0.001),
      child: PlasmaRenderer(
        type: PlasmaType.infinity,
        particles: 10,
        color: color,
        blur: 0.30,
        size: 1.30,
        speed: 5.30,
        offset: 0,
        blendMode: BlendMode.multiply,
        particleType: ParticleType.atlas,
        rotation: (randomOffset % 360).toDouble(),
      ),
    );
  }
}


