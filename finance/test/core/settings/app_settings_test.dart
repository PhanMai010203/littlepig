import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/core/settings/app_settings.dart';

void main() {
  group('AppSettings Animation Enhancement Tests', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
    });

    group('Default Animation Settings', () {
      test('should have correct default animation settings', () {
        expect(AppSettings.animationLevel, equals('normal'));
        expect(AppSettings.batterySaver, isFalse);
        expect(AppSettings.outlinedIcons, isFalse);
        expect(AppSettings.appAnimations, isTrue);
        expect(AppSettings.reduceAnimations, isFalse);
      });

      test('should return defaults when settings are not set', () {
        expect(AppSettings.getWithDefault<String>('animationLevel', 'fallback'),
            equals('normal'));
        expect(AppSettings.getWithDefault<bool>('batterySaver', true), isFalse);
        expect(
            AppSettings.getWithDefault<bool>('appAnimations', false), isTrue);
      });
    });

    group('Animation Level Settings', () {
      test('should set and get animationLevel correctly', () async {
        await AppSettings.setAnimationLevel('enhanced');
        expect(AppSettings.animationLevel, equals('enhanced'));

        await AppSettings.setAnimationLevel('reduced');
        expect(AppSettings.animationLevel, equals('reduced'));

        await AppSettings.setAnimationLevel('none');
        expect(AppSettings.animationLevel, equals('none'));
      });

      test('should persist animationLevel across sessions', () async {
        await AppSettings.setAnimationLevel('enhanced');

        // Simulate app restart by reinitializing
        await AppSettings.initialize();

        expect(AppSettings.animationLevel, equals('enhanced'));
      });
    });

    group('Battery Saver Settings', () {
      test('should set and get batterySaver correctly', () async {
        await AppSettings.setBatterySaver(true);
        expect(AppSettings.batterySaver, isTrue);

        await AppSettings.setBatterySaver(false);
        expect(AppSettings.batterySaver, isFalse);
      });

      test('should persist batterySaver across sessions', () async {
        await AppSettings.setBatterySaver(true);

        await AppSettings.initialize();

        expect(AppSettings.batterySaver, isTrue);
      });
    });

    group('App Animations Settings', () {
      test('should set and get appAnimations correctly', () async {
        await AppSettings.setAppAnimations(false);
        expect(AppSettings.appAnimations, isFalse);

        await AppSettings.setAppAnimations(true);
        expect(AppSettings.appAnimations, isTrue);
      });

      test('should persist appAnimations across sessions', () async {
        await AppSettings.setAppAnimations(false);

        await AppSettings.initialize();

        expect(AppSettings.appAnimations, isFalse);
      });
    });

    group('Outlined Icons Settings', () {
      test('should set and get outlinedIcons correctly', () async {
        await AppSettings.setOutlinedIcons(true);
        expect(AppSettings.outlinedIcons, isTrue);

        await AppSettings.setOutlinedIcons(false);
        expect(AppSettings.outlinedIcons, isFalse);
      });

      test('should persist outlinedIcons across sessions', () async {
        await AppSettings.setOutlinedIcons(true);

        await AppSettings.initialize();

        expect(AppSettings.outlinedIcons, isTrue);
      });
    });

    group('Reduce Animations Settings', () {
      test('should set and get reduceAnimations correctly', () async {
        await AppSettings.setReduceAnimations(true);
        expect(AppSettings.reduceAnimations, isTrue);

        await AppSettings.setReduceAnimations(false);
        expect(AppSettings.reduceAnimations, isFalse);
      });

      test('should persist reduceAnimations across sessions', () async {
        await AppSettings.setReduceAnimations(true);

        await AppSettings.initialize();

        expect(AppSettings.reduceAnimations, isTrue);
      });
    });

    group('Settings Integration', () {
      test('should handle multiple animation settings changes', () async {
        await AppSettings.setAnimationLevel('enhanced');
        await AppSettings.setBatterySaver(true);
        await AppSettings.setAppAnimations(false);
        await AppSettings.setReduceAnimations(true);

        expect(AppSettings.animationLevel, equals('enhanced'));
        expect(AppSettings.batterySaver, isTrue);
        expect(AppSettings.appAnimations, isFalse);
        expect(AppSettings.reduceAnimations, isTrue);
      });

      test('should reset animation settings to defaults', () async {
        // Change all settings from defaults
        await AppSettings.setAnimationLevel('none');
        await AppSettings.setBatterySaver(true);
        await AppSettings.setAppAnimations(false);
        await AppSettings.setReduceAnimations(true);
        await AppSettings.setOutlinedIcons(true);

        // Reset to defaults
        await AppSettings.resetToDefaults();

        // Check all defaults are restored
        expect(AppSettings.animationLevel, equals('normal'));
        expect(AppSettings.batterySaver, isFalse);
        expect(AppSettings.appAnimations, isTrue);
        expect(AppSettings.reduceAnimations, isFalse);
        expect(AppSettings.outlinedIcons, isFalse);
      });

      test('should maintain existing settings when adding new ones', () async {
        // Set some existing settings
        await AppSettings.setThemeMode(ThemeMode.dark);

        // Initialize again (simulating app update with new settings)
        await AppSettings.initialize();

        // Existing settings should be preserved
        expect(AppSettings.themeMode, equals(ThemeMode.dark));

        // New animation settings should have defaults
        expect(AppSettings.animationLevel, equals('normal'));
        expect(AppSettings.batterySaver, isFalse);
      });
    });

    group('Setting Validation', () {
      test('should handle invalid animationLevel gracefully', () async {
        // Set invalid value directly
        await AppSettings.set('animationLevel', 'invalid');

        // Should return the invalid value (no validation currently)
        expect(AppSettings.animationLevel, equals('invalid'));
      });

      test('should handle type mismatches gracefully', () {
        // getWithDefault should handle type mismatches by returning fallback
        expect(
            AppSettings.getWithDefault<bool>('animationLevel', true), isTrue);
        expect(AppSettings.getWithDefault<String>('batterySaver', 'fallback'),
            equals('fallback'));
      });
    });

    group('Legacy Compatibility', () {
      test('should maintain compatibility with existing theme settings',
          () async {
        await AppSettings.setThemeMode(ThemeMode.light);
        const testColor = Color(0xFFFF0000); // Red color
        await AppSettings.setAccentColor(testColor);

        expect(AppSettings.themeMode, equals(ThemeMode.light));
        expect(AppSettings.accentColor, equals(testColor));
      });

      test('should work with existing reduceAnimations setting', () async {
        // This setting existed before the enhancement
        await AppSettings.setReduceAnimations(true);

        expect(AppSettings.reduceAnimations, isTrue);
        expect(AppSettings.getWithDefault<bool>('reduceAnimations', false),
            isTrue);
      });
    });

    group('Performance', () {
      test('should cache settings for performance', () {
        // Multiple calls should return same value efficiently
        final level1 = AppSettings.animationLevel;
        final level2 = AppSettings.animationLevel;
        final level3 = AppSettings.animationLevel;

        expect(level1, equals(level2));
        expect(level2, equals(level3));
      });

      test('should handle multiple rapid setting changes', () async {
        for (int i = 0; i < 10; i++) {
          await AppSettings.setAnimationLevel(
              i % 2 == 0 ? 'normal' : 'enhanced');
        }

        expect(AppSettings.animationLevel, equals('enhanced'));
      });
    });
  });
}
