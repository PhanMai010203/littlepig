import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/services/animation_performance_service.dart';
import 'package:finance/core/settings/app_settings.dart';

void main() {
  group('AnimationPerformanceService - Phase 6.1 Tests', () {
    setUp(() async {
      // Reset settings to defaults before each test
      await AppSettings.set('appAnimations', true);
      await AppSettings.set('batterySaver', false);
      await AppSettings.set('animationLevel', 'normal');
      await AppSettings.set('reduceAnimations', false);
    });

    group('shouldUseComplexAnimations', () {
      test('returns true with default settings', () {
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
      });

      test('returns false when appAnimations is disabled', () async {
        await AppSettings.set('appAnimations', false);
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
      });

      test('returns false when batterySaver is enabled', () async {
        await AppSettings.set('batterySaver', true);
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
      });

      test('returns false when animationLevel is none', () async {
        await AppSettings.set('animationLevel', 'none');
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
      });

      test('returns true when animationLevel is enhanced', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isTrue);
      });
    });

    group('getOptimizedDuration', () {
      const baseDuration = Duration(milliseconds: 300);

      test('returns Duration.zero when appAnimations is disabled', () async {
        await AppSettings.set('appAnimations', false);
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(Duration.zero));
      });

      test('returns Duration.zero when batterySaver is enabled', () async {
        await AppSettings.set('batterySaver', true);
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(Duration.zero));
      });

      test('returns Duration.zero when animationLevel is none', () async {
        await AppSettings.set('animationLevel', 'none');
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(Duration.zero));
      });

      test('returns reduced duration when animationLevel is reduced', () async {
        await AppSettings.set('animationLevel', 'reduced');
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(Duration(milliseconds: 150))); // 50% of 300ms
      });

      test('returns base duration when animationLevel is normal', () async {
        await AppSettings.set('animationLevel', 'normal');
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(baseDuration));
      });

      test('returns enhanced duration when animationLevel is enhanced', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(Duration(milliseconds: 360))); // 120% of 300ms
      });
    });

    group('getOptimizedCurve', () {
      test('returns simple curve for reduced animations', () async {
        await AppSettings.set('animationLevel', 'reduced');
        final result = AnimationPerformanceService.getOptimizedCurve(Curves.bounceIn);
        expect(result, equals(Curves.easeOut));
      });

      test('returns enhanced curve for enhanced animations', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        final result = AnimationPerformanceService.getOptimizedCurve(Curves.linear);
        expect(result, equals(Curves.easeInOutCubicEmphasized));
      });

      test('returns default curve for normal animations', () async {
        await AppSettings.set('animationLevel', 'normal');
        const defaultCurve = Curves.bounceIn;
        final result = AnimationPerformanceService.getOptimizedCurve(defaultCurve);
        expect(result, equals(defaultCurve));
      });
    });

    group('shouldUseStaggeredAnimations', () {
      test('returns true for normal animation level', () async {
        await AppSettings.set('animationLevel', 'normal');
        expect(AnimationPerformanceService.shouldUseStaggeredAnimations, isTrue);
      });

      test('returns true for enhanced animation level', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        expect(AnimationPerformanceService.shouldUseStaggeredAnimations, isTrue);
      });

      test('returns false for reduced animation level', () async {
        await AppSettings.set('animationLevel', 'reduced');
        expect(AnimationPerformanceService.shouldUseStaggeredAnimations, isFalse);
      });

      test('returns false when complex animations disabled', () async {
        await AppSettings.set('batterySaver', true);
        expect(AnimationPerformanceService.shouldUseStaggeredAnimations, isFalse);
      });
    });

    group('maxSimultaneousAnimations', () {
      test('returns 1 when batterySaver is enabled', () async {
        await AppSettings.set('batterySaver', true);
        expect(AnimationPerformanceService.maxSimultaneousAnimations, equals(1));
      });

      test('returns 0 when animationLevel is none', () async {
        await AppSettings.set('animationLevel', 'none');
        expect(AnimationPerformanceService.maxSimultaneousAnimations, equals(0));
      });

      test('returns 2 when animationLevel is reduced', () async {
        await AppSettings.set('animationLevel', 'reduced');
        expect(AnimationPerformanceService.maxSimultaneousAnimations, equals(2));
      });

      test('returns 4 when animationLevel is normal', () async {
        await AppSettings.set('animationLevel', 'normal');
        expect(AnimationPerformanceService.maxSimultaneousAnimations, equals(4));
      });

      test('returns 8 when animationLevel is enhanced', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        expect(AnimationPerformanceService.maxSimultaneousAnimations, equals(8));
      });
    });

    group('shouldUseHapticFeedback', () {
      test('returns true for normal animation level', () async {
        await AppSettings.set('animationLevel', 'normal');
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
      });

      test('returns true for enhanced animation level', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
      });

      test('returns false when appAnimations is disabled', () async {
        await AppSettings.set('appAnimations', false);
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
      });

      test('returns false for reduced animation level', () async {
        await AppSettings.set('animationLevel', 'reduced');
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
      });
    });

    group('getPerformanceProfile', () {
      test('returns complete performance profile', () {
        final profile = AnimationPerformanceService.getPerformanceProfile();
        
        expect(profile, isA<Map<String, dynamic>>());
        expect(profile.containsKey('animationLevel'), isTrue);
        expect(profile.containsKey('appAnimations'), isTrue);
        expect(profile.containsKey('batterySaver'), isTrue);
        expect(profile.containsKey('reduceAnimations'), isTrue);
        expect(profile.containsKey('shouldUseComplexAnimations'), isTrue);
        expect(profile.containsKey('shouldUseStaggeredAnimations'), isTrue);
        expect(profile.containsKey('maxSimultaneousAnimations'), isTrue);
        expect(profile.containsKey('shouldUseHapticFeedback'), isTrue);
      });

      test('reflects current settings correctly', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        await AppSettings.set('batterySaver', true);
        
        final profile = AnimationPerformanceService.getPerformanceProfile();
        
        expect(profile['animationLevel'], equals('enhanced'));
        expect(profile['batterySaver'], isTrue);
        expect(profile['shouldUseComplexAnimations'], isFalse); // Because batterySaver is true
        expect(profile['maxSimultaneousAnimations'], equals(1)); // Because batterySaver is true
      });
    });

    group('Edge cases and combinations', () {
      test('handles invalid animation level gracefully', () async {
        await AppSettings.set('animationLevel', 'invalid_level');
        
        // Should fallback to normal behavior
        const baseDuration = Duration(milliseconds: 300);
        final result = AnimationPerformanceService.getOptimizedDuration(baseDuration);
        expect(result, equals(baseDuration));
      });

      test('battery saver overrides all other settings', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('batterySaver', true);
        
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(AnimationPerformanceService.getOptimizedDuration(Duration(milliseconds: 300)), 
               equals(Duration.zero));
        expect(AnimationPerformanceService.maxSimultaneousAnimations, equals(1));
      });

      test('appAnimations false overrides animation level', () async {
        await AppSettings.set('animationLevel', 'enhanced');
        await AppSettings.set('appAnimations', false);
        await AppSettings.set('batterySaver', false);
        
        expect(AnimationPerformanceService.shouldUseComplexAnimations, isFalse);
        expect(AnimationPerformanceService.getOptimizedDuration(Duration(milliseconds: 300)), 
               equals(Duration.zero));
        expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
      });
    });
  });
} 