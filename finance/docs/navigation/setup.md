# 🧭 Navigation Setup

Set up and configure the navigation system in your Flutter application with support for bottom navigation, routing, and deep linking.

## 🎯 Overview

The navigation system provides:
- **Bottom navigation** - Tab-based navigation
- **Named routing** - Clean route management
- **Deep linking** - URL-based navigation
- **Navigation state** - Persistent navigation state
- **Custom transitions** - Smooth page transitions

## 🚀 Basic Setup

### Navigation Configuration
```dart
// lib/core/navigation/navigation_config.dart
class NavigationConfig {
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String transactions = '/transactions';
  static const String budget = '/budget';
  
  static final List<NavigationItem> bottomNavItems = [
    NavigationItem(
      route: home,
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      index: 0,
    ),
    NavigationItem(
      route: transactions,
      label: 'Transactions',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      index: 1,
    ),
    NavigationItem(
      route: budget,
      label: 'Budget',
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
      index: 2,
    ),
    NavigationItem(
      route: profile,
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      index: 3,
    ),
  ];
}

class NavigationItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int index;
  
  const NavigationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.index,
  });
}
```

### Router Setup with GoRouter
```dart
// lib/core/navigation/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'navigation_config.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: NavigationConfig.home,
    routes: [
      // Main navigation shell
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: NavigationConfig.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: NavigationConfig.transactions,
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: NavigationConfig.budget,
            builder: (context, state) => const BudgetPage(),
          ),
          GoRoute(
            path: NavigationConfig.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      
      // Secondary routes (without bottom navigation)
      GoRoute(
        path: NavigationConfig.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      
      // Additional routes with parameters
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) {
          final transactionId = state.pathParameters['id']!;
          return TransactionDetailPage(transactionId: transactionId);
        },
      ),
      
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfilePage(),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => const NotFoundPage(),
    
    // Navigation logging
    redirect: (context, state) {
      print('Navigating to: ${state.uri}');
      return null; // No redirect needed
    },
  );
}
```

### Main Navigation Shell
```dart
// lib/core/navigation/main_navigation_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/themed_navigation_bar.dart';
import 'navigation_config.dart';

class MainNavigationShell extends StatefulWidget {
  final Widget child;
  
  const MainNavigationShell({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: ThemedNavigationBar(
        currentIndex: _currentIndex,
        items: NavigationConfig.bottomNavItems,
        onTap: _onNavItemTapped,
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    final item = NavigationConfig.bottomNavItems[index];
    context.go(item.route);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }
  
  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    final index = NavigationConfig.bottomNavItems
        .indexWhere((item) => item.route == location);
    
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
```

## 🎨 Custom Navigation Bar

### Themed Navigation Bar Widget
```dart
// lib/shared/widgets/themed_navigation_bar.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_text.dart';
import '../../core/navigation/navigation_config.dart';

class ThemedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;
  final bool showLabels;
  
  const ThemedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getColor(context, 'surface'),
        boxShadow: [
          BoxShadow(
            color: getColor(context, 'shadow').withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = currentIndex == item.index;
              return _buildNavItem(context, item, isSelected);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onTap(item.index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with selection indicator
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      color: getColor(context, 'primary').withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected
                    ? getColor(context, 'primary')
                    : getColor(context, 'textLight'),
                size: 24,
              ),
            ),
            
            if (showLabels) ...[
              const SizedBox(height: 4),
              AppText(
                item.label,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                colorName: isSelected ? 'primary' : 'textLight',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Alternative Material 3 Navigation Bar
```dart
// lib/shared/widgets/material_navigation_bar.dart
import 'package:flutter/material.dart';
import '../../core/navigation/navigation_config.dart';

class MaterialNavigationBar extends StatelessWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;
  
  const MaterialNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
```

## 🔄 Navigation State Management

### Navigation State Manager
```dart
// lib/core/navigation/navigation_state_manager.dart
import 'package:flutter/foundation.dart';
import 'navigation_config.dart';

