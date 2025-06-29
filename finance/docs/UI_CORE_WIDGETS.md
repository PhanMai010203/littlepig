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

---

### `SelectorWidget`

A flexible, reusable selector widget that supports multiple options with smooth animations and customizable styling. This widget follows the project's animation framework and replaces the old binary toggle patterns with a more versatile solution.

-   **Widget Location**: `lib/shared/widgets/selector_widget.dart`

**Key Features:**

-   🎯 **Multi-Option Support:** Handle 2 or more selectable options
-   🎨 **Customizable Styling:** Colors, icons, borders, and animations
-   ⚡ **Performance Optimized:** Uses `TappableWidget` and `AnimationUtils` 
-   📱 **Haptic Feedback:** Platform-appropriate feedback patterns
-   🏗️ **Type-Safe:** Generic support for enums and custom types
-   🔄 **Smooth Animations:** Consistent with project animation standards

**Basic Usage:**

```dart
import 'package:finance/shared/widgets/selector_widget.dart';

// Simple enum-based selector
enum Priority { low, medium, high }

SelectorWidget<Priority>(
  selectedValue: currentPriority,
  options: [
    SelectorOption(
      value: Priority.low,
      label: 'Low',
      iconPath: 'assets/icons/low.svg',
      activeIconColor: Colors.green,
    ),
    SelectorOption(
      value: Priority.medium, 
      label: 'Medium',
      iconPath: 'assets/icons/medium.svg',
      activeIconColor: Colors.orange,
    ),
    SelectorOption(
      value: Priority.high,
      label: 'High', 
      iconPath: 'assets/icons/high.svg',
      activeIconColor: Colors.red,
    ),
  ],
  onSelectionChanged: (priority) {
    setState(() => currentPriority = priority);
  },
),
```

**Advanced Usage with Custom Styling:**

```dart
SelectorWidget<String>(
  selectedValue: selectedCategory,
  options: categories.map((cat) => SelectorOption(
    value: cat.id,
    label: cat.name,
    iconPath: cat.iconPath,
    activeIconColor: cat.color,
    activeTextColor: getColor(context, "textPrimary"),
    activeBackgroundColor: cat.color,
  )).toList(),
  onSelectionChanged: _handleCategoryChange,
  height: 56,
  borderRadius: BorderRadius.circular(16),
  animationDuration: Duration(milliseconds: 250),
  hapticFeedback: true,
),
```

**Enum Extension Helper:**

For easy conversion of enums to selector options:

```dart
// Convert enum values to selector options
List<SelectorOption<MyEnum>> options = MyEnum.values.toSelectorOptions(
  labelBuilder: (value) => value.name.tr(), // Use translations
  iconPathBuilder: (value) => 'assets/icons/${value.name}.svg',
  activeIconColorBuilder: (value) => _getColorForEnum(value),
);
```

**Replacement Pattern:**

This widget replaces binary toggles and can handle any number of options:

```dart
// ❌ Old binary toggle pattern  
SmoothToggleSwitch(
  isExpenseBudget: isExpense,
  leftLabel: "Expense",
  rightLabel: "Savings", 
  onToggle: (isExpense) => setState(() => _isExpense = isExpense),
)

// ✅ New flexible selector pattern
SelectorWidget<BudgetType>(
  selectedValue: budgetType,
  options: BudgetType.values.toSelectorOptions(
    labelBuilder: (type) => "budgets.${type.name}_budget".tr(),
    iconPathBuilder: (type) => 'assets/icons/${type.name}.svg',
  ),
  onSelectionChanged: (type) => setState(() => budgetType = type),
);
```

**Real-World Example (Home Page Transaction Filter):**

```dart
// From home_page.dart - Transaction filter implementation
enum TransactionFilter { all, expense, income }

SelectorWidget<TransactionFilter>(
  selectedValue: _selectedTransactionFilter,
  options: TransactionFilter.values.toSelectorOptions(
    labelBuilder: (filter) {
      switch (filter) {
        case TransactionFilter.all:
          return 'transactions.filter_all'.tr();
        case TransactionFilter.expense:
          return 'transactions.filter_expense'.tr();
        case TransactionFilter.income:
          return 'transactions.filter_income'.tr();
      }
    },
  ),
  onSelectionChanged: _onTransactionFilterChanged,
  height: 44,
  borderRadius: BorderRadius.circular(12),
  animationDuration: const Duration(milliseconds: 250),
),
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