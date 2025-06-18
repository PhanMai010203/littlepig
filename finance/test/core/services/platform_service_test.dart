import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/services/platform_service.dart';

void main() {
  group('PlatformService', () {
    group('Platform Detection', () {
      test('getPlatform() should return a valid platform', () {
        final platform = PlatformService.getPlatform();
        expect(platform, isA<PlatformOS>());
      });

      test('platform properties should be consistent', () {
        final isMobile = PlatformService.isMobile;
        final isDesktop = PlatformService.isDesktop;
        final isWeb = PlatformService.isWeb;
        
        // Only one should be true at a time
        final trueCount = [isMobile, isDesktop, isWeb].where((x) => x).length;
        expect(trueCount, equals(1), reason: 'Exactly one platform type should be true');
      });

      test('supportsMaterial3 should always be true', () {
        expect(PlatformService.supportsMaterial3, isTrue);
      });

      test('supportsHaptics should match mobile platform', () {
        expect(PlatformService.supportsHaptics, equals(PlatformService.isMobile));
      });
    });

    group('Animation Properties', () {
      test('platformCurve should return a valid curve', () {
        final curve = PlatformService.platformCurve;
        expect(curve, isA<Curve>());
      });

      test('platformAnimationDuration should be reasonable', () {
        final duration = PlatformService.platformAnimationDuration;
        expect(duration.inMilliseconds, greaterThan(100));
        expect(duration.inMilliseconds, lessThan(1000));
      });

      test('supportsComplexAnimations should be platform appropriate', () {
        final supportsComplex = PlatformService.supportsComplexAnimations;
        
        if (PlatformService.isWeb) {
          expect(supportsComplex, isFalse, reason: 'Web should not support complex animations by default');
        } else {
          expect(supportsComplex, isTrue, reason: 'Mobile and desktop should support complex animations');
        }
      });
    });

    group('UI Preferences', () {
      test('prefersCenteredDialogs should be platform appropriate', () {
        final prefersCentered = PlatformService.prefersCenteredDialogs;
        
        if (PlatformService.getPlatform() == PlatformOS.isIOS || PlatformService.isDesktop) {
          expect(prefersCentered, isTrue, reason: 'iOS and desktop should prefer centered dialogs');
        }
        // Android can have either preference, so we don't test that
      });
    });

    group('Debug Information', () {
      test('getPlatformInfo should return complete information', () {
        final info = PlatformService.getPlatformInfo();
        
        expect(info, isA<Map<String, dynamic>>());
        expect(info.containsKey('platform'), isTrue);
        expect(info.containsKey('isMobile'), isTrue);
        expect(info.containsKey('isDesktop'), isTrue);
        expect(info.containsKey('isWeb'), isTrue);
        expect(info.containsKey('supportsComplexAnimations'), isTrue);
        expect(info.containsKey('supportsMaterial3'), isTrue);
        expect(info.containsKey('supportsHaptics'), isTrue);
        expect(info.containsKey('prefersCenteredDialogs'), isTrue);
        expect(info.containsKey('platformCurve'), isTrue);
        expect(info.containsKey('platformAnimationDuration'), isTrue);
      });
    });

    group('Screen Size Detection', () {
      testWidgets('getIsFullScreen should handle different screen sizes', (tester) async {
        // Test with a mock widget to get a BuildContext
        Widget testWidget = MaterialApp(
          home: Builder(
            builder: (context) {
              final isFullScreen = PlatformService.getIsFullScreen(context);
              expect(isFullScreen, isA<bool>());
              return Container();
            },
          ),
        );

        await tester.pumpWidget(testWidget);
      });

      testWidgets('getPlatformSafePadding should return valid padding', (tester) async {
        Widget testWidget = MaterialApp(
          home: Builder(
            builder: (context) {
              final padding = PlatformService.getPlatformSafePadding(context);
              expect(padding, isA<EdgeInsets>());
              return Container();
            },
          ),
        );

        await tester.pumpWidget(testWidget);
      });
    });

    group('Platform Specific Behavior', () {
      test('iOS platform should have appropriate settings', () {
        // This test will only run correctly on iOS, but we can test the logic
        if (PlatformService.getPlatform() == PlatformOS.isIOS) {
          expect(PlatformService.platformCurve, equals(Curves.easeInOutCubic));
          expect(PlatformService.platformAnimationDuration, equals(const Duration(milliseconds: 350)));
          expect(PlatformService.prefersCenteredDialogs, isTrue);
        }
      });

      test('Android platform should have appropriate settings', () {
        if (PlatformService.getPlatform() == PlatformOS.isAndroid) {
          expect(PlatformService.platformCurve, equals(Curves.easeInOutCubicEmphasized));
          expect(PlatformService.platformAnimationDuration, equals(const Duration(milliseconds: 300)));
        }
      });

      test('Web platform should have appropriate settings', () {
        if (PlatformService.getPlatform() == PlatformOS.isWeb) {
          expect(PlatformService.platformCurve, equals(Curves.easeInOut));
          expect(PlatformService.platformAnimationDuration, equals(const Duration(milliseconds: 200)));
          expect(PlatformService.supportsComplexAnimations, isFalse);
        }
      });
    });
  });
} 