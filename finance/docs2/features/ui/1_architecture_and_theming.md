# UI Guide: Architecture & Theming

This guide covers the foundational principles of the UI layer in the Finance App, including its architecture and theming system.

---

## 🏛️ UI Architecture Overview

The UI is built following Clean Architecture principles. As a UI developer, you will primarily work within the **Presentation Layer**.

-   **Location**: `lib/features/`
-   **Structure per Feature**:
    -   `presentation/pages/`: Contains the main screen widgets.
    -   `presentation/widgets/`: Contains UI components specific to that feature.
    -   `presentation/bloc/`: Handles state management for the feature using the BLoC pattern.

You will use shared components and services from the `lib/shared/` and `lib/core/` directories.

> **📝 Note**: Some feature directories may be sparse as the app is actively being developed. The architecture is in place and ready for new features.

---

## 🎨 Theming

The application has a robust theming system that supports light/dark modes and Material You dynamic colors.

-   **Theme Definition**: `lib/core/theme/app_theme.dart`
-   **Color Definitions**: `lib/core/theme/app_colors.dart`
-   **Text Style Definitions**: `lib/core/theme/app_text_theme.dart`

### Using Colors

Always use colors from the theme rather than hardcoding them. You can access the `ColorScheme` or the custom `AppColors` extension.

**Example: Accessing `ColorScheme`**

```dart
import 'package:finance/core/theme/app_colors.dart';

// Access primary color from the theme
Container(
  color: Theme.of(context).colorScheme.primary,
)

// Access custom color from the AppColors extension
Container(
  color: getColor(context, "success"),
)
```

### Available Color Names

The theme provides these semantic color names:
- `"primary"`, `"text"`, `"textLight"`, `"textSecondary"`
- `"background"`, `"surface"`, `"surfaceContainer"`
- `"success"`, `"error"`, `"warning"`, `"info"`
- `"border"`, `"divider"`, `"shadow"`
- `"white"`, `"black"`

### Using Text Styles

The app uses a custom text theme defined in `lib/core/theme/app_text_theme.dart`. It is automatically applied to `Text` widgets. For more control and advanced features, use the `AppText` widget. 