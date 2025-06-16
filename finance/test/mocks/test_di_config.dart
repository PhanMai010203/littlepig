import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance/core/services/database_service.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/features/currencies/data/datasources/currency_local_data_source.dart';
import 'package:finance/features/currencies/data/datasources/exchange_rate_remote_data_source.dart';
import 'package:finance/features/currencies/data/datasources/exchange_rate_local_data_source.dart';
import 'package:finance/services/currency_service.dart';
import 'package:finance/shared/utils/currency_formatter.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'mock_currency_local_data_source.dart';
import 'mock_exchange_rate_local_data_source.dart';
import 'mock_exchange_rate_remote_data_source.dart';
import 'mock_account_repository.dart';
import 'test_currency_repository_impl.dart';

Future<void> configureTestDependencies() async {
  final getIt = GetIt.instance;
  
  // Reset GetIt before setting up test dependencies
  await getIt.reset();
  
  // Register SharedPreferences
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Register Database Service (for custom exchange rates storage)
  final databaseService = DatabaseService();
  getIt.registerSingleton<DatabaseService>(databaseService);
  
  // Register Currency Data Sources (using mocks for testing)
  getIt.registerSingleton<CurrencyLocalDataSource>(
    MockCurrencyLocalDataSource(),
  );
  getIt.registerSingleton<ExchangeRateRemoteDataSource>(
    MockExchangeRateRemoteDataSource(),
  );
  getIt.registerSingleton<ExchangeRateLocalDataSource>(
    MockExchangeRateLocalDataSource(),
  );
  
  // Register Account Repository (mock for testing)
  getIt.registerSingleton<AccountRepository>(
    MockAccountRepository(),
  );
    // Register Currency Repository (using test implementation)
  getIt.registerSingleton<CurrencyRepository>(
    TestCurrencyRepositoryImpl(
      getIt<CurrencyLocalDataSource>(),
      getIt<ExchangeRateRemoteDataSource>(),
      getIt<ExchangeRateLocalDataSource>(),
    ),
  );
  
  // Register Currency Service
  getIt.registerSingleton<CurrencyService>(
    CurrencyService(
      getIt<CurrencyRepository>(),
      getIt<AccountRepository>(),
    ),
  );
  
  // Register Currency Formatter
  getIt.registerSingleton<CurrencyFormatter>(
    CurrencyFormatter(),
  );
}
