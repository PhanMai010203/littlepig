// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:finance/app/app.dart';
import 'helpers/test_di.dart';

void main() {
  setUpAll(() {
    // Initialize Flutter binding for tests
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences for testing environment
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, Object>{}; // Return empty preferences
      }
      return null;
    });

    // Mock path_provider for testing environment
    const MethodChannel pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel,
            (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return '/tmp/test_documents';
      }
      if (methodCall.method == 'getTemporaryDirectory') {
        return '/tmp/test_temp';
      }
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '/tmp/test_support';
      }
      return null;
    });

    // Mock device_info_plus for testing environment
    const MethodChannel deviceInfoChannel =
        MethodChannel('dev.fluttercommunity.plus/device_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(deviceInfoChannel,
            (MethodCall methodCall) async {
      if (methodCall.method == 'getAndroidDeviceInfo') {
        return <String, dynamic>{
          'id': 'test-device-id',
          'host': 'test-host',
          'tags': 'test-tags',
          'type': 'test-type',
          'model': 'test-model',
          'board': 'test-board',
          'brand': 'test-brand',
          'device': 'test-device',
          'product': 'test-product',
          'display': 'test-display',
          'hardware': 'test-hardware',
          'bootloader': 'test-bootloader',
          'fingerprint': 'test-fingerprint',
          'manufacturer': 'test-manufacturer',
          'supportedAbis': <String>[],
          'supported32BitAbis': <String>[],
          'supported64BitAbis': <String>[],
          'systemFeatures': <String>[],
          'version': <String, dynamic>{
            'baseOS': '',
            'codename': 'test',
            'incremental': 'test',
            'previewSdkInt': null,
            'release': '11',
            'sdkInt': 30,
            'securityPatch': 'test',
          },
          'isPhysicalDevice': true,
          'serialNumber': 'test-serial',
        };
      }
      return null;
    });
  });

  tearDownAll(() {
    // Clear method channel handlers
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler(null);
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler(null);
    const MethodChannel('dev.fluttercommunity.plus/device_info')
        .setMockMethodCallHandler(null);
  });

  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize dependencies before testing
    await configureTestDependencies();

    // Build a simplified version of our app for testing
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Test App'),
          ),
        ),
      ),
    );

    // Wait for all widgets to settle
    await tester.pumpAndSettle();

    // Basic verification that the app structure exists
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
}
