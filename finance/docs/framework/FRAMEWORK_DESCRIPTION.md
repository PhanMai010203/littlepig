# 🧭 Finance App - Navigation & Page Framework Guide

This document provides a comprehensive guide to understanding how the Finance Flutter app handles navigation, page templates, and page management. This framework guide helps developers understand the existing patterns and where to implement new features.

## 🏗️ Architecture Overview

The Finance app uses a sophisticated navigation system built on top of **GoRouter** with **Clean Architecture** principles, **BLoC state management**, and **customizable navigation components**.

```
📱 Navigation Architecture Stack
┌─────────────────────────────────────┐
│          GoRouter (Routing)         │
├─────────────────────────────────────┤
│       MainShell (App Frame)        │
├─────────────────────────────────────┤
│   AdaptiveBottomNavigation (UI)     │
├─────────────────────────────────────┤
│      NavigationBloc (State)        │
├─────────────────────────────────────┤
│    NavigationItem (Entities)       │
├─────────────────────────────────────┤
│      PageTemplate (Layout)         │
└─────────────────────────────────────┘
```

---

## 🛣️ Routing System

### GoRouter Configuration
**Location**: `lib/app/router/app_router.dart`

```dart
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Main navigation routes wrapped in shell
          GoRoute(path: AppRoutes.home, pageBuilder: (context, state) => 
            const NoTransitionPage(child: HomePage())),
          // ... other main routes
        ],
      ),
      // Non-shell routes (outside main navigation)
      GoRoute(path: AppRoutes.settings, builder: (context, state) => 
        const SettingsPage()),
    ],
  );
}
```

### Route Management
**Location**: `lib/app/router/app_routes.dart`

The app uses a centralized route constant system:

```dart
class AppRoutes {
  // Main navigation routes (wrapped in shell)
  static const String home = '/';
  static const String transactions = '/transactions';
  static const String budgets = '/budgets';
  static const String more = '/more';
  
  // Secondary routes (outside shell)
  static const String settings = '/settings';
  
  // Future expansion routes
  static const String goals = '/goals';
  static const String analytics = '/analytics';
  // ... additional routes
}
```

### Key Routing Features:
- **Shell Routes**: Main navigation pages wrapped in `MainShell` for consistent bottom navigation
- **No Transition Pages**: Smooth tab switching without page transitions
- **Secondary Routes**: Full-screen pages outside the main navigation shell
- **Future-Ready**: Pre-defined routes for upcoming features

---

## 🎯 Navigation System

### Navigation State Management
**Location**: `lib/features/navigation/presentation/bloc/`

The navigation system uses **BLoC pattern** for state management:

#### NavigationBloc
```dart
@injectable
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  // Handles navigation index changes
  // Manages navigation customization
  // Replaces navigation items dynamically
}
```

#### Navigation Events
```dart
@freezed
class NavigationEvent with _$NavigationEvent {
  const factory NavigationEvent.navigationIndexChanged(int index);
  const factory NavigationEvent.customizeNavigation(bool isCustomizing);
  const factory NavigationEvent.navigationItemReplaced(int index, NavigationItem newItem);
}
```

#### Navigation State
```dart
@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required int currentIndex,                    // Current selected tab
    required List<NavigationItem> navigationItems, // Customizable navigation items
    required bool isCustomizing,                 // Customization mode flag
  });
}
```

### Navigation Items
**Location**: `lib/features/navigation/domain/entities/navigation_item.dart`

Navigation items are domain entities with complete route and display information:

```dart
class NavigationItem extends Equatable {
  const NavigationItem({
    required this.id,           // Unique identifier
    required this.label,        // Localization key
    required this.iconPath,     // SVG asset path
    required this.routePath,    // GoRouter path
    this.isDefault = false,     // Default navigation item flag
  });
  
  // Pre-defined default items
  static const NavigationItem home = NavigationItem(
    id: 'home',
    label: 'navigation.home',
    iconPath: 'assets/icons/icon_home.svg',
    routePath: '/',
    isDefault: true,
  );
  // ... other default items
  
  // Customizable additional items
  static const List<NavigationItem> allItems = [
    home, transactions, budgets, more, goals, analytics, profile, notifications,
  ];
}
```

