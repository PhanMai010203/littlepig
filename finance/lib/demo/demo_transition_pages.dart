import 'package:flutter/material.dart';
import '../shared/widgets/page_template.dart';
import '../shared/widgets/animations/fade_in.dart';
import '../shared/widgets/animations/scale_in.dart';
import '../shared/widgets/animations/slide_in.dart';
import '../shared/widgets/animations/tappable_widget.dart';
import '../shared/widgets/app_text.dart';

/// Demo page showcasing slide transitions
class SlideTransitionDemoPage extends StatelessWidget {
  const SlideTransitionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Slide Transition Demo',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideIn(
                  direction: SlideDirection.left,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextStyles.heading(
                            'Slide Transition',
                            fontSize: 20,
                            colorName: 'primary',
                          ),
                          const SizedBox(height: 12),
                          AppTextStyles.body(
                            'This page demonstrates the slide transition effect. '
                            'Content slides in smoothly from the specified direction.',
                            colorName: 'textLight',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextStyles.subheading(
                  'Slide Directions:',
                  fontSize: 18,
                ),
                const SizedBox(height: 16),
                SlideIn(
                  direction: SlideDirection.up,
                  delay: const Duration(milliseconds: 200),
                  child: _DirectionCard('From Top', Icons.arrow_downward),
                ),
                const SizedBox(height: 12),
                SlideIn(
                  direction: SlideDirection.down,
                  delay: const Duration(milliseconds: 400),
                  child: _DirectionCard('From Bottom', Icons.arrow_upward),
                ),
                const SizedBox(height: 12),
                SlideIn(
                  direction: SlideDirection.left,
                  delay: const Duration(milliseconds: 600),
                  child: _DirectionCard('From Left', Icons.arrow_forward),
                ),
                const SizedBox(height: 12),
                SlideIn(
                  direction: SlideDirection.right,
                  delay: const Duration(milliseconds: 800),
                  child: _DirectionCard('From Right', Icons.arrow_back),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _DirectionCard(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text('Slides in from $title'.toLowerCase()),
      ),
    );
  }
}

/// Demo page showcasing fade transitions
class FadeTransitionDemoPage extends StatelessWidget {
  const FadeTransitionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Fade Transition Demo',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeIn(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextStyles.heading(
                            'Fade Transition',
                            fontSize: 20,
                            colorName: 'primary',
                          ),
                          const SizedBox(height: 12),
                          AppTextStyles.body(
                            'This page demonstrates the fade transition effect. '
                            'Content gracefully fades in with customizable delays.',
                            colorName: 'textLight',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextStyles.subheading(
                  'Staggered Fade Examples:',
                  fontSize: 18,
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  5,
                  (index) => FadeIn(
                    delay: Duration(milliseconds: 200 + (index * 150)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text('Fade Item ${index + 1}'),
                          subtitle: Text('Delay: ${200 + (index * 150)}ms'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Demo page showcasing scale transitions
class ScaleTransitionDemoPage extends StatelessWidget {
  const ScaleTransitionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Scale Transition Demo',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScaleIn(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextStyles.heading(
                            'Scale Transition',
                            fontSize: 20,
                            colorName: 'primary',
                          ),
                          const SizedBox(height: 12),
                          AppTextStyles.body(
                            'This page demonstrates the scale transition effect. '
                            'Content scales up smoothly with elastic curves.',
                            colorName: 'textLight',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextStyles.subheading(
                  'Scale Examples:',
                  fontSize: 18,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ScaleIn(
                        delay: const Duration(milliseconds: 200),
                        curve: Curves.elasticOut,
                        child: _ScaleCard(
                          'Elastic Out',
                          Icons.scatter_plot,
                          Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ScaleIn(
                        delay: const Duration(milliseconds: 400),
                        curve: Curves.bounceOut,
                        child: _ScaleCard(
                          'Bounce Out',
                          Icons.sports_basketball,
                          Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ScaleIn(
                        delay: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        child: _ScaleCard(
                          'Back Out',
                          Icons.undo,
                          Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ScaleIn(
                        delay: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        child: _ScaleCard(
                          'Ease Out Cubic',
                          Icons.auto_graph,
                          Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ScaleCard(String title, IconData icon, Color color) {
    return Card(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            AppTextStyles.caption(
              title,
            ),
          ],
        ),
      ),
    );
  }
}

/// Demo page showcasing combined slide-fade transitions
class SlideFadeTransitionDemoPage extends StatelessWidget {
  const SlideFadeTransitionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Slide-Fade Transition Demo',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SlideIn(
                  direction: SlideDirection.down,
                  child: FadeIn(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextStyles.heading(
                              'Slide-Fade Transition',
                              fontSize: 20,
                              colorName: 'primary',
                            ),
                            const SizedBox(height: 12),
                            AppTextStyles.body(
                              'This page demonstrates combined slide and fade transitions. '
                              'Perfect for modal presentations and drawer animations.',
                              colorName: 'textLight',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextStyles.subheading(
                  'Combined Animation Examples:',
                  fontSize: 18,
                ),
                const SizedBox(height: 16),
                _CombinedAnimationDemo(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CombinedAnimationDemo extends StatefulWidget {
  @override
  State<_CombinedAnimationDemo> createState() => _CombinedAnimationDemoState();
}

class _CombinedAnimationDemoState extends State<_CombinedAnimationDemo> {
  bool _showItems = false;

  @override
  void initState() {
    super.initState();
    // Trigger animations after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showItems = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TappableWidget(
          onTap: () => setState(() => _showItems = !_showItems),
          child: Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    _showItems ? 'Hide Items' : 'Show Items',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_showItems) ...[
          ...List.generate(
            4,
            (index) => SlideIn(
              direction: SlideDirection.left,
              delay: Duration(milliseconds: index * 100),
              child: FadeIn(
                delay: Duration(milliseconds: index * 100),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: Icon(
                        [
                          Icons.star,
                          Icons.favorite,
                          Icons.thumb_up,
                          Icons.celebration
                        ][index],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text('Combined Animation ${index + 1}'),
                      subtitle: const Text('Slides from left + fades in'),
                      trailing: const Icon(Icons.animation),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
