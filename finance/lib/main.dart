import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/utils/bloc_observer.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/material_you.dart';
import 'core/services/platform_service.dart';
import 'shared/widgets/app_lifecycle_manager.dart';
import 'demo/data_seeder.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize app settings system
  await AppSettings.initialize();
  // Initialize Material You system
  await MaterialYouManager.initialize();

  // Configure dependency injection (includes database initialization)
  await configureDependencies();

  // Seed database in debug mode
  if (kDebugMode) {
    await DataSeeder().seedDatabase();
  }

  // Set up Bloc observer for debugging
  Bloc.observer = AppBlocObserver();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set high refresh rate on supported devices
  await PlatformService.setHighRefreshRate();

  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN_HERE'; // Replace with your actual DSN
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.reportPackages = true;
      options.debug = kDebugMode; // Enable debug mode for Sentry in debug builds
    },
    appRunner: () => runApp(
      EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('vi'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: AppLifecycleManager(
          onAppResume: () async {
            await PlatformService.setHighRefreshRate();
          },
          child: const MainApp(),
        ),
      ),
    ),
  );
}
