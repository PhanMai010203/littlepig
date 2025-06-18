# Navigation System

Complete navigation system documentation with GoRouter integration, deep linking, and responsive design patterns.

## 📚 Navigation Guides

### 🏗️ [Setup](setup.md)
Complete navigation system setup with GoRouter, bottom navigation, deep linking, and responsive design.

### 🎨 [Navigation Patterns](patterns.md)
Advanced navigation patterns including custom tabs, drawers, modal navigation, and transition animations.

### 🔀 [Route Management](routes.md)
Advanced route management, configuration, guards, and performance optimization.

## 🎯 Quick Navigation

### Core Concepts
- **Router Configuration** - GoRouter setup and configuration
- **Route Definitions** - Organized route structure
- **Navigation Guards** - Authentication and permission guards
- **Deep Linking** - URL handling and parameter parsing

### Advanced Features
- **Custom Transitions** - Page transition animations
- **Nested Navigation** - Tab-based and hierarchical navigation
- **Modal Navigation** - Bottom sheets and custom modals
- **Route Middleware** - Authentication and permission checks

## 🏃 Quick Start

### Basic Navigation Setup

```dart
// 1. Install dependencies
flutter pub add go_router

// 2. Configure router
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

// 3. Use in MaterialApp
MaterialApp.router(
  routerConfig: router,
)

// 4. Navigate programmatically
context.go('/profile');
context.push('/settings');
```

### Navigation with Parameters

```dart
// Route definition
GoRoute(
  path: '/profile/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return ProfilePage(userId: userId);
  },
),

// Navigation
context.go('/profile/123');
context.goNamed('profile', pathParameters: {'userId': '123'});
```

## 🎨 Navigation Patterns

### Bottom Navigation

```dart
class MainShell extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
```

### Drawer Navigation

```dart
class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => context.go('/home'),
          ),
          // More items...
        ],
      ),
    );
  }
}
```

## 🔐 Authentication Integration

### Protected Routes

```dart
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return child;
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

// Usage
GoRoute(
  path: '/profile',
  builder: (context, state) => const AuthGuard(
    child: ProfilePage(),
  ),
),
```

### Redirect Logic

```dart
final router = GoRouter(
  redirect: (context, state) {
    final isAuthenticated = AuthService.isAuthenticated;
    final isOnAuthPage = state.location.startsWith('/auth');

    if (!isAuthenticated && !isOnAuthPage) {
      return '/auth/login';
    }

    if (isAuthenticated && isOnAuthPage) {
      return '/home';
    }

    return null;
  },
  routes: [...],
);
```

## 🔗 Deep Linking

### URL Structure

```
myapp://                    -> Home page
myapp://profile/123         -> User profile with ID 123
myapp://transaction/456     -> Transaction details
myapp://settings?tab=theme  -> Settings page with theme tab
```

### Implementation

```dart
// Android: android/app/src/main/AndroidManifest.xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="myapp" />
</intent-filter>

// iOS: ios/Runner/Info.plist
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>myapp.deeplink</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

## 📱 Responsive Navigation

### Adaptive Navigation

```dart
class AdaptiveNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop: Navigation rail
          return Row(
            children: [
              NavigationRail(
                destinations: [...],
                selectedIndex: currentIndex,
                onDestinationSelected: onItemTapped,
              ),
              Expanded(child: widget.child),
            ],
          );
        } else {
          // Mobile: Bottom navigation
          return Scaffold(
            body: widget.child,
            bottomNavigationBar: BottomNavigationBar(...),
          );
        }
      },
    );
  }
}
```

## 🎭 Advanced Features

### Custom Page Transitions

```dart
GoRoute(
  path: '/profile',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const ProfilePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
        ),
        child: child,
      );
    },
  ),
),
```

### Modal Navigation

```dart
// Show modal bottom sheet
void showCustomModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const CustomModalContent(),
    ),
  );
}
```

## ✅ Best Practices

### 1. Route Organization
- Group related routes together
- Use consistent naming conventions
- Implement proper error handling
- Add loading states for async routes

### 2. Performance
- Implement lazy loading for heavy pages
- Use shell routes for persistent UI elements
- Preload critical routes
- Monitor navigation performance

### 3. User Experience
- Provide clear navigation feedback
- Implement proper back button handling
- Use appropriate transitions
- Support deep linking throughout the app

### 4. Testing
- Test all navigation flows
- Mock authentication states
- Verify route parameters
- Test error scenarios

## 🔧 Troubleshooting

### Common Issues

**Route not found**
- Check route path spelling
- Verify route is properly registered
- Check for conflicting routes

**Authentication redirect loops**
- Review redirect logic
- Check authentication state management
- Verify route guards

**Deep links not working**
- Check platform configuration
- Verify URL scheme registration
- Test link handling logic

## 📚 Related Documentation

- [Getting Started](../getting-started/README.md) - Project setup and structure
- [Components](../components/README.md) - UI components for navigation
- [Theming](../theming/README.md) - Navigation styling and themes
- [Configuration](../configuration/README.md) - App configuration and settings

## 🔗 Quick Links

- [🏗️ Setup Guide](setup.md) - Basic navigation setup
- [🎨 Navigation Patterns](patterns.md) - Advanced patterns
- [🔀 Route Management](routes.md) - Route configuration
- [🏠 Documentation Home](../README.md)