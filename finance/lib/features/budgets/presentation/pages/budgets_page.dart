import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/page_template.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';
import '../bloc/budgets_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/settings/app_settings.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../domain/entities/budget.dart';
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
                    return BudgetTile(budget: budget);
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
    final Color budgetColor = _pickColor(context);
    const Color bgColor = Colors.white;

    final bool expensiveMotion =
        AppSettings.reduceAnimations || AppSettings.batterySaver ||
            MediaQuery.of(context).disableAnimations;

    return TappableWidget(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget details coming soon for ${budget.name}')),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppText(
              budget.name,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: budget.amount, end: remaining),
              duration: const Duration(milliseconds: 600),
              builder: (context, animatedRemaining, child) {
                final isOverspent = animatedRemaining < 0;
                return RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: '\$${animatedRemaining.abs().toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: isOverspent
                            ? ' overspent of \$${budget.amount.toStringAsFixed(0)}'
                            : ' left of \$${budget.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
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
    final color = brightness == Brightness.light ? baseColor.withOpacity(0.10) : baseColor.withOpacity(0.30);

    return Transform(
      transform: Matrix4.skewX(0.001),
      child: PlasmaRenderer(
        type: PlasmaType.infinity,
        particles: 10,
        color: color,
        blur: 0.30,
        size: 1.30,
        speed: 3.30,
        offset: 0,
        blendMode: BlendMode.multiply,
        particleType: ParticleType.atlas,
        rotation: (randomOffset % 360).toDouble(),
      ),
    );
  }
}


