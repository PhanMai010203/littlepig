# 🎨 Theming System

Welcome to the comprehensive theming documentation! This section covers everything you need to create beautiful, consistent, and accessible themes for your Flutter application.

## 📚 Documentation Structure

### Core Theming Concepts
- **[Colors](colors.md)** - Color system and semantic naming
- **[Typography](typography.md)** - Text styling and font management
- **[Material You](material-you.md)** - Dynamic theming integration
- **[Custom Themes](custom-themes.md)** - Creating and managing custom themes

## 🎯 Quick Navigation

### Getting Started with Theming
- [Color Basics](colors.md#basic-color-access) - Using colors in your app
- [Text Styling](typography.md#font-hierarchy) - Typography hierarchy
- [Theme Setup](custom-themes.md#basic-custom-theme) - Creating themes
- [Material You Setup](material-you.md#setting-up-material-you) - Dynamic colors

### Advanced Features
- [Color Harmonization](material-you.md#color-harmonization) - Cohesive color palettes
- [Responsive Typography](typography.md#responsive-typography) - Screen size adaptation
- [Theme Management](custom-themes.md#theme-management-system) - Theme switching
- [Accessibility](colors.md#color-accessibility) - WCAG compliance

## 🚀 Theming Philosophy

### Design Principles

**🎨 Semantic Colors**
Use meaningful color names instead of specific values:
```dart
// ✅ Good - Semantic naming
AppText('Success message', colorName: 'success')

// ❌ Avoid - Hardcoded colors
AppText('Success message', style: TextStyle(color: Colors.green))
```

**📱 Responsive Design**
Ensure themes work across all screen sizes:
```dart
// Typography adapts to screen size
AppText(
  'Responsive heading',
  fontSize: MediaQuery.of(context).size.width > 600 ? 28 : 24,
)
```

**♿ Accessibility First**
Maintain proper contrast ratios:
```dart
// High contrast text combinations
AppText(
  'Important message',
  colorName: 'textDark', // 7:1 contrast ratio
)
```

**🔄 Theme Consistency**
All components use the same theming system:
```dart
// Consistent across all widgets
Container(color: getColor(context, 'surface'))
AppText('Text', colorName: 'text')
AdaptiveButton(style: ButtonStyle.primary)
```

## 🎨 Color System Overview

### Color Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| **Primary** | Brand colors | `primary`, `primaryLight`, `primaryDark` |
| **Text** | Text hierarchy | `text`, `textLight`, `textDark` |
| **Surface** | Backgrounds | `background`, `surface`, `surfaceVariant` |
| **Status** | Feedback | `success`, `error`, `warning`, `info` |
| **Absolute** | Fixed colors | `white`, `black`, `transparent` |

### Usage Examples
```dart
// Primary brand color
Container(color: getColor(context, 'primary'))

// Text with proper hierarchy
AppText('Heading', colorName: 'textDark')
AppText('Body text', colorName: 'text')
AppText('Caption', colorName: 'textLight')

// Status feedback
AppText('Success!', colorName: 'success')
AppText('Error occurred', colorName: 'error')
```

## ✍️ Typography System Overview

### Font Hierarchy

| Level | Size | Weight | Usage |
|-------|------|--------|-------|
| **Display** | 48-36px | Bold | Hero sections |
| **Heading** | 32-16px | Semi-Bold | Page/section headers |
| **Body** | 18-14px | Regular | Main content |
| **Caption** | 12px | Regular | Metadata, labels |

### Font Families Available
- **Inter** - Modern UI font (primary)
- **DM Sans** - Geometric alternative
- **Roboto Condensed** - Data and numbers
- **Avenir LT Std** - Premium feel
- **Metropolis** - Branding
- **Inconsolata** - Code/monospace

```dart
// Using different font families
AppText('UI Text', fontFamily: 'Inter')
AppText('Brand Title', fontFamily: 'Avenir LT Std')
AppText('Code: var x = 10;', fontFamily: 'Inconsolata')
```

## 🎨 Material You Integration

### Dynamic Color Features
- **Wallpaper extraction** - Colors from user's wallpaper
- **System integration** - Android 12+ dynamic colors
- **Automatic harmonization** - Cohesive color palettes
- **Fallback themes** - Custom themes when unavailable

```dart
// Material You setup
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    return MaterialApp(
      theme: _buildTheme(lightDynamic, Brightness.light),
      darkTheme: _buildTheme(darkDynamic, Brightness.dark),
    );
  },
)
```

## 🛠️ Custom Theme Creation

### Theme Builder Approach
```dart
// Create custom themes easily
ThemeData myTheme = ThemeBuilder.buildTheme(
  seedColor: Color(0xFF6366F1),
  brightness: Brightness.light,
  fontFamily: 'Inter',
  borderRadius: 8.0,
  elevation: 2.0,
);
```

### Brand Integration
```dart
// Brand-specific themes
ThemeData brandTheme = BrandThemes.buildBrandTheme(
  primaryColor: brandColors.primary,
  secondaryColor: brandColors.secondary,
  fontFamily: 'Corporate Font',
  logoFontFamily: 'Brand Font',
);
```

## 📱 Implementation Patterns

### Basic Theme Usage
```dart
class ThemedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Themed Page',
      body: Column(
        children: [
          // Theme-aware container
          Container(
            color: getColor(context, 'surface'),
            child: AppText(
              'Theme-aware content',
              colorName: 'text',
            ),
          ),
          
          // Theme-aware button
          AdaptiveButton(
            text: 'Primary Action',
            style: ButtonStyle.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
```

### Theme Switching
```dart
class ThemeControlWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Column(
          children: [
            // Theme mode switcher
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ],
              selected: {themeManager.themeMode},
              onSelectionChanged: (selection) {
                themeManager.setThemeMode(selection.first);
              },
            ),
            
            // Color picker
            ThemeSelector(),
          ],
        );
      },
    );
  }
}
```

## ♿ Accessibility Guidelines

### Contrast Requirements
- **Normal text**: 4.5:1 minimum contrast ratio
- **Large text**: 3:1 minimum contrast ratio
- **UI components**: 3:1 minimum contrast ratio

### Implementation
```dart
// High contrast text
AppText(
  'Important message',
  colorName: 'textDark', // 7:1 contrast
  fontWeight: FontWeight.bold,
)

// Accessible color combinations
Container(
  color: getColor(context, 'surface'),
  child: AppText(
    'Accessible content',
    colorName: 'text', // 4.5:1 contrast
  ),
)
```

### Screen Reader Support
```dart
// Semantic labels for themes
Semantics(
  label: 'Dark theme toggle',
  child: Switch(
    value: isDarkMode,
    onChanged: (value) => toggleTheme(),
  ),
)
```

## 📊 Performance Best Practices

### Efficient Color Access
```dart
// ✅ Good - Cache colors for performance
class CachedColorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = _CachedColors(context);
    
    return Container(
      color: colors.surface,
      child: AppText('Cached colors', textColor: colors.text),
    );
  }
}

class _CachedColors {
  _CachedColors(BuildContext context)
      : surface = getColor(context, 'surface'),
        text = getColor(context, 'text');
        
  final Color surface;
  final Color text;
}
```

### Theme Rebuilds
```dart
// ✅ Good - Minimize theme-dependent rebuilds
class OptimizedThemedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StaticWidget(), // Doesn't rebuild on theme change
        ThemedWidget(), // Only this rebuilds
      ],
    );
  }
}
```

## 🔧 Troubleshooting Common Issues

### Colors Not Updating
**Problem**: Colors don't change when switching themes
```dart
// ❌ Problem
Container(color: Colors.blue) // Hardcoded

// ✅ Solution
Container(color: getColor(context, 'primary')) // Theme-aware
```

### Text Contrast Issues
**Problem**: Text is hard to read
```dart
// ❌ Problem
AppText('Text', colorName: 'textLight') // On light background

// ✅ Solution
AppText('Text', colorName: 'textDark') // Better contrast
```

### Performance Issues
**Problem**: Frequent theme rebuilds
```dart
// ❌ Problem
Widget build(BuildContext context) {
  return Container(
    color: getColor(context, 'surface'), // Called every rebuild
  );
}

// ✅ Solution - Cache colors
Widget build(BuildContext context) {
  final surfaceColor = getColor(context, 'surface');
  return Container(color: surfaceColor);
}
```

## 🌟 Advanced Theming Techniques

### Dynamic Theme Generation
```dart
// Generate themes from single color
ColorScheme generateScheme(Color seedColor, Brightness brightness) {
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  ).harmonized();
}
```

### Multi-Brand Support
```dart
// Support multiple brands
class MultiBrandApp extends StatelessWidget {
  final String brandId;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: MultiBrandManager.getThemeForBrand(brandId, Brightness.light),
      darkTheme: MultiBrandManager.getThemeForBrand(brandId, Brightness.dark),
    );
  }
}
```

### Theme Animation
```dart
// Smooth theme transitions
AnimatedTheme(
  duration: const Duration(milliseconds: 300),
  data: currentTheme,
  child: MaterialApp(...),
)
```

## 🔗 Integration Examples

### Complete App Setup
```dart
class ThemedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              return MaterialApp(
                theme: themeManager.buildLightTheme(lightDynamic),
                darkTheme: themeManager.buildDarkTheme(darkDynamic),
                themeMode: themeManager.themeMode,
                home: const HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}
```

## 📚 Learning Path

### Beginner
1. Start with [Colors](colors.md) to understand the color system
2. Learn [Typography](typography.md) for text styling
3. Practice with basic theme-aware widgets

### Intermediate
1. Explore [Material You](material-you.md) for dynamic theming
2. Create [Custom Themes](custom-themes.md) for your brand
3. Implement theme switching functionality

### Advanced
1. Build multi-brand theme systems
2. Create custom theme animations
3. Optimize theme performance
4. Implement accessibility features

## 🎯 Next Steps

Choose your starting point based on your needs:

- **New to theming?** → Start with [Colors](colors.md)
- **Want dynamic themes?** → Jump to [Material You](material-you.md)
- **Need custom branding?** → Explore [Custom Themes](custom-themes.md)
- **Typography focused?** → Check out [Typography](typography.md)

Each section provides comprehensive examples, best practices, and complete implementations to help you create beautiful, accessible, and performant themes for your Flutter application.
