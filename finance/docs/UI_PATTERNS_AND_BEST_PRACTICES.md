# UI Guide: Patterns & Best Practices

This guide covers common patterns, state management approaches, and app-wide utilities that help maintain a high-quality, performant, and robust UI.

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

### Platform-Aware Theming

#### Material Design Touch Feedback
The app uses platform-aware splash effects to provide appropriate user feedback:

- **Android**: Full Material Design ripple effects for familiar touch feedback
- **iOS**: No splash effects to match iOS design language expectations

This is automatically handled by the app theme, but when creating custom components, use this pattern:

```dart
import 'package:flutter/foundation.dart';

// Get platform-appropriate splash factory
InteractiveInkFeatureFactory get _platformSplashFactory {
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return NoSplash.splashFactory;
  }
  return InkRipple.splashFactory; // Material Design default
}

// Use in custom button components
Material(
  child: InkWell(
    splashFactory: _platformSplashFactory,
    onTap: onPressed,
    child: child,
  ),
)
```

#### Theme Contrast Best Practices
When creating components with opacity/transparency that work across light and dark themes:

```dart
// ✅ Good: Different alpha values for proper contrast
final optimizedColor = brightness == Brightness.light
    ? baseColor.withValues(alpha: 0.20) // Light theme: lower alpha
    : baseColor.withValues(alpha: 0.35); // Dark theme: higher alpha

// ❌ Bad: Same alpha value for both themes
final poorColor = baseColor.withValues(alpha: 0.20); // Lacks contrast in dark theme
```

**Rationale:**
- Light themes need lower alpha values for visual contrast against bright backgrounds
- Dark themes need higher alpha values for visibility against dark backgrounds
- Different blend modes may also be needed (`BlendMode.multiply` vs `BlendMode.screen`)

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

---

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

### Text Input Best Practices

#### Focus Management
The `TextInput` widget automatically handles focus restoration when the app resumes from background. Each `ResumeTextFieldFocus` wrapper manages its own focus state to prevent race conditions.

**Recommended Usage:**
Wrap pages or major UI sections that contain text inputs with `ResumeTextFieldFocus`:

```dart
class MyFormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResumeTextFieldFocus(
      child: PageTemplate(
        title: 'Form Page',
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                TextInput(hintText: 'Enter name'),
                TextInput(hintText: 'Enter email'),
                // ... other form fields
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Key Benefits:**
- **Instance-based state management**: Each `ResumeTextFieldFocus` manages its own focus state, preventing race conditions
- **Smart focus restoration**: Only restores focus when the app actually went to background, not on intentional dismissals
- **Automatic cleanup**: Stored focus is cleared when inappropriate (widget disposal, intentional keyboard dismissal)

#### Dismissing the Keyboard Gracefully

**Standard dismissal** (when user should be able to restore focus later):
```dart
ElevatedButton(
  onPressed: () {
    minimizeKeyboard(context);
    // Focus can still be restored if app goes to background
  },
  child: const Text('Save'),
);
```

**Dismissal with focus clearing** (when user is done with the form):
```dart
ElevatedButton(
  onPressed: () {
    minimizeKeyboardAndClearFocus(context);
    // Prevents focus restoration even if app goes to background
  },
  child: const Text('Submit & Close'),
);
```

#### Platform-Specific Interactions
`TappableWidget` automatically chooses the best feedback for the current platform. Whenever possible use the `.tappable()` extension instead of wrapping `GestureDetector` manually:

```dart
Container(
  padding: const EdgeInsets.all(16),
  child: const Icon(Icons.settings),
).tappable(
  onTap: _openSettings,
);
```

---

### CategoryBloc Singleton Pattern _(NEW)_

The **CategoryBloc** is an **eager singleton** created at app start-up.  It replaces on-demand repository calls so that *all* category-dependent UI can rely on an in-memory cache that is always warm.

| Characteristic | Value |
| --- | --- |
| Registration | `@singleton` via **Injectable** |
| Lifetime | Entire app session (DI container) |
| First load | Immediately in constructor (`add(LoadCategories())`) |
| Cache TTL | 30 minutes – see `isExpired` extension |
| Invalidation | CRUD events update or purge cache before emitting a new state |

#### Access Pattern

```dart
final categories = context.read<CategoriesBloc>().state.categories;
```

*Do **NOT** trigger a repository fetch in UI – rely on the bloc's cache.*

#### Integration Guidelines

1. **Provider order matters** – `CategoriesBloc` **must** appear *before* any bloc that depends on categories (e.g. `TransactionsBloc`).
2. When you add a new feature that needs categories:
   * Inject `CategoriesBloc` instead of `CategoryRepository`.
   * Handle empty categories by showing a loading/skeleton UI – this should be rare because the singleton is created at launch.
3. For category CRUD pages/screens, dispatch the appropriate event (`CreateCategory`, `UpdateCategory`, `DeleteCategory`) so that the singleton stays in sync.
4. Avoid direct state mutation; always go through bloc events.

#### Performance Rationale

• Saves ~400–500 ms during navigation to `TransactionsPage` (categories already in memory).  
• Reduces duplicate API calls across pages.  
• Centralises cache logic and TTL checks in one place.

--- 