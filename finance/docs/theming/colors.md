# 🎨 Color System

The color system provides a comprehensive, theme-aware approach to managing colors throughout your Flutter application with automatic light/dark mode support.

## 🎯 Overview

The color system is built around:
- **Semantic color names** - Meaningful color references
- **Automatic theme adaptation** - Light/dark mode switching
- **Material You integration** - Dynamic color support
- **Accessibility compliance** - WCAG contrast standards

## 🌈 Color Categories

### Primary Colors
Main brand and accent colors:

| Color Name | Usage | Example |
|------------|--------|---------|
| `'primary'` | Main brand color | Buttons, links, highlights |
| `'primaryLight'` | Lighter variant | Hover states, backgrounds |
| `'primaryDark'` | Darker variant | Active states, shadows |
| `'secondary'` | Secondary accent | Secondary buttons, badges |
| `'accent'` | Highlight color | Call-to-action elements |

```dart
// Using primary colors
Container(
  color: getColor(context, 'primary'),
  child: AppText('Primary button', colorName: 'white'),
)

// Gradient with primary variants
GradientContainer(
  colors: ['primary', 'primaryLight'],
  child: AppText('Gradient background'),
)
```

### Text Colors
Semantic text color hierarchy:

| Color Name | Usage | Contrast Ratio |
|------------|--------|----------------|
| `'text'` | Primary text | 4.5:1 minimum |
| `'textLight'` | Secondary text | 3:1 minimum |
| `'textDark'` | Headers, emphasis | 7:1 optimal |
| `'textDisabled'` | Disabled elements | 2.5:1 |

```dart
// Text hierarchy example
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText(
      'Main Heading',
      fontSize: 24,
      fontWeight: FontWeight.bold,
      colorName: 'textDark',
    ),
    AppText(
      'Body text content goes here.',
      fontSize: 16,
      colorName: 'text',
    ),
    AppText(
      'Additional information or metadata.',
      fontSize: 14,
      colorName: 'textLight',
    ),
  ],
)
```

### Surface Colors
Background and surface color system:

| Color Name | Usage | Description |
|------------|--------|-------------|
| `'background'` | App background | Main app background |
| `'surface'` | Cards, panels | Elevated surface color |
| `'surfaceVariant'` | Alternative surface | Secondary surface color |
| `'outline'` | Borders, dividers | Subtle border color |

```dart
// Surface color usage
Card(
  color: getColor(context, 'surface'),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(
        color: getColor(context, 'outline'),
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppText('Card content'),
    ),
  ),
)
```

### Status Colors
Semantic status and feedback colors:

| Color Name | Usage | Context |
|------------|--------|---------|
| `'success'` | Success states | Completed actions, positive feedback |
| `'error'` | Error states | Failures, warnings, destructive actions |
| `'warning'` | Warning states | Cautions, important notices |
| `'info'` | Information | Neutral information, tips |

```dart
// Status color examples
Column(
  children: [
    StatusCard(
      title: 'Operation Successful',
      message: 'Your changes have been saved.',
      status: 'success',
    ),
    StatusCard(
      title: 'Error Occurred',
      message: 'Please try again later.',
      status: 'error',
    ),
    StatusCard(
      title: 'Warning',
      message: 'This action cannot be undone.',
      status: 'warning',
    ),
    StatusCard(
      title: 'Information',
      message: 'Feature will be available soon.',
      status: 'info',
    ),
  ],
)
```

### Absolute Colors
Theme-independent colors:

| Color Name | Usage | Value |
|------------|--------|-------|
| `'white'` | Pure white | Always #FFFFFF |
| `'black'` | Pure black | Always #000000 |
| `'transparent'` | No color | Always transparent |

```dart
// Absolute colors for overlays and contrasts
Container(
  color: getColor(context, 'black').withOpacity(0.5),
  child: Center(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getColor(context, 'white'),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        'Modal content',
        colorName: 'black',
      ),
    ),
  ),
)
```

## 🔧 Using Colors in Code

