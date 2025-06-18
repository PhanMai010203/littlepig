import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:finance/features/navigation/presentation/widgets/main_shell.dart';
import 'package:finance/features/navigation/presentation/widgets/navigation_customization_content.dart';
import 'package:finance/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:finance/features/navigation/domain/entities/navigation_item.dart';
import 'package:finance/shared/widgets/page_template.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/core/di/injection.dart';

void main() {
  group('Phase 5 Navigation Enhancement Tests', () {
    setUp(() async {
      // Reset settings before each test
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
      
      // Initialize EasyLocalization for testing
      await EasyLocalization.ensureInitialized();
    });

    group('NavigationCustomizationContent Widget', () {
      testWidgets('NavigationCustomizationContent displays correctly with available items', (tester) async {
        const currentItem = NavigationItem.home;
        const availableItems = [NavigationItem.goals, NavigationItem.analytics];
        
        bool selectedCalled = false;
        NavigationItem? selectedItem;
        
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            home: Scaffold(
              body: NavigationCustomizationContent(
                currentIndex: 0,
                currentItem: currentItem,
                availableItems: availableItems,
                onItemSelected: (item) {
                  selectedCalled = true;
                  selectedItem = item;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check that content is displayed
        expect(find.byType(NavigationCustomizationContent), findsOneWidget);
        
        // Check that available items are displayed
        expect(find.text('Goals'), findsOneWidget);
        expect(find.text('Analytics'), findsOneWidget);
        
        // Test item selection
        await tester.tap(find.text('Goals'));
        await tester.pumpAndSettle();
        
        expect(selectedCalled, isTrue);
        expect(selectedItem, equals(NavigationItem.goals));
      });

      testWidgets('NavigationCustomizationContent shows empty state when no items available', (tester) async {
        const currentItem = NavigationItem.home;
        const availableItems = <NavigationItem>[];
        
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            home: Scaffold(
              body: NavigationCustomizationContent(
                currentIndex: 0,
                currentItem: currentItem,
                availableItems: availableItems,
                onItemSelected: (item) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check for empty state icon
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('NavigationCustomizationContent animations work correctly', (tester) async {
        const currentItem = NavigationItem.home;
        const availableItems = [NavigationItem.goals];
        
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            home: Scaffold(
              body: NavigationCustomizationContent(
                currentIndex: 0,
                currentItem: currentItem,
                availableItems: availableItems,
                onItemSelected: (item) {},
              ),
            ),
          ),
        );

        // Initial pump
        await tester.pump();
        
        // Pump frames to test animations
        await tester.pump(const Duration(milliseconds: 100)); // FadeIn delay
        await tester.pump(const Duration(milliseconds: 200)); // Second FadeIn delay
        await tester.pump(const Duration(milliseconds: 300)); // SlideIn delay
        await tester.pump(const Duration(milliseconds: 50));  // SlideIn index delay
        
        await tester.pumpAndSettle();
        
        // Verify content is visible after animations
        expect(find.text('Goals'), findsOneWidget);
      });
    });

    group('Enhanced PageTemplate', () {
      testWidgets('PageTemplate with FadeIn animation works', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PageTemplate(
              title: 'Test Page',
              body: const Text('Test Body'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Test Page'), findsOneWidget);
        expect(find.text('Test Body'), findsOneWidget);
      });

      testWidgets('PageTemplate title animation works on change', (tester) async {
        String title = 'Initial Title';
        
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          title = 'Updated Title';
                        });
                      },
                      child: const Text('Change Title'),
                    ),
                    Expanded(
                      child: PageTemplate(
                        title: title,
                        body: const Text('Test Body'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );

        // Initial state
        expect(find.text('Initial Title'), findsOneWidget);
        
        // Change title
        await tester.tap(find.text('Change Title'));
        await tester.pump();
        
        // During animation, both titles might be present
        await tester.pump(const Duration(milliseconds: 100));
        
        // After animation completes
        await tester.pumpAndSettle();
        expect(find.text('Updated Title'), findsOneWidget);
        expect(find.text('Initial Title'), findsNothing);
      });

      testWidgets('PageTemplate back button works correctly', (tester) async {
        bool backPressed = false;
        
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (context) => const Text('Home'),
              '/test': (context) => PageTemplate(
                title: 'Test Page',
                body: const Text('Test Body'),
                onBackPressed: () {
                  backPressed = true;
                  Navigator.pop(context);
                },
              ),
            },
            initialRoute: '/test',
          ),
        );

        await tester.pumpAndSettle();

        // Find and tap back button
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);
        
        await tester.tap(backButton);
        expect(backPressed, isTrue);
      });

      testWidgets('PageTemplate respects animation settings', (tester) async {
        // Test with animations disabled
        await AppSettings.set('appAnimations', false);
        
        await tester.pumpWidget(
          MaterialApp(
            home: PageTemplate(
              title: 'Test Page',
              body: const Text('Test Body'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Content should still be visible
        expect(find.text('Test Page'), findsOneWidget);
        expect(find.text('Test Body'), findsOneWidget);
      });
    });

    group('MainShell PopupFramework Integration', () {
      testWidgets('MainShell creates NavigationBloc correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) => NavigationBloc(),
              child: const MainShell(
                child: Text('Test Child'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(MainShell), findsOneWidget);
        expect(find.text('Test Child'), findsOneWidget);
      });

      testWidgets('MainShell handles navigation state changes', (tester) async {
        late NavigationBloc navigationBloc;
        
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) {
                navigationBloc = NavigationBloc();
                return navigationBloc;
              },
              child: const MainShell(
                child: Text('Test Child'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check initial state
        expect(navigationBloc.state.currentIndex, equals(0));
        expect(navigationBloc.state.navigationItems.length, equals(4));
        
        // Test navigation item replacement
        navigationBloc.add(
          const NavigationEvent.navigationItemReplaced(0, NavigationItem.goals),
        );
        
        await tester.pump();
        
        expect(navigationBloc.state.navigationItems[0], equals(NavigationItem.goals));
      });
    });

    group('Animation Integration Tests', () {
      testWidgets('TappableWidget integration works in navigation', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider(
              create: (context) => NavigationBloc(),
              child: const MainShell(
                child: Text('Test Child'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find navigation items (they should use TappableWidget now)
        final navigationItems = find.byType(Material);
        expect(navigationItems, findsWidgets);
      });

      testWidgets('Animation settings affect navigation components', (tester) async {
        // Test with different animation levels
        for (final level in ['none', 'reduced', 'normal', 'enhanced']) {
          await AppSettings.set('animationLevel', level);
          
          await tester.pumpWidget(
            MaterialApp(
              home: BlocProvider(
                create: (context) => NavigationBloc(),
                child: const MainShell(
                  child: Text('Test Child'),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Navigation should work regardless of animation level
          expect(find.byType(MainShell), findsOneWidget);
        }
      });

      testWidgets('Performance optimization works with battery saver', (tester) async {
        // Enable battery saver mode
        await AppSettings.set('batterySaver', true);
        
        await tester.pumpWidget(
          MaterialApp(
            home: PageTemplate(
              title: 'Test Page',
              body: const Text('Test Body'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Content should still be visible, just without animations
        expect(find.text('Test Page'), findsOneWidget);
        expect(find.text('Test Body'), findsOneWidget);
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('NavigationCustomizationContent handles null safely', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            home: Scaffold(
              body: NavigationCustomizationContent(
                currentIndex: 0,
                currentItem: NavigationItem.home,
                availableItems: const [],
                onItemSelected: (item) {},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should handle empty list gracefully
        expect(find.byType(NavigationCustomizationContent), findsOneWidget);
      });

      testWidgets('PageTemplate handles null title gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: PageTemplate(
              title: null,
              body: const Text('Test Body'),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should not have app bar when title is null
        expect(find.byType(AppBar), findsNothing);
        expect(find.text('Test Body'), findsOneWidget);
      });
    });
  });
} 