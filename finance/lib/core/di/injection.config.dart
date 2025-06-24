// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:finance/core/database/app_database.dart' as _i876;
import 'package:finance/features/accounts/domain/repositories/account_repository.dart'
    as _i151;
import 'package:finance/features/budgets/data/repositories/budget_repository_impl.dart'
    as _i607;
import 'package:finance/features/budgets/data/services/budget_auth_service.dart'
    as _i434;
import 'package:finance/features/budgets/data/services/budget_csv_service.dart'
    as _i886;
import 'package:finance/features/budgets/data/services/budget_filter_service_impl.dart'
    as _i186;
import 'package:finance/features/budgets/data/services/budget_update_service_impl.dart'
    as _i810;
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart'
    as _i687;
import 'package:finance/features/budgets/domain/services/budget_filter_service.dart'
    as _i586;
import 'package:finance/features/budgets/domain/services/budget_update_service.dart'
    as _i379;
import 'package:finance/features/budgets/presentation/bloc/budgets_bloc.dart'
    as _i501;
import 'package:finance/features/categories/domain/repositories/category_repository.dart'
    as _i461;
import 'package:finance/features/navigation/presentation/bloc/navigation_bloc.dart'
    as _i706;
import 'package:finance/features/settings/presentation/bloc/settings_bloc.dart'
    as _i295;
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart'
    as _i1062;
import 'package:finance/features/transactions/presentation/bloc/transactions_bloc.dart'
    as _i196;
import 'package:finance/services/currency_service.dart' as _i121;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i706.NavigationBloc>(() => _i706.NavigationBloc());
    gh.factory<_i295.SettingsBloc>(() => _i295.SettingsBloc());
    gh.factory<_i687.BudgetRepository>(
        () => _i607.BudgetRepositoryImpl(gh<_i876.AppDatabase>()));
    gh.factory<_i196.TransactionsBloc>(() => _i196.TransactionsBloc(
          gh<_i1062.TransactionRepository>(),
          gh<_i461.CategoryRepository>(),
        ));
    gh.factory<_i586.BudgetFilterService>(() => _i186.BudgetFilterServiceImpl(
          gh<_i1062.TransactionRepository>(),
          gh<_i151.AccountRepository>(),
          gh<_i687.BudgetRepository>(),
          gh<_i121.CurrencyService>(),
          gh<_i886.BudgetCsvService>(),
        ));
    gh.factory<_i379.BudgetUpdateService>(() => _i810.BudgetUpdateServiceImpl(
          gh<_i687.BudgetRepository>(),
          gh<_i586.BudgetFilterService>(),
          gh<_i434.BudgetAuthService>(),
        ));
    gh.factory<_i501.BudgetsBloc>(() => _i501.BudgetsBloc(
          gh<_i687.BudgetRepository>(),
          gh<_i379.BudgetUpdateService>(),
          gh<_i586.BudgetFilterService>(),
        ));
    return this;
  }
}
