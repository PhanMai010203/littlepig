import 'package:drift/drift.dart';
import 'package:finance/core/di/injection.dart';

/// Initializes the dependency injection framework for a test environment.
///
/// This function ensures that all necessary services, repositories, and BLoCs
/// are registered with GetIt using the 'test' environment configuration.
/// It should be called in the `setUp` or `setUpAll` block of a test file.
///
/// It also includes a reset of GetIt before configuration to ensure that
/// tests are hermetic and do not interfere with each other.
Future<void> configureTestDependencies() async {
  // Reset GetIt to ensure a clean slate for each test or test suite
  await getIt.reset();

  // Configure dependencies for the 'test' environment
  await configureDependencies('test');
}