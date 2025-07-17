// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:http/http.dart' as _i519;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/accounts/data/repositories/account_repository_impl.dart'
    as _i126;
import '../../features/accounts/domain/repositories/account_repository.dart'
    as _i706;
import '../../features/accounts/presentation/bloc/account_create_bloc.dart'
    as _i923;
import '../../features/accounts/presentation/bloc/account_selection_bloc.dart'
    as _i396;
import '../../features/budgets/data/repositories/budget_repository_impl.dart'
    as _i654;
import '../../features/budgets/data/services/budget_auth_service.dart' as _i867;
import '../../features/budgets/data/services/budget_csv_service.dart' as _i871;
import '../../features/budgets/data/services/budget_display_service_impl.dart'
    as _i70;
import '../../features/budgets/data/services/budget_filter_service_impl.dart'
    as _i30;
import '../../features/budgets/data/services/budget_update_service_impl.dart'
    as _i249;
import '../../features/budgets/data/services/budget_update_service_noop.dart'
    as _i171;
import '../../features/budgets/domain/repositories/budget_repository.dart'
    as _i1021;
import '../../features/budgets/domain/services/budget_display_service.dart'
    as _i279;
import '../../features/budgets/domain/services/budget_filter_service.dart'
    as _i375;
import '../../features/budgets/domain/services/budget_update_service.dart'
    as _i527;
import '../../features/budgets/presentation/bloc/budget_creation_bloc.dart'
    as _i408;
import '../../features/budgets/presentation/bloc/budgets_bloc.dart' as _i120;
import '../../features/categories/data/repositories/category_repository_impl.dart'
    as _i894;
import '../../features/categories/domain/repositories/category_repository.dart'
    as _i266;
import '../../features/currencies/data/datasources/currency_local_data_source.dart'
    as _i222;
import '../../features/currencies/data/datasources/exchange_rate_local_data_source.dart'
    as _i349;
import '../../features/currencies/data/datasources/exchange_rate_remote_data_source.dart'
    as _i771;
import '../../features/currencies/data/repositories/currency_repository_impl.dart'
    as _i575;
import '../../features/currencies/data/services/currency_intelligence_service_impl.dart'
    as _i888;
import '../../features/currencies/domain/repositories/currency_repository.dart'
    as _i1056;
import '../../features/currencies/domain/services/currency_intelligence_service.dart'
    as _i91;
import '../../features/currencies/domain/usecases/exchange_rate_operations.dart'
    as _i116;
import '../../features/currencies/domain/usecases/get_currencies.dart' as _i126;
import '../../features/currencies/presentation/bloc/currency_display_bloc.dart'
    as _i653;
import '../../features/more/presentation/bloc/sync_bloc.dart' as _i259;
import '../../features/navigation/presentation/bloc/navigation_bloc.dart'
    as _i162;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../../features/transactions/data/repositories/attachment_repository_impl.dart'
    as _i13;
import '../../features/transactions/data/repositories/transaction_repository_impl.dart'
    as _i443;
import '../../features/transactions/data/services/transaction_display_service_impl.dart'
    as _i533;
import '../../features/transactions/domain/repositories/attachment_repository.dart'
    as _i664;
import '../../features/transactions/domain/repositories/transaction_repository.dart'
    as _i421;
import '../../features/transactions/domain/services/transaction_display_service.dart'
    as _i888;
import '../../features/transactions/presentation/bloc/transaction_create_bloc.dart'
    as _i612;
import '../../features/transactions/presentation/bloc/transactions_bloc.dart'
    as _i439;
import '../../services/currency_service.dart' as _i351;
import '../../services/finance_service.dart' as _i19;
import '../database/app_database.dart' as _i982;
import '../database/migrations/schema_cleanup_migration.dart' as _i201;
import '../events/transaction_event_publisher.dart' as _i388;
import '../services/database_service.dart' as _i665;
import '../services/file_picker_service.dart' as _i108;
import '../sync/crdt_conflict_resolver.dart' as _i588;
import '../sync/google_drive_sync_service.dart' as _i465;
import '../sync/incremental_sync_service.dart' as _i767;
import '../sync/sync_service.dart' as _i520;
import 'register_module.dart' as _i291;

