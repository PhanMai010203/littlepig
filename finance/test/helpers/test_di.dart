import 'package:drift/drift.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/core/services/database_service.dart';

/// Test helper for initializing dependencies with injectable system
/// Uses environment-based DI and ensures test database isolation
Future<void> configureTestDependencies() async {
  // Configure drift to suppress multiple database warnings in tests  
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  
  // Reset dependencies first to avoid conflicts
  await resetDependencies();
  
  // Initialize injectable dependencies with test environment
  // This will use the @Environment('test') providers from RegisterModule
  await configureDependencies('test');
  
  // Additional test isolation: Replace DatabaseService with test version
  // This ensures tests use in-memory database instead of production SQLite
  if (getIt.isRegistered<DatabaseService>()) {
    await getIt.unregister<DatabaseService>();
    getIt.registerLazySingleton<DatabaseService>(() => DatabaseService.forTesting());
  }
}