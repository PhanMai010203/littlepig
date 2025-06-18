# Route Management

This guide covers advanced route management, configuration, and best practices for organizing your app's navigation structure.

## 📋 Table of Contents

- [Route Organization](#route-organization)
- [Route Configuration](#route-configuration)
- [Dynamic Routes](#dynamic-routes)
- [Route Guards & Middleware](#route-guards--middleware)
- [Error Handling](#error-handling)
- [Route Testing](#route-testing)
- [Performance Optimization](#performance-optimization)

## 🗂️ Route Organization

### Structured Route Definitions

```dart
// lib/core/routing/app_routes.dart
class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  
  // Parameterized routes
  static const String userProfile = '/profile/:userId';
  static const String transactionDetail = '/transaction/:transactionId';
  static const String budgetCategory = '/budget/category/:categoryId';
  
  // Nested routes
  static const String budgetOverview = '/budget';
  static const String budgetCategories = '/budget/categories';
  static const String budgetHistory = '/budget/history';
}

// lib/core/routing/route_config.dart
class RouteConfig {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    observers: [
      AnalyticsNavigationObserver(),
    ],
    redirect: _handleRedirect,
    errorBuilder: _errorBuilder,
    routes: [
      // Auth routes
      ..._authRoutes,
      
      // Main app routes
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          ..._homeRoutes,
          ..._budgetRoutes,
          ..._transactionRoutes,
          ..._profileRoutes,
          ..._settingsRoutes,
        ],
      ),
      
      // Standalone routes
      ..._standaloneRoutes,
    ],
  );

  // Auth routes group
  static List<RouteBase> get _authRoutes => [
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
  ];

  // Home routes group
  static List<RouteBase> get _homeRoutes => [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ];

  // Budget routes group
  static List<RouteBase> get _budgetRoutes => [
    GoRoute(
      path: AppRoutes.budgetOverview,
      name: 'budget',
      builder: (context, state) => const BudgetPage(),
      routes: [
        GoRoute(
          path: 'categories',
          name: 'budget_categories',
          builder: (context, state) => const BudgetCategoriesPage(),
          routes: [
            GoRoute(
              path: ':categoryId',
              name: 'budget_category_detail',
              builder: (context, state) {
                final categoryId = state.pathParameters['categoryId']!;
                return BudgetCategoryDetailPage(categoryId: categoryId);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'history',
          name: 'budget_history',
          builder: (context, state) => const BudgetHistoryPage(),
        ),
      ],
    ),
  ];

  // Error handling
  static Widget _errorBuilder(BuildContext context, GoRouterState state) {
    return ErrorPage(
      error: state.error,
      routePath: state.location,
    );
  }

  // Global redirect logic
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authService = GetIt.instance<AuthService>();
    final isAuthenticated = authService.isAuthenticated;
    final isOnAuthPage = state.location.startsWith('/auth') || 
                        state.location == AppRoutes.onboarding;

    // Handle authentication redirects
    if (!isAuthenticated && !isOnAuthPage && state.location != AppRoutes.splash) {
      return AppRoutes.login;
    }

    if (isAuthenticated && isOnAuthPage) {
      return AppRoutes.home;
    }

    // Handle onboarding
    final hasSeenOnboarding = authService.hasSeenOnboarding;
    if (!hasSeenOnboarding && state.location != AppRoutes.onboarding) {
      return AppRoutes.onboarding;
    }

    return null;
  }
}
```

### Route Extensions

```dart
// lib/core/routing/route_extensions.dart
extension GoRouterExtension on GoRouter {
  void pushAndClearStack(String path) {
    while (canPop()) {
      pop();
    }
    pushReplacement(path);
  }

  void pushAndRemoveUntil(String path, String untilPath) {
    pushReplacement(path);
  }
}

extension BuildContextRouting on BuildContext {
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go(AppRoutes.home);
    }
  }

  void goToHome() {
    go(AppRoutes.home);
  }

  void goToProfile([String? userId]) {
    if (userId != null) {
      go('/profile/$userId');
    } else {
      go(AppRoutes.profile);
    }
  }

  void goToLogin() {
    go(AppRoutes.login);
  }

  void logout() {
    // Clear any cached data
    GetIt.instance<AuthService>().logout();
    
    // Navigate to login and clear stack
    go(AppRoutes.login);
  }
}
```

## ⚙️ Route Configuration

### Advanced Route Configuration

```dart
// lib/core/routing/route_builder.dart
class RouteBuilder {
  static GoRoute buildAuthRoute({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) {
        // Add analytics tracking
        AnalyticsService.trackPageView(name);
        
        // Check if user is already authenticated
        final authService = GetIt.instance<AuthService>();
        if (authService.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.home);
          });
          return const SizedBox.shrink();
        }
        
        return builder(context, state);
      },
      routes: routes,
    );
  }

  static GoRoute buildProtectedRoute({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<String> requiredPermissions = const [],
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) {
        return AuthGuard(
          requiredPermissions: requiredPermissions,
          child: Builder(
            builder: (context) {
              // Track page view
              AnalyticsService.trackPageView(name);
              return builder(context, state);
            },
          ),
        );
      },
      routes: routes,
    );
  }

  static GoRoute buildPublicRoute({
    required String path,
    required String name,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) {
        // Track page view
        AnalyticsService.trackPageView(name);
        return builder(context, state);
      },
      routes: routes,
    );
  }
}
```

### Route Middleware

```dart
// lib/core/routing/route_middleware.dart
abstract class RouteMiddleware {
  Future<bool> canActivate(BuildContext context, GoRouterState state);
  Widget? handle(BuildContext context, GoRouterState state);
}

class AuthMiddleware implements RouteMiddleware {
  @override
  Future<bool> canActivate(BuildContext context, GoRouterState state) async {
    final authService = GetIt.instance<AuthService>();
    return authService.isAuthenticated;
  }

  @override
  Widget? handle(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

class PermissionMiddleware implements RouteMiddleware {
  final List<String> requiredPermissions;

  PermissionMiddleware(this.requiredPermissions);

  @override
  Future<bool> canActivate(BuildContext context, GoRouterState state) async {
    final permissionService = GetIt.instance<PermissionService>();
    
    for (final permission in requiredPermissions) {
      if (!await permissionService.hasPermission(permission)) {
        return false;
      }
    }
    
    return true;
  }

  @override
  Widget? handle(BuildContext context, GoRouterState state) {
    return const UnauthorizedPage();
  }
}

// Middleware wrapper
class MiddlewareRoute extends GoRoute {
  final List<RouteMiddleware> middleware;

  MiddlewareRoute({
    required super.path,
    required super.name,
    required Widget Function(BuildContext, GoRouterState) originalBuilder,
    required this.middleware,
    super.routes,
  }) : super(
    builder: (context, state) => _MiddlewareWrapper(
      middleware: middleware,
      builder: originalBuilder,
      context: context,
      state: state,
    ),
  );
}

class _MiddlewareWrapper extends StatelessWidget {
  final List<RouteMiddleware> middleware;
  final Widget Function(BuildContext, GoRouterState) builder;
  final BuildContext context;
  final GoRouterState state;

  const _MiddlewareWrapper({
    required this.middleware,
    required this.builder,
    required this.context,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkMiddleware(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return builder(context, state);
        }

        // Find the first middleware that failed and use its handler
        return FutureBuilder<Widget?>(
          future: _getFailedMiddlewareHandler(),
          builder: (context, handlerSnapshot) {
            return handlerSnapshot.data ?? const UnauthorizedPage();
          },
        );
      },
    );
  }

  Future<bool> _checkMiddleware() async {
    for (final middleware in middleware) {
      if (!await middleware.canActivate(context, state)) {
        return false;
      }
    }
    return true;
  }

  Future<Widget?> _getFailedMiddlewareHandler() async {
    for (final middleware in middleware) {
      if (!await middleware.canActivate(context, state)) {
        return middleware.handle(context, state);
      }
    }
    return null;
  }
}
```

## 🎯 Dynamic Routes

### Parameter Validation

```dart
// lib/core/routing/route_validators.dart
class RouteValidators {
  static bool isValidUserId(String userId) {
    return RegExp(r'^\d+$').hasMatch(userId);
  }

  static bool isValidUuid(String uuid) {
    return RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
        .hasMatch(uuid);
  }

  static bool isValidSlug(String slug) {
    return RegExp(r'^[a-z0-9-]+$').hasMatch(slug);
  }
}

// Usage in routes
GoRoute(
  path: '/user/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    
    if (!RouteValidators.isValidUserId(userId)) {
      return const NotFoundPage();
    }
    
    return UserProfilePage(userId: userId);
  },
),
```

### Route Generation

```dart
// lib/core/routing/route_generator.dart
class RouteGenerator {
  static String generateUserProfileRoute(String userId) {
    return '/profile/$userId';
  }

  static String generateTransactionRoute(String transactionId, {String? tab}) {
    final base = '/transaction/$transactionId';
    return tab != null ? '$base?tab=$tab' : base;
  }

  static String generateBudgetCategoryRoute(String categoryId) {
    return '/budget/category/$categoryId';
  }

  static Map<String, String> parseTransactionRoute(String route) {
    final uri = Uri.parse(route);
    final segments = uri.pathSegments;
    
    if (segments.length >= 2 && segments[0] == 'transaction') {
      return {
        'transactionId': segments[1],
        'tab': uri.queryParameters['tab'] ?? 'details',
      };
    }
    
    return {};
  }
}
```

## 🛡️ Route Guards & Middleware

### Advanced Authentication Guard

```dart
// lib/core/routing/advanced_auth_guard.dart
class AdvancedAuthGuard extends StatelessWidget {
  final Widget child;
  final List<String> requiredRoles;
  final List<String> requiredPermissions;
  final String? redirectTo;
  final bool requireEmailVerification;

  const AdvancedAuthGuard({
    Key? key,
    required this.child,
    this.requiredRoles = const [],
    this.requiredPermissions = const [],
    this.redirectTo,
    this.requireEmailVerification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          _redirectToLogin(context);
          return const LoadingPage();
        }

        return FutureBuilder<bool>(
          future: _checkPermissions(state.user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingPage();
            }

            if (snapshot.data == true) {
              return child;
            }

            return const UnauthorizedPage();
          },
        );
      },
    );
  }

  Future<bool> _checkPermissions(User user) async {
    // Check email verification
    if (requireEmailVerification && !user.isEmailVerified) {
      return false;
    }

    // Check roles
    if (requiredRoles.isNotEmpty) {
      final hasRequiredRole = requiredRoles.any(user.roles.contains);
      if (!hasRequiredRole) return false;
    }

    // Check permissions
    if (requiredPermissions.isNotEmpty) {
      final permissionService = GetIt.instance<PermissionService>();
      for (final permission in requiredPermissions) {
        if (!await permissionService.hasPermission(permission)) {
          return false;
        }
      }
    }

    return true;
  }

  void _redirectToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(redirectTo ?? AppRoutes.login);
    });
  }
}
```

## 🚨 Error Handling

### Custom Error Pages

```dart
// lib/shared/pages/error_pages.dart
class ErrorPage extends StatelessWidget {
  final Object? error;
  final String? routePath;

  const ErrorPage({
    Key? key,
    this.error,
    this.routePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorType = _getErrorType();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getErrorTitle(errorType)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getErrorIcon(errorType),
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                _getErrorTitle(errorType),
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _getErrorMessage(errorType),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Go Home'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () => context.goBack(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 32),
                ExpansionTile(
                  title: const Text('Debug Info'),
                  children: [
                    Text('Route: $routePath'),
                    Text('Error: $error'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  ErrorType _getErrorType() {
    if (error is GoException) {
      final goError = error as GoException;
      if (goError.message.contains('not found')) {
        return ErrorType.notFound;
      }
    }
    return ErrorType.general;
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.notFound:
        return 'Page Not Found';
      case ErrorType.unauthorized:
        return 'Unauthorized Access';
      case ErrorType.general:
        return 'Something Went Wrong';
    }
  }

  String _getErrorMessage(ErrorType type) {
    switch (type) {
      case ErrorType.notFound:
        return 'The page you\'re looking for doesn\'t exist or has been moved.';
      case ErrorType.unauthorized:
        return 'You don\'t have permission to access this page.';
      case ErrorType.general:
        return 'An unexpected error occurred. Please try again later.';
    }
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.unauthorized:
        return Icons.lock;
      case ErrorType.general:
        return Icons.error_outline;
    }
  }
}

enum ErrorType { notFound, unauthorized, general }
```

## 🧪 Route Testing

### Route Testing Utilities

```dart
// test/helpers/route_test_helper.dart
class RouteTestHelper {
  static Widget createTestApp({
    required Widget child,
    String initialLocation = '/',
  }) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => child,
          ),
        ],
      ),
    );
  }

  static Future<void> navigateAndSettle(
    WidgetTester tester,
    String path,
  ) async {
    final context = tester.element(find.byType(MaterialApp));
    context.go(path);
    await tester.pumpAndSettle();
  }

  static void expectRoute(String expectedRoute) {
    final context = navigatorKey.currentContext!;
    final currentRoute = GoRouter.of(context).location;
    expect(currentRoute, equals(expectedRoute));
  }
}

// test/routing/route_test.dart
void main() {
  group('Route Tests', () {
    testWidgets('should navigate to profile page', (tester) async {
      await tester.pumpWidget(
        RouteTestHelper.createTestApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.go('/profile/123'),
                child: const Text('Go to Profile'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();

      RouteTestHelper.expectRoute('/profile/123');
    });

    testWidgets('should redirect unauthenticated user to login', (tester) async {
      // Mock authentication service
      final mockAuthService = MockAuthService();
      when(mockAuthService.isAuthenticated).thenReturn(false);
      GetIt.instance.registerSingleton<AuthService>(mockAuthService);

      await tester.pumpWidget(
        RouteTestHelper.createTestApp(
          initialLocation: '/profile',
          child: const ProfilePage(),
        ),
      );

      await tester.pumpAndSettle();

      RouteTestHelper.expectRoute('/auth/login');
    });
  });
}
```

## ⚡ Performance Optimization

### Lazy Loading Routes

```dart
// lib/core/routing/lazy_routes.dart
class LazyRoutes {
  static GoRoute createLazyRoute({
    required String path,
    required String name,
    required Future<Widget> Function() pageBuilder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      name: name,
      builder: (context, state) => FutureBuilder<Widget>(
        future: pageBuilder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError) {
            return ErrorPage(error: snapshot.error);
          }
          
          return snapshot.data!;
        },
      ),
      routes: routes,
    );
  }
}

// Usage
static List<RouteBase> get _budgetRoutes => [
  LazyRoutes.createLazyRoute(
    path: '/budget',
    name: 'budget',
    pageBuilder: () async {
      // Lazy load the page
      await Future.delayed(const Duration(milliseconds: 100));
      return const BudgetPage();
    },
  ),
];
```

### Route Preloading

```dart
// lib/core/routing/route_preloader.dart
class RoutePreloader {
  static final Map<String, Widget> _preloadedPages = {};

  static void preloadRoute(String routeName, Widget Function() builder) {
    if (!_preloadedPages.containsKey(routeName)) {
      _preloadedPages[routeName] = builder();
    }
  }

  static Widget? getPreloadedPage(String routeName) {
    return _preloadedPages[routeName];
  }

  static void clearPreloadedPages() {
    _preloadedPages.clear();
  }

  static void preloadCriticalRoutes() {
    preloadRoute('home', () => const HomePage());
    preloadRoute('profile', () => const ProfilePage());
    preloadRoute('settings', () => const SettingsPage());
  }
}
```

## 📚 Related Documentation

- [Navigation Setup](setup.md) - Basic navigation setup
- [Navigation Patterns](patterns.md) - Advanced navigation patterns
- [Performance Optimization](../advanced/performance.md) - App performance tips
- [Testing Guide](../advanced/testing.md) - Testing navigation

## 🔗 Quick Links

- [← Navigation Patterns](patterns.md)
- [→ Configuration Overview](../configuration/README.md)
- [🏠 Documentation Home](../README.md)
