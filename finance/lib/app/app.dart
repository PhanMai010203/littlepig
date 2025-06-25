import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../features/accounts/domain/repositories/account_repository.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/currencies/domain/repositories/currency_repository.dart';
import '../core/theme/app_theme.dart';
import '../core/settings/app_settings.dart';
import '../features/budgets/presentation/bloc/budgets_bloc.dart';
import '../features/navigation/presentation/bloc/navigation_bloc.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/transactions/presentation/bloc/transactions_bloc.dart';
import 'router/app_router.dart';

/// Main App Provider - Receives dependencies via constructor and passes them to MainApp
class MainAppProvider extends StatelessWidget {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  final CurrencyRepository currencyRepository;
  final NavigationBloc navigationBloc;
  final SettingsBloc settingsBloc;
  final TransactionsBloc transactionsBloc;
  final BudgetsBloc budgetsBloc;

  const MainAppProvider({
    super.key,
    required this.accountRepository,
    required this.transactionRepository,
    required this.currencyRepository,
    required this.navigationBloc,
    required this.settingsBloc,
    required this.transactionsBloc,
    required this.budgetsBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MainApp(
      accountRepository: accountRepository,
      transactionRepository: transactionRepository,
      currencyRepository: currencyRepository,
      navigationBloc: navigationBloc,
      settingsBloc: settingsBloc,
      transactionsBloc: transactionsBloc,
      budgetsBloc: budgetsBloc,
    );
  }
}

/// Main App Widget - Pure widget that receives all dependencies via constructor
class MainApp extends StatefulWidget {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  final CurrencyRepository currencyRepository;
  final NavigationBloc navigationBloc;
  final SettingsBloc settingsBloc;
  final TransactionsBloc transactionsBloc;
  final BudgetsBloc budgetsBloc;

  const MainApp({
    super.key,
    required this.accountRepository,
    required this.transactionRepository,
    required this.currencyRepository,
    required this.navigationBloc,
    required this.settingsBloc,
    required this.transactionsBloc,
    required this.budgetsBloc,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    // Set up callback for theme changes from settings
    AppSettings.setAppStateChangeCallback(() {
      setState(() {
        // This will rebuild the app with new theme settings
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>.value(
          value: widget.accountRepository,
        ),
        RepositoryProvider<TransactionRepository>.value(
          value: widget.transactionRepository,
        ),
        RepositoryProvider<CurrencyRepository>.value(
          value: widget.currencyRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: widget.navigationBloc,
          ),
          BlocProvider.value(
            value: widget.settingsBloc..add(const SettingsEvent.loadSettings()),
          ),
          BlocProvider.value(
            value: widget.transactionsBloc,
          ),
          BlocProvider.value(
            value: widget.budgetsBloc,
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp.router(
              title: 'finance_app'.tr(),
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settingsState.themeMode,
              routerConfig: AppRouter.router,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
            );
          },
        ),
      ),
    );
  }
}
