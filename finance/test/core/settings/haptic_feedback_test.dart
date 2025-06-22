import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/core/services/animation_performance_service.dart';

void main() {
  group('Haptic Feedback Settings Tests', () {
    setUp(() async {
      // Initialize clean SharedPreferences
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
    });

    test('haptic feedback should be enabled by default', () {
      expect(AppSettings.hapticFeedback, isTrue);
      expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
    });

    test('should be able to disable haptic feedback', () async {
      await AppSettings.setHapticFeedback(false);

      expect(AppSettings.hapticFeedback, isFalse);
      expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
    });

    test('should be able to enable haptic feedback', () async {
      await AppSettings.setHapticFeedback(false);
      await AppSettings.setHapticFeedback(true);

      expect(AppSettings.hapticFeedback, isTrue);
      expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
    });

    test('battery saver should override haptic feedback setting', () async {
      await AppSettings.setHapticFeedback(true);
      await AppSettings.setBatterySaver(true);

      expect(AppSettings.hapticFeedback, isTrue); // Setting should remain true
      expect(AnimationPerformanceService.shouldUseHapticFeedback,
          isFalse); // But service should return false
    });

    test('haptic feedback should be independent of animation settings',
        () async {
      // Set animations off but haptics on
      await AppSettings.setAppAnimations(false);
      await AppSettings.setHapticFeedback(true);
      await AppSettings.setBatterySaver(false);

      expect(AppSettings.hapticFeedback, isTrue);
      expect(AppSettings.appAnimations, isFalse);
      expect(AnimationPerformanceService.shouldUseHapticFeedback, isTrue);
    });

    test('settings should persist across app restarts', () async {
      await AppSettings.setHapticFeedback(false);

      // Simulate app restart by reinitializing
      await AppSettings.initialize();

      expect(AppSettings.hapticFeedback, isFalse);
      expect(AnimationPerformanceService.shouldUseHapticFeedback, isFalse);
    });
  });
}
