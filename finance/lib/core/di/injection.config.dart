// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
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
    gh.factory<_i196.TransactionsBloc>(() => _i196.TransactionsBloc(
          gh<_i1062.TransactionRepository>(),
          gh<_i461.CategoryRepository>(),
        ));
    return this;
  }
}