### Customizable Navigation Features:
- **Dynamic Tab Replacement**: Long-press any tab to replace with different navigation item
- **Extensible Items**: Pre-defined additional navigation items for future features
- **Persistent Customization**: Navigation preferences persist across app sessions
- **Localization Support**: All navigation labels use translation keys

---

## 🖼️ MainShell Component

### Shell Architecture
**Location**: `lib/features/navigation/presentation/widgets/main_shell.dart`

The `MainShell` is the main application frame that wraps all primary navigation pages:

```dart
class MainShell extends StatelessWidget {
  final Widget child;  // Current page content
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: child,                    // Page content area
          bottomNavigationBar: AdaptiveBottomNavigation(
            currentIndex: state.currentIndex,
            items: state.navigationItems,
            onTap: (index) {
              // Update navigation state
              context.read<NavigationBloc>().add(
                NavigationEvent.navigationIndexChanged(index),
              );
              // Navigate to selected route
              context.go(state.navigationItems[index].routePath);
            },
            onLongPress: (index) {
              // Show customization dialog
              _showCustomizationDialog(context, index, state);
            },
          ),
        );
      },
    );
  }
}
```

### Shell Features:
- **Consistent Layout**: All main pages share the same navigation framework
- **State Integration**: Connected to NavigationBloc for state management
- **Route Synchronization**: Automatically syncs navigation state with routing
- **Customization UI**: Built-in navigation customization dialogs

---

## 📱 AdaptiveBottomNavigation

### Advanced Navigation UI
**Location**: `lib/features/navigation/presentation/widgets/adaptive_bottom_navigation.dart`

The bottom navigation component features advanced animations and interactions:

#### Key Features:
- **Smooth Animations**: Sliding indicator with easing curves
- **Bounce Effects**: Touch feedback with scale animations
- **Customization Support**: Long-press navigation items to replace
- **SVG Icon Support**: Uses `flutter_svg` for crisp icon rendering
- **Theme Integration**: Respects Material You design system

#### Animation System:
```dart
class _AdaptiveBottomNavigationState extends State<AdaptiveBottomNavigation>
    with TickerProviderStateMixin {
  
  // Scale animations for bounce effect
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;
  
  // Sliding indicator animation
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  
  void _animateIndicator(int from, int to) {
    _indicatorAnimation = Tween<double>(
      begin: from.toDouble(),
      end: to.toDouble(),
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeInOutCubic,
    ));
    _indicatorController.forward(from: 0.0);
  }
}
```

---

## 📄 Page Template System

### Shared Page Layout
**Location**: `lib/shared/widgets/page_template.dart`

The `PageTemplate` provides a consistent layout structure for all pages:

```dart
class PageTemplate extends StatelessWidget {
  const PageTemplate({
    this.title,                     // Optional app bar title
    required this.body,             // Main content area
    this.actions,                   // App bar actions
    this.floatingActionButton,      // FAB
    this.backgroundColor,           // Custom background color
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      appBar: title != null ? AppBar(
        title: Text(title!, style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        )),
        actions: actions,
        elevation: 0,
        scrolledUnderElevation: 1,
      ) : null,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
```

### Template Features:
- **Optional App Bar**: Can be omitted for custom header layouts
- **Theme Integration**: Automatic color scheme and typography
- **Material Design 3**: Supports elevation and scroll-under effects
- **Consistent Styling**: Standardized title styling and spacing

---

## 🎨 Page Implementation Patterns

### Pattern 1: Standard Template Usage
**Example**: `TransactionsPage` (`lib/features/transactions/presentation/pages/transactions_page.dart`)

```dart
class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'navigation.transactions'.tr(),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) => _buildTransactionItem(index),
      ),
    );
  }
}
```

### Pattern 2: Custom Layout (No Template)
**Example**: `HomePage` (`lib/features/home/presentation/pages/home_page.dart`)

