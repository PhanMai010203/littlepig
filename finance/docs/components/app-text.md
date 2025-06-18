# 📝 AppText Widget

The `AppText` widget is your primary text component that provides consistent styling and theme integration across your Flutter application.

## 🎯 Overview

The AppText widget automatically adapts to your app's theme and provides convenient methods for styling text without writing repetitive styling code.

## 🚀 Basic Usage

### Simple Text
```dart
import '../../../../shared/widgets/app_text.dart';

AppText('Hello World!')
```

### Text with Custom Size
```dart
AppText(
  'Welcome to our app',
  fontSize: 24,
)
```

### Styled Text
```dart
AppText(
  'Important Message',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  colorName: 'primary',
)
```

## 🎨 Color System Integration

### Available Color Names
You can use predefined color names that automatically adapt to your theme:

| Color Name | Usage | Description |
|------------|-------|-------------|
| `'primary'` | Accent elements | Main brand color |
| `'text'` | Body text | Primary text color |
| `'textLight'` | Secondary text | Lighter text for descriptions |
| `'textDark'` | Headers | Darker text for emphasis |
| `'background'` | Backgrounds | Main background color |
| `'surface'` | Cards/surfaces | Surface background color |
| `'success'` | Success messages | Green success indicator |
| `'error'` | Error messages | Red error indicator |
| `'warning'` | Warning messages | Orange warning indicator |
| `'info'` | Info messages | Blue information indicator |
| `'white'` | Pure white | Always white regardless of theme |
| `'black'` | Pure black | Always black regardless of theme |

### Color Examples
```dart
// Primary brand color
AppText('Brand Message', colorName: 'primary')

// Success message
AppText('Operation completed!', colorName: 'success')

// Error message
AppText('Something went wrong', colorName: 'error')

// Light text for descriptions
AppText('Additional information', colorName: 'textLight')
```

## 📏 Typography Scaling

### Font Sizes
```dart
// Small text
AppText('Fine print', fontSize: 12)

// Regular text
AppText('Body text', fontSize: 16)

// Large text
AppText('Heading', fontSize: 24)

// Extra large text
AppText('Title', fontSize: 32)
```

### Font Weights
```dart
// Light weight
AppText('Light text', fontWeight: FontWeight.w300)

// Regular weight (default)
AppText('Normal text', fontWeight: FontWeight.normal)

// Bold weight
AppText('Bold text', fontWeight: FontWeight.bold)

// Extra bold
AppText('Heavy text', fontWeight: FontWeight.w900)
```

## 🔤 Advanced Text Features

### Auto-Sizing Text
Automatically adjusts text size to fit available space:

```dart
AppText(
  'This text will automatically resize to fit the container',
  autoSize: true,
  maxLines: 2,
)
```

### Text Alignment
```dart
// Center aligned
AppText(
  'Centered text',
  textAlign: TextAlign.center,
)

// Right aligned
AppText(
  'Right aligned text',
  textAlign: TextAlign.right,
)

// Justified
AppText(
  'This is a longer text that will be justified across multiple lines.',
  textAlign: TextAlign.justify,
)
```

### Rich Text with Spans
Create text with multiple styles:

```dart
AppText.rich([
  TextSpan(
    text: 'Welcome ',
    style: AppTextStyle(fontSize: 16),
  ),
  TextSpan(
    text: 'new user',
    style: AppTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: getColor(context, 'primary'),
    ),
  ),
  TextSpan(
    text: '! Start exploring.',
    style: AppTextStyle(fontSize: 16),
  ),
])
```

## 📱 Responsive Text

### Screen Size Adaptation
```dart
// Responsive font size based on screen width
AppText(
  'Responsive Title',
  fontSize: MediaQuery.of(context).size.width > 600 ? 32 : 24,
)
```

### Breakpoint-Based Sizing
```dart
class ResponsiveText extends StatelessWidget {
  final String text;
  
  const ResponsiveText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Define breakpoints
    late double fontSize;
    if (screenWidth < 480) {
      fontSize = 14; // Mobile
    } else if (screenWidth < 768) {
      fontSize = 16; // Tablet
    } else {
      fontSize = 18; // Desktop
    }
    
    return AppText(
      text,
      fontSize: fontSize,
    );
  }
}
```

## 🌟 Common Patterns

### Page Headers
```dart
AppText(
  'Page Title',
  fontSize: 28,
  fontWeight: FontWeight.bold,
  colorName: 'textDark',
)
```

### Section Headers
```dart
AppText(
  'Section Title',
  fontSize: 20,
  fontWeight: FontWeight.w600,
  colorName: 'text',
)
```

### Body Text
```dart
AppText(
  'This is the main content of your page or section.',
  fontSize: 16,
  colorName: 'text',
)
```

### Captions and Descriptions
```dart
AppText(
  'Additional information or captions',
  fontSize: 14,
  colorName: 'textLight',
)
```

### Status Messages
```dart
// Success
AppText(
  'Operation completed successfully!',
  fontSize: 16,
  colorName: 'success',
  fontWeight: FontWeight.w500,
)

// Error
AppText(
  'An error occurred. Please try again.',
  fontSize: 16,
  colorName: 'error',
  fontWeight: FontWeight.w500,
)
```

## ⚡ Performance Tips

### Text Reuse
```dart
// ✅ Good: Reuse text styles
final headerStyle = AppTextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: getColor(context, 'textDark'),
);

AppText('Header 1', style: headerStyle)
AppText('Header 2', style: headerStyle)
```

### Avoid Excessive Rebuilds
```dart
// ✅ Good: Extract text widgets that don't change
class StaticLabel extends StatelessWidget {
  const StaticLabel({super.key});
  
  @override
  Widget build(BuildContext context) {
    return AppText(
      'This text never changes',
      fontSize: 16,
      colorName: 'text',
    );
  }
}
```

## 🔗 Related Documentation

- [Page Template](page-template.md) - Learn about the page wrapper
- [Theming System](../theming/colors.md) - Understanding the color system
- [Custom Widgets](custom-widgets.md) - Other available components

## 📋 Complete Example

Here's a complete example showing various AppText usage patterns:

```dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';

class TextShowcasePage extends StatelessWidget {
  const TextShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Text Showcase',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            AppText(
              'Typography Examples',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              colorName: 'textDark',
            ),
            const SizedBox(height: 24),
            
            // Section Header
            AppText(
              'Different Sizes',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              colorName: 'text',
            ),
            const SizedBox(height: 12),
            
            // Size examples
            AppText('Small text (12px)', fontSize: 12),
            AppText('Regular text (16px)', fontSize: 16),
            AppText('Large text (24px)', fontSize: 24),
            AppText('Extra large text (32px)', fontSize: 32),
            
            const SizedBox(height: 24),
            
            // Color examples
            AppText(
              'Different Colors',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              colorName: 'text',
            ),
            const SizedBox(height: 12),
            
            AppText('Primary color', colorName: 'primary'),
            AppText('Success message', colorName: 'success'),
            AppText('Error message', colorName: 'error'),
            AppText('Warning message', colorName: 'warning'),
            AppText('Info message', colorName: 'info'),
            AppText('Light text', colorName: 'textLight'),
          ],
        ),
      ),
    );
  }
}
```

This example demonstrates the flexibility and power of the AppText widget for creating consistent, theme-aware text throughout your application.
