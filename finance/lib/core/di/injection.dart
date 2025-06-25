import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

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

/// Configure dependencies with reset option
Future<void> configureDependenciesWithReset() async {
  await resetDependencies();
  await configureDependencies();
}