```dart
class HomePage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      // No title - custom header layout
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _CustomHeader(),
            _WelcomeCard(),
            _QuickActions(),
            _OverviewCards(),
            _RecentActivity(),
          ],
        ),
      ),
    );
  }
}
```

### Pattern 3: Direct Scaffold (Non-Shell Routes)
**Example**: `BudgetsPage` (`lib/features/budgets/presentation/pages/budgets_page.dart`)

```dart
class BudgetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('navigation.budgets'.tr()),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        // Custom content implementation
      ),
    );
  }
}
```

---

## 🔧 Integration with Clean Architecture

### App-Level Integration
**Location**: `lib/app/app.dart`

The navigation system integrates with the broader app architecture:

```dart
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<NavigationBloc>()),
        BlocProvider(create: (context) => getIt<SettingsBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp.router(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settingsState.themeMode,
            routerConfig: AppRouter.router,         // Navigation integration
            // ... localization setup
          );
        },
      ),
    );
  }
}
```

### Dependency Injection
The navigation system is integrated with the DI container:

```dart
// In injection.dart
@injectable
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> { ... }
```

---

## 📋 Implementation Guidelines

### For New Pages in Existing Features:

1. **Create Page Widget**:
   ```dart
   // lib/features/{feature}/presentation/pages/{page}_page.dart
   class NewPage extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return PageTemplate(
         title: 'page.title'.tr(),
         body: // Your content here,
       );
     }
   }
   ```

2. **Add Route Definition**:
   ```dart
   // In app_routes.dart
   static const String newPage = '/new-page';
   ```

3. **Register Route**:
   ```dart
   // In app_router.dart - add to ShellRoute or as standalone route
   GoRoute(
     path: AppRoutes.newPage,
     name: AppRoutes.newPage,
     pageBuilder: (context, state) => const NoTransitionPage(child: NewPage()),
   ),
   ```

### For New Navigation Items:

1. **Define Navigation Item**:
   ```dart
   // In navigation_item.dart
   static const NavigationItem newItem = NavigationItem(
     id: 'new_item',
     label: 'navigation.new_item',
     iconPath: 'assets/icons/icon_new_item.svg',
     routePath: '/new-item',
   );
   ```

2. **Add to Available Items**:
   ```dart
   // Update allItems list in navigation_item.dart
   static const List<NavigationItem> allItems = [
     // ... existing items
     newItem,
   ];
   ```

3. **Add Translation**:
   ```json
   // In assets/translations/en.json
   {
     "navigation": {
       "new_item": "New Item"
     }
   }
   ```

### For Secondary/Modal Pages:

1. **Create Outside Shell Route**:
   ```dart
   // In app_router.dart - outside ShellRoute
   GoRoute(
     path: AppRoutes.secondaryPage,
     name: AppRoutes.secondaryPage,
     builder: (context, state) => const SecondaryPage(),
   ),
   ```

2. **Navigate Using Context**:
   ```dart
   // Navigate to secondary page
   context.push(AppRoutes.secondaryPage);
   
   // Or replace current route
   context.go(AppRoutes.secondaryPage);
   ```

---

## 🎯 Key Architectural Benefits

### 🔄 Modularity
- **Clean Separation**: Navigation logic separated from business logic
- **Feature Independence**: Each feature manages its own pages
- **Reusable Components**: Shared page template and navigation widgets

### 🎨 Consistency
- **Unified Styling**: Consistent theming across all pages
- **Standardized Patterns**: Clear page implementation patterns
- **Material Design 3**: Modern design system integration

### 🚀 Scalability
- **Easy Page Addition**: Simple process to add new pages
- **Dynamic Navigation**: Customizable navigation items
- **Route Management**: Centralized route configuration

### 🧪 Testability
- **BLoC Pattern**: Testable navigation state management
- **Dependency Injection**: Mockable navigation components
- **Isolated Logic**: Separate navigation business logic

### 🌐 Internationalization
- **Localized Navigation**: All navigation items support i18n
- **Dynamic Labels**: Navigation labels change with locale
- **RTL Support**: Proper right-to-left language support

---

## 🎬 Animation & Dialog Framework

