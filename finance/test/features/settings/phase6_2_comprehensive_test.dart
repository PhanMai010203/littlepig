import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/services/animation_performance_service.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/shared/widgets/animations/animation_performance_monitor.dart';
import 'package:finance/shared/widgets/animations/animation_utils.dart';
import 'package:finance/shared/widgets/animations/fade_in.dart';
import 'package:finance/shared/widgets/animations/scale_in.dart';
import 'package:finance/shared/widgets/animations/slide_in.dart';
import 'package:finance/shared/widgets/animations/tappable_widget.dart';

void main() {
  group(
      'Phase 6.2 Comprehensive Tests - Animation Performance Monitoring & Integration',
      () {
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

    group('AnimationPerformanceMonitor Widget Tests', () {
      testWidgets('basic monitor displays correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimationPerformanceMonitor(
                showFullDetails: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Should display basic performance information
        expect(find.text('0 / 4'), findsOneWidget);
        expect(find.text('16ms'), findsOneWidget);
      });

      testWidgets('detailed monitor shows comprehensive information',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimationPerformanceMonitor(
                showFullDetails: true,
              ),
            ),
          ),
        );

        await tester.pump();

        // Should display detailed performance sections
        expect(find.text('Animations: 0 / 4'), findsOneWidget);
        expect(find.text('Frame Time: 16ms'), findsOneWidget);
        expect(find.text('Performance: Good'), findsOneWidget);
        expect(find.text('Level: normal'), findsOneWidget);
      });

      testWidgets('floating monitor positions correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  Container(color: Colors.blue),
                  FloatingPerformanceMonitor(
                    position: FloatingMonitorPosition.topRight,
                    showFullDetails: false,
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // Should find the positioned monitor
        expect(find.byType(Positioned), findsOneWidget);
        expect(find.byType(AnimationPerformanceMonitor), findsOneWidget);
      });

      testWidgets('monitor updates performance data in real-time',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimationPerformanceMonitor(
                refreshInterval: Duration(milliseconds: 100),
                showFullDetails: true,
              ),
            ),
          ),
        );

        // Initial state
        await tester.pumpAndSettle();
        expect(find.text('Animations: 0 / 4'), findsOneWidget);

        // Simulate performance change
        AnimationPerformanceService.registerAnimationStart();

        // Wait for refresh
        await tester.pumpAndSettle();
        expect(find.text('Animations: 1 / 4'), findsOneWidget); // Should update

        // Clean up
        AnimationPerformanceService.registerAnimationEnd();
      });

      testWidgets('monitor respects theme colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.dark,
              ),
            ),
            home: Scaffold(
              body: AnimationPerformanceMonitor(
                backgroundColor: Colors.red.withOpacity(0.5),
                textColor: Colors.white,
              ),
            ),
          ),
        );

        await tester.pump();

        // Should find container with custom styling
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(AnimationPerformanceMonitor),
                matching: find.byType(Container),
              )
              .first,
        );

        expect(container.decoration, isA<BoxDecoration>());
      });
    });

    group('PerformanceMonitorExtension Tests', () {
      testWidgets('withPerformanceMonitor extension works', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                color: Colors.green,
                child: Text('Test Content'),
              ).withPerformanceMonitor(
                position: FloatingMonitorPosition.bottomLeft,
                showFullDetails: true,
                enabled: true,
              ),
            ),
          ),
        );

        await tester.pump();

        // Should wrap content in Stack with FloatingPerformanceMonitor
        expect(
            find.byWidgetPredicate((widget) =>
                widget is Stack &&
                widget.children
                    .any((child) => child is FloatingPerformanceMonitor)),
            findsOneWidget);
        expect(find.byType(FloatingPerformanceMonitor), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('extension respects enabled flag', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                color: Colors.green,
                child: Text('Test Content'),
              ).withPerformanceMonitor(
                enabled: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Should NOT wrap with monitoring when disabled
        expect(find.byType(FloatingPerformanceMonitor), findsNothing);
        expect(find.text('Test Content'), findsOneWidget);
      });
    });

    group('Real-time Performance Tracking Integration', () {
      testWidgets('AnimationUtils tracks animation metrics correctly',
          (tester) async {
        // Create multiple animations to test tracking
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FadeIn(
                    child: Container(height: 50, color: Colors.red),
                  ),
                  ScaleIn(
                    child: Container(height: 50, color: Colors.blue),
                  ),
                  SlideIn(
                    child: Container(height: 50, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        );

        // Allow animations to start
        await tester.pump();
        await tester.pump(Duration(milliseconds: 100));

        final metrics = AnimationUtils.getPerformanceMetrics();

        // Should track active animations
        expect(metrics['activeAnimations'], isA<int>());
        expect(metrics['animationMetrics'], isA<Map>());
        expect(metrics['performanceProfile'], isA<Map>());

        // Should have animation type tracking
        final animationMetricsRaw = metrics['animationMetrics'];
        final animationMetrics =
            Map<String, dynamic>.from(animationMetricsRaw as Map);
        expect(
            animationMetrics.containsKey('FadeIn') ||
                animationMetrics.containsKey('ScaleIn') ||
                animationMetrics.containsKey('SlideIn'),
            isTrue);
      });

      testWidgets('performance service tracks frame times', (tester) async {
        // Simulate frame time recording
        AnimationPerformanceService.recordFrameTime(Duration(milliseconds: 16));
        AnimationPerformanceService.recordFrameTime(Duration(milliseconds: 18));
        AnimationPerformanceService.recordFrameTime(Duration(milliseconds: 15));

        final metrics = AnimationPerformanceService.performanceMetrics;

        expect(metrics['averageFrameTimeMs'], isA<int>());
        expect(metrics['frameTimeHistory'], isA<List>());
        expect(metrics['isPerformanceGood'], isA<bool>());
        expect(metrics['performanceScale'], isA<double>());
      });

      testWidgets('concurrent animation limiting works', (tester) async {
        await AppSettings.set('animationLevel', 'reduced'); // Max 2 concurrent

        // Test that canStartAnimation respects limits
        expect(AnimationUtils.canStartAnimation(), isTrue);

        // Simulate starting animations
        AnimationUtils.registerAnimationStart('Test1');
        expect(AnimationUtils.canStartAnimation(), isTrue);

        AnimationUtils.registerAnimationStart('Test2');
        expect(AnimationUtils.canStartAnimation(), isFalse); // Should hit limit

        // Clean up
        AnimationUtils.registerAnimationEnd('Test1');
        AnimationUtils.registerAnimationEnd('Test2');
      });

      testWidgets('staggered animation logic respects capacity',
          (tester) async {
        await AppSettings.setAnimationLevel('enhanced'); // Max 8 animations

        // Use up most of the animation capacity
        for (int i = 0; i < 7; i++) {
          AnimationPerformanceService.registerAnimationStart();
        }

        // Staggered animations should now be disabled to preserve performance
        expect(
            AnimationPerformanceService.shouldUseStaggeredAnimations, isFalse);

        // Clean up
        AnimationPerformanceService.resetPerformanceMetrics();
        expect(
            AnimationPerformanceService.shouldUseStaggeredAnimations, isTrue);
      });
    });

    group('Animation Widget Performance Integration', () {
      testWidgets('TappableWidget integrates with performance service',
          (tester) async {
        await AppSettings.set('animationLevel', 'enhanced');

        bool tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TappableWidget(
                onTap: () => tapped = true,
                hapticFeedback: true,
                bounceOnTap: true,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );

        // Tap the widget
        await tester.tap(find.byType(TappableWidget));
        await tester.pump();

        expect(tapped, isTrue);

        // Should respect performance settings for haptic feedback
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
      });

      testWidgets('animation widgets respect performance limits',
          (tester) async {
        await AppSettings.set('animationLevel', 'none');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FadeIn(
                    duration: Duration(milliseconds: 300),
                    child: Text('Fade Test'),
                  ),
                  ScaleIn(
                    duration: Duration(milliseconds: 300),
                    child: Text('Scale Test'),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pump();

        // With animations disabled, widgets should render immediately
        expect(find.text('Fade Test'), findsOneWidget);
        expect(find.text('Scale Test'), findsOneWidget);

        // Verify no animations are tracked
        final metrics = AnimationUtils.getPerformanceMetrics();
        expect(metrics['activeAnimations'], equals(0));
      });
    });

    group('Battery Saver Integration Tests', () {
      testWidgets('battery saver mode overrides all animation settings',
          (tester) async {
        await AppSettings.set('batterySaver', true);
        await AppSettings.set('animationLevel', 'enhanced');

        // Check performance service outputs
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(
            AnimationPerformanceService.getOptimizedDuration(
                Duration(milliseconds: 100)),
            Duration.zero);
        expect(AnimationPerformanceService.maxSimultaneousAnimations, 1);

        // Check monitor UI
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimationPerformanceMonitor(showFullDetails: true),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Battery Saver: ON'), findsOneWidget);
      });
    });

    group('Settings Integration and Real-time Updates', () {
      testWidgets('monitor updates when settings change', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimationPerformanceMonitor(
                showFullDetails: true,
                refreshInterval: Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Level: normal'), findsOneWidget);

        // Change setting
        await AppSettings.set('animationLevel', 'enhanced');

        await tester.pumpAndSettle();
        expect(find.text('Level: enhanced'), findsOneWidget);
      });

      test('performance profile reflects all settings correctly', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', false);
        await AppSettings.set('reduceAnimations', false);

        final profile = AnimationPerformanceService.getPerformanceProfile();

        // Verify all settings are reflected
        expect(profile['animationLevel'], equals('enhanced'));
        expect(profile['appAnimations'], isTrue);
        expect(profile['batterySaver'], isFalse);
        expect(profile['reduceAnimations'], isFalse);

        // Verify computed values
        expect(profile['shouldUseComplexAnimations'], isTrue);
        expect(profile['shouldUseStaggeredAnimations'], isTrue);
        expect(profile['maxSimultaneousAnimations'], equals(8));
        expect(profile['shouldUseHapticFeedback'], isTrue);

        // Verify performance metrics are included
        expect(profile['performanceMetrics'], isA<Map<String, dynamic>>());
        final metrics = profile['performanceMetrics'] as Map<String, dynamic>;
        expect(metrics.containsKey('totalAnimationsCreated'), isTrue);
        expect(metrics.containsKey('currentActiveAnimations'), isTrue);
        expect(metrics.containsKey('averageFrameTimeMs'), isTrue);
        expect(metrics.containsKey('isPerformanceGood'), isTrue);
      });
    });

    group('Performance Optimization and Scaling', () {
      test('performance scale adjusts based on frame times', () {
        // Record good frame times
        AnimationPerformanceService.resetPerformanceMetrics();
        for (int i = 0; i < 10; i++) {
          AnimationPerformanceService.recordFrameTime(
              Duration(milliseconds: 16));
        }

        final goodProfile = AnimationPerformanceService.getPerformanceProfile();
        final goodMetrics =
            goodProfile['performanceMetrics'] as Map<String, dynamic>;
        expect(goodMetrics['performanceScale'], equals(1.0));

        // Record poor frame times
        AnimationPerformanceService.resetPerformanceMetrics();
        for (int i = 0; i < 10; i++) {
          AnimationPerformanceService.recordFrameTime(
              Duration(milliseconds: 30));
        }

        final poorProfile = AnimationPerformanceService.getPerformanceProfile();
        final poorMetrics =
            poorProfile['performanceMetrics'] as Map<String, dynamic>;
        expect(poorMetrics['performanceScale'], equals(0.8));
      });

      test('duration optimization applies performance scaling', () {
        const testDuration = Duration(milliseconds: 300);

        // Test with good performance
        AnimationPerformanceService.resetPerformanceMetrics();
        for (int i = 0; i < 5; i++) {
          AnimationPerformanceService.recordFrameTime(
              Duration(milliseconds: 16));
        }

        final goodDuration =
            AnimationPerformanceService.getOptimizedDuration(testDuration);
        expect(goodDuration.inMilliseconds, equals(300)); // Full duration

        // Test with poor performance
        AnimationPerformanceService.resetPerformanceMetrics();
        for (int i = 0; i < 5; i++) {
          AnimationPerformanceService.recordFrameTime(
              Duration(milliseconds: 30));
        }

        final poorDuration =
            AnimationPerformanceService.getOptimizedDuration(testDuration);
        expect(poorDuration.inMilliseconds, equals(240)); // 80% of 300ms
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('monitor handles null performance data gracefully',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AnimationPerformanceMonitor(),
            ),
          ),
        );

        await tester.pump();

        // Should not crash and should display some content
        expect(find.byType(AnimationPerformanceMonitor), findsOneWidget);
      });

      test('performance service handles extreme values', () {
        // Test with very high frame times
        AnimationPerformanceService.resetPerformanceMetrics();
        AnimationPerformanceService.recordFrameTime(
            Duration(milliseconds: 1000));

        final metrics = AnimationPerformanceService.performanceMetrics;
        expect(metrics['isPerformanceGood'], isFalse);
        expect(metrics['performanceScale'], equals(0.8));

        // Test with zero frame times
        AnimationPerformanceService.resetPerformanceMetrics();
        AnimationPerformanceService.recordFrameTime(Duration.zero);

        final zeroMetrics = AnimationPerformanceService.performanceMetrics;
        expect(zeroMetrics['averageFrameTimeMs'], equals(0));
        expect(zeroMetrics['isPerformanceGood'],
            isTrue); // Zero is considered good
      });

      test('animation registration handles negative counts gracefully', () {
        AnimationPerformanceService.resetPerformanceMetrics();

        // Try to end more animations than started
        AnimationPerformanceService.registerAnimationEnd();
        AnimationPerformanceService.registerAnimationEnd();

        final metrics = AnimationPerformanceService.performanceMetrics;
        expect(metrics['currentActiveAnimations'],
            equals(0)); // Should not go negative
      });
    });

    group('Integration with Existing Animation Framework', () {
      testWidgets('monitor works with all animation widget types',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FadeIn(child: Text('1')),
                  ScaleIn(child: Text('2')),
                  SlideIn(child: Text('3')),
                ],
              ).withPerformanceMonitor(enabled: true, showFullDetails: true),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('Animations:'), findsOneWidget);
      });
    });

    group('Performance Benchmarks', () {
      test('monitoring overhead is minimal', () {
        final stopwatch = Stopwatch()..start();

        // Simulate frequent performance calls
        for (int i = 0; i < 1000; i++) {
          AnimationPerformanceService.getPerformanceProfile();
          AnimationUtils.getPerformanceMetrics();
          AnimationPerformanceService.shouldUseComplexAnimations;
          AnimationPerformanceService.maxSimultaneousAnimations;
        }

        stopwatch.stop();

        // Should complete quickly (less than 200ms for 1000 calls)
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });

      test('performance data is consistent across calls', () {
        // Set up consistent state
        AnimationPerformanceService.resetPerformanceMetrics();
        AnimationPerformanceService.recordFrameTime(Duration(milliseconds: 16));

        // Get multiple snapshots
        final profile1 = AnimationPerformanceService.getPerformanceProfile();
        final profile2 = AnimationPerformanceService.getPerformanceProfile();
        final metrics1 = AnimationUtils.getPerformanceMetrics();
        final metrics2 = AnimationUtils.getPerformanceMetrics();

        // Should be consistent
        expect(profile1['animationLevel'], equals(profile2['animationLevel']));
        expect(profile1['maxSimultaneousAnimations'],
            equals(profile2['maxSimultaneousAnimations']));
        expect(
            metrics1['activeAnimations'], equals(metrics2['activeAnimations']));
      });
    });
  });
}
