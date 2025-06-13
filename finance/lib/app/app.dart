import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../core/settings/app_settings.dart';
import '../features/navigation/presentation/bloc/navigation_bloc.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import 'router/app_router.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<NavigationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<SettingsBloc>()..add(const SettingsEvent.loadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(        builder: (context, settingsState) {
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
    );
  }
}