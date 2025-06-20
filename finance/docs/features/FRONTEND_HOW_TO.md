# Frontend Development Guide

This guide is for frontend developers working on the Finance App. It focuses on the UI layer, reusable components, and the overall frontend framework, without needing to dive into the data or domain layers.

---

## 🏛️ Frontend Architecture Overview

The frontend is built following Clean Architecture principles. As a frontend developer, you will primarily work within the **Presentation Layer**.

-   **Location**: `lib/features/`
-   **Structure per Feature**:
    -   `presentation/pages/`: Contains the main screen widgets.
    -   `presentation/widgets/`: Contains UI components specific to that feature.
    -   `presentation/bloc/`: Handles state management for the feature using the BLoC pattern.

You will use shared components and services from the `lib/shared/` and `lib/core/` directories.

> **📝 Note**: Some feature directories may be sparse as the app is actively being developed. The architecture is in place and ready for new features.

---

## 🎨 Theming

The application has a robust theming system that supports light/dark modes and Material You dynamic colors.

-   **Theme Definition**: `lib/core/theme/app_theme.dart`
-   **Color Definitions**: `lib/core/theme/app_colors.dart`
-   **Text Style Definitions**: `lib/core/theme/app_text_theme.dart`

### Using Colors

Always use colors from the theme rather than hardcoding them. You can access the `ColorScheme` or the custom `AppColors` extension.

**Example: Accessing `ColorScheme`**

```dart
import 'package:finance/core/theme/app_colors.dart';

// Access primary color from the theme
Container(
  color: Theme.of(context).colorScheme.primary,
)

// Access custom color from the AppColors extension
Container(
  color: getColor(context, "success"),
)
```

### Available Color Names

The theme provides these semantic color names:
- `"primary"`, `"text"`, `"textLight"`, `"textSecondary"`
- `"background"`, `"surface"`, `"surfaceContainer"`
- `"success"`, `"error"`, `"warning"`, `"info"`
- `"border"`, `"divider"`, `"shadow"`
- `"white"`, `"black"`

### Using Text Styles

The app uses a custom text theme defined in `lib/core/theme/app_text_theme.dart`. It is automatically applied to `Text` widgets. For more control and advanced features, use the `AppText` widget.

---

## ✍️ Typography (`AppText` Widget)

For all text, you should use the custom `AppText` widget for consistency and advanced features like automatic font sizing and font fallbacks for different languages.

-   **Widget Location**: `lib/shared/widgets/app_text.dart`

### Basic Usage

```dart
import 'package:finance/shared/widgets/app_text.dart';

// Basic text
AppText("Hello, World!"),

// Text with specific style
AppText(
  "This is a heading",
  fontSize: 24,
  fontWeight: FontWeight.bold,
  colorName: "primary", // Uses color from AppColors
),

// Text with auto-sizing
AppText(
  "This text will resize to fit",
  autoSizeText: true,
  maxFontSize: 24,
  minFontSize: 12,
),
```

### Using Predefined Styles

For convenience, `AppTextStyles` provides static methods for common text styles.

```dart
import 'package:finance/shared/widgets/app_text.dart';

// Use predefined styles
AppTextStyles.heading("My Page Title"),
AppTextStyles.subheading("A brief description"),
AppTextStyles.body("This is the main content of the page."),
AppTextStyles.caption("A small note at the bottom."),
```

---

## 📱 Core Reusable Widgets

### `PageTemplate`

This widget provides a standard layout for pages with an `AppBar`, `body`, and optional `FloatingActionButton`. It also handles page entrance animations.

-   **Widget Location**: `lib/shared/widgets/page_template.dart`

**Example Usage:**

```dart
import 'package:finance/shared/widgets/page_template.dart';
import 'package:finance/shared/widgets/app_text.dart';

class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'My Feature',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText("Content goes here!"),
            const SizedBox(height: 16),
            // Your content widgets
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### Advanced PageTemplate Usage

```dart
PageTemplate(
  title: 'Settings',
  showBackButton: true,
  backgroundColor: getColor(context, "surface"),
  actions: [
    IconButton(
      icon: Icon(Icons.save),
      onPressed: () => _saveSettings(),
    ),
  ],
  onBackPressed: () {
    // Custom back logic
    if (_hasUnsavedChanges) {
      _showSaveDialog();
    } else {
      Navigator.pop(context);
    }
  },
  body: _buildSettingsContent(),
)
```

---

## 💬 Dialogs & Popups

The project includes a powerful framework for creating dialogs and popups consistently.

-   **Framework Location**: `lib/shared/widgets/dialogs/popup_framework.dart`
-   **Bottom Sheet Service**: `lib/shared/widgets/dialogs/bottom_sheet_service.dart`
-   **Dialog Service**: `lib/core/services/dialog_service.dart`

### Showing a Dialog

**Method 1: Using DialogService (Recommended)**

```dart
import 'package:finance/core/services/dialog_service.dart';

