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