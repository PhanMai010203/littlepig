# UI Guide: Core Widgets & Typography

This document covers the essential reusable widgets and typography standards for the Finance App, ensuring a consistent and high-quality user interface.

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

This widget provides a standard page layout with a modern, collapsible `SliverAppBar` that dynamically responds to scrolling. It's the standard wrapper for all pages in the app.

-   **Widget Location**: `lib/shared/widgets/page_template.dart`

**Key Features:**

-   **Collapsible App Bar:** The header starts large and shrinks into a standard `AppBar` as the user scrolls.
-   **Theme-Aware:** The app bar's background opacity and color are tied to the current theme and scroll position.
-   **Sliver-Based:** It uses a `CustomScrollView` under the hood, requiring its content to be provided as a list of sliver widgets.
-   **⚡ Performance Optimized:** No entrance animations - content appears instantly for better performance.

**Example Usage:**

To use `PageTemplate`, you must provide a `List<Widget>` to the `slivers` property. Non-sliver widgets must be wrapped in a `SliverToBoxAdapter` or `SliverPadding`.

```dart
import 'package:finance/shared/widgets/page_template.dart';
import 'package:finance/shared/widgets/app_text.dart';

class MyFeaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'My Feature',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText("Content goes here!"),
                const SizedBox(height: 16),
                // Example of platform-adaptive tappable card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: AppText('Tap me!'),
                  ),
                ).tappable(
                  onTap: () => print('Card tapped!'),
                  // Automatically uses iOS fade or Android ripple
                ),
              ],
            ),
          ),
        ),
        // If you have a list, use SliverList
        SliverList.builder(
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: AppText('Item ${index + 1}'),
            // Right-click support on desktop automatically added
            onLongPress: () => _showContextMenu(index),
          ).tappable(
            onTap: () => _selectItem(index),
          ),
        )
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

### `LanguageSelector`

This widget provides a standardized UI for selecting the application's language. It displays a list of available languages with their native and English names, and shows the current selection.

-   **Widget Location**: `lib/shared/widgets/language_selector.dart`

**Example Usage:**

```dart
import 'package:finance/shared/widgets/language_selector.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Settings',
      body: Column(
        children: [
          // Other settings...
          LanguageSelector(),
          // Other settings...
        ],
      ),
    );
  }
}
```

---

### `TappableWidget`

This is a foundational wrapper widget that provides customizable tap feedback with **platform-specific behavior**. It automatically adapts to provide native-feeling interactions on iOS, Android, and desktop platforms.

-   **Widget Location**: `lib/shared/widgets/animations/tappable_widget.dart`
-   **iOS Implementation**: `lib/shared/widgets/animations/faded_button.dart`

**Key Features:**

-   🍎 **iOS**: Uses `FadedButton` with precise fade animations (150ms press, 230ms release)
-   🤖 **Android**: Uses Material Design ripple effects with scale/opacity animations
-   🖥️ **Desktop/Web**: Includes right-click support and appropriate mouse cursors
-   ⚡ **Performance**: Respects animation settings and device capabilities
-   📱 **Haptic**: Platform-appropriate haptic feedback (heavy impact on iOS long press)

**Example 1: Using the `TappableWidget` wrapper**

```dart
TappableWidget(
  onTap: () => print('Card tapped!'),
  borderRadius: BorderRadius.circular(12),
  child: MyCard(
    // ...
  ),
);
```

**Example 2: Using the `.tappable()` extension (Recommended)**

The `.tappable()` extension is the most convenient way to add feedback to any widget. It automatically adapts to the current platform:

```dart
MyWidget(
  // ...
).tappable(
  onTap: () => print('Widget tapped!'),
  animationType: TapAnimationType.scale, // Used on Android
  scaleFactor: 0.9,
);

Icon(Icons.add).tappable(
  onTap: _increment,
  hapticFeedback: false,
);
```

**Platform-Specific Behavior:**

- **iOS**: Automatically uses fade animation with `pressedOpacity: 0.5`
- **Android**: Uses the specified `animationType` (scale, opacity, both, or none)
- **Web/Desktop**: Adds right-click support that triggers `onLongPress` if defined
- **All platforms**: Respects performance settings and reduces motion preferences 

---

### Advanced TextInput Features

#### Auto-Focus Restoration
```dart
// Wrap your app at the root to automatically restore focus when returning
ResumeTextFieldFocus(
  child: MaterialApp.router(
    routerConfig: appRouter,
  ),
)
```

#### Styling Options
```dart
TextInput(
  style: TextInputStyle.underline,
  handleOnTapOutside: true,
  textCapitalization: TextCapitalization.sentences,
  prefix: "€",
  suffix: "/mo",
)
```

#### Keyboard Management Helpers
```dart
minimizeKeyboard(context); // Globally dismisses the keyboard safely
```

---

### TappableTextEntry – Inline Editing Made Easy

`TappableTextEntry` lets you show a piece of text that becomes editable when tapped. It now integrates `AnimatedSizeSwitcher` by default for buttery-smooth size changes.

| **Parameter** | **Description** |
|---------------|-----------------|
| `enableAnimatedSwitcher` | Toggle the size/opacity transition |
| `customTitleBuilder` | Provide your own builder while keeping placeholder logic |
| `showPlaceHolderWhenTextEquals` | Treat a specific value as "empty" and show the placeholder |
| `addTappableBackground` | Adds a subtle, theme-aware background behind the text |
| `autoSizeText` | Enables dynamic font sizing via `AppText` |

#### Basic Usage
```dart
TappableTextEntry(
  title: myTitle,
  placeholder: "Tap to enter…",
  onTap: _openEditor,
)
```

#### With Custom Title Builder
```dart
TappableTextEntry(
  title: myTitle,
  placeholder: "Category",
  enableAnimatedSwitcher: true,
  customTitleBuilder: (titleBuilder) => Row(
    children: [
      Icon(Icons.category_outlined),
      const SizedBox(width: 8),
      titleBuilder(myTitle),
    ],
  ),
  onTap: _pickCategory,
) 