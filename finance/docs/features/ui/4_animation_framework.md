# UI Guide: Animation Framework

The Finance App includes a comprehensive set of pre-built, settings-aware animations to create a fluid and engaging user experience. This guide explains how to use them.

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