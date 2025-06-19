import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/app/router/page_transitions.dart';
import 'package:finance/shared/widgets/transitions/open_container_navigation.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/core/services/platform_service.dart';

void main() {
  group('Phase 4: Page Transitions & Navigation', () {
    setUp(() async {
      // Reset settings before each test
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
    });

    group('AppPageTransitions', () {
      testWidgets('slideTransitionPage creates CustomTransitionPage',
          (tester) async {
        const testChild = Scaffold(body: Text('Slide Test Page'));

        final page = AppPageTransitions.slideTransitionPage(
          child: testChild,
          name: 'test',
          direction: SlideDirection.fromRight,
        );

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test that the page can be used in navigation
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Slide Test Page'), findsOneWidget);
      });

      testWidgets('fadeTransitionPage creates CustomTransitionPage',
          (tester) async {
        const testChild = Scaffold(body: Text('Fade Test Page'));

        final page = AppPageTransitions.fadeTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Fade Test Page'), findsOneWidget);
      });

      testWidgets('scaleTransitionPage creates CustomTransitionPage',
          (tester) async {
        const testChild = Scaffold(body: Text('Scale Test Page'));

        final page = AppPageTransitions.scaleTransitionPage(
          child: testChild,
          name: 'test',
          alignment: Alignment.center,
        );

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Scale Test Page'), findsOneWidget);
      });

      testWidgets('slideFadeTransitionPage creates CustomTransitionPage',
          (tester) async {
        const testChild = Scaffold(body: Text('SlideFade Test Page'));

        final page = AppPageTransitions.slideFadeTransitionPage(
          child: testChild,
          name: 'test',
          direction: SlideDirection.fromBottom,
        );

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('SlideFade Test Page'), findsOneWidget);
      });

      testWidgets('noTransitionPage creates NoTransitionPage', (tester) async {
        const testChild = Scaffold(body: Text('No Transition Test Page'));

        final page = AppPageTransitions.noTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(page, isA<NoTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('No Transition Test Page'), findsOneWidget);
      });

      testWidgets('platformTransitionPage respects animation settings',
          (tester) async {
        const testChild = Scaffold(body: Text('Platform Test Page'));

        // Test with animations disabled
        await AppSettings.setAppAnimations(false);

        final pageNoAnimation = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(pageNoAnimation, isA<NoTransitionPage>());

        // Test with animations enabled
        await AppSettings.setAppAnimations(true);
        await AppSettings.setReduceAnimations(false);
        await AppSettings.setBatterySaver(false);
        await AppSettings.setAnimationLevel('normal');

        final pageWithAnimation = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(pageWithAnimation, isA<CustomTransitionPage>());
      });

      test('SlideDirection enum has all directions', () {
        expect(SlideDirection.values.length, equals(4));
        expect(SlideDirection.values, contains(SlideDirection.fromLeft));
        expect(SlideDirection.values, contains(SlideDirection.fromRight));
        expect(SlideDirection.values, contains(SlideDirection.fromTop));
        expect(SlideDirection.values, contains(SlideDirection.fromBottom));
      });
    });

    group('PageTransitionExtension', () {
      testWidgets('slideTransition extension works', (tester) async {
        const testWidget = Scaffold(body: Text('Extension Slide Test'));

        final page = testWidget.slideTransition(
          name: 'test',
          direction: SlideDirection.fromLeft,
        );

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Extension Slide Test'), findsOneWidget);
      });

      testWidgets('fadeTransition extension works', (tester) async {
        const testWidget = Scaffold(body: Text('Extension Fade Test'));

        final page = testWidget.fadeTransition(name: 'test');

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Extension Fade Test'), findsOneWidget);
      });

      testWidgets('scaleTransition extension works', (tester) async {
        const testWidget = Scaffold(body: Text('Extension Scale Test'));

        final page = testWidget.scaleTransition(
          name: 'test',
          alignment: Alignment.topLeft,
        );

        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Extension Scale Test'), findsOneWidget);
      });

      testWidgets('platformTransition extension works', (tester) async {
        const testWidget = Scaffold(body: Text('Extension Platform Test'));

        final page = testWidget.platformTransition(name: 'test');

        expect(page, isA<Page>());
        expect(page.name, equals('test'));

        // Test navigation functionality
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => page,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Extension Platform Test'), findsOneWidget);
      });
    });

    group('OpenContainerNavigation', () {
      testWidgets('renders closed builder by default', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: OpenContainerNavigation(
              openPage: const Scaffold(body: Text('Open Page')),
              closedBuilder: (openContainer) {
                return GestureDetector(
                  onTap: openContainer,
                  child: const Text('Closed Container'),
                );
              },
            ),
          ),
        );

        expect(find.text('Closed Container'), findsOneWidget);
        expect(find.text('Open Page'), findsNothing);
      });

      testWidgets('opens page when tapped with animations enabled',
          (tester) async {
        await AppSettings.setAppAnimations(true);
        await AppSettings.setReduceAnimations(false);
        await AppSettings.setBatterySaver(false);

        await tester.pumpWidget(
          MaterialApp(
            home: OpenContainerNavigation(
              openPage: const Scaffold(body: Text('Open Page')),
              closedBuilder: (openContainer) {
                return GestureDetector(
                  onTap: openContainer,
                  child: const Text('Closed Container'),
                );
              },
            ),
          ),
        );

        expect(find.text('Closed Container'), findsOneWidget);

        // Tap to open
        await tester.tap(find.text('Closed Container'));
        await tester.pumpAndSettle();

        expect(find.text('Open Page'), findsOneWidget);
      });

      testWidgets('falls back to standard navigation when animations disabled',
          (tester) async {
        await AppSettings.setAppAnimations(false);

        await tester.pumpWidget(
          MaterialApp(
            home: OpenContainerNavigation(
              openPage: const Scaffold(body: Text('Open Page')),
              closedBuilder: (openContainer) {
                return GestureDetector(
                  onTap: openContainer,
                  child: const Text('Closed Container'),
                );
              },
            ),
          ),
        );

        expect(find.text('Closed Container'), findsOneWidget);

        // Tap to open
        await tester.tap(find.text('Closed Container'));
        await tester.pumpAndSettle();

        expect(find.text('Open Page'), findsOneWidget);
      });

      testWidgets('calls onOpen callback', (tester) async {
        bool onOpenCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: OpenContainerNavigation(
              openPage: const Scaffold(body: Text('Open Page')),
              onOpen: () => onOpenCalled = true,
              closedBuilder: (openContainer) {
                return GestureDetector(
                  onTap: openContainer,
                  child: const Text('Closed Container'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Closed Container'));
        await tester.pump();

        expect(onOpenCalled, isTrue);
      });
    });

    group('OpenContainerCard', () {
      testWidgets('renders card with content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OpenContainerCard(
                openPage: const Scaffold(body: Text('Open Page')),
                child: const Text('Card Content'),
              ),
            ),
          ),
        );

        expect(find.text('Card Content'), findsOneWidget);
        expect(find.byType(Material), findsWidgets);
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('opens page when card is tapped', (tester) async {
        await AppSettings.setAppAnimations(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OpenContainerCard(
                openPage: const Scaffold(body: Text('Open Page')),
                child: const Text('Card Content'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Card Content'));
        await tester.pumpAndSettle();

        expect(find.text('Open Page'), findsOneWidget);
      });
    });

    group('OpenContainerListTile', () {
      testWidgets('renders list tile with content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OpenContainerListTile(
                openPage: const Scaffold(body: Text('Open Page')),
                leading: const Icon(Icons.star),
                title: const Text('List Item'),
                subtitle: const Text('Subtitle'),
                trailing: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        );

        expect(find.text('List Item'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        expect(find.byType(ListTile), findsOneWidget);
      });

      testWidgets('opens page when list tile is tapped', (tester) async {
        await AppSettings.setAppAnimations(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OpenContainerListTile(
                openPage: const Scaffold(body: Text('Open Page')),
                title: const Text('List Item'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('List Item'));
        await tester.pumpAndSettle();

        expect(find.text('Open Page'), findsOneWidget);
      });
    });

    group('OpenContainerExtension', () {
      testWidgets('openContainerNavigation extension works', (tester) async {
        const testWidget = Text('Test Widget');

        final containerWidget = testWidget.openContainerNavigation(
          openPage: const Scaffold(body: Text('Open Page')),
        );

        expect(containerWidget, isA<OpenContainerNavigation>());

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: containerWidget)),
        );

        expect(find.text('Test Widget'), findsOneWidget);
      });

      testWidgets('openContainerCard extension works', (tester) async {
        const testWidget = Text('Test Widget');

        final cardWidget = testWidget.openContainerCard(
          openPage: const Scaffold(body: Text('Open Page')),
        );

        expect(cardWidget, isA<OpenContainerCard>());

        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: cardWidget)),
        );

        expect(find.text('Test Widget'), findsOneWidget);
      });
    });

    group('Animation Integration', () {
      testWidgets('respects animation level settings', (tester) async {
        const testChild = Scaffold(body: Text('Animation Level Test'));

        // Test none level
        await AppSettings.setAnimationLevel('none');
        final pageNone = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );
        expect(pageNone, isA<NoTransitionPage>());

        // Test normal level
        await AppSettings.setAnimationLevel('normal');
        await AppSettings.setAppAnimations(true);
        await AppSettings.setReduceAnimations(false);
        await AppSettings.setBatterySaver(false);

        final pageNormal = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );
        expect(pageNormal, isA<CustomTransitionPage>());
      });

      testWidgets('respects battery saver mode', (tester) async {
        const testChild = Scaffold(body: Text('Battery Saver Test'));

        await AppSettings.setBatterySaver(true);

        final page = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(page, isA<NoTransitionPage>());
      });

      testWidgets('respects reduce animations setting', (tester) async {
        const testChild = Scaffold(body: Text('Reduce Animations Test'));

        await AppSettings.setReduceAnimations(true);

        final page = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(page, isA<NoTransitionPage>());
      });
    });

    group('Platform Integration', () {
      testWidgets('platform detection affects transition choice',
          (tester) async {
        const testChild = Scaffold(body: Text('Platform Detection Test'));

        await AppSettings.setAppAnimations(true);
        await AppSettings.setReduceAnimations(false);
        await AppSettings.setBatterySaver(false);
        await AppSettings.setAnimationLevel('normal');

        final page = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        // Should create a CustomTransitionPage when animations are enabled
        expect(page, isA<CustomTransitionPage>());
        expect(page.name, equals('test'));
      });
    });

    group('Performance', () {
      testWidgets('no-transition pages have zero overhead', (tester) async {
        const testChild = Scaffold(body: Text('Performance Test'));

        await AppSettings.setAppAnimations(false);

        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) {
          AppPageTransitions.noTransitionPage(
            child: testChild,
            name: 'test_$i',
          );
        }

        stopwatch.stop();

        // Should be very fast (less than 10ms for 100 pages)
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
      });

      testWidgets('transition pages respect animation settings for performance',
          (tester) async {
        const testChild = Scaffold(body: Text('Performance Settings Test'));

        // Test with battery saver (should use no transition for performance)
        await AppSettings.setBatterySaver(true);

        final batteryPage = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        expect(batteryPage, isA<NoTransitionPage>());

        // Test with reduced animations (should use simpler transitions)
        await AppSettings.setBatterySaver(false);
        await AppSettings.setAnimationLevel('reduced');
        await AppSettings.setAppAnimations(true);
        await AppSettings.setReduceAnimations(false);

        final reducedPage = AppPageTransitions.platformTransitionPage(
          child: testChild,
          name: 'test',
        );

        // Should still create a transition page, but with reduced complexity
        expect(reducedPage, isA<CustomTransitionPage>());
      });
    });
  });
}
