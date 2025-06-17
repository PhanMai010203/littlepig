import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

import 'injection.config.dart';
import '../services/database_service.dart';
import '../services/file_picker_service.dart';
import '../sync/sync_service.dart';
import '../sync/google_drive_sync_service.dart';

// Repository interfaces
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/repositories/attachment_repository.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/currencies/domain/repositories/currency_repository.dart';

// Repository implementations
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/data/repositories/attachment_repository_impl.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/accounts/data/repositories/account_repository_impl.dart';
import '../../features/budgets/data/repositories/budget_repository_impl.dart';
import '../../features/currencies/data/repositories/currency_repository_impl.dart';

// Currency data sources
import '../../features/currencies/data/datasources/currency_local_data_source.dart';
import '../../features/currencies/data/datasources/exchange_rate_remote_data_source.dart';
import '../../features/currencies/data/datasources/exchange_rate_local_data_source.dart';

// Currency use cases
import '../../features/currencies/domain/usecases/get_currencies.dart';
import '../../features/currencies/domain/usecases/exchange_rate_operations.dart';

// Services
import '../../services/currency_service.dart';

// Budget services
import '../../features/budgets/domain/services/budget_filter_service.dart';
import '../../features/budgets/data/services/budget_filter_service_impl.dart';
import '../../features/budgets/data/services/budget_csv_service.dart';
import '../../features/budgets/domain/services/budget_update_service.dart';
import '../../features/budgets/data/services/budget_update_service_impl.dart';
import '../../features/budgets/data/services/budget_auth_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Check if already initialized to prevent duplicate registration
  if (getIt.isRegistered<DatabaseService>()) {
    return;
  }
  
  // Initialize injectable dependencies FIRST (for existing BLoCs)
  getIt.init();
  
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }
  
  // Get device ID
  final deviceInfo = DeviceInfoPlugin();
  String deviceId;
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor ?? 'unknown-ios';
  } else {
    deviceId = 'unknown-platform';
  }
  
  // Register Database Service with our custom implementation
  final databaseService = DatabaseService();
  getIt.registerSingleton<DatabaseService>(databaseService);
  
  // Register Google Sign In
  final googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/drive.file',
  ]);
  getIt.registerSingleton<GoogleSignIn>(googleSignIn);
  
  // Register basic repositories first (except TransactionRepository which depends on BudgetUpdateService)
  getIt.registerSingleton<AttachmentRepository>(
    AttachmentRepositoryImpl(databaseService.database, googleSignIn),
  );
  getIt.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(databaseService.database),
  );
  getIt.registerSingleton<AccountRepository>(
    AccountRepositoryImpl(databaseService.database),
  );
  getIt.registerSingleton<BudgetRepository>(
    BudgetRepositoryImpl(databaseService.database),
  );
  
  // Register Currency Data Sources
  getIt.registerSingleton<CurrencyLocalDataSource>(
    CurrencyLocalDataSourceImpl(),
  );
  getIt.registerSingleton<ExchangeRateRemoteDataSource>(
    ExchangeRateRemoteDataSourceImpl(httpClient: http.Client()),
  );
  getIt.registerSingleton<ExchangeRateLocalDataSource>(
    ExchangeRateLocalDataSourceImpl(),
  );
  
  // Register Currency Repository
  getIt.registerSingleton<CurrencyRepository>(
    CurrencyRepositoryImpl(
      getIt<CurrencyLocalDataSource>(),
      getIt<ExchangeRateRemoteDataSource>(),
      getIt<ExchangeRateLocalDataSource>(),
    ),
  );
  
  // Register Currency Use Cases
  getIt.registerSingleton<GetAllCurrencies>(
    GetAllCurrencies(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<GetPopularCurrencies>(
    GetPopularCurrencies(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<SearchCurrencies>(
    SearchCurrencies(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<ConvertCurrency>(
    ConvertCurrency(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<GetExchangeRates>(
    GetExchangeRates(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<SetCustomExchangeRate>(
    SetCustomExchangeRate(getIt<CurrencyRepository>()),
  );  getIt.registerSingleton<RefreshExchangeRates>(
    RefreshExchangeRates(getIt<CurrencyRepository>()),
  );
  
  // Register Currency Service
  getIt.registerSingleton<CurrencyService>(
    CurrencyService(
      getIt<CurrencyRepository>(),
      getIt<AccountRepository>(),
    ),
  );
  
  // Register Budget Services (basic services first)
  getIt.registerSingleton<BudgetCsvService>(
    BudgetCsvService(),
  );
  
  // Register Budget Authentication Service (no dependencies)
  getIt.registerSingleton<BudgetAuthService>(
    BudgetAuthService(),
  );
  
  // Create temporary transaction repository for budget filter service (circular dependency workaround)
  getIt.registerSingleton<TransactionRepository>(
    TransactionRepositoryImpl(databaseService.database, deviceId),
  );
  
  getIt.registerSingleton<BudgetFilterService>(
    BudgetFilterServiceImpl(
      getIt<TransactionRepository>(),
      getIt<AccountRepository>(),
      getIt<CurrencyService>(),
      getIt<BudgetCsvService>(),
    ),
  );
  
  // Register Budget Update Service
  getIt.registerSingleton<BudgetUpdateService>(
    BudgetUpdateServiceImpl(
      getIt<BudgetRepository>(),
      getIt<BudgetFilterService>(),
      getIt<BudgetAuthService>(),
    ),
  );
  
  // Re-register TransactionRepository with BudgetUpdateService dependency
  getIt.unregister<TransactionRepository>();
  getIt.registerSingleton<TransactionRepository>(
    TransactionRepositoryImpl(
      databaseService.database, 
      deviceId,
      budgetUpdateService: getIt<BudgetUpdateService>(),
    ),
  );
  
  // Register File Picker Service
  getIt.registerSingleton<FilePickerService>(
    FilePickerService(
      getIt<AttachmentRepository>(),
      getIt<GoogleSignIn>(),
    ),
  );
  
  // Register Sync Service
  final syncService = GoogleDriveSyncService(databaseService.database);
  await syncService.initialize();
  getIt.registerSingleton<SyncService>(syncService);
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

/// Configure dependencies for testing with in-memory database
Future<void> configureTestDependencies() async {
  // Check if already initialized to prevent duplicate registration
  if (getIt.isRegistered<DatabaseService>()) {
    return;
  }
  
  // Initialize injectable dependencies FIRST (for existing BLoCs)
  getIt.init();
  
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  }
  
  // Use test device ID
  const deviceId = 'test-device-id';
  
  // Register Database Service with test implementation (in-memory)
  final databaseService = DatabaseService.forTesting();
  getIt.registerSingleton<DatabaseService>(databaseService);
  
  // Register Google Sign In
  final googleSignIn = GoogleSignIn(scopes: [
    'https://www.googleapis.com/auth/drive.file',
  ]);
  getIt.registerSingleton<GoogleSignIn>(googleSignIn);
  
  // Register basic repositories first (except TransactionRepository which depends on BudgetUpdateService)
  getIt.registerSingleton<AttachmentRepository>(
    AttachmentRepositoryImpl(databaseService.database, googleSignIn),
  );
  getIt.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(databaseService.database),
  );
  getIt.registerSingleton<AccountRepository>(
    AccountRepositoryImpl(databaseService.database),
  );
  getIt.registerSingleton<BudgetRepository>(
    BudgetRepositoryImpl(databaseService.database),
  );
  
  // Register Currency Data Sources
  getIt.registerSingleton<CurrencyLocalDataSource>(
    CurrencyLocalDataSourceImpl(),
  );
  getIt.registerSingleton<ExchangeRateRemoteDataSource>(
    ExchangeRateRemoteDataSourceImpl(httpClient: http.Client()),
  );
  getIt.registerSingleton<ExchangeRateLocalDataSource>(
    ExchangeRateLocalDataSourceImpl(),
  );
  
  // Register Currency Repository
  getIt.registerSingleton<CurrencyRepository>(
    CurrencyRepositoryImpl(
      getIt<CurrencyLocalDataSource>(),
      getIt<ExchangeRateRemoteDataSource>(),
      getIt<ExchangeRateLocalDataSource>(),
    ),
  );
  
  // Register Currency Use Cases
  getIt.registerSingleton<GetAllCurrencies>(
    GetAllCurrencies(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<GetPopularCurrencies>(
    GetPopularCurrencies(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<SearchCurrencies>(
    SearchCurrencies(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<ConvertCurrency>(
    ConvertCurrency(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<GetExchangeRates>(
    GetExchangeRates(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<SetCustomExchangeRate>(
    SetCustomExchangeRate(getIt<CurrencyRepository>()),
  );
  getIt.registerSingleton<RefreshExchangeRates>(
    RefreshExchangeRates(getIt<CurrencyRepository>()),
  );
  
  // Register Currency Service
  getIt.registerSingleton<CurrencyService>(
    CurrencyService(
      getIt<CurrencyRepository>(),
      getIt<AccountRepository>(),
    ),
  );
  
  // Register Budget Services (basic services first)
  getIt.registerSingleton<BudgetCsvService>(
    BudgetCsvService(),
  );
  
  // Register Budget Authentication Service (no dependencies)
  getIt.registerSingleton<BudgetAuthService>(
    BudgetAuthService(),
  );
  
  // Create temporary transaction repository for budget filter service (circular dependency workaround)
  getIt.registerSingleton<TransactionRepository>(
    TransactionRepositoryImpl(databaseService.database, deviceId),
  );
  
  getIt.registerSingleton<BudgetFilterService>(
    BudgetFilterServiceImpl(
      getIt<TransactionRepository>(),
      getIt<AccountRepository>(),
      getIt<CurrencyService>(),
      getIt<BudgetCsvService>(),
    ),
  );
  
  // Register Budget Update Service
  getIt.registerSingleton<BudgetUpdateService>(
    BudgetUpdateServiceImpl(
      getIt<BudgetRepository>(),
      getIt<BudgetFilterService>(),
      getIt<BudgetAuthService>(),
    ),
  );
  
  // Re-register TransactionRepository with BudgetUpdateService dependency
  getIt.unregister<TransactionRepository>();
  getIt.registerSingleton<TransactionRepository>(
    TransactionRepositoryImpl(
      databaseService.database, 
      deviceId,
      budgetUpdateService: getIt<BudgetUpdateService>(),
    ),
  );
  
  // Register File Picker Service
  getIt.registerSingleton<FilePickerService>(
    FilePickerService(
      getIt<AttachmentRepository>(),
      getIt<GoogleSignIn>(),
    ),
  );
  
  // Register Sync Service
  final syncService = GoogleDriveSyncService(databaseService.database);
  await syncService.initialize();
  getIt.registerSingleton<SyncService>(syncService);
}