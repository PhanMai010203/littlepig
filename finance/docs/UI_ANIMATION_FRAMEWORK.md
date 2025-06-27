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