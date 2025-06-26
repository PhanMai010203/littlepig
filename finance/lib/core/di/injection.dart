import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';
import 'register_module.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies([String? environment]) async {
  // Check if already initialized to prevent duplicate registration
  if (getIt.isRegistered<String>(instanceName: 'environment')) {
    return;
  }

  // Use injectable for all dependency registration
  await getIt.init(environment: environment);
  
  // Mark as initialized with the environment
  getIt.registerSingleton<String>(environment ?? 'prod', instanceName: 'environment');
}

/// Reset all GetIt registrations (useful for testing or hot reload)
Future<void> resetDependencies() async {
  await getIt.reset();
}

/// Reset all dependencies and re-configure with the desired environment.
///
/// This is a convenience wrapper that lets tests or hot-reload scenarios
/// switch between environments (e.g. `'test'`, `'prod'`, `'dev'`) in a
/// single call.  Production code should typically call
/// `configureDependencies()` once, but tests can do:
///
/// ```dart
/// await configureDependenciesWithReset('test'); // fresh test env
/// ```
///
/// Passing `null` keeps the default `'prod'` environment consistent with
/// [configureDependencies].
Future<void> configureDependenciesWithReset([String? environment]) async {
  await resetDependencies();
  await configureDependencies(environment);
}
