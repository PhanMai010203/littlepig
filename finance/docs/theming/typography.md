# ✍️ Typography System

The typography system provides consistent, scalable, and theme-aware text styling throughout your Flutter application with built-in accessibility and responsive design support.

## 🎯 Overview

The typography system includes:
- **Semantic text styles** - Meaningful style hierarchies
- **Responsive scaling** - Adapts to screen sizes
- **Font family management** - Multiple font options
- **Accessibility compliance** - WCAG guidelines support

## 📝 Font Hierarchy

### Heading Styles
Structured heading hierarchy for content organization:

| Style | Font Size | Weight | Usage |
|-------|-----------|--------|-------|
| H1 | 32px | Bold (700) | Page titles |
| H2 | 28px | SemiBold (600) | Section headers |
| H3 | 24px | SemiBold (600) | Subsection headers |
| H4 | 20px | Medium (500) | Card titles |
| H5 | 18px | Medium (500) | List headers |
| H6 | 16px | Medium (500) | Small headers |

```dart
// Heading examples
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText(
      'Page Title (H1)',
      fontSize: 32,
      fontWeight: FontWeight.bold,
      colorName: 'textDark',
    ),
    AppText(
      'Section Header (H2)',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      colorName: 'textDark',
    ),
    AppText(
      'Subsection Header (H3)',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      colorName: 'text',
    ),
    AppText(
      'Card Title (H4)',
      fontSize: 20,
      fontWeight: FontWeight.w500,
      colorName: 'text',
    ),
  ],
)
```

### Body Text Styles
Content text with appropriate hierarchy:

| Style | Font Size | Weight | Usage |
|-------|-----------|--------|-------|
| Body Large | 18px | Regular (400) | Important content |
| Body | 16px | Regular (400) | Main content |
| Body Small | 14px | Regular (400) | Secondary content |
| Caption | 12px | Regular (400) | Metadata, labels |

```dart
// Body text examples
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText(
      'This is large body text for important content.',
      fontSize: 18,
      colorName: 'text',
    ),
    AppText(
      'This is regular body text for main content.',
      fontSize: 16,
      colorName: 'text',
    ),
    AppText(
      'This is small body text for secondary information.',
      fontSize: 14,
      colorName: 'textLight',
    ),
    AppText(
      'This is caption text for metadata.',
      fontSize: 12,
      colorName: 'textLight',
    ),
  ],
)
```

### Display Styles
Large, prominent text for special occasions:

| Style | Font Size | Weight | Usage |
|-------|-----------|--------|-------|
| Display Large | 48px | Bold (700) | Hero sections |
| Display Medium | 40px | Bold (700) | Feature highlights |
| Display Small | 36px | SemiBold (600) | Special announcements |

```dart
// Display text examples
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    AppText(
      'Hero Title',
      fontSize: 48,
      fontWeight: FontWeight.bold,
      colorName: 'primary',
    ),
    AppText(
      'Feature Highlight',
      fontSize: 40,
      fontWeight: FontWeight.bold,
      colorName: 'textDark',
    ),
    AppText(
      'Special Announcement',
      fontSize: 36,
      fontWeight: FontWeight.w600,
      colorName: 'text',
    ),
  ],
)
```

## 🎨 Font Families

### Available Fonts
The system includes multiple font families for different purposes:

| Font Family | Purpose | Characteristics |
|-------------|---------|-----------------|
| **Inter** | Primary UI | Modern, clean, highly legible |
| **DM Sans** | Alternative UI | Geometric, friendly |
| **Roboto Condensed** | Data/Numbers | Compact, efficient |
| **Avenir LT Std** | Premium feel | Elegant, sophisticated |
| **Metropolis** | Branding | Distinctive, modern |
| **Inconsolata** | Code/Monospace | Fixed-width, code-friendly |

