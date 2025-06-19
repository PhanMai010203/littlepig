import 'package:finance/core/services/dialog_service.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/shared/widgets/animations/fade_in.dart';
import 'package:finance/shared/widgets/dialogs/bottom_sheet_service.dart';
import 'package:finance/shared/widgets/dialogs/popup_framework.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Animation Framework & Dialogs', () {
    setUp(() async {
      // Ensure the binding is initialized
      TestWidgetsFlutterBinding.ensureInitialized();
      // Mock SharedPreferences for AppSettings
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
      // Default settings for tests
      await AppSettings.set('reduceAnimations', false);
      await AppSettings.set('animationLevel', 'normal');
      await AppSettings.set('batterySaver', false);
    });

    tearDown(() async {
      // Clear all settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('FadeIn respects reduceAnimations setting', (tester) async {
      // Enable reduced animations
      await AppSettings.set('reduceAnimations', true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FadeIn(
              child: Container(key: const ValueKey('content'), color: Colors.blue),
            ),
          ),
        ),
      );

      // In reduced animation mode, the widget should be immediately visible
      // and should not build an animation widget.
      await tester.pump(); 

      final finder = find.byKey(const ValueKey('content'));
      expect(finder, findsOneWidget);

      // Expect that no FadeTransition widget is built.
      expect(find.byType(FadeTransition), findsNothing);
    });

    testWidgets('DialogService shows a PopupFramework dialog', (tester) async {
      const dialogTitle = 'Test Dialog';
      const dialogContentText = 'This is a test.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  DialogService.showPopup(
                    context,
                    const Text(dialogContentText),
                    title: dialogTitle,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // pumpAndSettle to allow animations to finish

      // Verify the dialog is shown
      expect(find.byType(PopupFramework), findsOneWidget);
      expect(find.text(dialogTitle), findsOneWidget);
      expect(find.text(dialogContentText), findsOneWidget);
    });

    testWidgets('BottomSheetService shows a custom bottom sheet', (tester) async {
      const sheetTitle = 'Test Bottom Sheet';
      const sheetContentText = 'This is a bottom sheet test.';

       await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  BottomSheetService.showCustomBottomSheet(
                    context,
                    const Text(sheetContentText),
                    title: sheetTitle,
                  );
                },
                child: const Text('Show Bottom Sheet'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to show the bottom sheet
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify the bottom sheet is shown with title and content
      expect(find.text(sheetTitle), findsOneWidget);
      expect(find.text(sheetContentText), findsOneWidget);
    });
  });
} 