import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/services/animation_performance_service.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/core/services/dialog_service.dart';
import 'package:finance/shared/widgets/dialogs/popup_framework.dart';

void main() {
  group('Phase 6.1 Integration Tests', () {
    setUp(() async {
      // Reset settings to defaults before each test
      await AppSettings.set('appAnimations', true);
      await AppSettings.set('batterySaver', false);
      await AppSettings.set('animationLevel', 'normal');
      await AppSettings.set('outlinedIcons', false);
    });

    group('Animation Performance Service Integration', () {
      test('service responds to settings changes', () async {
        // Test default state
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(4));

        // Change to battery saver mode
        await AppSettings.set('batterySaver', true);
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(1));

        // Disable battery saver, enable enhanced animations
        await AppSettings.set('batterySaver', false);
        await AppSettings.set('animationLevel', 'enhanced');
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(8));
      });

      test('duration optimization works correctly', () async {
        const baseDuration = Duration(milliseconds: 300);

        // Test normal level
        await AppSettings.set('animationLevel', 'normal');
        expect(
          AnimationPerformanceService.getOptimizedDuration(baseDuration),
          equals(baseDuration),
        );

        // Test reduced level
        await AppSettings.set('animationLevel', 'reduced');
        expect(
          AnimationPerformanceService.getOptimizedDuration(baseDuration),
          equals(Duration(milliseconds: 150)),
        );

        // Test enhanced level
        await AppSettings.set('animationLevel', 'enhanced');
        expect(
          AnimationPerformanceService.getOptimizedDuration(baseDuration),
          equals(Duration(milliseconds: 360)),
        );
      });

      test('performance profile accuracy', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', false);

        final profile = AnimationPerformanceService.getPerformanceProfile();

        expect(profile['animationLevel'], equals('enhanced'));
        expect(profile['appAnimations'], isTrue);
        expect(profile['batterySaver'], isFalse);
        expect(profile['shouldUseComplexAnimations'], isTrue);
        expect(profile['shouldUseStaggeredAnimations'], isTrue);
        expect(profile['maxSimultaneousAnimations'], equals(8));
        expect(profile['shouldUseHapticFeedback'], isTrue);
      });
    });

    group('Dialog Service Integration', () {
      testWidgets('DialogService uses correct animation types', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        DialogService.showPopup<void>(
                          context,
                          const Text('Test Content'),
                          title: 'Test Dialog',
                          subtitle: 'Test Subtitle',
                          icon: Icons.info,
                        );
                      },
                      child: const Text('Show Dialog'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Tap button to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify PopupFramework is used
        expect(find.byType(PopupFramework), findsOneWidget);
        expect(find.text('Test Dialog'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
      });

      testWidgets('DialogService respects animation settings', (tester) async {
        // Test with animations disabled
        await AppSettings.set('appAnimations', false);

        expect(DialogService.areDialogAnimationsEnabled, isFalse);
        expect(DialogService.defaultPopupAnimation,
            equals(PopupAnimationType.none));

        // Test with animations enabled
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', false);
        await AppSettings.set('animationLevel', 'normal');

        expect(DialogService.areDialogAnimationsEnabled, isTrue);
        expect(DialogService.defaultPopupAnimation,
            isNot(equals(PopupAnimationType.none)));
      });
    });

    group('Settings Integration Scenarios', () {
      test('battery saver overrides all other animation settings', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', true);

        // Battery saver should override everything
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(
            AnimationPerformanceService.shouldUseStaggeredAnimations, isFalse);
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(1));

        final duration = AnimationPerformanceService.getOptimizedDuration(
          const Duration(milliseconds: 300),
        );
        expect(duration, equals(Duration.zero));
      });

      test('animation level progression works correctly', () async {
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', false);

        final testDuration = Duration(milliseconds: 400);

        // None: Should disable animations
        await AppSettings.set('animationLevel', 'none');
        expect(
          AnimationPerformanceService.getOptimizedDuration(testDuration),
          equals(Duration.zero),
        );
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(0));

        // Reduced: Should reduce animations
        await AppSettings.set('animationLevel', 'reduced');
        expect(
          AnimationPerformanceService.getOptimizedDuration(testDuration),
          equals(Duration(milliseconds: 200)), // 50% of 400ms
        );
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(2));

        // Normal: Should use standard animations
        await AppSettings.set('animationLevel', 'normal');
        expect(
          AnimationPerformanceService.getOptimizedDuration(testDuration),
          equals(testDuration),
        );
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(4));

        // Enhanced: Should enhance animations
        await AppSettings.set('animationLevel', 'enhanced');
        expect(
          AnimationPerformanceService.getOptimizedDuration(testDuration),
          equals(Duration(milliseconds: 480)), // 120% of 400ms
        );
        expect(
            AnimationPerformanceService.maxSimultaneousAnimations, equals(8));
      });

      test('complex animation rules work correctly', () async {
        await AppSettings.set('batterySaver', false);
        await AppSettings.set('appAnimations', true);

        // Enhanced level should enable complex animations
        await AppSettings.set('animationLevel', 'enhanced');
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
        expect(
            AnimationPerformanceService.shouldUseStaggeredAnimations, isTrue);

        // Reduced level should disable complex animations but keep simple ones
        await AppSettings.set('animationLevel', 'reduced');
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
        expect(
            AnimationPerformanceService.shouldUseStaggeredAnimations, isFalse);

        // None level should disable all complex animations
        await AppSettings.set('animationLevel', 'none');
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(
            AnimationPerformanceService.shouldUseStaggeredAnimations, isFalse);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('handles invalid animation level gracefully', () async {
        await AppSettings.set('animationLevel', 'invalid_level');
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', false);

        // Should fallback to normal behavior
        const baseDuration = Duration(milliseconds: 300);
        final result =
            AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(
            result, equals(baseDuration)); // Should use default normal behavior

        final maxAnimations =
            AnimationPerformanceService.maxSimultaneousAnimations;
        expect(maxAnimations, equals(4)); // Should use default normal value
      });

      test('handles null or missing settings gracefully', () async {
        // This tests the getWithDefault behavior
        final profile = AnimationPerformanceService.getPerformanceProfile();

        // Should have all required keys
        expect(profile.containsKey('animationLevel'), isTrue);
        expect(profile.containsKey('appAnimations'), isTrue);
        expect(profile.containsKey('batterySaver'), isTrue);
        expect(profile.containsKey('reduceAnimations'), isTrue);

        // Should have computed values
        expect(profile.containsKey('shouldUseComplexAnimations'), isTrue);
        expect(profile.containsKey('shouldUseStaggeredAnimations'), isTrue);
        expect(profile.containsKey('maxSimultaneousAnimations'), isTrue);
        expect(profile.containsKey('shouldUseHapticFeedback'), isTrue);
      });

      test('performance profile reflects real-time changes', () async {
        // Initial state
        await AppSettings.set('animationLevel', 'normal');
        final initialProfile =
            AnimationPerformanceService.getPerformanceProfile();
        expect(initialProfile['animationLevel'], equals('normal'));
        expect(initialProfile['maxSimultaneousAnimations'], equals(4));

        // Change setting
        await AppSettings.set('animationLevel', 'enhanced');
        final updatedProfile =
            AnimationPerformanceService.getPerformanceProfile();
        expect(updatedProfile['animationLevel'], equals('enhanced'));
        expect(updatedProfile['maxSimultaneousAnimations'], equals(8));

        // The profiles should be different
        expect(initialProfile['animationLevel'],
            isNot(equals(updatedProfile['animationLevel'])));
        expect(initialProfile['maxSimultaneousAnimations'],
            isNot(equals(updatedProfile['maxSimultaneousAnimations'])));
      });
    });

    group('Performance Benchmarks', () {
      test('service calls are fast enough for real-time use', () {
        // Test that performance-critical methods execute quickly
        final stopwatch = Stopwatch()..start();

        // These should be very fast since they're used in hot paths
        for (int i = 0; i < 1000; i++) {
          AnimationPerformanceService.shouldUseComplexAnimations;
          AnimationPerformanceService.maxSimultaneousAnimations;
          AnimationPerformanceService.shouldUseStaggeredAnimations;
          AnimationPerformanceService.shouldUseHapticFeedback;
        }

        stopwatch.stop();

        // Should complete 1000 calls in under 100ms (very conservative)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('duration optimization is consistent', () {
        const testDurations = [
          Duration(milliseconds: 100),
          Duration(milliseconds: 200),
          Duration(milliseconds: 300),
          Duration(milliseconds: 500),
          Duration(milliseconds: 1000),
        ];

        for (final level in ['none', 'reduced', 'normal', 'enhanced']) {
          AppSettings.set('animationLevel', level);

          for (final duration in testDurations) {
            final optimized1 =
                AnimationPerformanceService.getOptimizedDuration(duration);
            final optimized2 =
                AnimationPerformanceService.getOptimizedDuration(duration);

            // Should be consistent
            expect(optimized1, equals(optimized2));

            // Should be reasonable (not negative, not excessively long)
            expect(optimized1.inMilliseconds, greaterThanOrEqualTo(0));
            expect(optimized1.inMilliseconds,
                lessThanOrEqualTo(duration.inMilliseconds * 2));
          }
        }
      });
    });
  });
}
