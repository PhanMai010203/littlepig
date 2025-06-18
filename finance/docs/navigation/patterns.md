# Navigation Patterns

This guide covers advanced navigation patterns and custom navigation solutions for complex app flows.

## 📋 Table of Contents

- [Custom Navigation Patterns](#custom-navigation-patterns)
- [Advanced Routing](#advanced-routing)
- [Navigation Guards](#navigation-guards)
- [Nested Navigation](#nested-navigation)
- [Modal Navigation](#modal-navigation)
- [Transition Animations](#transition-animations)
- [Best Practices](#best-practices)

## 🎯 Custom Navigation Patterns

### Tab-Based Navigation with Custom Tabs

```dart
// lib/shared/widgets/custom_tab_bar.dart
class CustomTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<TabItem> items;

  const CustomTabBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          TabItem item = entry.value;
          bool isSelected = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TabItem {
  final IconData icon;
  final String label;
  final String route;

  const TabItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
```

### Drawer Navigation with Custom Design

```dart
// lib/shared/widgets/custom_drawer.dart
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'John Doe',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'john.doe@example.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  route: '/home',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Budget',
                  route: '/budget',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.receipt_long_outlined,
                  title: 'Transactions',
                  route: '/transactions',
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  route: '/settings',
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  route: '/help',
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sign Out',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final isSelected = GoRouter.of(context).location == route;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
```

## 🔀 Advanced Routing

### Route Parameters and Query Strings

```dart
// Advanced route definitions
GoRoute(
  path: '/profile/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    final tab = state.queryParameters['tab'] ?? 'info';
    
    return ProfilePage(
      userId: userId,
      initialTab: tab,
    );
  },
),

// Navigation with parameters
context.go('/profile/123?tab=settings');

// Programmatic navigation with query parameters
context.goNamed(
  'profile',
  pathParameters: {'userId': '123'},
  queryParameters: {'tab': 'settings'},
);
```

### Conditional Routing

```dart
// lib/core/routing/route_guards.dart
class RouteGuard {
  static bool canAccessRoute(String route, BuildContext context) {
    final authService = GetIt.instance<AuthService>();
    
    // Protected routes
    const protectedRoutes = ['/profile', '/settings', '/budget'];
    
    if (protectedRoutes.contains(route)) {
      return authService.isAuthenticated;
    }
    
    return true;
  }
  
  static String? redirect(BuildContext context, GoRouterState state) {
    final authService = GetIt.instance<AuthService>();
    final isAuthenticated = authService.isAuthenticated;
    final isOnAuthPage = state.location.startsWith('/auth');
    
    // Redirect to login if not authenticated and not on auth page
    if (!isAuthenticated && !isOnAuthPage) {
      return '/auth/login';
    }
    
    // Redirect to home if authenticated and on auth page
    if (isAuthenticated && isOnAuthPage) {
      return '/home';
    }
    
    return null;
  }
}

// Apply to router
final router = GoRouter(
  redirect: RouteGuard.redirect,
  routes: [
    // Routes...
  ],
);
```

## 🛡️ Navigation Guards

### Authentication Guard

```dart
// lib/core/routing/auth_guard.dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  final String? redirectTo;

  const AuthGuard({
    Key? key,
    required this.child,
    this.redirectTo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return child;
        } else if (state is AuthUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(redirectTo ?? '/auth/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

// Usage in routes
GoRoute(
  path: '/profile',
  builder: (context, state) => const AuthGuard(
    child: ProfilePage(),
    redirectTo: '/auth/login',
  ),
),
```

### Permission Guard

```dart
// lib/core/routing/permission_guard.dart
class PermissionGuard extends StatelessWidget {
  final Widget child;
  final List<String> requiredPermissions;
  final Widget? fallback;

  const PermissionGuard({
    Key? key,
    required this.child,
    required this.requiredPermissions,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkPermissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data == true) {
          return child;
        }
        
        return fallback ?? const UnauthorizedPage();
      },
    );
  }

  Future<bool> _checkPermissions() async {
    final permissionService = GetIt.instance<PermissionService>();
    
    for (final permission in requiredPermissions) {
      if (!await permissionService.hasPermission(permission)) {
        return false;
      }
    }
    
    return true;
  }
}
```

## 🏗️ Nested Navigation

### Tab-Based Nested Navigation

```dart
// lib/features/main/main_shell.dart
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({Key? key, required this.child}) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _navigateToTab(index);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _navigateToTab(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/budget');
        break;
      case 2:
        context.go('/transactions');
        break;
      case 3:
        context.go('/more');
        break;
    }
  }
}

// Router configuration with shell
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/budget',
          builder: (context, state) => const BudgetPage(),
        ),
        // More routes...
      ],
    ),
  ],
);
```

## 🎭 Modal Navigation

### Custom Modal Routes

```dart
// lib/shared/widgets/custom_modal.dart
class CustomModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    Color? barrierColor,
    Duration? animationDuration,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: animationDuration ?? const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}
```

## 🎬 Transition Animations

### Custom Page Transitions

```dart
// lib/core/routing/custom_transitions.dart
class CustomPageTransition extends CustomTransitionPage {
  const CustomPageTransition({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
    transitionsBuilder: _transitionsBuilder,
    transitionDuration: const Duration(milliseconds: 300),
  );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  }
}

// Different transition types
class FadePageTransition extends CustomTransitionPage {
  const FadePageTransition({
    required super.child,
    required super.name,
    super.arguments,
    super.restorationId,
    super.key,
  }) : super(
    transitionsBuilder: _transitionsBuilder,
    transitionDuration: const Duration(milliseconds: 300),
  );

  static Widget _transitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// Usage in routes
GoRoute(
  path: '/profile',
  pageBuilder: (context, state) => CustomPageTransition(
    name: 'profile',
    child: const ProfilePage(),
  ),
),
```

## ✅ Best Practices

### 1. Navigation State Management

```dart
// lib/core/navigation/navigation_service.dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();

  static BuildContext get context => navigatorKey.currentContext!;

  static Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static void pop<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }

  static Future<T?> pushReplacementNamed<T, TO>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  static Future<T?> pushNamedAndClearStack<T>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
```

### 2. Deep Link Handling

```dart
// lib/core/routing/deep_link_handler.dart
class DeepLinkHandler {
  static void handleInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _processLink(initialLink);
      }
    } catch (e) {
      debugPrint('Failed to handle initial link: $e');
    }
  }

  static void listenForLinks() {
    linkStream.listen(
      (String link) => _processLink(link),
      onError: (err) => debugPrint('Deep link error: $err'),
    );
  }

  static void _processLink(String link) {
    final uri = Uri.parse(link);
    final path = uri.path;
    final queryParams = uri.queryParameters;

    // Route to appropriate page
    if (path.startsWith('/profile/')) {
      final userId = path.split('/')[2];
      context.go('/profile/$userId', extra: queryParams);
    } else if (path == '/settings') {
      context.go('/settings');
    }
    // Add more route handling as needed
  }
}
```

### 3. Navigation Analytics

```dart
// lib/core/routing/navigation_observer.dart
class AnalyticsNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackPageView(route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackPageView(newRoute.settings.name);
    }
  }

  void _trackPageView(String? routeName) {
    if (routeName != null) {
      // Track with your analytics service
      AnalyticsService.trackPageView(routeName);
    }
  }
}
```

## 📚 Related Documentation

- [Navigation Setup](setup.md) - Basic navigation configuration
- [Route Management](routes.md) - Route definitions and management
- [Custom Widgets](../components/custom-widgets.md) - Navigation-related widgets
- [Performance Optimization](../advanced/performance.md) - Navigation performance tips

## 🔗 Quick Links

- [← Back to Navigation](README.md)
- [→ Route Management](routes.md)
- [🏠 Documentation Home](../README.md)
