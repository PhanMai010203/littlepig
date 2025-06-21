# UI Guide: Navigation

This guide covers the navigation system in the Finance App, from basic routing with GoRouter to the advanced adaptive bottom navigation bar.

---

## 🧭 Navigation

Navigation is handled by the **GoRouter** package.

-   **Router Configuration**: `lib/app/router/app_router.dart`
-   **Route Definitions**: `lib/app/router/app_routes.dart`

### Navigating to a New Page

```dart
import 'package:go_router/go_router.dart';
import 'package:finance/app/router/app_routes.dart';

// Navigate to the settings page
context.go(AppRoutes.settings);

// Navigate by name
context.goNamed('settings');

// Navigate with parameters
context.go('/transaction/123');

// Navigate and replace current page
context.pushReplacement(AppRoutes.home);
```

### Page Transitions

The router is configured with custom page transitions. When defining a new route in `app_router.dart`, you can specify the transition type.

-   **Transitions Location**: `lib/app/router/page_transitions.dart`

**Example: Adding a new route with a slide transition**

In `app_router.dart`:

```dart
GoRoute(
  path: '/my-new-page',
  name: 'my-new-page',
  pageBuilder: (context, state) =>
      AppPageTransitions.slideTransitionPage(
    child: const MyNewPage(),
    direction: SlideDirection.fromRight,
  ),
),
```
---

## ### Adaptive Bottom Navigation (Phase 5)

The app provides a highly customizable bottom navigation bar with built-in animations and accessibility support.

-   **Widget Location**: `lib/features/navigation/presentation/widgets/adaptive_bottom_navigation.dart`
-   **Domain Entity**: `lib/features/navigation/domain/entities/navigation_item.dart`

**Basic Usage:**

```dart
import 'package:finance/features/navigation/presentation/widgets/adaptive_bottom_navigation.dart';
import 'package:finance/features/navigation/domain/entities/navigation_item.dart';

final _items = [
  NavigationItem(label: 'home', iconPath: 'assets/icons/icon_home.svg', route: AppRoutes.home),
  NavigationItem(label: 'transactions', iconPath: 'assets/icons/icon_transactions.svg', route: AppRoutes.transactions),
  NavigationItem(label: 'settings', iconPath: 'assets/icons/icon_settings.svg', route: AppRoutes.settings),
];

Scaffold(
  body: _pages[_currentIndex],
  bottomNavigationBar: AdaptiveBottomNavigation(
    currentIndex: _currentIndex,
    items: _items,
    onTap: (index) => setState(() => _currentIndex = index),
    onLongPress: (index) {
      // Optional: open the customization dialog on long-press
    },
  ),
);
```

### Navigation Customization Dialog

Long-pressing a navigation item opens a dialog that lets the user replace it with another available item.

-   **Dialog Content Widget**: `lib/features/navigation/presentation/widgets/navigation_customization_content.dart`
-   **Recommended Invocation** (via `DialogService`):

```dart
import 'package:finance/core/services/dialog_service.dart';
import 'package:finance/features/navigation/presentation/widgets/navigation_customization_content.dart';

void _showNavigationCustomization(BuildContext context, int index) {
  DialogService.showPopup(
    context,
    NavigationCustomizationContent(
      currentIndex: index,
      currentItem: _items[index],
      availableItems: _allItems.where((e) => !_items.contains(e)).toList(),
      onItemSelected: (newItem) {
        setState(() => _items[index] = newItem);
        Navigator.pop(context);
      },
    ),
    title: 'Customize Navigation',
  );
}
```

### Container Transitions (`OpenContainer`)

For seamless transitions between a list item (or card) and a new page, the app uses the `OpenContainer` pattern. This is ideal for "master-detail" views.

-   **Wrapper Widget**: `lib/shared/widgets/transitions/open_container_navigation.dart`

This file provides several helpful abstractions over Flutter's `animations` package `OpenContainer` widget.

**Example 1: Basic `.openContainerNavigation()` extension**

Wrap any widget to make it tap to a new page with a container transform.

```dart
MyWidget(
  // ...
).openContainerNavigation(
  openPage: const MyDetailPage(),
  onOpen: () => print('Transition started!'),
);
```

**Example 2: `OpenContainerCard`**

A pre-styled card that acts as an `OpenContainer`.

```dart
OpenContainerCard(
  openPage: const MyDetailPage(),
  child: const Text('Tap me to see details'),
);
```

**Example 3: `OpenContainerListTile`**

A `ListTile` that acts as an `OpenContainer`.

```dart
OpenContainerListTile(
  openPage: const MyDetailPage(),
  title: const Text('My Item'),
  leading: const Icon(Icons.info),
);
``` 