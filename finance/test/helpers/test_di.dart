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
/// **DEPRECATED** – Prefer using [configureDependenciesWithReset] directly in
/// tests to avoid an extra layer of indirection. This helper remains for
/// backwards-compatibility but will be removed in a future release.
@Deprecated('Use configureDependenciesWithReset("test") instead')
Future<void> configureTestDependencies() async {
  // Configure dependencies for the 'test' environment with a clean slate
  await configureDependenciesWithReset('test');
}