### Basic Color Access
```dart
import '../../../../core/theme/app_colors.dart';

// Get a color from the theme
Color primaryColor = getColor(context, 'primary');

// Use in widgets
Container(
  color: getColor(context, 'surface'),
  decoration: BoxDecoration(
    border: Border.all(
      color: getColor(context, 'outline'),
    ),
  ),
)
```

### Color with Opacity
```dart
// Add transparency to any color
Container(
  color: getColor(context, 'primary').withOpacity(0.1),
  child: AppText('Subtle background'),
)

// Semi-transparent overlay
Container(
  color: getColor(context, 'black').withOpacity(0.6),
  child: AppText('Overlay text', colorName: 'white'),
)
```

### Conditional Colors
```dart
// Choose colors based on conditions
Color getStatusColor(String status) {
  switch (status) {
    case 'active':
      return getColor(context, 'success');
    case 'pending':
      return getColor(context, 'warning');
    case 'failed':
      return getColor(context, 'error');
    default:
      return getColor(context, 'textLight');
  }
}

// Usage
Container(
  color: getStatusColor(item.status),
  child: AppText(item.status.toUpperCase()),
)
```

## 🌓 Light and Dark Mode

### Automatic Theme Switching
Colors automatically adapt between light and dark themes:

```dart
// Light mode: primary = blue, surface = white
// Dark mode: primary = light blue, surface = dark gray

Container(
  color: getColor(context, 'surface'), // Automatically adapts
  child: AppText(
    'This text adapts to theme',
    colorName: 'text', // Automatically contrasts with background
  ),
)
```

### Theme-Aware Gradients
```dart
// Gradients that work in both themes
GradientContainer(
  colors: ['primary', 'primaryLight'],
  child: AppText(
    'Beautiful gradient',
    colorName: 'white', // Ensures good contrast
  ),
)
```

### Custom Theme-Aware Colors
```dart
class CustomColors {
  static Color getCustomColor(BuildContext context, bool isDark) {
    return isDark 
        ? getColor(context, 'primaryLight')
        : getColor(context, 'primaryDark');
  }
}

// Usage
Container(
  color: CustomColors.getCustomColor(
    context, 
    Theme.of(context).brightness == Brightness.dark,
  ),
)
```

## 🎨 Material You Integration

### Dynamic Colors
Support for Material You dynamic color system:

```dart
// Enable dynamic colors in your app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightDynamic ?? defaultLightColorScheme,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic ?? defaultDarkColorScheme,
          ),
          home: MyHomePage(),
        );
      },
    );
  }
}
```

### Accessing Dynamic Colors
```dart
// Get Material You colors when available
Color getSeedColor(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return colorScheme.primary; // Uses system accent color if available
}

// Fallback to custom colors
Color getAccentColor(BuildContext context) {
  if (colorScheme.primary != null) {
    return colorScheme.primary;
  }
  return getColor(context, 'primary'); // Fallback
}
```

## 🔍 Color Accessibility

### Contrast Compliance
All color combinations meet WCAG guidelines:

```dart
// High contrast text combinations
AppText(
  'High contrast text',
  colorName: 'textDark', // 7:1 contrast ratio
  backgroundColor: getColor(context, 'background'),
)

// Minimum contrast for body text
AppText(
  'Regular body text',
  colorName: 'text', // 4.5:1 contrast ratio
)
```

### Color Blind Accessibility
```dart
// Avoid color-only communication
Row(
  children: [
    Icon(
      Icons.check_circle,
      color: getColor(context, 'success'),
    ),
    AppText('Success', colorName: 'success'),
  ],
)

// Use patterns in addition to colors
Container(
  decoration: BoxDecoration(
    color: getColor(context, 'error'),
    border: Border.all(
      color: getColor(context, 'errorDark'),
      width: 2,
      style: BorderStyle.solid,
    ),
  ),
  child: AppText('Error message'),
)
```

## 📊 Color Testing