const String _test = 'test';
const String _prod = 'prod';
const String _dev = 'dev';

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i162.NavigationBloc>(() => _i162.NavigationBloc());
    gh.factory<_i585.SettingsBloc>(() => _i585.SettingsBloc());
    gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i183.ImagePicker>(() => registerModule.imagePicker);
    gh.lazySingleton<_i588.CRDTConflictResolver>(
        () => _i588.CRDTConflictResolver());
    gh.lazySingleton<_i388.TransactionEventPublisher>(
        () => _i388.TransactionEventPublisher());
    gh.lazySingleton<_i867.BudgetAuthService>(() => _i867.BudgetAuthService());
    gh.lazySingleton<_i871.BudgetCsvService>(() => _i871.BudgetCsvService());
    gh.lazySingleton<_i222.CurrencyLocalDataSource>(
        () => _i222.CurrencyLocalDataSourceImpl());
    gh.lazySingleton<_i527.BudgetUpdateService>(
      () => _i171.BudgetUpdateServiceNoOp(),
      registerFor: {_test},
    );
    gh.lazySingleton<_i279.BudgetDisplayService>(
        () => _i70.BudgetDisplayServiceImpl());
    gh.lazySingleton<_i349.ExchangeRateLocalDataSource>(
        () => _i349.ExchangeRateLocalDataSourceImpl());
    gh.lazySingleton<_i888.TransactionDisplayService>(
        () => _i533.TransactionDisplayServiceImpl());
    gh.lazySingleton<_i665.DatabaseService>(
      () => registerModule.databaseService,
      registerFor: {
        _prod,
        _dev,
      },
    );
    gh.lazySingleton<_i665.DatabaseService>(
      () => registerModule.testDatabaseService,
      registerFor: {_test},
    );
    gh.lazySingleton<_i982.AppDatabase>(
      () => registerModule.testAppDatabase(gh<_i665.DatabaseService>()),
      registerFor: {_test},
    );
    gh.lazySingleton<_i771.ExchangeRateRemoteDataSource>(
        () => _i771.ExchangeRateRemoteDataSourceImpl(gh<_i519.Client>()));
    gh.lazySingleton<_i982.AppDatabase>(
      () => registerModule.appDatabase(gh<_i665.DatabaseService>()),
      registerFor: {
        _prod,
        _dev,
      },
    );
    gh.lazySingleton<_i1056.CurrencyRepository>(
        () => _i575.CurrencyRepositoryImpl(
              gh<_i222.CurrencyLocalDataSource>(),
              gh<_i771.ExchangeRateRemoteDataSource>(),
              gh<_i349.ExchangeRateLocalDataSource>(),
            ));
    gh.lazySingleton<_i116.ConvertCurrency>(
        () => _i116.ConvertCurrency(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i116.GetExchangeRates>(
        () => _i116.GetExchangeRates(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i116.SetCustomExchangeRate>(
        () => _i116.SetCustomExchangeRate(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i116.RefreshExchangeRates>(
        () => _i116.RefreshExchangeRates(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i126.GetAllCurrencies>(
        () => _i126.GetAllCurrencies(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i126.GetPopularCurrencies>(
        () => _i126.GetPopularCurrencies(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i126.SearchCurrencies>(
        () => _i126.SearchCurrencies(gh<_i1056.CurrencyRepository>()));
    gh.lazySingleton<_i1021.BudgetRepository>(
        () => _i654.BudgetRepositoryImpl(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i706.AccountRepository>(
        () => _i126.AccountRepositoryImpl(gh<_i982.AppDatabase>()));
    await gh.factoryAsync<_i465.GoogleDriveSyncService>(
      () => registerModule.googleDriveSyncService(gh<_i982.AppDatabase>()),
      preResolve: true,
    );
    await gh.factoryAsync<_i767.IncrementalSyncService>(
      () => registerModule.incrementalSyncService(
        gh<_i982.AppDatabase>(),
        gh<_i460.SharedPreferences>(),
      ),
      preResolve: true,
    );
    gh.lazySingleton<_i664.AttachmentRepository>(
        () => _i13.AttachmentRepositoryImpl(
              gh<_i982.AppDatabase>(),
              gh<_i116.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i421.TransactionRepository>(
        () => _i443.TransactionRepositoryImpl(
              gh<_i982.AppDatabase>(),
              gh<_i388.TransactionEventPublisher>(),
            ));
    gh.lazySingleton<_i201.SchemaCleanupMigration>(
        () => _i201.SchemaCleanupMigration(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i266.CategoryRepository>(
        () => _i894.CategoryRepositoryImpl(gh<_i982.AppDatabase>()));
    gh.lazySingleton<_i520.SyncService>(
        () => registerModule.syncService(gh<_i767.IncrementalSyncService>()));
    gh.factory<_i439.TransactionsBloc>(() => _i439.TransactionsBloc(
          gh<_i421.TransactionRepository>(),
          gh<_i266.CategoryRepository>(),
          gh<_i388.TransactionEventPublisher>(),
        ));
    gh.factory<_i408.BudgetCreationBloc>(() => _i408.BudgetCreationBloc(
          gh<_i706.AccountRepository>(),
          gh<_i266.CategoryRepository>(),
        ));
    gh.lazySingleton<_i351.CurrencyService>(() => _i351.CurrencyService(
          gh<_i1056.CurrencyRepository>(),
          gh<_i706.AccountRepository>(),
        ));
    gh.lazySingleton<_i259.SyncBloc>(
        () => _i259.SyncBloc(gh<_i520.SyncService>()));
    gh.lazySingleton<_i108.FilePickerService>(() => _i108.FilePickerService(
          gh<_i664.AttachmentRepository>(),
          gh<_i116.GoogleSignIn>(),
        ));
    gh.factory<_i19.FinanceService>(() => _i19.FinanceService(
          gh<_i421.TransactionRepository>(),
          gh<_i266.CategoryRepository>(),
          gh<_i706.AccountRepository>(),
          gh<_i1021.BudgetRepository>(),
          gh<_i520.SyncService>(),
          gh<_i351.CurrencyService>(),
        ));
    gh.factory<_i653.CurrencyDisplayBloc>(() => _i653.CurrencyDisplayBloc(
          gh<_i351.CurrencyService>(),
          gh<_i1056.CurrencyRepository>(),
          gh<_i706.AccountRepository>(),
        ));
    gh.lazySingleton<_i91.CurrencyIntelligenceService>(
        () => _i888.CurrencyIntelligenceServiceImpl(
              gh<_i351.CurrencyService>(),
              gh<_i706.AccountRepository>(),
            ));
    gh.factory<_i612.TransactionCreateBloc>(() => _i612.TransactionCreateBloc(
          gh<_i421.TransactionRepository>(),
          gh<_i266.CategoryRepository>(),
          gh<_i706.AccountRepository>(),
          gh<_i1021.BudgetRepository>(),
          gh<_i664.AttachmentRepository>(),
        ));
    gh.factory<_i923.AccountCreateBloc>(() => _i923.AccountCreateBloc(
          gh<_i706.AccountRepository>(),
          gh<_i351.CurrencyService>(),
        ));
    gh.lazySingleton<_i375.BudgetFilterService>(
        () => _i30.BudgetFilterServiceImpl(
              gh<_i421.TransactionRepository>(),
              gh<_i706.AccountRepository>(),
              gh<_i1021.BudgetRepository>(),
              gh<_i351.CurrencyService>(),
              gh<_i871.BudgetCsvService>(),
            ));
    gh.lazySingleton<_i527.BudgetUpdateService>(
      () => _i249.BudgetUpdateServiceImpl(
        gh<_i1021.BudgetRepository>(),
        gh<_i375.BudgetFilterService>(),
        gh<_i867.BudgetAuthService>(),
        gh<_i388.TransactionEventPublisher>(),
      ),
      registerFor: {
        _prod,
        _dev,
      },
    );
    gh.factory<_i120.BudgetsBloc>(() => _i120.BudgetsBloc(
          gh<_i1021.BudgetRepository>(),
          gh<_i527.BudgetUpdateService>(),
          gh<_i375.BudgetFilterService>(),
          gh<_i706.AccountRepository>(),
          gh<_i266.CategoryRepository>(),
        ));
    gh.factory<_i396.AccountSelectionBloc>(() => _i396.AccountSelectionBloc(
          gh<_i706.AccountRepository>(),
          gh<_i653.CurrencyDisplayBloc>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