void _showInfoDialog(BuildContext context) {
  DialogService.showPopup(
    context,
    AppText("This is an important message."),
    title: "Information",
    subtitle: "Please read carefully",
    icon: Icons.info,
    showCloseButton: true,
  );
}
```

**Method 2: Using `.asPopup()` Extension**

```dart
import 'package:finance/shared/widgets/dialogs/popup_framework.dart';

void _showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return MyCustomWidget().asPopup(
        title: "Information",
        subtitle: "This is an important message.",
        icon: Icons.info,
      );
    },
  );
}
```

### Confirmation Dialogs

```dart
// Simple confirmation
final confirmed = await DialogService.showConfirmationDialog(
  context,
  title: "Delete Item",
  message: "Are you sure you want to delete this item?",
  isDangerous: true,
);

if (confirmed == true) {
  // Proceed with deletion
}
```

### Bottom Sheets

```dart
import 'package:finance/shared/widgets/dialogs/bottom_sheet_service.dart';

// Simple bottom sheet
void _showBottomSheet(BuildContext context) {
  BottomSheetService.showSimpleBottomSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText("Bottom Sheet Content"),
        // Your content here
      ],
    ),
    title: "Options",
  );
}

// Options bottom sheet
void _showOptionsSheet(BuildContext context) {
  BottomSheetService.showOptionsBottomSheet<String>(
    context,
    title: "Choose an option",
    options: [
      BottomSheetOption(
        title: "Edit",
        value: "edit",
        icon: Icons.edit,
      ),
      BottomSheetOption(
        title: "Delete",
        value: "delete",
        icon: Icons.delete,
      ),
    ],
  ).then((selectedValue) {
    if (selectedValue != null) {
      // Handle selection
    }
  });
}
```

---

## ✨ Animation Framework

The app has a comprehensive set of pre-built, settings-aware animations that you should use to create a fluid user experience.

-   **Animation Widgets Location**: `lib/shared/widgets/animations/`
-   **Animation Utilities**: `lib/shared/widgets/animations/animation_utils.dart`

All animations respect the user's animation settings (e.g., reduced motion).

### Common Animations

```dart
import 'package:finance/shared/widgets/animations/fade_in.dart';
import 'package:finance/shared/widgets/animations/scale_in.dart';
import 'package:finance/shared/widgets/animations/slide_in.dart';
import 'package:finance/shared/widgets/animations/bouncing_widget.dart';
import 'package:finance/shared/widgets/animations/breathing_widget.dart';
import 'package:finance/shared/widgets/animations/animated_expanded.dart';
import 'package:finance/shared/widgets/animations/animated_size_switcher.dart';
import 'package:finance/shared/widgets/animations/scaled_animated_switcher.dart';
import 'package:finance/shared/widgets/animations/slide_fade_transition.dart';
import 'package:finance/shared/widgets/animations/shake_animation.dart';
import 'package:finance/shared/widgets/animations/tappable_widget.dart';

// Fade in animation
FadeIn(
  delay: Duration(milliseconds: 100),
  child: MyCardWidget(),
),

// Scale in animation
ScaleIn(
  delay: Duration(milliseconds: 200),
  child: MyButtonWidget(),
),

// Slide in animation
SlideIn(
  direction: SlideDirection.left,
  child: MyListItem(),
),

// Tappable widget with feedback
TappableWidget(
  onTap: () => _handleTap(),
  child: MyInteractiveWidget(),
),
```

### Staggered Animations

```dart
// Create staggered list animations
Column(
  children: List.generate(items.length, (index) {
    return FadeIn(
      delay: Duration(milliseconds: index * 100),
      child: SlideIn(
        delay: Duration(milliseconds: index * 100 + 50),
        direction: SlideDirection.left,
        child: ListTile(
          title: AppText(items[index].title),
        ),
      ),
    );
  }),
)
```

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

## 🎯 Common Patterns & Best Practices

### State Management with BLoC

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'My Feature',
      body: BlocBuilder<MyFeatureBloc, MyFeatureState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          return Column(
            children: [
              AppText(state.title),
              // Your UI based on state
            ],
          );
        },
      ),
    );
  }
}
```

### Error Handling

```dart
// Global error display
void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: AppText(message, colorName: "white"),
      backgroundColor: getColor(context, "error"),
    ),
  );
}

// Error state in UI
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    if (state.hasError) {
      return Column(
        children: [
          Icon(Icons.error, color: getColor(context, "error")),
          AppText(state.errorMessage, colorName: "error"),
          ElevatedButton(
            onPressed: () => context.read<MyBloc>().add(RetryEvent()),
            child: AppText("Retry"),
          ),
        ],
      );
    }
    // Normal UI
  },
)
```

### Loading States

```dart
// Shimmer loading effect
import 'package:shimmer/shimmer.dart';

Widget _buildLoadingCard() {
  return Shimmer.fromColors(
    baseColor: getColor(context, "surface"),
    highlightColor: getColor(context, "surfaceContainer"),
    child: Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
```

