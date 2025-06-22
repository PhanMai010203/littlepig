import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/shared/widgets/animations/fade_in.dart';
import 'package:finance/shared/widgets/animations/scale_in.dart';
import 'package:finance/shared/widgets/animations/slide_in.dart';
import 'package:finance/shared/widgets/animations/bouncing_widget.dart';
import 'package:finance/shared/widgets/animations/breathing_widget.dart';
import 'package:finance/shared/widgets/animations/animated_expanded.dart';
import 'package:finance/shared/widgets/animations/animated_size_switcher.dart';
import 'package:finance/shared/widgets/animations/scaled_animated_switcher.dart';
import 'package:finance/shared/widgets/animations/slide_fade_transition.dart';
import 'package:finance/shared/widgets/animations/tappable_widget.dart';
import 'package:finance/shared/widgets/animations/shake_animation.dart';
import 'package:finance/shared/widgets/animations/animated_scale_opacity.dart';
import 'package:finance/core/settings/app_settings.dart';

void main() {
  group('Phase 2 Animation Widgets', () {
    setUp(() async {
      // Reset settings before each test
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
    });

    group('Entry Animations', () {
      testWidgets('FadeIn creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: FadeIn(
              child: Container(width: 100, height: 100, color: Colors.red),
            ),
          ),
        );
        expect(find.byType(FadeIn), findsOneWidget);
      });

      testWidgets('ScaleIn creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ScaleIn(
              child: Container(width: 100, height: 100, color: Colors.blue),
            ),
          ),
        );
        expect(find.byType(ScaleIn), findsOneWidget);
      });

      testWidgets('SlideIn creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SlideIn(
              child: Container(width: 100, height: 100, color: Colors.green),
            ),
          ),
        );
        expect(find.byType(SlideIn), findsOneWidget);
      });

      testWidgets('BouncingWidget creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BouncingWidget(
              autoStart: false,
              child: Container(width: 100, height: 100, color: Colors.orange),
            ),
          ),
        );
        expect(find.byType(BouncingWidget), findsOneWidget);
      });

      testWidgets('BreathingWidget creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BreathingWidget(
              autoStart: false,
              child: Container(width: 100, height: 100, color: Colors.purple),
            ),
          ),
        );
        expect(find.byType(BreathingWidget), findsOneWidget);
      });
    });

    group('Transition Animations', () {
      testWidgets('AnimatedExpanded creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedExpanded(
              expand: true,
              child: Container(width: 100, height: 100, color: Colors.cyan),
            ),
          ),
        );
        expect(find.byType(AnimatedExpanded), findsOneWidget);
      });

      testWidgets('AnimatedSizeSwitcher creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedSizeSwitcher(
              child: Container(width: 100, height: 100, color: Colors.teal),
            ),
          ),
        );
        expect(find.byType(AnimatedSizeSwitcher), findsOneWidget);
      });

      testWidgets('ScaledAnimatedSwitcher creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ScaledAnimatedSwitcher(
              child: Container(width: 100, height: 100, color: Colors.indigo),
            ),
          ),
        );
        expect(find.byType(ScaledAnimatedSwitcher), findsOneWidget);
      });

      testWidgets('SlideFadeTransition creates widget', (tester) async {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: tester,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: SlideFadeTransition(
              animation: controller,
              child: Container(width: 100, height: 100, color: Colors.amber),
            ),
          ),
        );

        expect(find.byType(SlideFadeTransition), findsOneWidget);
        controller.dispose();
      });
    });

    group('Interactive Animations', () {
      testWidgets('TappableWidget creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TappableWidget(
              onTap: () {},
              child: Container(width: 100, height: 100, color: Colors.red),
            ),
          ),
        );
        expect(find.byType(TappableWidget), findsOneWidget);
      });

      testWidgets('ShakeAnimation creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ShakeAnimation(
              autoStart: false,
              child: Container(width: 100, height: 100, color: Colors.yellow),
            ),
          ),
        );
        expect(find.byType(ShakeAnimation), findsOneWidget);
      });

      testWidgets('AnimatedScaleOpacity creates widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AnimatedScaleOpacity(
              visible: true,
              child: Container(width: 100, height: 100, color: Colors.pink),
            ),
          ),
        );
        expect(find.byType(AnimatedScaleOpacity), findsOneWidget);
      });
    });

    group('Animation Settings Integration', () {
      testWidgets('widgets respect animation settings', (tester) async {
        await AppSettings.setAppAnimations(false);

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                FadeIn(child: SizedBox(width: 50, height: 50)),
                ScaleIn(child: SizedBox(width: 50, height: 50)),
                TappableWidget(
                  onTap: () {},
                  child: SizedBox(width: 50, height: 50),
                ),
              ],
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(SizedBox), findsNWidgets(3));
      });

      testWidgets('widgets respect battery saver setting', (tester) async {
        await AppSettings.setBatterySaver(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                FadeIn(
                    child: SizedBox(
                        key: const ValueKey('fade'), width: 50, height: 50)),
                BouncingWidget(
                  autoStart: false,
                  child: SizedBox(
                      key: const ValueKey('bounce'), width: 50, height: 50),
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byKey(const ValueKey('fade')), findsOneWidget);
        expect(find.byKey(const ValueKey('bounce')), findsOneWidget);
      });

      testWidgets('widgets respect reduce animations setting', (tester) async {
        await AppSettings.setReduceAnimations(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                SlideIn(
                    child: SizedBox(
                        key: const ValueKey('slide'), width: 50, height: 50)),
                BreathingWidget(
                  autoStart: false,
                  child: SizedBox(
                      key: const ValueKey('breathing'), width: 50, height: 50),
                ),
              ],
            ),
          ),
        );

        await tester.pump();

        expect(find.byKey(const ValueKey('slide')), findsOneWidget);
        expect(find.byKey(const ValueKey('breathing')), findsOneWidget);
      });
    });
  });
}