### Setting Font Families
```dart
// Using different font families
AppText(
  'Modern UI Text',
  fontFamily: 'Inter',
  fontSize: 16,
)

AppText(
  'Elegant Heading',
  fontFamily: 'Avenir LT Std',
  fontSize: 24,
  fontWeight: FontWeight.bold,
)

AppText(
  'Code Example',
  fontFamily: 'Inconsolata',
  fontSize: 14,
  colorName: 'text',
)

AppText(
  'Data: 1,234.56',
  fontFamily: 'Roboto Condensed',
  fontSize: 18,
  fontWeight: FontWeight.w500,
)
```

### Font Loading
Fonts are automatically loaded from the assets:

```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    
    - family: DM Sans
      fonts:
        - asset: assets/fonts/DMSans-Regular.ttf
        - asset: assets/fonts/DMSans-Bold.ttf
          weight: 700
    
    - family: Inconsolata
      fonts:
        - asset: assets/fonts/Inconsolata-Regular.ttf
        - asset: assets/fonts/Inconsolata-Bold.ttf
          weight: 700
```

## 📱 Responsive Typography

### Screen Size Adaptation
Typography automatically scales based on screen size:

```dart
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  
  const ResponsiveText(
    this.text, {
    super.key,
    this.baseFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive font size
    double fontSize = baseFontSize;
    if (screenWidth < 480) {
      fontSize = baseFontSize * 0.9; // Mobile
    } else if (screenWidth > 1024) {
      fontSize = baseFontSize * 1.1; // Desktop
    }
    
    return AppText(
      text,
      fontSize: fontSize,
    );
  }
}
```

### Breakpoint-Based Scaling
```dart
class BreakpointText extends StatelessWidget {
  final String text;
  
  const BreakpointText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize;
        FontWeight fontWeight;
        
        if (constraints.maxWidth < 480) {
          // Mobile
          fontSize = 20;
          fontWeight = FontWeight.w600;
        } else if (constraints.maxWidth < 768) {
          // Tablet
          fontSize = 24;
          fontWeight = FontWeight.w600;
        } else {
          // Desktop
          fontSize = 28;
          fontWeight = FontWeight.bold;
        }
        
        return AppText(
          text,
          fontSize: fontSize,
          fontWeight: fontWeight,
        );
      },
    );
  }
}
```

### Adaptive Line Height
```dart
// Calculate appropriate line height
double getLineHeight(double fontSize) {
  if (fontSize <= 14) return 1.4;
  if (fontSize <= 18) return 1.5;
  if (fontSize <= 24) return 1.4;
  return 1.3; // Large text
}

AppText(
  'Text with adaptive line height',
  fontSize: 16,
  height: getLineHeight(16), // Line height multiplier
)
```

## 🎯 Typography Patterns

### Content Hierarchy
```dart
class ContentHierarchy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Article title
        AppText(
          'Understanding Flutter Typography',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        AppText(
          'A comprehensive guide to text styling',
          fontSize: 18,
          colorName: 'textLight',
        ),
        const SizedBox(height: 16),
        
        // Body paragraph
        AppText(
          'Typography is one of the most important aspects of user interface design. It helps establish visual hierarchy, improves readability, and creates a consistent user experience.',
          fontSize: 16,
          colorName: 'text',
          height: 1.5,
        ),
        const SizedBox(height: 16),
        
        // Section header
        AppText(
          'Key Principles',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          colorName: 'textDark',
        ),
        const SizedBox(height: 8),
        
        // List items
        _buildListItem('Consistency across the application'),
        _buildListItem('Appropriate contrast for accessibility'),
        _buildListItem('Scalable sizing for different devices'),
      ],
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('• ', fontSize: 16, colorName: 'primary'),
          Expanded(
            child: AppText(
              text,
              fontSize: 16,
              colorName: 'text',
            ),
          ),
        ],
      ),
    );
  }
}
```

