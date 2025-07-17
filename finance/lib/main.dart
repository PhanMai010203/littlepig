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
import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';
import 'features/budgets/domain/repositories/budget_repository.dart';
import 'features/budgets/domain/services/budget_display_service.dart';
import 'features/currencies/domain/repositories/currency_repository.dart';
import 'features/budgets/presentation/bloc/budgets_bloc.dart';
import 'features/navigation/presentation/bloc/navigation_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/transactions/presentation/bloc/transactions_bloc.dart';
import 'features/more/presentation/bloc/sync_bloc.dart';
import 'features/currencies/presentation/bloc/currency_display_bloc.dart';
import 'features/accounts/presentation/bloc/account_selection_bloc.dart';
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
  // Note: Keeping getIt calls here as main.dart is an acceptable entry point for DI access
  // This is the only place where service locator pattern is used outside of DI configuration
  if (kDebugMode) {
    try {
      final dataSeeder = DataSeeder(
        getIt<AccountRepository>(),
        getIt<CategoryRepository>(),
        getIt<TransactionRepository>(),
        getIt<BudgetRepository>(),
      );
      await dataSeeder.clearAllData();
      await dataSeeder.seedAllData();
    } catch (e) {
      debugPrint('Failed to seed demo data: $e');
    }
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
      options.debug =
          kDebugMode; // Enable debug mode for Sentry in debug builds
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
          child: MainAppProvider(
            accountRepository: getIt<AccountRepository>(),
            transactionRepository: getIt<TransactionRepository>(),
            currencyRepository: getIt<CurrencyRepository>(),
            budgetRepository: getIt<BudgetRepository>(),
            budgetDisplayService: getIt<BudgetDisplayService>(),
            navigationBloc: getIt<NavigationBloc>(),
            settingsBloc: getIt<SettingsBloc>(),
            transactionsBloc: getIt<TransactionsBloc>(),
            budgetsBloc: getIt<BudgetsBloc>(),
            syncBloc: getIt<SyncBloc>(),
            currencyDisplayBloc: getIt<CurrencyDisplayBloc>(),
            accountSelectionBloc: getIt<AccountSelectionBloc>(),
          ),
        ),
      ),
    ),
  );
}