### Debug Color Palette
```dart
class ColorPaletteDebug extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = [
      'primary', 'primaryLight', 'primaryDark',
      'secondary', 'accent',
      'text', 'textLight', 'textDark',
      'background', 'surface', 'surfaceVariant',
      'success', 'error', 'warning', 'info',
      'white', 'black',
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((colorName) {
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: getColor(context, colorName),
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AppText(
              colorName,
              fontSize: 10,
              textAlign: TextAlign.center,
            ),
          ],
        );
      }).toList(),
    );
  }
}
```

### Contrast Testing
```dart
class ContrastTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildContrastExample('primary', 'white'),
        _buildContrastExample('text', 'background'),
        _buildContrastExample('error', 'surface'),
      ],
    );
  }
  
  Widget _buildContrastExample(String textColor, String bgColor) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      color: getColor(context, bgColor),
      child: AppText(
        'Sample text in $textColor on $bgColor',
        colorName: textColor,
      ),
    );
  }
}
```

## 🔗 Related Documentation

- [Typography](typography.md) - Text styling and fonts
- [Material You](material-you.md) - Dynamic color system
- [Custom Themes](custom-themes.md) - Creating custom themes
- [Components](../components/) - Using colors in components

## 📋 Complete Color Usage Example

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';

class ColorShowcasePage extends StatelessWidget {
  const ColorShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Color System',
      backgroundColor: getColor(context, 'background'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorSection(
              context,
              'Primary Colors',
              ['primary', 'primaryLight', 'primaryDark'],
            ),
            const SizedBox(height: 24),
            
            _buildColorSection(
              context,
              'Text Colors',
              ['text', 'textLight', 'textDark'],
            ),
            const SizedBox(height: 24),
            
            _buildColorSection(
              context,
              'Status Colors',
              ['success', 'error', 'warning', 'info'],
            ),
            const SizedBox(height: 24),
            
            _buildGradientExamples(context),
            const SizedBox(height: 24),
            
            _buildAccessibilityExamples(context),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    String title,
    List<String> colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          colorName: 'textDark',
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorName) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: getColor(context, colorName),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: getColor(context, 'outline'),
                  width: 1,
                ),
              ),
              child: Center(
                child: AppText(
                  colorName,
                  fontSize: 10,
                  textAlign: TextAlign.center,
                  colorName: _getContrastColor(colorName),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGradientExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Gradient Examples',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          colorName: 'textDark',
        ),
        const SizedBox(height: 12),
        
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                getColor(context, 'primary'),
                getColor(context, 'primaryLight'),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: AppText(
              'Primary Gradient',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              colorName: 'white',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilityExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Accessibility Examples',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          colorName: 'textDark',
        ),
        const SizedBox(height: 12),
        
        _buildAccessibilityCard(
          context,
          'Success Message',
          'Operation completed successfully!',
          'success',
          Icons.check_circle,
        ),
        const SizedBox(height: 8),
        
        _buildAccessibilityCard(
          context,
          'Error Message',
          'Something went wrong. Please try again.',
          'error',
          Icons.error,
        ),
        const SizedBox(height: 8),
        
        _buildAccessibilityCard(
          context,
          'Warning Message',
          'This action cannot be undone.',
          'warning',
          Icons.warning,
        ),
      ],
    );
  }

  Widget _buildAccessibilityCard(
    BuildContext context,
    String title,
    String message,
    String statusColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getColor(context, 'surface'),
        border: Border.all(
          color: getColor(context, statusColor),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: getColor(context, statusColor),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  colorName: statusColor,
                ),
                AppText(
                  message,
                  fontSize: 14,
                  colorName: 'text',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getContrastColor(String colorName) {
    // Determine appropriate contrast color
    final darkColors = ['primary', 'primaryDark', 'success', 'error', 'warning'];
    return darkColors.contains(colorName) ? 'white' : 'textDark';
  }
}
```

This comprehensive color system ensures consistent, accessible, and beautiful color usage throughout your Flutter application while automatically adapting to different themes and user preferences.
