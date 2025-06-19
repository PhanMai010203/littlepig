import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/shared/widgets/animations/animation_utils.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/core/services/platform_service.dart';
import 'package:finance/core/services/animation_performance_service.dart';

void main() {
  group('AnimationUtils', () {
    setUp(() async {
      // Reset settings before each test
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
      AnimationPerformanceService.resetPerformanceMetrics();
    });

    group('Animation Control', () {
      test('shouldAnimate() returns true with default settings', () {
        expect(AnimationUtils.shouldAnimate(), isTrue);
      });

      test('shouldAnimate() returns false when appAnimations is disabled', () async {
        await AppSettings.setAppAnimations(false);
        expect(AnimationUtils.shouldAnimate(), isFalse);
      });

      test('shouldAnimate() returns false when reduceAnimations is enabled', () async {
        await AppSettings.setReduceAnimations(true);
        expect(AnimationUtils.shouldAnimate(), isFalse);
      });

      test('shouldAnimate() returns false when batterySaver is enabled', () async {
        await AppSettings.setBatterySaver(true);
        expect(AnimationUtils.shouldAnimate(), isFalse);
      });

      test('shouldAnimate() returns false when animationLevel is none', () async {
        await AppSettings.setAnimationLevel('none');
        expect(AnimationUtils.shouldAnimate(), isFalse);
      });

      test('shouldAnimate() respects platform capabilities for web', () async {
        // If running on web with no complex animation support
        if (PlatformService.isWeb && !PlatformService.supportsComplexAnimations) {
          expect(AnimationUtils.shouldAnimate(), isFalse);
          
          // Should return true only if explicitly enhanced
          await AppSettings.setAnimationLevel('enhanced');
          expect(AnimationUtils.shouldAnimate(), isTrue);
        }
      });
    });

    group('Duration Calculation', () {
      test('getDuration() returns zero when animations disabled', () async {
        await AppSettings.setAppAnimations(false);
        expect(AnimationUtils.getDuration().inMilliseconds, equals(0));
      });

      test('getDuration() returns platform duration by default', () {
        final duration = AnimationUtils.getDuration();
        final platformDuration = PlatformService.platformAnimationDuration;
        expect(duration, equals(platformDuration));
      });

      test('getDuration() uses fallback when provided', () {
        const fallback = Duration(milliseconds: 500);
        final duration = AnimationUtils.getDuration(fallback);
        expect(duration, equals(fallback));
      });

      test('getDuration() modifies duration based on animation level', () async {
        const baseDuration = Duration(milliseconds: 300);
        
        // Reduced level
        await AppSettings.setAnimationLevel('reduced');
        final reducedDuration = AnimationUtils.getDuration(baseDuration);
        expect(reducedDuration.inMilliseconds, equals(150)); // 50% of base
        
        // Enhanced level
        await AppSettings.setAnimationLevel('enhanced');
        final enhancedDuration = AnimationUtils.getDuration(baseDuration);
        expect(enhancedDuration.inMilliseconds, equals(360)); // 120% of base
        
        // Normal level
        await AppSettings.setAnimationLevel('normal');
        final normalDuration = AnimationUtils.getDuration(baseDuration);
        expect(normalDuration, equals(baseDuration));
      });
    });

    group('Curve Selection', () {
      test('getCurve() returns linear when animations disabled', () async {
        await AppSettings.setAppAnimations(false);
        expect(AnimationUtils.getCurve(), equals(Curves.linear));
      });

      test('getCurve() returns platform curve by default', () {
        final curve = AnimationUtils.getCurve();
        final platformCurve = PlatformService.platformCurve;
        expect(curve, equals(platformCurve));
      });

      test('getCurve() uses fallback when provided', () {
        const fallback = Curves.bounceIn;
        final curve = AnimationUtils.getCurve(fallback);
        expect(curve, equals(fallback));
      });

      test('getCurve() modifies curve based on animation level', () async {
        // Reduced level
        await AppSettings.setAnimationLevel('reduced');
        expect(AnimationUtils.getCurve(), equals(Curves.easeInOut));
        
        // Enhanced level
        await AppSettings.setAnimationLevel('enhanced');
        expect(AnimationUtils.getCurve(), equals(Curves.elasticOut));
        
        // Normal level
        await AppSettings.setAnimationLevel('normal');
        expect(AnimationUtils.getCurve(), equals(PlatformService.platformCurve));
      });
    });

    group('Complex Animation Control', () {
      test('shouldUseComplexAnimations() returns true by default', () {
        if (PlatformService.supportsComplexAnimations) {
          expect(AnimationUtils.shouldUseComplexAnimations(), isTrue);
        }
      });

      test('shouldUseComplexAnimations() returns false when animations disabled', () async {
        await AppSettings.setAppAnimations(false);
        expect(AnimationUtils.shouldUseComplexAnimations(), isFalse);
      });

      test('shouldUseComplexAnimations() returns true on reduced level if performance is good', () async {
        await AppSettings.setAnimationLevel('reduced');
        // It returns true because 'reduced' is not 'none' and performance is good by default in tests
        expect(AnimationUtils.shouldUseComplexAnimations(), isTrue);
      });

      test('shouldUseComplexAnimations() respects platform capabilities', () {
        if (!PlatformService.supportsComplexAnimations) {
          expect(AnimationUtils.shouldUseComplexAnimations(), isFalse);
        }
      });
    });

    group('Staggered Animation Control', () {
      test('shouldUseStaggeredAnimations() returns false on reduced level', () async {
        await AppSettings.setAnimationLevel('reduced');
        expect(AnimationUtils.shouldUseStaggeredAnimations(), isFalse);
      });

      test('shouldUseStaggeredAnimations() is context-aware of active animations', () async {
        await AppSettings.setAnimationLevel('normal');
        
        // Initially should allow staggered animations
        expect(AnimationUtils.shouldUseStaggeredAnimations(), isTrue);
        
        // Simulate many active animations to reach the limit
        for (int i = 0; i < 5; i++) {
          AnimationPerformanceService.registerAnimationStart();
        }
        
        // Should now return false due to too many active animations
        expect(AnimationUtils.shouldUseStaggeredAnimations(), isFalse);
        
        // Clean up
        for (int i = 0; i < 5; i++) {
          AnimationPerformanceService.registerAnimationEnd();
        }
      });

      test('shouldUseStaggeredAnimations() returns false when animations disabled', () async {
        await AppSettings.setAppAnimations(false);
        expect(AnimationUtils.shouldUseStaggeredAnimations(), isFalse);
      });

      test('shouldUseStaggeredAnimations() returns false in battery saver mode', () async {
        await AppSettings.setBatterySaver(true);
        expect(AnimationUtils.shouldUseStaggeredAnimations(), isFalse);
      });
    });

    group('Stagger Delay', () {
      test('getStaggerDelay() returns zero when animations disabled', () async {
        await AppSettings.setAppAnimations(false);
        expect(AnimationUtils.getStaggerDelay(0).inMilliseconds, equals(0));
      });

      test('getStaggerDelay() uses default base delay', () {
        final delay = AnimationUtils.getStaggerDelay(0);
        expect(delay.inMilliseconds, equals(50)); // Default base delay
      });

      test('getStaggerDelay() uses custom base delay', () {
        const baseDelay = Duration(milliseconds: 100);
        final delay = AnimationUtils.getStaggerDelay(0, baseDelay: baseDelay);
        expect(delay, equals(baseDelay));
      });

      test('getStaggerDelay() modifies delay based on animation level', () async {
        const baseDelay = Duration(milliseconds: 100);
        
        // Reduced level
        await AppSettings.setAnimationLevel('reduced');
        final reducedDelay = AnimationUtils.getStaggerDelay(0, baseDelay: baseDelay);
        expect(reducedDelay.inMilliseconds, equals(50)); // 50% of base
        
        // Enhanced level
        await AppSettings.setAnimationLevel('enhanced');
        final enhancedDelay = AnimationUtils.getStaggerDelay(0, baseDelay: baseDelay);
        expect(enhancedDelay.inMilliseconds, equals(120)); // 120% of base
      });
    });

    group('Animation Controller Creation', () {
      testWidgets('createController() creates valid controller', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final controller = AnimationUtils.createController(
                  vsync: tester,
                  duration: const Duration(milliseconds: 200),
                  debugLabel: 'test_controller',
                );
                
                expect(controller, isA<AnimationController>());
                expect(controller.duration, equals(const Duration(milliseconds: 200)));
                expect(controller.debugLabel, equals('test_controller'));
                
                controller.dispose();
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('createController() respects animation settings', (tester) async {
        await AppSettings.setAppAnimations(false);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final controller = AnimationUtils.createController(
                  vsync: tester,
                  duration: const Duration(milliseconds: 200),
                );
                
                expect(controller.duration, equals(Duration.zero));
                
                controller.dispose();
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Curved Animation Creation', () {
      testWidgets('createCurvedAnimation() creates valid curved animation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final controller = AnimationController(
                  duration: const Duration(milliseconds: 200),
                  vsync: tester,
                );
                
                final curvedAnimation = AnimationUtils.createCurvedAnimation(
                  parent: controller,
                  curve: Curves.easeIn,
                );
                
                expect(curvedAnimation, isA<CurvedAnimation>());
                expect(curvedAnimation.curve, equals(Curves.easeIn));
                
                controller.dispose();
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Widget Wrappers', () {
      testWidgets('animatedContainer() creates AnimatedContainer', (tester) async {
        Widget container = AnimationUtils.animatedContainer(
          width: 100,
          height: 100,
          color: Colors.red,
          duration: const Duration(milliseconds: 200),
        );
        
        expect(container, isA<AnimatedContainer>());
        
        await tester.pumpWidget(MaterialApp(home: container));
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });

      testWidgets('animatedOpacity() creates AnimatedOpacity', (tester) async {
        Widget opacity = AnimationUtils.animatedOpacity(
          child: Container(),
          opacity: 0.5,
          duration: const Duration(milliseconds: 200),
        );
        
        expect(opacity, isA<AnimatedOpacity>());
        
        await tester.pumpWidget(MaterialApp(home: opacity));
        expect(find.byType(AnimatedOpacity), findsOneWidget);
      });

      testWidgets('animatedScale() creates AnimatedScale', (tester) async {
        Widget scale = AnimationUtils.animatedScale(
          child: Container(),
          scale: 1.5,
          duration: const Duration(milliseconds: 200),
        );
        
        expect(scale, isA<AnimatedScale>());
        
        await tester.pumpWidget(MaterialApp(home: scale));
        expect(find.byType(AnimatedScale), findsOneWidget);
      });
    });

    group('Animation Integration', () {
      test('multiple settings work together correctly', () async {
        // Set multiple settings that should disable animations
        await AppSettings.setReduceAnimations(true);
        await AppSettings.setBatterySaver(true);
        await AppSettings.setAnimationLevel('none');
        
        expect(AnimationUtils.shouldAnimate(), isFalse);
        expect(AnimationUtils.getDuration().inMilliseconds, equals(0));
        expect(AnimationUtils.getCurve(), equals(Curves.linear));
        expect(AnimationUtils.shouldUseComplexAnimations(), isFalse);
      });

      test('settings override platform preferences appropriately', () async {
        const baseDuration = Duration(milliseconds: 300);
        await AppSettings.setAnimationLevel('enhanced');
        
        final duration = AnimationUtils.getDuration(baseDuration);
        
        // Should use the 'enhanced' multiplier, not the platform default
        expect(duration.inMilliseconds, 360);
      });
    });

    group('Debug Information', () {
      test('getAnimationDebugInfo() returns complete information', () {
        final debugInfo = AnimationUtils.getAnimationDebugInfo();
        
        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo.containsKey('shouldAnimate'), isTrue);
        expect(debugInfo.containsKey('animationLevel'), isTrue);
        expect(debugInfo.containsKey('appAnimations'), isTrue);
        expect(debugInfo.containsKey('reduceAnimations'), isTrue);
        expect(debugInfo.containsKey('batterySaver'), isTrue);
        expect(debugInfo.containsKey('shouldUseComplexAnimations'), isTrue);
        expect(debugInfo.containsKey('platformInfo'), isTrue);
        expect(debugInfo.containsKey('defaultDuration'), isTrue);
        expect(debugInfo.containsKey('defaultCurve'), isTrue);
      });

      test('debug info reflects current settings state', () async {
        await AppSettings.setAnimationLevel('enhanced');
        await AppSettings.setBatterySaver(true);
        
        final debugInfo = AnimationUtils.getAnimationDebugInfo();
        
        expect(debugInfo['animationLevel'], equals('enhanced'));
        expect(debugInfo['batterySaver'], isTrue);
        expect(debugInfo['shouldAnimate'], isFalse); // Because batterySaver is true
      });
    });
  });
} 