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

### Keyboard-Aware Bottom Sheets (Post-Refactor Pattern)

The app now includes a refined, high-performance approach to bottom sheets that automatically handle keyboard interactions without jank. This pattern is built into `BottomSheetService` and leverages the internal `_KeyboardAwareBottomSheet` widget.

#### Best Practice: Using Bottom Sheets with Text Input

```dart
// ✅ Recommended: Use popupWithKeyboard for sheets with text fields
void _showTransactionForm(BuildContext context) {
  BottomSheetService.showCustomBottomSheet(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInput(hintText: "Transaction title"),
        TextInput(hintText: "Amount", keyboardType: TextInputType.number),
        TextInput(hintText: "Notes", maxLines: 3),
      ],
    ),
    title: "Add Transaction",
    popupWithKeyboard: true,     // Optimizes snap sizes for keyboard
    resizeForKeyboard: true,     // Enables smooth tracking (default)
    snapSizes: [0.9, 1.0],       // Keyboard-friendly snap points
  );
}
```

#### Technical Pattern: Real-Time Keyboard Synchronization

The `_KeyboardAwareBottomSheet` widget provides frame-by-frame keyboard tracking:

```dart
// This pattern is internal to BottomSheetService but demonstrates the approach
class _KeyboardAwareBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Real-time animated values from MediaQuery
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    
    // Simple padding approach - no Stack complexity
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: child,
    );
  }
}
```

**Key Benefits:**
- **Zero Jank:** Content moves smoothly with keyboard animation
- **Simple Architecture:** No complex timing logic or competing animations
- **Automatic:** Works for all bottom sheet types (draggable, standard, options)
- **Backward Compatible:** Existing code continues to work unchanged

#### Bottom Sheet Performance Guidelines

```dart
// ✅ Good: Use appropriate snap sizes for content type
BottomSheetService.showCustomBottomSheet(
  context,
  content,
  snapSizes: [0.3, 0.6, 0.9],    // Multiple options for scrollable content
  resizeForKeyboard: true,        // Enable for forms
);

// ✅ Good: Optimize for keyboard scenarios
BottomSheetService.showCustomBottomSheet(
  context,
  formContent,
  popupWithKeyboard: true,        // Uses [0.9, 1.0] snap sizes
  resizeForKeyboard: true,        // Smooth keyboard tracking
);

// ✅ Good: Disable for static content that doesn't need keyboard
BottomSheetService.showOptionsBottomSheet(
  context,
  title: "Choose action",
  options: menuOptions,
  resizeForKeyboard: false,       // Static options don't need keyboard tracking
);
``` 