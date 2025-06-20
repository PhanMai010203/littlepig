import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/core/sync/sync_service.dart';
import 'package:finance/core/services/database_service.dart';

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

  tearDownAll(() async {
    // Clear method channel handlers
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler(null);
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler(null);
    const MethodChannel('dev.fluttercommunity.plus/device_info')
        .setMockMethodCallHandler(null);
  });

  group('Dependency Injection Tests', () {
    test('should configure dependencies without errors', () async {
      // Arrange - ensure clean state
      await resetDependencies();

      // Act
      await configureTestDependencies();

      // Assert - no exceptions should be thrown
      expect(getIt.isRegistered<DatabaseService>(), isTrue);
      expect(getIt.isRegistered<TransactionRepository>(), isTrue);
      expect(getIt.isRegistered<CategoryRepository>(), isTrue);
      expect(getIt.isRegistered<AccountRepository>(), isTrue);
      expect(getIt.isRegistered<BudgetRepository>(), isTrue);
      expect(getIt.isRegistered<SyncService>(), isTrue);
    });

    test('should handle multiple configuration calls gracefully', () async {
      // Arrange - ensure clean state
      await resetDependencies();

      // Act - call configure multiple times
      await configureTestDependencies();
      await configureTestDependencies(); // This should not throw
      await configureTestDependencies(); // This should not throw either

      // Assert - services should still be registered
      expect(getIt.isRegistered<DatabaseService>(), isTrue);
      expect(getIt.isRegistered<TransactionRepository>(), isTrue);
    });

    test('should reset and reconfigure dependencies', () async {
      // Arrange
      await resetDependencies();
      await configureTestDependencies();
      expect(getIt.isRegistered<DatabaseService>(), isTrue);

      // Act
      await configureTestDependencies();

      // Assert
      expect(getIt.isRegistered<DatabaseService>(), isTrue);
      expect(getIt.isRegistered<TransactionRepository>(), isTrue);
    });

    tearDown(() async {
      // Clean up after each test
      await resetDependencies();
    });
  });
}
