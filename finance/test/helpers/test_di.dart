import 'package:drift/drift.dart';
import 'package:finance/core/di/injection.dart';

/// Test helper for initializing dependencies with injectable system
/// Uses environment-based DI and ensures test database isolation
Future<void> configureTestDependencies() async {
  // Configure drift to suppress multiple database warnings in tests  
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  
  // Reset dependencies first to avoid conflicts
  await resetDependencies();
  
  // Initialize injectable dependencies with test environment
  // The @Environment('test') providers in RegisterModule automatically provide
  // the test database and other test-specific implementations
  await configureDependencies('test');
}