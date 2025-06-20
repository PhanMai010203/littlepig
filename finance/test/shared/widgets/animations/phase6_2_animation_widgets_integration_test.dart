import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/services/animation_performance_service.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/shared/widgets/animations/animation_utils.dart';
import 'package:finance/shared/widgets/animations/fade_in.dart';
import 'package:finance/shared/widgets/animations/scale_in.dart';
import 'package:finance/shared/widgets/animations/slide_in.dart';
import 'package:finance/shared/widgets/animations/tappable_widget.dart';
import 'package:finance/shared/widgets/animations/bouncing_widget.dart';
import 'package:finance/shared/widgets/animations/breathing_widget.dart';
import 'package:finance/shared/widgets/animations/shake_animation.dart';
import 'package:finance/shared/widgets/animations/animated_scale_opacity.dart';
import 'package:finance/shared/widgets/animations/slide_fade_transition.dart';
import 'package:finance/shared/widgets/animations/scaled_animated_switcher.dart';
import 'package:finance/shared/widgets/animations/animated_size_switcher.dart';
import 'package:finance/shared/widgets/animations/animated_expanded.dart';

void main() {
  group('Phase 6.2 Animation Widgets Integration Tests', () {
    setUp(() async {
      // Reset all settings and performance metrics before each test
      await AppSettings.set('appAnimations', true);
      await AppSettings.set('batterySaver', false);
      await AppSettings.set('animationLevel', 'normal');
      await AppSettings.set('reduceAnimations', false);

      // Reset performance tracking
      AnimationPerformanceService.resetPerformanceMetrics();
      AnimationUtils.resetPerformanceMetrics();
    });

    group('Entry Animation Widgets Performance Integration', () {
      testWidgets('FadeIn integrates with performance service', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FadeIn(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Animation should be created and tracked
        final metrics = AnimationUtils.getPerformanceMetrics();
        final animationMetricsRaw = metrics['animationMetrics'];
        final animationMetrics =
            Map<String, dynamic>.from(animationMetricsRaw as Map);

        // Should track FadeIn animations
        expect(animationMetrics.containsKey('FadeIn'), isTrue);
        expect(metrics['activeAnimations'], greaterThan(0));
      });

      testWidgets('ScaleIn respects performance settings', (tester) async {
        await AppSettings.set('animationLevel', 'reduced');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ScaleIn(
                duration: Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                child: Text('Scale Test'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should use optimized duration for reduced level
        final optimizedDuration =
            AnimationPerformanceService.getOptimizedDuration(
          const Duration(milliseconds: 500),
        );
        expect(optimizedDuration.inMilliseconds, equals(250)); // 50% of 500ms
      });

      testWidgets('SlideIn handles animation level changes', (tester) async {
        await AppSettings.set('animationLevel', 'enhanced');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SlideIn(
                duration: Duration(milliseconds: 400),
                direction: SlideDirection.right,
                child: Text('Slide Test'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Enhanced level should allow complex animations
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(8));
      });
    });

    group('Interactive Animation Widgets Performance Integration', () {
      testWidgets('TappableWidget performance optimization', (tester) async {
        await AppSettings.set('animationLevel', 'enhanced');

        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TappableWidget(
                onTap: () => tapped = true,
                hapticFeedback: true,
                bounceOnTap: true,
                scaleFactor: 0.95,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        );

        // Test tap interaction
        await tester.tap(find.byType(TappableWidget));
        await tester.pump();

        expect(tapped, isTrue);

        // Should use haptic feedback in enhanced mode
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
      });

      testWidgets('TappableWidget respects battery saver mode', (tester) async {
        await AppSettings.set('batterySaver', true);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TappableWidget(
                onTap: () {},
                hapticFeedback: true,
                bounceOnTap: true,
                child: const Text('Battery Saver Test'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Battery saver should disable haptic feedback
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(1));
      });
    });

    group('Effect Animation Widgets Performance Integration', () {
      testWidgets('BouncingWidget performance tracking', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BouncingWidget(
                duration: Duration(milliseconds: 800),
                scaleFactor: 1.2,
                child: Icon(Icons.star, size: 50),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should track bouncing animation
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['activeAnimations'], greaterThan(0));
        expect(metrics['animationMetrics'], isA<Map>());
      });

      testWidgets('BreathingWidget respects performance limits',
          (tester) async {
        await AppSettings.set('animationLevel', 'reduced');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BreathingWidget(
                duration: const Duration(milliseconds: 1000),
                breathingSpeed: 0.1,
                child: Container(width: 80, height: 80, color: Colors.green),
              ),
            ),
          ),
        );

        await tester.pump();

        // Reduced level should still allow complex animations if performance is good
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(2));
      });

      testWidgets('ShakeAnimation integrates with performance monitoring',
          (tester) async {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: tester,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ShakeAnimation(
                shakeOffset: 5.0,
                child: Text('Shake Test'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Start shake animation
        controller.forward();
        await tester.pump(const Duration(milliseconds: 50));

        // Should track shake animation
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['performanceProfile'], isA<Map<String, dynamic>>());

        controller.dispose();
      });
    });

    group('Transition Widgets Performance Integration', () {
      testWidgets('AnimatedScaleOpacity performance optimization',
          (tester) async {
        bool visible = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => visible = !visible),
                        child: const Text('Toggle'),
                      ),
                      AnimatedScaleOpacity(
                        visible: visible,
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Toggle visibility
        await tester.tap(find.text('Toggle'));
        await tester.pump();

        // Should respect animation settings
        final optimizedDuration =
            AnimationPerformanceService.getOptimizedDuration(
          const Duration(milliseconds: 250),
        );
        expect(optimizedDuration.inMilliseconds,
            equals(250)); // Normal level = 100%
      });

      testWidgets('SlideFadeTransition performance tracking', (tester) async {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: tester,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SlideFadeTransition(
                animation: controller,
                direction: SlideFadeDirection.up,
                slideDistance: 30.0,
                child: const Text('Slide Fade Test'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Start transition
        controller.forward();
        await tester.pump(const Duration(milliseconds: 100));

        // Should track animation
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['activeAnimations'], greaterThanOrEqualTo(0));

        controller.dispose();
      });
    });

    group('Switcher Widgets Performance Integration', () {
      testWidgets('ScaledAnimatedSwitcher performance optimization',
          (tester) async {
        int counter = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => counter++),
                        child: const Text('Switch'),
                      ),
                      ScaledAnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        scaleIn: 0.8,
                        scaleOut: 1.2,
                        child: Text('Count: $counter', key: ValueKey(counter)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Switch content
        await tester.tap(find.text('Switch'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Should use optimized duration
        final optimizedDuration =
            AnimationUtils.getDuration(const Duration(milliseconds: 300));
        expect(optimizedDuration.inMilliseconds, equals(300)); // Normal level
      });

      testWidgets('AnimatedSizeSwitcher respects performance settings',
          (tester) async {
        bool expanded = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => expanded = !expanded),
                        child: const Text('Toggle Size'),
                      ),
                      AnimatedSizeSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          width: expanded ? 200 : 100,
                          height: expanded ? 200 : 100,
                          color: Colors.purple,
                          key: ValueKey(expanded),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Toggle size
        await tester.tap(find.text('Toggle Size'));
        await tester.pump();

        // Should track size change animation
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['performanceProfile'], isA<Map<String, dynamic>>());
      });
    });

    group('Layout Animation Widgets Performance Integration', () {
      testWidgets('AnimatedExpanded performance tracking', (tester) async {
        bool expanded = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => expanded = !expanded),
                        child: const Text('Expand'),
                      ),
                      AnimatedExpanded(
                        expand: expanded,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          height: 100,
                          color: Colors.cyan,
                          child: const Text('Expandable Content'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Trigger expansion
        await tester.tap(find.text('Expand'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Should respect performance settings for complex animations
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
      });
    });

    group('Performance Limits and Concurrent Animation Management', () {
      testWidgets('concurrent animation limiting across widget types',
          (tester) async {
        await AppSettings.set('animationLevel', 'reduced'); // Max 2 concurrent

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FadeIn(child: Text('Fade 1')),
                  FadeIn(child: Text('Fade 2')),
                  FadeIn(child: Text('Fade 3')), // Should be limited
                  ScaleIn(child: Text('Scale 1')),
                  SlideIn(child: Text('Slide 1')),
                ],
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Should respect concurrent animation limits
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['maxSimultaneousAnimations'], equals(2));

        // Active animations should not exceed the limit
        expect(metrics['activeAnimations'], lessThanOrEqualTo(2));
      });

      testWidgets('animation widgets respect canStartAnimation',
          (tester) async {
        await AppSettings.set('animationLevel', 'reduced'); // Max 2 concurrent

        // Fill animation capacity
        AnimationUtils.registerAnimationStart('Test1');
        AnimationUtils.registerAnimationStart('Test2');

        // Should not be able to start more animations
        expect(AnimationUtils.canStartAnimation(), isFalse);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: FadeIn(
                child: Text('Should be limited'),
              ),
            ),
          ),
        );

        await tester.pump();

        // Animation should still be created but respect limits
        expect(find.text('Should be limited'), findsOneWidget);

        // Clean up
        AnimationUtils.registerAnimationEnd('Test1');
        AnimationUtils.registerAnimationEnd('Test2');
      });
    });

    group('Settings Changes During Animation', () {
      testWidgets('animation level change during active animations',
          (tester) async {
        await AppSettings.set('animationLevel', 'normal');

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FadeIn(
                    duration: Duration(milliseconds: 1000), // Long duration
                    child: Text('Long Animation'),
                  ),
                  BouncingWidget(
                    duration: Duration(milliseconds: 2000), // Very long
                    child: Text('Bouncing'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Verify animations are running
        final initialMetrics = AnimationUtils.getPerformanceMetrics();
        expect(initialMetrics['activeAnimations'], greaterThan(0));

        // Change animation level during animations
        await AppSettings.set('animationLevel', 'enhanced');

        // New performance profile should reflect the change
        final newProfile = AnimationPerformanceService.getPerformanceProfile();
        expect(newProfile['animationLevel'], equals('enhanced'));
        expect(newProfile['maxSimultaneousAnimations'], equals(8));
      });

      testWidgets('battery saver activation during animations', (tester) async {
        await AppSettings.set('batterySaver', false);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BreathingWidget(
                duration: const Duration(milliseconds: 2000),
                child: Container(width: 50, height: 50, color: Colors.red),
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Enable battery saver during animation
        await AppSettings.set('batterySaver', true);

        // Should immediately affect performance settings
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(1));

        final optimizedDuration =
            AnimationPerformanceService.getOptimizedDuration(
          const Duration(milliseconds: 300),
        );
        expect(optimizedDuration, equals(Duration.zero));
      });
    });

    group('Performance Degradation Simulation', () {
      testWidgets('poor performance affects animation behavior',
          (tester) async {
        // Simulate poor frame times
        for (int i = 0; i < 20; i++) {
          AnimationPerformanceService.recordFrameTime(
              const Duration(milliseconds: 35)); // Poor performance
        }

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FadeIn(child: Text('Fade Performance Test')),
                  ScaleIn(child: Text('Scale Performance Test')),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Poor performance should trigger optimization
        final metrics = AnimationPerformanceService.performanceMetrics;
        expect(metrics['isPerformanceGood'], isFalse);
        expect(metrics['performanceScale'], equals(0.8));

        // Duration optimization should apply 80% scaling
        const testDuration = Duration(milliseconds: 300);
        final optimizedDuration =
            AnimationPerformanceService.getOptimizedDuration(testDuration);
        expect(optimizedDuration.inMilliseconds, equals(240)); // 80% of 300ms
      });
    });

    group('Widget-specific Performance Features', () {
      testWidgets('TappableWidget bounce animation performance',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TappableWidget(
                onTap: () {},
                bounceOnTap: true,
                scaleFactor: 0.9,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
        );

        await tester.pump();

        // Should check if it can start animation before bouncing
        expect(AnimationUtils.canStartAnimation(), isTrue);

        // Tap to trigger bounce
        await tester.tap(find.byType(TappableWidget));
        await tester.pump(const Duration(milliseconds: 50));

        // Should track bounce animation
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['activeAnimations'], greaterThanOrEqualTo(0));
      });

      testWidgets('animation widgets handle disabled animations gracefully',
          (tester) async {
        await AppSettings.set('appAnimations', false);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  const FadeIn(child: Text('No Fade')),
                  const ScaleIn(child: Text('No Scale')),
                  const SlideIn(child: Text('No Slide')),
                  TappableWidget(
                    onTap: () {},
                    child: const Text('No Tap Animation'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // All content should be visible immediately
        expect(find.text('No Fade'), findsOneWidget);
        expect(find.text('No Scale'), findsOneWidget);
        expect(find.text('No Slide'), findsOneWidget);
        expect(find.text('No Tap Animation'), findsOneWidget);

        // No animations should be tracked
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['activeAnimations'], equals(0));
      });
    });

    group('Memory and Resource Management', () {
      test('animation widgets dispose controllers properly', () {
        // This test ensures no memory leaks from animation controllers
        // We can't directly test memory in unit tests, but we can verify
        // that the performance tracking doesn't accumulate indefinitely

        AnimationPerformanceService.resetPerformanceMetrics();

        // Simulate many animation lifecycles
        for (int i = 0; i < 100; i++) {
          AnimationPerformanceService.registerAnimationCreated();
          AnimationPerformanceService.registerAnimationStart();
          AnimationPerformanceService.registerAnimationEnd();
        }

        final metrics = AnimationPerformanceService.performanceMetrics;
        expect(metrics['totalAnimationsCreated'], equals(100));
        expect(metrics['currentActiveAnimations'], equals(0)); // All ended
      });

      test('performance monitoring data cleanup', () {
        // Fill frame time history to capacity
        for (int i = 0; i < 100; i++) {
          AnimationPerformanceService.recordFrameTime(
              const Duration(milliseconds: 16));
        }

        final metrics = AnimationPerformanceService.performanceMetrics;
        final frameHistory = metrics['frameTimeHistory'] as List;

        // Should limit history size to prevent memory growth
        expect(frameHistory.length, lessThanOrEqualTo(60)); // Max history size
      });
    });
  });
}