### Card Typography
```dart
class TypographyCard extends StatelessWidget {
  final String title;
  final String content;
  final String? metadata;
  
  const TypographyCard({
    super.key,
    required this.title,
    required this.content,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card title
            AppText(
              title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              colorName: 'textDark',
            ),
            const SizedBox(height: 8),
            
            // Main content
            AppText(
              content,
              fontSize: 14,
              colorName: 'text',
              height: 1.4,
            ),
            
            if (metadata != null) ...[
              const SizedBox(height: 12),
              AppText(
                metadata!,
                fontSize: 12,
                colorName: 'textLight',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Button Typography
```dart
class TypographyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  
  const TypographyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getButtonStyle(type);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: getColor(context, style.backgroundColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: AppText(
        text.toUpperCase(),
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        colorName: style.textColor,
        letterSpacing: 0.5,
      ),
    );
  }

  ButtonStyle _getButtonStyle(ButtonType type) {
    switch (type) {
      case ButtonType.primary:
        return ButtonStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          backgroundColor: 'primary',
          textColor: 'white',
        );
      case ButtonType.secondary:
        return ButtonStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          backgroundColor: 'surface',
          textColor: 'primary',
        );
      case ButtonType.text:
        return ButtonStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          backgroundColor: 'transparent',
          textColor: 'primary',
        );
    }
  }
}
```

## 📏 Text Measurements

### Dynamic Text Sizing
```dart
class DynamicText extends StatelessWidget {
  final String text;
  final double maxWidth;
  
  const DynamicText({
    super.key,
    required this.text,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = 16;
        
        // Test if text fits
        while (fontSize > 10) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(fontSize: fontSize),
            ),
            textDirection: TextDirection.ltr,
          );
          
          textPainter.layout(maxWidth: maxWidth);
          
          if (textPainter.height <= constraints.maxHeight) {
            break;
          }
          
