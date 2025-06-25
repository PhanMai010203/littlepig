import 'package:drift/drift.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/core/services/database_service.dart';
import 'package:finance/core/sync/sync_service.dart';
import 'package:finance/core/sync/incremental_sync_service.dart';

/// Test helper for initializing dependencies with injectable system
/// Replaces the old configureTestDependencies function
Future<void> configureTestDependencies() async {
  // Configure drift to suppress multiple database warnings in tests  
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  
  // Reset dependencies first to avoid conflicts
  await resetDependencies();
  
  // Initialize injectable dependencies (production for now - will handle test env later)
  await configureDependencies();
  
  // For testing, replace DatabaseService with test version after initialization
  if (getIt.isRegistered<DatabaseService>()) {
    getIt.unregister<DatabaseService>();
    getIt.registerSingleton<DatabaseService>(DatabaseService.forTesting());
  }
  
  // Manually register SyncService for testing (since it requires async initialization)
  if (!getIt.isRegistered<SyncService>()) {
    final syncService = IncrementalSyncService(getIt<DatabaseService>().database);
    await syncService.initialize();
    getIt.registerSingleton<SyncService>(syncService);
  }
}