The Finance app includes a sophisticated, performance-aware animation and dialog framework designed to create a consistent, high-quality user experience.

### 🎯 Core Principles
- **Performance First**: Animations are optimized to run smoothly on a wide range of devices. The framework includes a battery saver mode and performance scaling.
- **Consistency**: Provides a shared library of animations and dialogs to ensure a uniform look and feel across the app.
- **Customizability**: Allows for easy customization of animations and dialogs while maintaining consistency.

### 🚀 Animation System

The animation system is managed by `AnimationPerformanceService` and exposed through `AnimationUtils`.

#### AnimationPerformanceService
**Location**: `lib/core/services/animation_performance_service.dart`

This service is the brain of the animation system. It centralizes all performance-related logic:
- **Animation Levels**: Defines different levels of animation complexity ('none', 'reduced', 'normal', 'enhanced').
- **Performance-based Scaling**: Adjusts animation durations and complexity based on real-time performance metrics.
- **Battery Saver Integration**: Drastically reduces or disables animations when battery saver is active.

#### AnimationUtils
**Location**: `lib/shared/widgets/animations/animation_utils.dart`

This utility class is the primary entry point for using animations in the UI. It provides simple, high-level methods to:
- Get optimized durations and curves.
- Check if animations should play.
- Create performance-aware `AnimationController`s.

#### Animation Widgets
**Location**: `lib/shared/widgets/animations/`

A rich library of pre-built animation widgets is available:
- **Entry Animations**: `FadeIn`, `ScaleIn`, `SlideIn` for staggered list item entrances.
- **Interactive Animations**: `TappableWidget` for touch feedback, `ShakeAnimation` for errors.
- **Effect Animations**: `BouncingWidget`, `BreathingWidget` for engaging effects.
- **Transition Animations**: `AnimatedExpanded`, `ScaledAnimatedSwitcher` for smooth content transitions.

### ポップアップ Dialog & Popup System

#### DialogService & BottomSheetService
**Location**: `lib/core/services/dialog_service.dart`, `lib/shared/widgets/dialogs/bottom_sheet_service.dart`

These services provide a simple API to show dialogs and bottom sheets:
- `DialogService.showPopup()`: Shows a platform-adaptive dialog.
- `BottomSheetService.showCustomBottomSheet()`: Shows a customizable bottom sheet with snap points.

#### PopupFramework
**Location**: `lib/shared/widgets/dialogs/popup_framework.dart`

This widget provides a consistent UI template for all popups and bottom sheets, ensuring they match the app's theme and design language.

### Transitions

#### Page Transitions
**Location**: `lib/app/router/page_transitions.dart`

The routing system uses custom page transitions that are aware of the animation settings, providing smooth slide and fade transitions between pages.

#### OpenContainerNavigation
**Location**: `lib/shared/widgets/transitions/open_container_navigation.dart`

Implements the Material 3 "Open Container" transform pattern for seamless transitions from a list item or card to a detail page.

### 📊 Performance Monitoring
**Location**: `lib/shared/widgets/animations/animation_performance_monitor.dart`

A real-time performance monitor can be enabled in debug builds to display key animation metrics, helping developers diagnose performance issues. It can be added to any widget using the `.withPerformanceMonitor()` extension.

---

## 🔮 Future Expansion

### Planned Features:
- **Deep Linking**: URL-based navigation to specific pages
- **Nested Navigation**: Tab-specific navigation stacks
- **Page Transitions**: Custom animation between pages
- **Breadcrumb Navigation**: Hierarchical navigation paths
- **Gesture Navigation**: Swipe-based navigation
- **Navigation Analytics**: Track user navigation patterns

### Extension Points:
- **Custom Navigation Items**: Plugin system for navigation extensions
- **Theme-Based Navigation**: Different navigation styles per theme
- **Context-Aware Navigation**: Navigation adapts to user context
- **Accessibility Features**: Enhanced navigation for accessibility

---

This framework provides a solid foundation for navigation and page management in the Finance app, enabling rapid development while maintaining consistency and scalability. New developers can quickly understand the patterns and contribute effectively to the codebase. 