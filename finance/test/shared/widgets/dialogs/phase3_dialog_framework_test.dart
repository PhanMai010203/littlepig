import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/shared/widgets/dialogs/popup_framework.dart';
import 'package:finance/core/services/dialog_service.dart';
import 'package:finance/shared/widgets/dialogs/bottom_sheet_service.dart';
import 'package:finance/core/settings/app_settings.dart';
import 'package:finance/core/services/platform_service.dart';

void main() {
  group('Phase 3 Dialog Framework Tests', () {
    setUp(() async {
      // Reset settings before each test
      SharedPreferences.setMockInitialValues({});
      await AppSettings.initialize();
    });

    group('PopupFramework Widget', () {
      testWidgets('PopupFramework creates basic popup', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PopupFramework(
                title: 'Test Title',
                child: Text('Test Content'),
              ),
            ),
          ),
        );

        expect(find.byType(PopupFramework), findsOneWidget);
        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('PopupFramework with all components', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PopupFramework(
                title: 'Test Title',
                subtitle: 'Test Subtitle',
                icon: Icons.info,
                showCloseButton: true,
                child: Text('Test Content'),
              ),
            ),
          ),
        );

        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('PopupFramework respects animation settings', (tester) async {
        // Disable animations
        await AppSettings.set('appAnimations', false);
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PopupFramework(
                title: 'Test Title',
                animationType: PopupAnimationType.scaleIn,
                child: Text('Test Content'),
              ),
            ),
          ),
        );

        expect(find.byType(PopupFramework), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('PopupFramework handles different animation types', (tester) async {
        for (final animationType in PopupAnimationType.values) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: PopupFramework(
                  title: 'Test Title',
                  animationType: animationType,
                  child: Text('Test Content ${animationType.name}'),
                ),
              ),
            ),
          );

          expect(find.byType(PopupFramework), findsOneWidget);
          expect(find.text('Test Content ${animationType.name}'), findsOneWidget);
          
          // Clear the widget tree for next iteration
          await tester.pumpWidget(Container());
        }
      });

      testWidgets('PopupFramework extension method works', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Test Content').asPopup(
                title: 'Test Title',
                subtitle: 'Test Subtitle',
                icon: Icons.info,
              ),
            ),
          ),
        );

        expect(find.byType(PopupFramework), findsOneWidget);
        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test Subtitle'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('PopupFramework with custom subtitle widget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PopupFramework(
                title: 'Test Title',
                customSubtitleWidget: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Custom Subtitle'),
                ),
                child: Text('Test Content'),
              ),
            ),
          ),
        );

        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Custom Subtitle'), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('PopupFramework close button functionality', (tester) async {
        bool closeCalled = false;
        void onClosePressedCallback() {
          closeCalled = true;
        }
        
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: PopupFramework(
                title: 'Test Title',
                showCloseButton: true,
                onClosePressed: onClosePressedCallback,
                child: Text('Test Content'),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        
        // Find and tap the close button
        final closeButton = find.byType(IconButton);
        expect(closeButton, findsOneWidget);
        
        // Use tapAt with the center of the button to ensure it's tappable
        final buttonRect = tester.getRect(closeButton);
        await tester.tapAt(buttonRect.center);
        await tester.pump();
        expect(closeCalled, isTrue);
      });
    });

    group('DialogService', () {
      testWidgets('DialogService showPopup works', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    DialogService.showPopup(
                      context,
                      Text('Dialog Content'),
                      title: 'Dialog Title',
                    );
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        // Tap the button to show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Dialog Title'), findsOneWidget);
        expect(find.text('Dialog Content'), findsOneWidget);
      });

      testWidgets('DialogService showConfirmationDialog works', (tester) async {
        bool? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await DialogService.showConfirmationDialog(
                      context,
                      title: 'Confirm Action',
                      message: 'Are you sure?',
                    );
                  },
                  child: Text('Show Confirmation'),
                );
              },
            ),
          ),
        );

        // Tap the button to show confirmation dialog
        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Are you sure?'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Tap confirm
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
      });

      testWidgets('DialogService showInfoDialog works', (tester) async {
        bool? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await DialogService.showInfoDialog(
                      context,
                      title: 'Information',
                      message: 'This is important info.',
                    );
                  },
                  child: Text('Show Info'),
                );
              },
            ),
          ),
        );

        // Tap the button to show info dialog
        await tester.tap(find.text('Show Info'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Information'), findsOneWidget);
        expect(find.text('This is important info.'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        // Tap OK
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
      });

      testWidgets('DialogService showErrorDialog works', (tester) async {
        bool? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await DialogService.showErrorDialog(
                      context,
                      title: 'Error',
                      message: 'Something went wrong.',
                      details: 'Stack trace details here',
                    );
                  },
                  child: Text('Show Error'),
                );
              },
            ),
          ),
        );

        // Tap the button to show error dialog
        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Something went wrong.'), findsOneWidget);
        expect(find.text('Show Details'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        // Tap Show Details
        await tester.tap(find.text('Show Details'));
        await tester.pumpAndSettle();

        // Verify details are shown
        expect(find.text('Hide Details'), findsOneWidget);
        expect(find.text('Stack trace details here'), findsOneWidget);

        // Tap OK
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
      });

      testWidgets('DialogService showLoadingDialog works', (tester) async {
        VoidCallback? dismissCallback;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    dismissCallback = DialogService.showLoadingDialog(
                      context,
                      title: 'Loading',
                      message: 'Please wait...',
                    );
                  },
                  child: Text('Show Loading'),
                );
              },
            ),
          ),
        );

        // Tap the button to show loading dialog
        await tester.tap(find.text('Show Loading'));
        await tester.pump();

        // Verify dialog is shown
        expect(find.text('Loading'), findsOneWidget);
        expect(find.text('Please wait...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Dismiss the dialog
        expect(dismissCallback, isNotNull);
        dismissCallback!();
        await tester.pump();

        // Verify dialog is dismissed
        expect(find.text('Loading'), findsNothing);
      });

      testWidgets('DialogService showCustomDialog works', (tester) async {
        String? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await DialogService.showCustomDialog<String>(
                      context,
                      content: Text('Custom content'),
                      title: 'Custom Dialog',
                      actions: [
                        DialogAction(
                          label: 'Action 1',
                          onPressed: () => 'result1',
                        ),
                        DialogAction(
                          label: 'Action 2',
                          onPressed: () => 'result2',
                          isPrimary: true,
                        ),
                      ],
                    );
                  },
                  child: Text('Show Custom'),
                );
              },
            ),
          ),
        );

        // Tap the button to show custom dialog
        await tester.tap(find.text('Show Custom'));
        await tester.pumpAndSettle();

        // Verify dialog is shown
        expect(find.text('Custom Dialog'), findsOneWidget);
        expect(find.text('Custom content'), findsOneWidget);
        expect(find.text('Action 1'), findsOneWidget);
        expect(find.text('Action 2'), findsOneWidget);

        // Tap Action 2 (primary)
        await tester.tap(find.text('Action 2'));
        await tester.pumpAndSettle();

        expect(result, equals('result2'));
      });

      testWidgets('DialogService animation settings work', (tester) async {
        // Test with animations disabled
        await AppSettings.set('appAnimations', false);
        
        expect(DialogService.areDialogAnimationsEnabled, isFalse);
        expect(DialogService.defaultPopupAnimation, equals(PopupAnimationType.none));

        // Test with animations enabled
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('reduceAnimations', false);
        await AppSettings.set('batterySaver', false);
        await AppSettings.set('animationLevel', 'normal');
        
        expect(DialogService.areDialogAnimationsEnabled, isTrue);
        expect(DialogService.defaultPopupAnimation, isNot(equals(PopupAnimationType.none)));
      });

      testWidgets('DialogService extension methods work', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    final result = await context.showConfirmation(
                      title: 'Confirm',
                      message: 'Are you sure?',
                    );
                  },
                  child: Text('Show Confirmation'),
                );
              },
            ),
          ),
        );

        // Test confirmation dialog display
        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();
        
        // Verify dialog is shown
        expect(find.text('Confirm'), findsWidgets);
        expect(find.text('Are you sure?'), findsOneWidget);
        
        // Test that the dialog framework is working - just verify it displays
        expect(find.byType(Dialog), findsOneWidget);
      });
    });

    group('BottomSheetService', () {
      testWidgets('BottomSheetService showSimpleBottomSheet works', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    BottomSheetService.showSimpleBottomSheet(
                      context,
                      Text('Bottom Sheet Content'),
                      title: 'Bottom Sheet Title',
                    );
                  },
                  child: Text('Show Bottom Sheet'),
                );
              },
            ),
          ),
        );

        // Tap the button to show bottom sheet
        await tester.tap(find.text('Show Bottom Sheet'));
        await tester.pumpAndSettle();

        // Verify bottom sheet is shown
        expect(find.text('Bottom Sheet Title'), findsOneWidget);
        expect(find.text('Bottom Sheet Content'), findsOneWidget);
      });

      testWidgets('BottomSheetService showOptionsBottomSheet works', (tester) async {
        String? selectedOption;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    selectedOption = await BottomSheetService.showOptionsBottomSheet<String>(
                      context,
                      title: 'Select Option',
                      options: [
                        BottomSheetOption(
                          title: 'Option 1',
                          value: 'option1',
                          icon: Icons.star,
                        ),
                        BottomSheetOption(
                          title: 'Option 2',
                          value: 'option2',
                          subtitle: 'With subtitle',
                          icon: Icons.favorite,
                        ),
                        BottomSheetOption(
                          title: 'Disabled Option',
                          value: 'disabled',
                          enabled: false,
                        ),
                      ],
                    );
                  },
                  child: Text('Show Options'),
                );
              },
            ),
          ),
        );

        // Tap the button to show options bottom sheet
        await tester.tap(find.text('Show Options'));
        await tester.pumpAndSettle();

        // Verify bottom sheet is shown
        expect(find.text('Select Option'), findsOneWidget);
        expect(find.text('Option 1'), findsOneWidget);
        expect(find.text('Option 2'), findsOneWidget);
        expect(find.text('With subtitle'), findsOneWidget);
        expect(find.text('Disabled Option'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsOneWidget);

        // Tap on Option 1
        await tester.tap(find.text('Option 1'));
        await tester.pumpAndSettle();

        expect(selectedOption, equals('option1'));
      });

      testWidgets('BottomSheetService showConfirmationBottomSheet works', (tester) async {
        bool? result;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    result = await BottomSheetService.showConfirmationBottomSheet(
                      context,
                      title: 'Confirm Action',
                      message: 'Are you sure you want to proceed?',
                      isDangerous: true,
                    );
                  },
                  child: Text('Show Confirmation'),
                );
              },
            ),
          ),
        );

        // Tap the button to show confirmation bottom sheet
        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();

        // Verify bottom sheet is shown
        expect(find.text('Confirm Action'), findsOneWidget);
        expect(find.text('Are you sure you want to proceed?'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Tap confirm
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
      });

      testWidgets('BottomSheetService animation settings work', (tester) async {
        // Test with animations disabled
        await AppSettings.set('appAnimations', false);
        expect(BottomSheetService.defaultBottomSheetAnimation, equals(BottomSheetAnimationType.none));

        // Test with animations enabled
        await AppSettings.set('appAnimations', true);
        await AppSettings.set('reduceAnimations', false);
        await AppSettings.set('batterySaver', false);
        await AppSettings.set('animationLevel', 'normal');
        
        expect(BottomSheetService.defaultBottomSheetAnimation, isNot(equals(BottomSheetAnimationType.none)));

        // Test reduced animations
        await AppSettings.set('animationLevel', 'reduced');
        expect(BottomSheetService.defaultBottomSheetAnimation, equals(BottomSheetAnimationType.fadeIn));
      });

      testWidgets('BottomSheetService extension methods work', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await context.showBottomSheet<String>(
                          Text('Simple Sheet'),
                          title: 'Simple',
                        );
                      },
                      child: Text('Show Simple Sheet'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await context.showOptions<String>(
                          title: 'Options',
                          options: [
                            BottomSheetOption(title: 'Option A', value: 'a'),
                            BottomSheetOption(title: 'Option B', value: 'b'),
                          ],
                        );
                      },
                      child: Text('Show Options'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await context.showBottomSheetConfirmation(
                          title: 'Confirm',
                          message: 'Are you sure?',
                        );
                      },
                      child: Text('Show Confirmation'),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        // Test simple sheet (dismiss by tapping outside)
        await tester.tap(find.text('Show Simple Sheet'));
        await tester.pumpAndSettle();
        expect(find.text('Simple'), findsOneWidget);
        // Dismiss by tapping outside
        await tester.tapAt(Offset(50, 50));
        await tester.pumpAndSettle();

        // Test options sheet
        await tester.tap(find.text('Show Options'));
        await tester.pumpAndSettle();
        
        expect(find.text('Options'), findsOneWidget);
        expect(find.text('Option A'), findsOneWidget);
        
        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        // Test confirmation sheet
        await tester.tap(find.text('Show Confirmation'));
        await tester.pumpAndSettle();
        
        expect(find.text('Confirm'), findsWidgets);
        expect(find.text('Are you sure?'), findsOneWidget);
        
        // Just verify the bottom sheet framework works
        expect(find.byType(BottomSheet), findsOneWidget);
      });

      testWidgets('BottomSheetOption model works correctly', (tester) async {
        const option = BottomSheetOption(
          title: 'Test Option',
          value: 'test_value',
          subtitle: 'Test subtitle',
          icon: Icons.settings,
          enabled: true,
        );

        expect(option.title, equals('Test Option'));
        expect(option.value, equals('test_value'));
        expect(option.subtitle, equals('Test subtitle'));
        expect(option.icon, equals(Icons.settings));
        expect(option.enabled, isTrue);

        const disabledOption = BottomSheetOption(
          title: 'Disabled Option',
          value: 'disabled_value',
          enabled: false,
        );

        expect(disabledOption.enabled, isFalse);
        expect(disabledOption.subtitle, isNull);
        expect(disabledOption.icon, isNull);
      });
    });

    group('Integration Tests', () {
      testWidgets('Dialog and bottom sheet can be shown together', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    // Show dialog first
                    DialogService.showPopup(
                      context,
                      ElevatedButton(
                        onPressed: () {
                          // Show bottom sheet from dialog
                          BottomSheetService.showSimpleBottomSheet(
                            context,
                            Text('Bottom Sheet from Dialog'),
                          );
                        },
                        child: Text('Show Bottom Sheet'),
                      ),
                      title: 'Dialog with Bottom Sheet',
                    );
                  },
                  child: Text('Show Dialog'),
                );
              },
            ),
          ),
        );

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Dialog with Bottom Sheet'), findsOneWidget);

        // Show bottom sheet from dialog
        await tester.tap(find.text('Show Bottom Sheet'));
        await tester.pumpAndSettle();

        expect(find.text('Bottom Sheet from Dialog'), findsOneWidget);
      });

      testWidgets('Animation settings affect all dialog types', (tester) async {
        // Test with various animation levels
        for (final level in ['none', 'reduced', 'normal', 'enhanced']) {
          await AppSettings.set('animationLevel', level);
          
          // Test that services respect the setting
          final dialogAnimation = DialogService.defaultPopupAnimation;
          final sheetAnimation = BottomSheetService.defaultBottomSheetAnimation;
          
          if (level == 'none') {
            expect(dialogAnimation, equals(PopupAnimationType.none));
            expect(sheetAnimation, equals(BottomSheetAnimationType.none));
          } else {
            expect(dialogAnimation, isNot(equals(PopupAnimationType.none)));
            if (level != 'reduced') {
              expect(sheetAnimation, isNot(equals(BottomSheetAnimationType.none)));
            }
          }
        }
      });

      testWidgets('Platform service integration works', (tester) async {
        // Test that platform detection affects dialog behavior
        final isMobile = PlatformService.isMobile;
        final prefersCentered = PlatformService.prefersCenteredDialogs;
        
        // These should return consistent values
        expect(isMobile, isA<bool>());
        expect(prefersCentered, isA<bool>());
        
        // Test platform info
        final platformInfo = PlatformService.getPlatformInfo();
        expect(platformInfo, isA<Map<String, dynamic>>());
        expect(platformInfo.containsKey('platform'), isTrue);
        expect(platformInfo.containsKey('isMobile'), isTrue);
        expect(platformInfo.containsKey('isDesktop'), isTrue);
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('PopupFramework handles null values gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PopupFramework(
                title: null,
                subtitle: null,
                icon: null,
                child: Text('Content Only'),
              ),
            ),
          ),
        );

        expect(find.byType(PopupFramework), findsOneWidget);
        expect(find.text('Content Only'), findsOneWidget);
      });

      testWidgets('DialogAction with different configurations', (tester) async {
        const primaryAction = DialogAction(
          label: 'Primary',
          isPrimary: true,
          closesDialog: true,
        );
        
        const destructiveAction = DialogAction(
          label: 'Delete',
          isDestructive: true,
          closesDialog: true,
        );
        
        const nonClosingAction = DialogAction(
          label: 'Non-closing',
          closesDialog: false,
        );

        expect(primaryAction.isPrimary, isTrue);
        expect(primaryAction.isDestructive, isFalse);
        expect(primaryAction.closesDialog, isTrue);
        
        expect(destructiveAction.isDestructive, isTrue);
        expect(destructiveAction.isPrimary, isFalse);
        
        expect(nonClosingAction.closesDialog, isFalse);
      });

      testWidgets('BottomSheetService handles empty options list', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    BottomSheetService.showOptionsBottomSheet<String>(
                      context,
                      title: 'Empty Options',
                      options: [],
                    );
                  },
                  child: Text('Show Empty Options'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show Empty Options'));
        await tester.pumpAndSettle();

        expect(find.text('Empty Options'), findsOneWidget);
        // Should show empty content without errors
      });
    });
  });
} 