          fontSize -= 0.5;
        }
        
        return AppText(
          text,
          fontSize: fontSize,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
```

### Auto-Sizing Implementation
```dart
class AutoSizeText extends StatelessWidget {
  final String text;
  final double minFontSize;
  final double maxFontSize;
  final int? maxLines;
  
  const AutoSizeText(
    this.text, {
    super.key,
    this.minFontSize = 12,
    this.maxFontSize = 24,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return AppText(
      text,
      autoSize: true,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
      maxLines: maxLines,
    );
  }
}
```

## 🌍 Internationalization

### Multi-Language Support
```dart
class InternationalText extends StatelessWidget {
  final String key;
  final double? fontSize;
  
  const InternationalText(
    this.key, {
    super.key,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    
    // Adjust font size for different languages
    double adjustedFontSize = fontSize ?? 16;
    
    switch (locale.languageCode) {
      case 'zh': // Chinese
        adjustedFontSize *= 1.1; // Slightly larger for Chinese characters
        break;
      case 'ar': // Arabic
        adjustedFontSize *= 1.05; // Adjust for Arabic script
        break;
      case 'ja': // Japanese
        adjustedFontSize *= 1.1; // Adjust for Japanese characters
        break;
    }
    
    return AppText(
      AppLocalizations.of(context).getString(key),
      fontSize: adjustedFontSize,
      textDirection: _getTextDirection(locale),
    );
  }

  TextDirection _getTextDirection(Locale locale) {
    // RTL languages
    if (['ar', 'he', 'fa', 'ur'].contains(locale.languageCode)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }
}
```

## ♿ Accessibility Features

### Screen Reader Support
```dart
class AccessibleText extends StatelessWidget {
  final String text;
  final String? semanticLabel;
  
  const AccessibleText(
    this.text, {
    super.key,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      child: AppText(text),
    );
  }
}
```

### High Contrast Support
```dart
class HighContrastText extends StatelessWidget {
  final String text;
  
  const HighContrastText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isHighContrast = MediaQuery.of(context).highContrast;
    
    return AppText(
      text,
      colorName: isHighContrast ? 'textDark' : 'text',
      fontWeight: isHighContrast ? FontWeight.w600 : FontWeight.normal,
    );
  }
}
```

### Text Scale Factor Support
```dart
class ScalableText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  
  const ScalableText(
    this.text, {
    super.key,
    this.baseFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    // Limit scale factor to prevent layout issues
    final clampedScale = textScaleFactor.clamp(0.8, 1.3);
    
    return AppText(
      text,
      fontSize: baseFontSize * clampedScale,
    );
  }
}
```

## 🔗 Related Documentation

- [Colors](colors.md) - Color system integration
- [Material You](material-you.md) - Dynamic typography
- [AppText Component](../components/app-text.md) - Implementation details
- [Custom Themes](custom-themes.md) - Typography in themes

## 📋 Complete Typography Example

```dart
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../core/theme/app_colors.dart';

class TypographyShowcase extends StatelessWidget {
  const TypographyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Typography System',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisplaySection(),
            const SizedBox(height: 32),
            _buildHeadingSection(),
            const SizedBox(height: 32),
            _buildBodySection(),
            const SizedBox(height: 32),
            _buildFontFamilySection(),
            const SizedBox(height: 32),
            _buildResponsiveSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Display Styles',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        const SizedBox(height: 16),
        
        AppText(
          'Large Display',
          fontSize: 48,
          fontWeight: FontWeight.bold,
          colorName: 'primary',
        ),
        AppText(
          'Medium Display',
          fontSize: 40,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        AppText(
          'Small Display',
          fontSize: 36,
          fontWeight: FontWeight.w600,
          colorName: 'text',
        ),
      ],
    );
  }

  Widget _buildHeadingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Heading Hierarchy',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        const SizedBox(height: 16),
        
        AppText('Heading 1', fontSize: 32, fontWeight: FontWeight.bold),
        AppText('Heading 2', fontSize: 28, fontWeight: FontWeight.w600),
        AppText('Heading 3', fontSize: 24, fontWeight: FontWeight.w600),
        AppText('Heading 4', fontSize: 20, fontWeight: FontWeight.w500),
        AppText('Heading 5', fontSize: 18, fontWeight: FontWeight.w500),
        AppText('Heading 6', fontSize: 16, fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Body Text Styles',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        const SizedBox(height: 16),
        
        AppText(
          'Large body text for important content that needs emphasis.',
          fontSize: 18,
          colorName: 'text',
        ),
        const SizedBox(height: 8),
        
        AppText(
          'Regular body text for main content. This is the primary text size used throughout the application for readability.',
          fontSize: 16,
          colorName: 'text',
        ),
        const SizedBox(height: 8),
        
        AppText(
          'Small body text for secondary information and additional details.',
          fontSize: 14,
          colorName: 'textLight',
        ),
        const SizedBox(height: 8),
        
        AppText(
          'Caption text for metadata, timestamps, and minor labels.',
          fontSize: 12,
          colorName: 'textLight',
        ),
      ],
    );
  }

  Widget _buildFontFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Font Families',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        const SizedBox(height: 16),
        
        AppText(
          'Inter - Modern and clean UI font',
          fontFamily: 'Inter',
          fontSize: 16,
        ),
        AppText(
          'DM Sans - Geometric and friendly',
          fontFamily: 'DM Sans',
          fontSize: 16,
        ),
        AppText(
          'Avenir LT Std - Elegant and sophisticated',
          fontFamily: 'Avenir LT Std',
          fontSize: 16,
        ),
        AppText(
          'Roboto Condensed - Compact for data',
          fontFamily: 'Roboto Condensed',
          fontSize: 16,
        ),
        AppText(
          'Inconsolata - Monospace for code',
          fontFamily: 'Inconsolata',
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildResponsiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Responsive Typography',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          colorName: 'textDark',
        ),
        const SizedBox(height: 16),
        
        LayoutBuilder(
          builder: (context, constraints) {
            double fontSize = 16;
            if (constraints.maxWidth < 400) {
              fontSize = 14;
            } else if (constraints.maxWidth > 800) {
              fontSize = 18;
            }
            
            return AppText(
              'This text adapts its size based on available width. Current size: ${fontSize.toStringAsFixed(0)}px',
              fontSize: fontSize,
              colorName: 'text',
            );
          },
        ),
      ],
    );
  }
}
```

This comprehensive typography system ensures consistent, accessible, and beautiful text styling throughout your Flutter application while supporting multiple languages, screen sizes, and accessibility requirements.
