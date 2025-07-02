import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/accounts/domain/repositories/account_repository.dart';
import '../../features/budgets/domain/repositories/budget_repository.dart';
import '../../features/budgets/domain/services/budget_display_service.dart';
import '../../features/transactions/domain/services/transaction_display_service.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/currencies/domain/repositories/currency_repository.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/navigation/presentation/widgets/main_shell.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/budgets/presentation/pages/budget_create_page.dart';
import '../../features/transactions/presentation/pages/transaction_create_page.dart';
import '../../features/accounts/presentation/pages/account_create_page.dart';
import '../../features/budgets/presentation/bloc/budget_creation_bloc.dart';
import '../../features/accounts/presentation/bloc/account_create_bloc.dart';
import 'app_routes.dart';
import 'page_transitions.dart';
// Add these imports for demo pages
import '../../demo/framework_demo_page.dart';
import '../../demo/demo_transition_pages.dart';


class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.home,
            pageBuilder: (context, state) =>
                AppPageTransitions.noTransitionPage(
              child: HomePage(
                accountRepository: getIt<AccountRepository>(),
                transactionRepository: getIt<TransactionRepository>(),
                currencyRepository: getIt<CurrencyRepository>(),
                budgetRepository: getIt<BudgetRepository>(),
                budgetDisplayService: getIt<BudgetDisplayService>(),
                transactionDisplayService: getIt<TransactionDisplayService>(),
                categoryRepository: getIt<CategoryRepository>(),
              ),
              name: state.name,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: AppRoutes.transactions,
            pageBuilder: (context, state) =>
                AppPageTransitions.noTransitionPage(
              child: const TransactionsPage(),
              name: state.name,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.budgets,
            name: AppRoutes.budgets,
            pageBuilder: (context, state) =>
                AppPageTransitions.noTransitionPage(
              child: const BudgetsPage(),
              name: state.name,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.more,
            name: AppRoutes.more,
            pageBuilder: (context, state) =>
                AppPageTransitions.noTransitionPage(
              child: const MorePage(),
              name: state.name,
              key: state.pageKey,
            ),
          ),
        ],
      ),
      // Non-shell routes with custom transitions
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.settings,
        pageBuilder: (context, state) =>
            AppPageTransitions.platformTransitionPage(
          child: const SettingsPage(),
          name: state.name,
          key: state.pageKey,
        ),
      ),

      // Budget creation page
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.budgetCreate,
        name: AppRoutes.budgetCreate,
        pageBuilder: (context, state) {
          return AppPageTransitions.platformTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => BudgetCreationBloc(
                getIt<AccountRepository>(),
                getIt<CategoryRepository>(),
              ),
              child: const BudgetCreatePage(),
            ),
            name: state.name,
          );
        },
      ),

      // Transaction creation page
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.transactionCreate,
        name: AppRoutes.transactionCreate,
        pageBuilder: (context, state) {
          return AppPageTransitions.platformTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => BudgetCreationBloc(
                getIt<AccountRepository>(),
                getIt<CategoryRepository>(),
              ),
              child: const TransactionCreatePage(),
            ),
            name: state.name,
          );
        },
      ),

      // Account creation page
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.accountCreate,
        name: AppRoutes.accountCreate,
        pageBuilder: (context, state) {
          return AppPageTransitions.platformTransitionPage(
            key: state.pageKey,
            child: const AccountCreatePage(),
            name: state.name,
          );
        },
      ),

      // Example of custom transition routes
      // These demonstrate different transition types available

      // Slide transition example (future transaction details page)
      GoRoute(
        path: '/transaction/:id',
        name: 'transaction_detail',
        pageBuilder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          // This is a placeholder - you would create the actual TransactionDetailPage
          return AppPageTransitions.slideTransitionPage(
            child: _buildPlaceholderPage('Transaction $transactionId'),
            name: state.name,
            key: state.pageKey,
            direction: SlideDirection.fromRight,
          );
        },
      ),

      // Fade transition example (future profile page)
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) {
          return AppPageTransitions.fadeTransitionPage(
            child: _buildPlaceholderPage('Profile'),
            name: state.name,
            key: state.pageKey,
          );
        },
      ),

      // Scale transition example (future add transaction page)
      GoRoute(
        path: '/add-transaction',
        name: 'add_transaction',
        pageBuilder: (context, state) {
          return AppPageTransitions.scaleTransitionPage(
            child: _buildPlaceholderPage('Add Transaction'),
            name: state.name,
            key: state.pageKey,
          );
        },
      ),

      // Slide-fade transition example (future reports page)
      GoRoute(
        path: '/reports',
        name: 'reports',
        pageBuilder: (context, state) {
          return AppPageTransitions.slideFadeTransitionPage(
            child: _buildPlaceholderPage('Reports'),
            name: state.name,
            key: state.pageKey,
            direction: SlideDirection.fromBottom,
          );
        },
      ),

      // Modal slide transition example (settings modal)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings-modal',
        name: 'settings_modal',
        pageBuilder: (context, state) {
          return AppPageTransitions.modalSlideTransitionPage(
            child: _buildPlaceholderPage('Settings Modal'),
            name: state.name,
            key: state.pageKey,
            fullscreenDialog: true,
          );
        },
      ),

      // Subtle slide transition example (notifications)
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) {
          return AppPageTransitions.subtleSlideTransitionPage(
            child: _buildPlaceholderPage('Notifications'),
            name: state.name,
            key: state.pageKey,
            direction: SlideDirection.fromTop,
            slideOffset: 0.05,
          );
        },
      ),

      // Horizontal slide transition example (tab navigation simulation)
      GoRoute(
        path: '/categories',
        name: 'categories',
        pageBuilder: (context, state) {
          return AppPageTransitions.horizontalSlideTransitionPage(
            child: _buildPlaceholderPage('Categories'),
            name: state.name,
            key: state.pageKey,
            fromRight: true,
            slideDistance: 0.3,
          );
        },
      ),
      // Demo framework main page
      GoRoute(
        path: '/demo',
        name: 'framework_demo',
        pageBuilder: (context, state) =>
            AppPageTransitions.platformTransitionPage(
          child: const FrameworkDemoPage(),
          name: state.name,
          key: state.pageKey,
        ),
      ),
      // Demo transition pages
      GoRoute(
        path: '/demo/slide-transition',
        name: 'slide_transition_demo',
        pageBuilder: (context, state) =>
            AppPageTransitions.platformTransitionPage(
          child: const SlideTransitionDemoPage(),
          name: state.name,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/demo/fade-transition',
        name: 'fade_transition_demo',
        pageBuilder: (context, state) =>
            AppPageTransitions.platformTransitionPage(
          child: const FadeTransitionDemoPage(),
          name: state.name,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/demo/scale-transition',
        name: 'scale_transition_demo',
        pageBuilder: (context, state) =>
            AppPageTransitions.platformTransitionPage(
          child: const ScaleTransitionDemoPage(),
          name: state.name,
          key: state.pageKey,
        ),
      ),
      GoRoute(
        path: '/demo/slide-fade-transition',
        name: 'slide_fade_transition_demo',
        pageBuilder: (context, state) =>
            AppPageTransitions.platformTransitionPage(
          child: const SlideFadeTransitionDemoPage(),
          name: state.name,
          key: state.pageKey,
        ),
      ),
    ],
  );

  /// Helper method to build placeholder pages for demonstration
  /// In real implementation, these would be actual page widgets
  static Widget _buildPlaceholderPage(String title) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder page demonstrating\nthe $title transition.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