class NavigationStateManager extends ChangeNotifier {
  int _currentIndex = 0;
  String _currentRoute = NavigationConfig.home;
  final List<String> _navigationHistory = [];
  
  int get currentIndex => _currentIndex;
  String get currentRoute => _currentRoute;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  
  void setCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < NavigationConfig.bottomNavItems.length) {
      _currentIndex = index;
      _currentRoute = NavigationConfig.bottomNavItems[index].route;
      _addToHistory(_currentRoute);
      notifyListeners();
    }
  }
  
  void setCurrentRoute(String route) {
    if (route != _currentRoute) {
      _currentRoute = route;
      _updateIndexFromRoute(route);
      _addToHistory(route);
      notifyListeners();
    }
  }
  
  void _updateIndexFromRoute(String route) {
    final index = NavigationConfig.bottomNavItems
        .indexWhere((item) => item.route == route);
    if (index != -1) {
      _currentIndex = index;
    }
  }
  
  void _addToHistory(String route) {
    _navigationHistory.add(route);
    
    // Keep history limited to last 10 routes
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
  }
  
  bool canGoBack() {
    return _navigationHistory.length > 1;
  }
  
  String? getPreviousRoute() {
    if (_navigationHistory.length > 1) {
      return _navigationHistory[_navigationHistory.length - 2];
    }
    return null;
  }
  
  void clearHistory() {
    _navigationHistory.clear();
    notifyListeners();
  }
}
```

### Navigation Provider Integration
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_state_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NavigationStateManager(),
        ),
        // Other providers...
      ],
      child: MaterialApp.router(
        title: 'Navigation Demo',
        routerConfig: AppRouter.router,
      ),
    );
  }
}
```

## 🔗 Deep Linking Support

### URL Strategy Configuration
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  // Remove # from URLs on web
  usePathUrlStrategy();
  runApp(const MyApp());
}
```

### Deep Link Handling
```dart
// lib/core/navigation/deep_link_handler.dart
class DeepLinkHandler {
  static String? handleInitialLink(String? link) {
    if (link == null) return null;
    
    final uri = Uri.parse(link);
    
    // Handle different deep link patterns
    switch (uri.pathSegments.first) {
      case 'transaction':
        if (uri.pathSegments.length > 1) {
          return '/transaction/${uri.pathSegments[1]}';
        }
        break;
      case 'profile':
        return NavigationConfig.profile;
      case 'settings':
        return NavigationConfig.settings;
      default:
        return NavigationConfig.home;
    }
    
    return NavigationConfig.home;
  }
  
  static Map<String, String> extractQueryParameters(String route) {
    final uri = Uri.parse(route);
    return uri.queryParameters;
  }
}
```

### Route Parameters
```dart
// Example: /transaction/123?tab=details
class TransactionDetailPage extends StatelessWidget {
  final String transactionId;
  
  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    // Get query parameters
    final state = GoRouterState.of(context);
    final tab = state.uri.queryParameters['tab'] ?? 'overview';
    
    return PageTemplate(
      title: 'Transaction $transactionId',
      body: TransactionDetailView(
        transactionId: transactionId,
        initialTab: tab,
      ),
    );
  }
}
```

## 🎭 Custom Page Transitions

### Transition Configurations
```dart
// lib/core/navigation/page_transitions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageTransitions {
  // Slide transition
  static Page<T> slideTransition<T extends Object?>(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
              CurveTween(curve: Curves.easeInOutCubic),
            ),
          ),
          child: child,
        );
      },
    );
  }
  
  // Fade transition
  static Page<T> fadeTransition<T extends Object?>(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutQuart).animate(animation),
          child: child,
        );
      },
    );
  }
  
  // Scale transition
  static Page<T> scaleTransition<T extends Object?>(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurveTween(curve: Curves.easeInOutBack).animate(animation),
          child: child,
        );
      },
    );
  }
}
```

### Using Custom Transitions
```dart
// Updated router with transitions
GoRoute(
  path: '/settings',
  pageBuilder: (context, state) {
    return PageTransitions.slideTransition(
      state,
      const SettingsPage(),
    );
  },
),

