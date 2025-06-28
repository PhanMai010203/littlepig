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
Always wrap the root of your app (or any subtree that needs automatic focus restoration) with `ResumeTextFieldFocus`:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResumeTextFieldFocus(
      child: MaterialApp.router(
        routerConfig: appRouter,
      ),
    );
  }
}
```

#### Dismissing the Keyboard Gracefully
Use the helper `minimizeKeyboard(context)` to dismiss the keyboard without breaking the current focus chain:

```dart
ElevatedButton(
  onPressed: () {
    minimizeKeyboard(context);
  },
  child: const Text('Save'),
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