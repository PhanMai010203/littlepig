import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../shared/widgets/page_template.dart';
import '../shared/widgets/animations/fade_in.dart';
import '../shared/widgets/animations/scale_in.dart';
import '../shared/widgets/animations/slide_in.dart';
import '../shared/widgets/animations/tappable_widget.dart';
import '../shared/widgets/animations/bouncing_widget.dart';
import '../shared/widgets/animations/breathing_widget.dart';
import '../shared/widgets/animations/shake_animation.dart';
import '../shared/widgets/animations/animated_expanded.dart';
import '../shared/widgets/animations/scaled_animated_switcher.dart';
import '../shared/widgets/app_text.dart';
import '../core/services/dialog_service.dart';
import '../shared/widgets/dialogs/bottom_sheet_service.dart';
import '../core/di/injection.dart';

/// Comprehensive demo page showcasing all framework capabilities
///
/// This page demonstrates:
/// - Page template usage patterns
/// - Animation framework components
/// - Dialog and popup system
/// - Reusable widgets
/// - Navigation patterns
/// - Performance considerations
class FrameworkDemoPage extends StatefulWidget {
  const FrameworkDemoPage({super.key});

  @override
  State<FrameworkDemoPage> createState() => _FrameworkDemoPageState();
}

class _FrameworkDemoPageState extends State<FrameworkDemoPage> {
  bool _expandedSection = false;
  int _switcherIndex = 0;
  final List<String> _switcherTexts = ['First', 'Second', 'Third', 'Fourth'];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Framework Demo',
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(context),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildAnimationSection(),
          const SizedBox(height: 24),
          _buildInteractiveSection(),
          const SizedBox(height: 24),
          _buildDialogSection(),
          const SizedBox(height: 24),
          _buildNavigationSection(),
          const SizedBox(height: 24),
          _buildTextSection(),
          const SizedBox(height: 24),
          _buildPerformanceSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeIn(
      delay: const Duration(milliseconds: 100),
      child: const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Finance App Framework Demo',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                colorName: 'primary',
              ),
              SizedBox(height: 12),
              AppText(
                'This comprehensive demo showcases all framework capabilities including '
                'page templates, animations, dialogs, reusable widgets, and navigation patterns. '
                'Perfect for developers to understand and reference implementation patterns.',
                colorName: 'textLight',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationSection() {
    return FadeIn(
      delay: const Duration(milliseconds: 200),
      child: _DemoSection(
        title: 'Animation Framework',
        subtitle: 'Showcase of all available animation widgets',
        children: [
          // Entry animations row
          Row(
            children: [
              Expanded(
                child: FadeIn(
                  delay: const Duration(milliseconds: 300),
                  child: _AnimationCard(
                    title: 'Fade In',
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('Faded')),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ScaleIn(
                  delay: const Duration(milliseconds: 400),
                  child: _AnimationCard(
                    title: 'Scale In',
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('Scaled')),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SlideIn(
                  direction: SlideDirection.left,
                  delay: const Duration(milliseconds: 500),
                  child: _AnimationCard(
                    title: 'Slide In',
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text('Slid In')),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnimationCard(
                  title: 'Tappable',
                  child: TappableWidget(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tapped with animation!')),
                    ),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Tap Me!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Effect animations
          Row(
            children: [
              Expanded(
                child: _AnimationCard(
                  title: 'Bouncing',
                  child: BouncingWidget(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.sports_basketball),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AnimationCard(
                  title: 'Breathing',
                  child: BreathingWidget(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.favorite, color: Colors.red),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Interactive animations
          _AnimationCard(
            title: 'Shake Animation (Error)',
            child: ShakeAnimation(
              child: TappableWidget(
                onTap: () => _triggerShake(),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Tap to Shake',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSection() {
    return FadeIn(
      delay: const Duration(milliseconds: 300),
      child: _DemoSection(
        title: 'Interactive Components',
        subtitle: 'Dynamic animations and state transitions',
        children: [
          _AnimationCard(
            title: 'Animated Expanded',
            child: Column(
              children: [
                TappableWidget(
                  onTap: () =>
                      setState(() => _expandedSection = !_expandedSection),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _expandedSection ? 'Collapse' : 'Expand',
                          style: const TextStyle(color: Colors.white),
                        ),
                        Icon(
                          _expandedSection
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedExpanded(
                  expand: _expandedSection,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'This content smoothly expands and collapses with fade effects. '
                      'Perfect for FAQ sections, settings panels, or any collapsible content.',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _AnimationCard(
            title: 'Scaled Animated Switcher',
            child: Column(
              children: [
                ScaledAnimatedSwitcher(
                  child: Container(
                    key: ValueKey(_switcherIndex),
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        _switcherTexts[_switcherIndex],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _switcherTexts.length,
                    (index) => TappableWidget(
                      onTap: () => setState(() => _switcherIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _switcherIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: _switcherIndex == index
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogSection() {
    return FadeIn(
      delay: const Duration(milliseconds: 400),
      child: _DemoSection(
        title: 'Dialog & Popup System',
        subtitle: 'Comprehensive dialog and bottom sheet framework',
        children: [
          Row(
            children: [
              Expanded(
                child: TappableWidget(
                  onTap: () => _showPopupDialog(context),
                  child: const _ActionCard(
                    icon: Icons.info,
                    title: 'Popup Dialog',
                    subtitle: 'Show standard popup',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TappableWidget(
                  onTap: () => _showConfirmDialog(context),
                  child: const _ActionCard(
                    icon: Icons.help,
                    title: 'Confirm Dialog',
                    subtitle: 'Action confirmation',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TappableWidget(
                  onTap: () => _showBottomSheet(context),
                  child: const _ActionCard(
                    icon: Icons.menu,
                    title: 'Bottom Sheet',
                    subtitle: 'Custom bottom sheet',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TappableWidget(
                  onTap: () => _showSnappingBottomSheet(context),
                  child: const _ActionCard(
                    icon: Icons.view_agenda,
                    title: 'Snapping Sheet',
                    subtitle: 'Snap points sheet',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection() {
    return FadeIn(
      delay: const Duration(milliseconds: 500),
      child: _DemoSection(
        title: 'Navigation Patterns',
        subtitle: 'Different page transition demonstrations',
        children: [
          Row(
            children: [
              Expanded(
                child: TappableWidget(
                  onTap: () => context.push('/demo/slide-transition'),
                  child: const _ActionCard(
                    icon: Icons.arrow_forward,
                    title: 'Slide Transition',
                    subtitle: 'Right slide effect',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TappableWidget(
                  onTap: () => context.push('/demo/fade-transition'),
                  child: const _ActionCard(
                    icon: Icons.opacity,
                    title: 'Fade Transition',
                    subtitle: 'Fade in/out effect',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TappableWidget(
                  onTap: () => context.push('/demo/scale-transition'),
                  child: const _ActionCard(
                    icon: Icons.zoom_in,
                    title: 'Scale Transition',
                    subtitle: 'Scale up effect',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TappableWidget(
                  onTap: () => context.push('/demo/slide-fade-transition'),
                  child: const _ActionCard(
                    icon: Icons.swipe_up,
                    title: 'Slide-Fade',
                    subtitle: 'Combined effects',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return FadeIn(
      delay: const Duration(milliseconds: 600),
      child: _DemoSection(
        title: 'Text Framework',
        subtitle: 'AppText widget with comprehensive styling',
        children: [
          _TextExample(
            'Display Large',
            () => const AppText('Display Large Text',
                fontSize: 28, fontWeight: FontWeight.bold),
          ),
          _TextExample(
            'Headline Medium',
            () => const AppText('Headline Medium Text',
                fontSize: 24, fontWeight: FontWeight.w600),
          ),
          _TextExample(
            'Title Large',
            () => const AppText('Title Large Text',
                fontSize: 20, fontWeight: FontWeight.w500),
          ),
          _TextExample(
            'Body Large',
            () => const AppText('Body Large Text', fontSize: 16),
          ),
          _TextExample(
            'Body Medium',
            () => const AppText('Body Medium Text', fontSize: 14),
          ),
          _TextExample(
            'Label Small',
            () => const AppText('Label Small Text', fontSize: 12),
          ),
          const SizedBox(height: 16),
          const AppText(
            'Custom Styled Examples:',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          const AppText(
            'Primary Color Bold',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            colorName: 'primary',
          ),
          const AppText(
            'Secondary Color Medium',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            colorName: 'secondary',
          ),
          const AppText(
            'Error Color Text',
            fontSize: 12,
            colorName: 'error',
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return FadeIn(
      delay: const Duration(milliseconds: 700),
      child: _DemoSection(
        title: 'Performance Features',
        subtitle: 'Framework performance and optimization',
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'Performance Optimizations',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 12),
                  _PerformanceItem(
                    'Animation Performance Service',
                    'Automatically adjusts animation complexity based on device performance',
                  ),
                  _PerformanceItem(
                    'Battery Saver Integration',
                    'Reduces animations when battery saver is active',
                  ),
                  _PerformanceItem(
                    'Platform-Aware Components',
                    'Adapts behavior for iOS, Android, web, and desktop',
                  ),
                  _PerformanceItem(
                    'Reduced Motion Support',
                    'Respects system accessibility settings',
                  ),
                  _PerformanceItem(
                    'Performance Monitoring',
                    'Real-time performance tracking in debug builds',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerShake() {
    // This would trigger the shake animation
    // The ShakeAnimation widget handles the actual animation
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Framework Information'),
        content: const Text(
          'This demo showcases the complete Finance App framework including:\n\n'
          '• Page Template system\n'
          '• Animation framework\n'
          '• Dialog system\n'
          '• Reusable widgets\n'
          '• Navigation patterns\n'
          '• Performance optimizations\n\n'
          'All components follow Clean Architecture principles and are designed for scalability.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPopupDialog(BuildContext context) async {
    await DialogService.showPopup<void>(
      context,
      const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This is a popup created using the PopupFramework. '
              'It supports custom actions, styling, and animations.'),
        ],
      ),
      title: 'Framework Popup',
    );
  }

  void _showConfirmDialog(BuildContext context) async {
    final result = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirm Action',
      message: 'Would you like to perform this action? This demonstrates '
          'the confirmation dialog pattern.',
      confirmText: 'Yes',
      cancelText: 'No',
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action confirmed!')),
      );
    }
  }

  void _showBottomSheet(BuildContext context) {
    BottomSheetService.showCustomBottomSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo),
            title: const Text('Camera'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Files'),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      title: 'Custom Bottom Sheet',
    );
  }

  void _showSnappingBottomSheet(BuildContext context) {
    BottomSheetService.showCustomBottomSheet(
      context,
      SingleChildScrollView(
        child: Column(
          children: List.generate(
            20,
            (index) => ListTile(
              title: Text('Item ${index + 1}'),
              subtitle: Text('This is item number ${index + 1}'),
              leading: CircleAvatar(child: Text('${index + 1}')),
            ),
          ),
        ),
      ),
      title: 'Snapping Bottom Sheet',
      snapSizes: const [0.3, 0.6, 0.9],
    );
  }
}

// Helper widgets for the demo

class _DemoSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _DemoSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          colorName: 'primary',
        ),
        const SizedBox(height: 4),
        AppText(
          subtitle,
          fontSize: 14,
          colorName: 'secondary',
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _AnimationCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _AnimationCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              title,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            AppText(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 4),
            AppText(
              subtitle,
              fontSize: 12,
              colorName: 'secondary',
            ),
          ],
        ),
      ),
    );
  }
}

class _TextExample extends StatelessWidget {
  final String title;
  final Widget Function() builder;

  const _TextExample(this.title, this.builder);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: AppText(
              '$title:',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(child: builder()),
        ],
      ),
    );
  }
}

class _PerformanceItem extends StatelessWidget {
  final String title;
  final String description;

  const _PerformanceItem(this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 2),
                AppText(
                  description,
                  fontSize: 12,
                  colorName: 'secondary',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
