import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/shared/widgets/dialogs/bottom_sheet_service_v2.dart';

void main() {
  group('BottomSheetServiceV2', () {
    testWidgets('should show simple bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  BottomSheetServiceV2.showSimpleBottomSheet(
                    context,
                    const Text('Test Content'),
                    title: 'Test Sheet',
                  );
                },
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the sheet
      await tester.tap(find.text('Show Sheet'));
      await tester.pumpAndSettle();

      // Verify the sheet content is displayed
      expect(find.text('Test Sheet'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('should show options bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  BottomSheetServiceV2.showOptionsBottomSheet<String>(
                    context,
                    title: 'Choose Option',
                    options: [
                      const BottomSheetOption(
                        title: 'Option 1',
                        value: 'option1',
                        icon: Icons.star,
                      ),
                      const BottomSheetOption(
                        title: 'Option 2',
                        value: 'option2',
                        icon: Icons.favorite,
                      ),
                    ],
                  );
                },
                child: const Text('Show Options'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the options sheet
      await tester.tap(find.text('Show Options'));
      await tester.pumpAndSettle();

      // Verify the options are displayed
      expect(find.text('Choose Option'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should show confirmation bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  BottomSheetServiceV2.showConfirmationBottomSheet(
                    context,
                    title: 'Confirm Action',
                    message: 'Are you sure you want to proceed?',
                    confirmText: 'Yes',
                    cancelText: 'No',
                    icon: Icons.warning,
                  );
                },
                child: const Text('Show Confirmation'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the confirmation sheet
      await tester.tap(find.text('Show Confirmation'));
      await tester.pumpAndSettle();

      // Verify the confirmation dialog content
      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure you want to proceed?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('should handle extension methods', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  context.showSimpleSheetV2(
                    const Text('Extension Test'),
                    title: 'Extension Sheet',
                  );
                },
                child: const Text('Show via Extension'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the sheet via extension
      await tester.tap(find.text('Show via Extension'));
      await tester.pumpAndSettle();

      // Verify the sheet content is displayed
      expect(find.text('Extension Sheet'), findsOneWidget);
      expect(find.text('Extension Test'), findsOneWidget);
    });

    // Note: Private method testing would require making methods public or using @visibleForTesting
    // For now, we'll test the behavior through the public API which exercises these methods
  });
}