### Adaptive Bottom Navigation (Phase 5)

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

### App Lifecycle Manager

Wrap the root `MaterialApp` (or the outermost `Scaffold`) with `AppLifecycleManager` to automatically coordinate high refresh-rate displays and centralized timers.

-   **Widget Location**: `lib/shared/widgets/app_lifecycle_manager.dart`

```dart
import 'package:finance/shared/widgets/app_lifecycle_manager.dart';

AppLifecycleManager(
  child: MaterialApp.router(
    routerConfig: appRouter,
    // …other params
  ),
);
```

### Animation Performance Monitor

Use the in-app FPS and jank monitor while building complex widgets or animations.

-   **Widget Location**: `lib/shared/widgets/animations/animation_performance_monitor.dart`

```dart
import 'package:finance/shared/widgets/animations/animation_performance_monitor.dart';

class DebugOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AnimationPerformanceMonitor(
      showLabel: true, // Displays current FPS
      child: SizedBox.shrink(),
    );
  }
}
```

---

## 🔧 Troubleshooting

### Common Issues

**1. Colors not updating with theme changes**
```dart
// ❌ Wrong - hardcoded color
Container(color: Colors.blue)

// ✅ Correct - theme-aware color
Container(color: getColor(context, "primary"))
```

**2. Text not following theme**
```dart
// ❌ Wrong - hardcoded text style
Text("Hello", style: TextStyle(fontSize: 16))

// ✅ Correct - using AppText
AppText("Hello", fontSize: 16)
```

**3. Animations not respecting user preferences**
```dart
// ❌ Wrong - direct animation
AnimatedContainer(duration: Duration(milliseconds: 300))

// ✅ Correct - using animation framework
FadeIn(child: MyWidget())
```

### Performance Tips

1. **Use `const` constructors** whenever possible
2. **Wrap expensive widgets** in `RepaintBoundary`
3. **Use `ListView.builder`** for long lists
4. **Avoid rebuilding entire widget trees** - use `BlocBuilder` with specific state slices

---

## 🧪 Testing Frontend Components

### Widget Testing

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:finance/shared/widgets/app_text.dart';

void main() {
  testWidgets('AppText displays correct text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppText("Test Text"),
        ),
      ),
    );

    expect(find.text("Test Text"), findsOneWidget);
  });
}
```

---

## 📚 Quick Reference

### Essential Imports

```dart
// Core theming
import 'package:finance/core/theme/app_colors.dart';
import 'package:finance/shared/widgets/app_text.dart';
import 'package:finance/shared/widgets/page_template.dart';

// Dialogs and sheets
import 'package:finance/core/services/dialog_service.dart';
import 'package:finance/shared/widgets/dialogs/bottom_sheet_service.dart';

// Animations
import 'package:finance/shared/widgets/animations/fade_in.dart';
import 'package:finance/shared/widgets/animations/scale_in.dart';
import 'package:finance/shared/widgets/animations/slide_in.dart';
import 'package:finance/shared/widgets/animations/bouncing_widget.dart';
import 'package:finance/shared/widgets/animations/breathing_widget.dart';
import 'package:finance/shared/widgets/animations/animated_expanded.dart';
import 'package:finance/shared/widgets/animations/animated_size_switcher.dart';
import 'package:finance/shared/widgets/animations/scaled_animated_switcher.dart';
import 'package:finance/shared/widgets/animations/slide_fade_transition.dart';
import 'package:finance/shared/widgets/animations/shake_animation.dart';
import 'package:finance/shared/widgets/animations/tappable_widget.dart';

// Navigation
import 'package:go_router/go_router.dart';
import 'package:finance/app/router/app_routes.dart';

// State management
import 'package:flutter_bloc/flutter_bloc.dart';

// Added navigation widgets
import 'package:finance/features/navigation/presentation/widgets/adaptive_bottom_navigation.dart';
import 'package:finance/features/navigation/presentation/widgets/navigation_customization_content.dart';

// Core theming (continued)
import 'package:finance/shared/widgets/app_lifecycle_manager.dart';

// Animations (continued)
import 'package:finance/shared/widgets/animations/animation_performance_monitor.dart';
```

### Color Quick Reference

```dart
// Semantic colors
getColor(context, "primary")     // Brand color
getColor(context, "success")     // Green
getColor(context, "error")       // Red
getColor(context, "warning")     // Orange
getColor(context, "info")        // Blue

// Text colors
getColor(context, "text")        // Primary text
getColor(context, "textLight")   // Secondary text

// Surface colors
getColor(context, "background")  // Main background
getColor(context, "surface")     // Card background
getColor(context, "surfaceContainer")      // Elevated surface
getColor(context, "surfaceContainerHigh")  // High-level container
```

This ensures that UI transitions are consistent across the application. 