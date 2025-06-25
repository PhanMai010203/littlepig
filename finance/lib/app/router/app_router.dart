import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/navigation/presentation/widgets/main_shell.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import 'app_routes.dart';
import 'page_transitions.dart';
// Add these imports for demo pages
import '../../demo/framework_demo_page.dart';
import '../../demo/demo_transition_pages.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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
              child: const HomePageProvider(),
              name: state.name,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: AppRoutes.transactions,
            pageBuilder: (context, state) =>
                AppPageTransitions.noTransitionPage(
              child: const TransactionsPageProvider(),
              name: state.name,
              key: state.pageKey,
            ),
          ),
          GoRoute(
            path: AppRoutes.budgets,
            name: AppRoutes.budgets,
            pageBuilder: (context, state) =>
                AppPageTransitions.noTransitionPage(
              child: const BudgetsPageProvider(),
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