GoRoute(
  path: '/profile/edit',
  pageBuilder: (context, state) {
    return PageTransitions.fadeTransition(
      state,
      const EditProfilePage(),
    );
  },
),
```

## 📱 Responsive Navigation

### Adaptive Navigation Layout
```dart
// lib/shared/widgets/adaptive_navigation.dart
import 'package:flutter/material.dart';
import '../../core/navigation/navigation_config.dart';

class AdaptiveNavigation extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  
  const AdaptiveNavigation({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile layout
        if (constraints.maxWidth < 768) {
          return Scaffold(
            body: child,
            bottomNavigationBar: ThemedNavigationBar(
              currentIndex: currentIndex,
              items: NavigationConfig.bottomNavItems,
              onTap: onIndexChanged,
            ),
          );
        }
        
        // Tablet/Desktop layout
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: onIndexChanged,
                labelType: NavigationRailLabelType.all,
                destinations: NavigationConfig.bottomNavItems.map((item) {
                  return NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  );
                }).toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
```

### Breakpoint-Based Navigation
```dart
// lib/core/navigation/responsive_navigation.dart
enum ScreenSize { mobile, tablet, desktop }

class ResponsiveNavigation {
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) return ScreenSize.mobile;
    if (width < 1200) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }
  
  static bool shouldShowBottomNavigation(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }
  
  static bool shouldShowNavigationRail(BuildContext context) {
    return getScreenSize(context) != ScreenSize.mobile;
  }
  
  static bool shouldShowDrawer(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }
}
```

## 🔗 Related Documentation

- [Custom Navigation](custom-navigation.md) - Advanced navigation patterns
- [Route Management](route-management.md) - Route configuration and management
- [Components](../components/) - Navigation-related components
- [Getting Started](../getting-started/) - Basic setup and installation

## 📋 Complete Navigation Example

```dart
// Complete navigation setup example
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Main app with complete navigation
class NavigationDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationStateManager(),
      child: MaterialApp.router(
        title: 'Navigation Demo',
        routerConfig: _buildRouter(),
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: NavigationConfig.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return Consumer<NavigationStateManager>(
              builder: (context, navManager, _) {
                return AdaptiveNavigation(
                  currentIndex: navManager.currentIndex,
                  onIndexChanged: (index) {
                    navManager.setCurrentIndex(index);
                    final route = NavigationConfig.bottomNavItems[index].route;
                    context.go(route);
                  },
                  child: child,
                );
              },
            );
          },
          routes: [
            GoRoute(
              path: NavigationConfig.home,
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: NavigationConfig.transactions,
              builder: (context, state) => const TransactionsPage(),
            ),
            GoRoute(
              path: NavigationConfig.budget,
              builder: (context, state) => const BudgetPage(),
            ),
            GoRoute(
              path: NavigationConfig.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
        
        // Modal routes
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            return PageTransitions.slideTransition(
              state,
              const SettingsPage(),
            );
          },
        ),
        
        // Parameterized routes
        GoRoute(
          path: '/transaction/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return TransactionDetailPage(transactionId: id);
          },
        ),
      ],
    );
  }
}

// Usage in pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Home',
      body: Column(
        children: [
          AppText('Welcome to the Home page'),
          
          ElevatedButton(
            onPressed: () => context.go('/settings'),
            child: const Text('Go to Settings'),
          ),
          
          ElevatedButton(
            onPressed: () => context.go('/transaction/123'),
            child: const Text('View Transaction'),
          ),
        ],
      ),
    );
  }
}
```

This navigation setup provides a complete, flexible, and responsive navigation system that works across all platforms while maintaining consistency with your app's theming and design system.
