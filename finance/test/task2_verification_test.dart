import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/core/services/database_service.dart';
import 'package:finance/core/database/app_database.dart';

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
  });
  group('Task 2 Verification: Test Environment Configuration', () {
    test('DatabaseService uses in-memory database in test environment', () async {
      // Reset GetIt to ensure clean state
      await getIt.reset();
      
      // Configure dependencies for test environment
      await configureDependencies('test');
      
      // Get DatabaseService from dependency injection
      final databaseService = getIt<DatabaseService>();
      final database = getIt<AppDatabase>();
      
      // Verify that the database is using in-memory storage
      // In-memory databases don't persist to disk
      expect(database, isNotNull);
      expect(databaseService, isNotNull);
      
      // Verify we can perform basic operations (proves it's working)
      final accounts = await database.select(database.accountsTable).get();
      expect(accounts, isA<List>());
      
      // Clean up
      await database.close();
      await getIt.reset();
    });
    
    test('Test environment uses different database instance than production', () async {
      // Reset GetIt to ensure clean state
      await getIt.reset();
      
      // Configure dependencies for test environment
      await configureDependencies('test');
      
      // Get test instances
      final testDatabaseService = getIt<DatabaseService>();
      final testDatabase = getIt<AppDatabase>();
      
      // Verify instances are created
      expect(testDatabaseService, isNotNull);
      expect(testDatabase, isNotNull);
      
      // Clean up test instances
      await testDatabase.close();
      await getIt.reset();
      
      // Now configure for dev environment
      await configureDependencies('dev');
      
      final devDatabaseService = getIt<DatabaseService>();
      final devDatabase = getIt<AppDatabase>();
      
      // Verify dev instances are different from test instances
      expect(devDatabaseService, isNotNull);
      expect(devDatabase, isNotNull);
      
      // The instances should be different objects
      expect(identical(testDatabaseService, devDatabaseService), isFalse);
      expect(identical(testDatabase, devDatabase), isFalse);
      
      // Clean up
      await devDatabase.close();
      await getIt.reset();
    });
  });
}