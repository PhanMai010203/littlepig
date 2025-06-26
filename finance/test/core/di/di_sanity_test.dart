import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/di/injection.dart';

// Core services
import 'package:finance/core/services/database_service.dart';
import 'package:finance/core/database/app_database.dart';
import 'package:finance/core/sync/sync_service.dart';
import 'package:finance/services/currency_service.dart';

// Repositories
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/features/transactions/domain/repositories/attachment_repository.dart';

// BLoCs
import 'package:finance/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:finance/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finance/features/navigation/presentation/bloc/navigation_bloc.dart';
import 'package:finance/features/settings/presentation/bloc/settings_bloc.dart';

// Budget services  
import 'package:finance/features/budgets/domain/services/budget_filter_service.dart';
import 'package:finance/features/budgets/domain/services/budget_update_service.dart';
import 'package:finance/features/budgets/data/services/budget_auth_service.dart';
import 'package:finance/features/budgets/data/services/budget_csv_service.dart';

// Test helper
import '../../helpers/test_di.dart';

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
          'version': <String, dynamic>{
            'release': '11',
            'sdkInt': 30,
          },
          'isPhysicalDevice': true,
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

  group('Phase 4: DI System Sanity Tests', () {
    setUp(() async {
      // Ensure clean state before each test
      await resetDependencies();
    });

    tearDown(() async {
      // Clean up after each test
      await resetDependencies();
    });

    group('4.1: Critical Dependencies Verification', () {
      test('should register all critical BLoCs', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Verify all critical BLoCs are registered
        expect(getIt.isRegistered<BudgetsBloc>(), isTrue,
            reason: 'BudgetsBloc must be registered - critical for budget functionality');
        expect(getIt.isRegistered<TransactionsBloc>(), isTrue,
            reason: 'TransactionsBloc must be registered - critical for transaction functionality');
        expect(getIt.isRegistered<NavigationBloc>(), isTrue,
            reason: 'NavigationBloc must be registered - critical for app navigation');
        expect(getIt.isRegistered<SettingsBloc>(), isTrue,
            reason: 'SettingsBloc must be registered - critical for app settings');
      });

      test('should register all critical repositories', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Verify all repositories are registered
        expect(getIt.isRegistered<TransactionRepository>(), isTrue,
            reason: 'TransactionRepository must be registered');
        expect(getIt.isRegistered<CategoryRepository>(), isTrue,
            reason: 'CategoryRepository must be registered');
        expect(getIt.isRegistered<AccountRepository>(), isTrue,
            reason: 'AccountRepository must be registered');
        expect(getIt.isRegistered<BudgetRepository>(), isTrue,
            reason: 'BudgetRepository must be registered');
        expect(getIt.isRegistered<CurrencyRepository>(), isTrue,
            reason: 'CurrencyRepository must be registered');
        expect(getIt.isRegistered<AttachmentRepository>(), isTrue,
            reason: 'AttachmentRepository must be registered');
      });

      test('should register all core services', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Verify core services are registered
        expect(getIt.isRegistered<DatabaseService>(), isTrue,
            reason: 'DatabaseService must be registered - critical for data persistence');
        expect(getIt.isRegistered<AppDatabase>(), isTrue,
            reason: 'AppDatabase must be registered - critical for database operations');
        expect(getIt.isRegistered<SyncService>(), isTrue,
            reason: 'SyncService must be registered - critical for data synchronization');
        expect(getIt.isRegistered<CurrencyService>(), isTrue,
            reason: 'CurrencyService must be registered - critical for currency operations');
      });

      test('should register all budget-specific services', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Verify budget services are registered
        expect(getIt.isRegistered<BudgetFilterService>(), isTrue,
            reason: 'BudgetFilterService must be registered - critical for budget filtering');
        expect(getIt.isRegistered<BudgetUpdateService>(), isTrue,
            reason: 'BudgetUpdateService must be registered - critical for budget updates');
        expect(getIt.isRegistered<BudgetAuthService>(), isTrue,
            reason: 'BudgetAuthService must be registered - needed for budget security');
        expect(getIt.isRegistered<BudgetCsvService>(), isTrue,
            reason: 'BudgetCsvService must be registered - needed for budget export');
      });
    });

    group('4.2: Environment-Specific Tests', () {
      test('should use test environment configuration correctly', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Verify we're in test environment
        final databaseService = getIt<DatabaseService>();
        expect(databaseService, isNotNull,
            reason: 'DatabaseService should be available in test environment');

        // Test environment should use in-memory database
        final database = getIt<AppDatabase>();
        expect(database, isNotNull,
            reason: 'AppDatabase should be available in test environment');
      });

      test('should handle environment switching correctly', () async {
        // Arrange - Start with test environment
        await configureTestDependencies();
        expect(getIt.isRegistered<DatabaseService>(), isTrue);

        // Act - Reset and configure again (simulating environment change)
        await resetDependencies();
        await configureTestDependencies();

        // Assert - Services should still be registered correctly
        expect(getIt.isRegistered<DatabaseService>(), isTrue);
        expect(getIt.isRegistered<BudgetsBloc>(), isTrue);
        expect(getIt.isRegistered<TransactionsBloc>(), isTrue);
      });

      test('should handle multiple configurations gracefully', () async {
        // Arrange & Act - Call configure multiple times
        await configureTestDependencies();
        await configureTestDependencies(); // Should not throw
        await configureTestDependencies(); // Should not throw

        // Assert - All services should still be available
        expect(getIt.isRegistered<DatabaseService>(), isTrue);
        expect(getIt.isRegistered<BudgetsBloc>(), isTrue);
      });
    });

    group('4.3: Dependency Resolution Chain Tests', () {
      test('should resolve complex dependency chains for BudgetsBloc', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - BudgetsBloc should resolve with all its dependencies
        expect(() => getIt<BudgetsBloc>(), returnsNormally,
            reason: 'BudgetsBloc should resolve with all dependencies');

        final budgetsBloc = getIt<BudgetsBloc>();
        expect(budgetsBloc, isNotNull,
            reason: 'BudgetsBloc instance should be created successfully');
      });

      test('should resolve complex dependency chains for TransactionsBloc', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - TransactionsBloc should resolve with all its dependencies
        expect(() => getIt<TransactionsBloc>(), returnsNormally,
            reason: 'TransactionsBloc should resolve with all dependencies');

        final transactionsBloc = getIt<TransactionsBloc>();
        expect(transactionsBloc, isNotNull,
            reason: 'TransactionsBloc instance should be created successfully');
      });

      test('should resolve service dependencies correctly', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Services should resolve their repository dependencies
        expect(() => getIt<BudgetUpdateService>(), returnsNormally,
            reason: 'BudgetUpdateService should resolve with repository dependencies');
        expect(() => getIt<BudgetFilterService>(), returnsNormally,
            reason: 'BudgetFilterService should resolve with repository dependencies');
      });

      test('should resolve repository dependencies correctly', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Repositories should resolve their database dependencies
        expect(() => getIt<TransactionRepository>(), returnsNormally,
            reason: 'TransactionRepository should resolve with database dependencies');
        expect(() => getIt<BudgetRepository>(), returnsNormally,
            reason: 'BudgetRepository should resolve with database dependencies');
      });
    });

    group('4.4: Error Scenario & Edge Case Tests', () {
      test('should handle rapid reset/configure cycles', () async {
        // Act & Assert - Rapid cycles should not cause issues
        for (int i = 0; i < 5; i++) {
          await resetDependencies();
          await configureTestDependencies();
          expect(getIt.isRegistered<DatabaseService>(), isTrue,
              reason: 'Services should be available after cycle $i');
        }
      });

      test('should handle accessing services after reset', () async {
        // Arrange
        await configureTestDependencies();
        expect(getIt.isRegistered<DatabaseService>(), isTrue);

        // Act
        await resetDependencies();

        // Assert - Services should not be registered after reset
        expect(getIt.isRegistered<DatabaseService>(), isFalse,
            reason: 'Services should not be registered after reset');
      });

      test('should handle configuration without reset', () async {
        // Arrange - Configure once
        await configureTestDependencies();
        final firstCallSucceeded = getIt.isRegistered<DatabaseService>();

        // Act - Configure again without reset (should be graceful)
        await configureTestDependencies();

        // Assert - Should still work correctly
        expect(firstCallSucceeded, isTrue);
        expect(getIt.isRegistered<DatabaseService>(), isTrue,
            reason: 'Services should remain available after duplicate configuration');
      });
    });

    group('4.5: Performance & Memory Tests', () {
      test('should initialize DI system efficiently', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await configureTestDependencies();

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'DI initialization should complete within 5 seconds');
      });

      test('should handle multiple service resolutions efficiently', () async {
        // Arrange
        await configureTestDependencies();
        final stopwatch = Stopwatch()..start();

        // Act - Resolve services multiple times
        for (int i = 0; i < 100; i++) {
          getIt<DatabaseService>();
          getIt<BudgetsBloc>();
          getIt<TransactionsBloc>();
        }

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Service resolution should be fast');
      });

      test('should cleanup properly during reset cycles', () async {
        // Act & Assert - Multiple reset cycles should not accumulate memory issues
        for (int i = 0; i < 10; i++) {
          await configureTestDependencies();
          
          // Verify services are available
          expect(getIt.isRegistered<DatabaseService>(), isTrue);
          expect(getIt.isRegistered<BudgetsBloc>(), isTrue);
          
          await resetDependencies();
          
          // Verify services are cleaned up
          expect(getIt.isRegistered<DatabaseService>(), isFalse);
          expect(getIt.isRegistered<BudgetsBloc>(), isFalse);
        }
      });
    });

    group('4.6: System Integration Tests', () {
      test('should provide complete end-to-end dependency chain', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - Full chain: UI -> BLoC -> Service -> Repository -> Database
        final database = getIt<AppDatabase>();
        final budgetRepo = getIt<BudgetRepository>();
        final budgetService = getIt<BudgetUpdateService>();
        final budgetsBloc = getIt<BudgetsBloc>();

        expect(database, isNotNull, reason: 'Database layer should be available');
        expect(budgetRepo, isNotNull, reason: 'Repository layer should be available');
        expect(budgetService, isNotNull, reason: 'Service layer should be available');
        expect(budgetsBloc, isNotNull, reason: 'BLoC layer should be available');
      });

      test('should support all major application features', () async {
        // Arrange & Act
        await configureTestDependencies();

        // Assert - All major feature areas should have their dependencies
        // Transactions feature
        expect(getIt.isRegistered<TransactionsBloc>(), isTrue);
        expect(getIt.isRegistered<TransactionRepository>(), isTrue);

        // Budgets feature
        expect(getIt.isRegistered<BudgetsBloc>(), isTrue);
        expect(getIt.isRegistered<BudgetRepository>(), isTrue);

        // Accounts feature
        expect(getIt.isRegistered<AccountRepository>(), isTrue);

        // Categories feature
        expect(getIt.isRegistered<CategoryRepository>(), isTrue);

        // Currency feature
        expect(getIt.isRegistered<CurrencyRepository>(), isTrue);
        expect(getIt.isRegistered<CurrencyService>(), isTrue);

        // Navigation & Settings
        expect(getIt.isRegistered<NavigationBloc>(), isTrue);
        expect(getIt.isRegistered<SettingsBloc>(), isTrue);
      });
    });
  });
}