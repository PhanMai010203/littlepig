# UI Guide: Testing & Troubleshooting

This document provides guidance on troubleshooting common UI issues, testing components, and a quick reference for essential imports and colors.

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
5. **Avoid `setState` in scroll listeners.** Calling `setState` from a `ScrollController` listener will rebuild the entire widget on every scroll tick, causing severe performance issues. Instead, use an `AnimatedBuilder` to listen to the `ScrollController` and rebuild only the necessary parts of the widget tree.
6. **⚡ Avoid entrance animations for page content.** Page-level fade-in animations have been removed from core components (`PageTemplate`, budget pages, transaction pages) for better performance. Only use entrance animations for:
   - User interactions and feedback
   - Modal/dialog appearances  
   - Small interactive elements
   - State changes within a page

### Recently Fixed Issues (vNext)

| Issue | Symptoms | Resolution |
|-------|----------|------------|
| **Budget tile color fallback picks wrong color / silent error** | Invalid hex string in optional `colour` field crashed or silently defaulted to palette color. | `_pickColor()` now logs invalid hex values and safely falls back to palette without swallowing other errors. |
| **SelectorWidget crashes when `selectedValue` not in options** | `TabController` throws exception (`initialIndex` -1) during build/update. | `_getSelectedIndex()` now defaults to **0** when no match is found and `didUpdateWidget` checks range before animating. |
| **CollapsibleAppBarTitle division-by-zero** | Runtime error when `expandedHeight == toolbarHeight`. | Added safe denominator (`1`) fallback when the delta height is `0`. |

> These fixes are available starting **commit: _vNext (June 2025)_**. Make sure you've pulled the latest changes before troubleshooting similar crashes.

---

## 🧪 Testing UI Components

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