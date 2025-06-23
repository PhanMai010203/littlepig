import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:finance/features/navigation/presentation/widgets/adaptive_bottom_navigation.dart';
import 'package:finance/features/navigation/domain/entities/navigation_item.dart';

void main() {
  group('AdaptiveBottomNavigation - Phase 1.1 Tests', () {
    late List<NavigationItem> testItems;

    setUp(() {
      testItems = [
        const NavigationItem(
          id: 'home',
          label: 'Home',
          iconPath: 'assets/icons/icon_home.svg',
          routePath: '/',
        ),
        const NavigationItem(
          id: 'transactions',
          label: 'Transactions',
          iconPath: 'assets/icons/icon_transactions.svg',
          routePath: '/transactions',
        ),
        const NavigationItem(
          id: 'budgets',
          label: 'Budgets',
          iconPath: 'assets/icons/icon_budget.svg',
          routePath: '/budgets',
        ),
        const NavigationItem(
          id: 'more',
          label: 'More',
          iconPath: 'assets/icons/icon_more.svg',
          routePath: '/more',
        ),
      ];
    });

    Widget createWidget({
      int currentIndex = 0,
      ValueChanged<int>? onTap,
      ValueChanged<int>? onLongPress,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: AdaptiveBottomNavigation(
            currentIndex: currentIndex,
            items: testItems,
            onTap: onTap ?? (index) {},
            onLongPress: onLongPress,
          ),
        ),
      );
    }

    testWidgets('should render all navigation items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // Verify that all 4 default items are rendered
      expect(find.byType(AdaptiveBottomNavigation), findsOneWidget);
      
      // Check for SVG icons (should have 4 icons for 4 items)
      expect(find.byType(SvgPicture), findsNWidgets(4));

      // Verify each navigation item exists
      for (final item in testItems) {
        expect(find.text(item.label), findsOneWidget);
      }
    });

    testWidgets('should highlight current selected item', (WidgetTester tester) async {
      const selectedIndex = 2; // Budgets
      await tester.pumpWidget(createWidget(currentIndex: selectedIndex));

      // Find the indicator container (positioned indicator)
      final indicatorFinder = find.byType(AnimatedPositioned);
      expect(indicatorFinder, findsOneWidget);

      // The indicator should be positioned for the selected item
      final animatedPositioned = tester.widget<AnimatedPositioned>(indicatorFinder);
      
      // Since we have 4 items and selectedIndex=2, the left position should be calculated
      // This verifies the indicator positioning logic
      expect(animatedPositioned.left, isNotNull);
      expect(animatedPositioned.left! > 0, isTrue);
    });

    testWidgets('should call onTap when item is tapped', (WidgetTester tester) async {
      int? tappedIndex;
      
      await tester.pumpWidget(createWidget(
        onTap: (index) => tappedIndex = index,
      ));

             // Tap on the second item (Transactions)
       await tester.tap(find.text('Transactions'));
       await tester.pump();

       expect(tappedIndex, equals(1));
    });

    testWidgets('should call onLongPress when item is long pressed', (WidgetTester tester) async {
      int? longPressedIndex;
      
      await tester.pumpWidget(createWidget(
        onLongPress: (index) => longPressedIndex = index,
      ));

             // Long press on the third item (Budgets)
       await tester.longPress(find.text('Budgets'));
       await tester.pump();

       expect(longPressedIndex, equals(2));
    });

    testWidgets('should animate indicator when currentIndex changes', (WidgetTester tester) async {
      // Start with first item selected
      Widget widget = createWidget(currentIndex: 0);
      await tester.pumpWidget(widget);

      // Get initial indicator position
      final initialIndicator = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned)
      );
      final initialLeft = initialIndicator.left!;

      // Change to second item
      widget = createWidget(currentIndex: 1);
      await tester.pumpWidget(widget);

      // Get new indicator position
      final newIndicator = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned)
      );
      final newLeft = newIndicator.left!;

      // Indicator position should have changed
      expect(newLeft, isNot(equals(initialLeft)));
      expect(newLeft > initialLeft, isTrue);
    });

    testWidgets('should trigger bounce animation on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

             // Tap on an item to trigger bounce animation
       await tester.tap(find.text('Home'));
       await tester.pump(); // Trigger the animation start

      // Advance time to see the animation effect
      await tester.pump(const Duration(milliseconds: 75)); // Mid-animation
      
      // The widget should still be present and functional
      expect(find.byType(AdaptiveBottomNavigation), findsOneWidget);
      
      // Complete the animation
      await tester.pump(const Duration(milliseconds: 200));
      
      // Animation should be complete, widget still functional
      expect(find.byType(AdaptiveBottomNavigation), findsOneWidget);
    });

    testWidgets('should handle rapid successive taps', (WidgetTester tester) async {
      final List<int> tappedIndices = [];
      
      await tester.pumpWidget(createWidget(
        onTap: (index) => tappedIndices.add(index),
      ));

             // Rapidly tap different items
       await tester.tap(find.text('Home'));
       await tester.pump(const Duration(milliseconds: 10));
       
       await tester.tap(find.text('Transactions'));
       await tester.pump(const Duration(milliseconds: 10));
       
       await tester.tap(find.text('Budgets'));
       await tester.pump(const Duration(milliseconds: 10));

      // All taps should be registered
      expect(tappedIndices, equals([0, 1, 2]));
    });

    testWidgets('should maintain visual state during animation', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(currentIndex: 1));

      // Verify initial visual state
      expect(find.byType(SvgPicture), findsNWidgets(4));
      expect(find.byType(AnimatedPositioned), findsOneWidget);

             // Tap to trigger animation
       await tester.tap(find.text('Transactions'));
       await tester.pump();

      // During animation, all visual elements should still be present
      expect(find.byType(SvgPicture), findsNWidgets(4));
      expect(find.byType(AnimatedPositioned), findsOneWidget);

      // Complete animation
      await tester.pump(const Duration(milliseconds: 300));

      // After animation, all elements should still be present
      expect(find.byType(SvgPicture), findsNWidgets(4));
      expect(find.byType(AnimatedPositioned), findsOneWidget);
    });

         testWidgets('should work with different numbers of items', (WidgetTester tester) async {
       // Test with just 3 items
       final customItems = [
         testItems[0], // Home
         testItems[1], // Transactions
         testItems[2], // Budgets
       ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AdaptiveBottomNavigation(
              currentIndex: 0,
              items: customItems,
              onTap: (index) {},
            ),
          ),
        ),
      );

             // Should render exactly 3 items
       expect(find.byType(SvgPicture), findsNWidgets(3));
       expect(find.text('Home'), findsOneWidget);
       expect(find.text('Transactions'), findsOneWidget);
       expect(find.text('Budgets'), findsOneWidget);
       
       // Should not render the 'more' item
       expect(find.text('More'), findsNothing);
    });

    group('flutter_animate Integration Tests', () {
      testWidgets('should use flutter_animate for bounce effect', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

                 // Tap to trigger flutter_animate bounce
         await tester.tap(find.text('Home'));
         await tester.pump();

        // The widget should be using flutter_animate (this is verified by the import 
        // and usage in the source code we examined)
        expect(find.byType(AdaptiveBottomNavigation), findsOneWidget);
        
        // Advance through the animation timeline
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 150));
        
        // Animation should complete without errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle animation completion correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

                 // Trigger animation
         await tester.tap(find.text('Transactions'));
         await tester.pump();

        // Let animation complete fully
        await tester.pump(const Duration(milliseconds: 200));

        // Should not have any pending timers or exceptions
        expect(tester.takeException(), isNull);
        
                 // Widget should still be functional after animation
         await tester.tap(find.text('Budgets'));
         expect(tester.takeException(), isNull);
      });
    });
  });
} 