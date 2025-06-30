# UI Guide: Animation Framework

The Finance App includes a comprehensive set of pre-built, settings-aware animations to create a fluid and engaging user experience. This guide explains how to use them.

---

## ⚡ Performance Considerations

**Important**: For optimal app performance, **page entrance animations have been disabled** in core components. The following components no longer use entrance animations:

- **PageTemplate**: All pages using `PageTemplate` now load instantly without fade-in effects
- **Budget pages**: `BudgetsPage`, `BudgetCreatePage`, and related components load immediately
- **Transaction pages**: `TransactionsPage` and related components load immediately

### When to Avoid Animations

❌ **Avoid entrance animations for:**
- Page content that loads on navigation
- Large lists or heavy components
- Critical UI elements that users expect to see immediately
- Components that are frequently recreated

✅ **Use animations for:**
- User interactions (taps, hovers)
- State changes within a page
- Modal/dialog appearances
- Loading states and micro-interactions

---

## ✨ Animation Framework

The app has a comprehensive set of pre-built, settings-aware animations that you should use sparingly to create a fluid user experience.

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

// Fade in animation - USE SPARINGLY
FadeIn(
  delay: Duration(milliseconds: 100),
  child: MyInteractiveWidget(), // Only for interactions, not page content
),

// Scale in animation - USE SPARINGLY  
ScaleIn(
  delay: Duration(milliseconds: 200),
  child: MyButtonWidget(), // Only for interactive elements
),

// Slide in animation - USE SPARINGLY
SlideIn(
  direction: SlideDirection.left,
  child: MyModalContent(), // Only for modals/dialogs
),

// Tappable widget with feedback - RECOMMENDED
TappableWidget(
  onTap: () => _handleTap(),
  child: MyInteractiveWidget(),
),
```

### Staggered Animations

**⚠️ Warning**: Staggered animations can significantly impact performance on page load. Use only for small lists or interactive elements within a page.

```dart
// ❌ DON'T: Use staggered animations for page content
// ✅ DO: Use for small interactive lists or modal content
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

### Numeric Counter (AnimatedCount)

Use `AnimatedCount` to animate numbers (currency, scores, statistics) without manual AnimationController logic.

```dart
AnimatedCount(
  from: 0,
  to: totalAmount,
  duration: const Duration(milliseconds: 600),
  builder: (context, value) => Text(
    '\$${value.toStringAsFixed(0)}',
    style: AppTextStyles.headlineMedium,
  ),
);
```

You can also build rich layouts:

```dart
AnimatedCount(
  from: previousValue,
  to: currentValue,
  builder: (context, v) => RichText(
    text: TextSpan(
      children: [
        TextSpan(text: '\$${v.toStringAsFixed(0)}', style: boldStyle),
        const TextSpan(text: ' left'),
      ],
    ),
  ),
);
```

The widget lives in `lib/shared/widgets/animations/animated_count_text.dart` and internally uses `TweenAnimationBuilder`, automatically respecting reduce-motion settings (since duration will be `Duration.zero` when animations are disabled).

### AnimatedSizeSwitcher

`AnimatedSizeSwitcher` makes content replacement feel silky-smooth by combining `AnimatedSize` with an `AnimatedSwitcher` fade. It automatically disables itself when the user has reduced-motion enabled or when the global animation level is set to `none`.

```dart
AnimatedSizeSwitcher(
  enabled: true,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  child: MyWidget(key: ValueKey(contentId)),
)
```

Tip: You can quickly enable it on any widget via the `.animatedSizeSwitcher()` extension:
```dart
someWidget.animatedSizeSwitcher();
```

### Platform-Specific Animations

The animation framework now automatically adapts tap feedback based on the current platform:

```dart
TappableWidget(
  child: myContent,
  onTap: _handleTap,
);
// • iOS → uses FadedButton with subtle opacity fade (0.5 pressed opacity)
// • Android → uses scale / opacity ripple as per Material 3 guidelines
// • Desktop/Web → keeps animations lightweight and adds right-click support
```

This logic lives in `lib/shared/widgets/animations/tappable_widget.dart` and leverages `PlatformService` to decide which implementation to use.

---

## 🔄 Enhanced Page Transitions *(Recently Added)*

The animation framework now includes three specialized page transition types for better user experience, following Clean Architecture principles:

### Modal Slide Transition
Perfect for fullscreen dialogs, settings pages, and creation flows:
```dart
// In app_router.dart
GoRoute(
  parentNavigatorKey: _rootNavigatorKey,
  path: '/budget-create',
  name: 'budget_create',
  pageBuilder: (context, state) => AppPageTransitions.modalSlideTransitionPage(
    child: const BudgetCreatePage(),
    name: state.name,
    key: state.pageKey,
    fullscreenDialog: true,
  ),
),
```

### Subtle Slide Transition  
Gentle slide with minimal offset for elegant page changes:
```dart
GoRoute(
  path: '/notifications',
  name: 'notifications',
  pageBuilder: (context, state) => AppPageTransitions.subtleSlideTransitionPage(
    child: const NotificationsPage(),
    name: state.name,
    key: state.pageKey,
    direction: SlideDirection.fromTop,
    slideOffset: 0.05, // Very subtle movement
  ),
),
```

### Horizontal Slide Transition
Optimized for tab-like navigation and category switching:
```dart
GoRoute(
  path: '/categories',
  name: 'categories',
  pageBuilder: (context, state) => AppPageTransitions.horizontalSlideTransitionPage(
    child: const CategoriesPage(),
    name: state.name,
    key: state.pageKey,
    fromRight: true,
    slideDistance: 0.3, // Moderate slide distance
  ),
),
```

### Transition Selection Guidelines

| Transition Type | Use Case | Example |
|-----------------|----------|---------|
| `modalSlideTransitionPage` | Fullscreen dialogs, creation flows | Budget creation, settings |
| `subtleSlideTransitionPage` | Related content, gentle navigation | Notifications, help pages |
| `horizontalSlideTransitionPage` | Tab navigation, category switching | Category browsing, filters |
| `platformTransitionPage` | Default choice for standard navigation | Settings, profile pages |
| `noTransitionPage` | Performance-critical or shell routes | Main navigation tabs |

**All transitions respect user animation preferences and follow the app's performance guidelines.** 