import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/features/home/widgets/account_card.dart';

void main() {
  group('AccountCard', () {
    testWidgets('should call onSelected with correct index when tapped',
        (WidgetTester tester) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountCard(
              title: 'Test Account',
              amount: '\$1,000.00',
              transactions: '5 transactions',
              color: Colors.blue,
              isSelected: false,
              index: 2,
              onSelected: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AccountCard));
      await tester.pump();

      expect(selectedIndex, equals(2));
    });

    testWidgets('should display selected state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountCard(
              title: 'Selected Account',
              amount: '\$1,000.00',
              transactions: '5 transactions',
              color: Colors.blue,
              isSelected: true,
              index: 0,
              onSelected: (index) {},
            ),
          ),
        ),
      );

      // The selected account should have a visible border
      final container = find.byType(AnimatedContainer);
      expect(container, findsOneWidget);

      final animatedContainer = tester.widget<AnimatedContainer>(container);
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.border?.top.color, equals(Colors.blue));
    });

    testWidgets('should display account information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountCard(
              title: 'My Savings Account',
              amount: '\$5,000.00',
              transactions: '25 transactions',
              color: Colors.green,
              isSelected: false,
              index: 1,
              onSelected: (index) {},
            ),
          ),
        ),
      );

      expect(find.text('My Savings Account'), findsOneWidget);
      expect(find.text('\$5,000.00'), findsOneWidget);
      expect(find.text('25 transactions'), findsOneWidget);
    });

    testWidgets('should handle unselected state correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccountCard(
              title: 'Unselected Account',
              amount: '\$2,000.00',
              transactions: '10 transactions',
              color: Colors.red,
              isSelected: false,
              index: 3,
              onSelected: (index) {},
            ),
          ),
        ),
      );

      final container = find.byType(AnimatedContainer);
      expect(container, findsOneWidget);

      final animatedContainer = tester.widget<AnimatedContainer>(container);
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.border?.top.color, equals(Colors.transparent));
    });
  });

  group('AddAccountCard', () {
    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddAccountCard(
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AddAccountCard));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('should display add account UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddAccountCard(
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
    });
  });
}
