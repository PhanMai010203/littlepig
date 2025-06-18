# 🎨 Custom Themes

Learn how to create, customize, and manage custom themes in your Flutter application while maintaining Material You compatibility and accessibility standards.

## 🎯 Overview

Custom themes allow you to:
- **Brand consistency** - Match your company/app branding
- **Unique identity** - Stand out from default Material Design
- **User preferences** - Offer multiple theme options
- **Accessibility** - Ensure proper contrast and usability

## 🚀 Creating Custom Themes

### Basic Custom Theme
```dart
class CustomThemes {
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1), // Indigo
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    
    // Typography
    textTheme: GoogleFonts.interTextTheme(),
    
    // App Bar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
    
    // Cards
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    
    // Dark theme specific adjustments
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
    ),
  );
}
```

### Theme Builder Class
```dart
class ThemeBuilder {
  static ThemeData buildTheme({
    required Color seedColor,
    required Brightness brightness,
    String fontFamily = 'Inter',
    double borderRadius = 8.0,
    double elevation = 2.0,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      
      // Typography
      textTheme: _buildTextTheme(fontFamily, brightness),
      
      // Components
      appBarTheme: _buildAppBarTheme(colorScheme),
      cardTheme: _buildCardTheme(colorScheme, borderRadius, elevation),
      elevatedButtonTheme: _buildButtonTheme(colorScheme, borderRadius),
      inputDecorationTheme: _buildInputTheme(colorScheme, borderRadius),
      
      // Navigation
      navigationBarTheme: _buildNavigationBarTheme(colorScheme),
      bottomAppBarTheme: _buildBottomAppBarTheme(colorScheme),
      
      // Dialogs
      dialogTheme: _buildDialogTheme(colorScheme, borderRadius),
    );
  }

  static TextTheme _buildTextTheme(String fontFamily, Brightness brightness) {
    final baseTheme = brightness == Brightness.light 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme;
        
    return GoogleFonts.getTextTheme(fontFamily, baseTheme);
  }

  static AppBarTheme _buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surfaceTint,
    );
  }

  static CardTheme _buildCardTheme(
    ColorScheme colorScheme,
    double borderRadius,
    double elevation,
  ) {
    return CardTheme(
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  static ElevatedButtonThemeData _buildButtonTheme(
    ColorScheme colorScheme,
    double borderRadius,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
```

## 🎨 Predefined Theme Collections

### Professional Themes
```dart
class ProfessionalThemes {
  // Corporate Blue
  static ThemeData corporate = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF1565C0),
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    borderRadius: 4.0,
    elevation: 1.0,
  );

  // Financial Green
  static ThemeData financial = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF2E7D32),
    brightness: Brightness.light,
    fontFamily: 'Inter',
    borderRadius: 8.0,
    elevation: 2.0,
  );

  // Healthcare Blue
  static ThemeData healthcare = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF0277BD),
    brightness: Brightness.light,
    fontFamily: 'Source Sans Pro',
    borderRadius: 12.0,
    elevation: 3.0,
  );
}
```

### Creative Themes
```dart
class CreativeThemes {
  // Vibrant Purple
  static ThemeData vibrant = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF8E24AA),
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    borderRadius: 16.0,
    elevation: 4.0,
  );

  // Sunset Orange
  static ThemeData sunset = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFFFF6D00),
    brightness: Brightness.light,
    fontFamily: 'Nunito',
    borderRadius: 20.0,
    elevation: 6.0,
  );

  // Ocean Teal
  static ThemeData ocean = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF00ACC1),
    brightness: Brightness.light,
    fontFamily: 'Quicksand',
    borderRadius: 12.0,
    elevation: 2.0,
  );
}
```

### Dark Theme Variants
```dart
class DarkThemes {
  // AMOLED Black
  static ThemeData amoled = ThemeData(
    colorScheme: const ColorScheme.dark(
      background: Color(0xFF000000),
      surface: Color(0xFF111111),
      primary: Color(0xFF6366F1),
    ),
    useMaterial3: true,
  );

  // Midnight Blue
  static ThemeData midnight = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF3F51B5),
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    borderRadius: 8.0,
    elevation: 1.0,
  );

  // Forest Green
  static ThemeData forest = ThemeBuilder.buildTheme(
    seedColor: const Color(0xFF388E3C),
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    borderRadius: 6.0,
    elevation: 2.0,
  );
}
```

## 🔧 Theme Management System

### Theme Manager
```dart
enum ThemeType {
  system,
  light,
  dark,
  corporate,
  creative,
  amoled,
}

class ThemeManager extends ChangeNotifier {
  ThemeType _currentTheme = ThemeType.system;
  Color _customSeedColor = const Color(0xFF6366F1);
  
  ThemeType get currentTheme => _currentTheme;
  Color get customSeedColor => _customSeedColor;
  
  ThemeData get lightTheme {
    switch (_currentTheme) {
      case ThemeType.corporate:
        return ProfessionalThemes.corporate;
      case ThemeType.creative:
        return CreativeThemes.vibrant;
      default:
        return ThemeBuilder.buildTheme(
          seedColor: _customSeedColor,
          brightness: Brightness.light,
        );
    }
  }
  
  ThemeData get darkTheme {
    switch (_currentTheme) {
      case ThemeType.amoled:
        return DarkThemes.amoled;
      case ThemeType.corporate:
        return _buildDarkVariant(ProfessionalThemes.corporate);
      case ThemeType.creative:
        return _buildDarkVariant(CreativeThemes.vibrant);
      default:
        return ThemeBuilder.buildTheme(
          seedColor: _customSeedColor,
          brightness: Brightness.dark,
        );
    }
  }
  
  ThemeMode get themeMode {
    switch (_currentTheme) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
      case ThemeType.amoled:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  void setTheme(ThemeType theme) {
    _currentTheme = theme;
    _saveThemePreference();
    notifyListeners();
  }
  
  void setCustomSeedColor(Color color) {
    _customSeedColor = color;
    _saveThemePreference();
    notifyListeners();
  }
  
  ThemeData _buildDarkVariant(ThemeData lightTheme) {
    final lightScheme = lightTheme.colorScheme;
    return ThemeBuilder.buildTheme(
      seedColor: lightScheme.primary,
      brightness: Brightness.dark,
    );
  }
  
  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_type', _currentTheme.toString());
    await prefs.setInt('custom_seed_color', _customSeedColor.value);
  }
  
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_type');
    final colorValue = prefs.getInt('custom_seed_color');
    
    if (themeString != null) {
      _currentTheme = ThemeType.values.firstWhere(
        (e) => e.toString() == themeString,
        orElse: () => ThemeType.system,
      );
    }
    
    if (colorValue != null) {
      _customSeedColor = Color(colorValue);
    }
    
    notifyListeners();
  }
}
```

### Theme Selector Widget
```dart
class ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Theme Selection',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            
            // Theme type selection
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ThemeType.values.map((theme) {
                return ChoiceChip(
                  label: Text(_getThemeLabel(theme)),
                  selected: themeManager.currentTheme == theme,
                  onSelected: (selected) {
                    if (selected) {
                      themeManager.setTheme(theme);
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Custom color picker
            AppText(
              'Custom Accent Color',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 12),
            
            _buildColorPicker(themeManager),
          ],
        );
      },
    );
  }

  Widget _buildColorPicker(ThemeManager themeManager) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEF4444), // Red
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFEC4899), // Pink
      const Color(0xFF84CC16), // Lime
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((color) {
        final isSelected = themeManager.customSeedColor.value == color.value;
        
        return GestureDetector(
          onTap: () => themeManager.setCustomSeedColor(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  String _getThemeLabel(ThemeType theme) {
    switch (theme) {
      case ThemeType.system:
        return 'System';
      case ThemeType.light:
        return 'Light';
      case ThemeType.dark:
        return 'Dark';
      case ThemeType.corporate:
        return 'Corporate';
      case ThemeType.creative:
        return 'Creative';
      case ThemeType.amoled:
        return 'AMOLED';
    }
  }
}
```

## 🎨 Brand Theme Integration

### Company Branding
```dart
class BrandThemes {
  static ThemeData buildBrandTheme({
    required Color primaryColor,
    required Color secondaryColor,
    Color? accentColor,
    String fontFamily = 'Inter',
    String? logoFontFamily,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      
      // Brand typography
      textTheme: _buildBrandTextTheme(fontFamily, logoFontFamily),
      
      // Custom app bar for branding
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.getFont(
          logoFontFamily ?? fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      
      // Brand-specific components
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  static TextTheme _buildBrandTextTheme(String fontFamily, String? logoFont) {
    final baseTheme = GoogleFonts.getTextTheme(fontFamily);
    
    return baseTheme.copyWith(
      displayLarge: GoogleFonts.getFont(
        logoFont ?? fontFamily,
        textStyle: baseTheme.displayLarge,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: GoogleFonts.getFont(
        logoFont ?? fontFamily,
        textStyle: baseTheme.headlineLarge,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
```

### Multi-Brand Support
```dart
class MultiBrandManager {
  static final Map<String, BrandConfig> _brands = {
    'default': BrandConfig(
      primaryColor: const Color(0xFF6366F1),
      secondaryColor: const Color(0xFF8B5CF6),
      fontFamily: 'Inter',
    ),
    'corporate': BrandConfig(
      primaryColor: const Color(0xFF1565C0),
      secondaryColor: const Color(0xFF1976D2),
      fontFamily: 'Roboto',
      logoFontFamily: 'Roboto Condensed',
    ),
    'startup': BrandConfig(
      primaryColor: const Color(0xFF8E24AA),
      secondaryColor: const Color(0xFF9C27B0),
      fontFamily: 'Poppins',
      logoFontFamily: 'Montserrat',
    ),
  };

  static ThemeData getThemeForBrand(String brandId, Brightness brightness) {
    final brand = _brands[brandId] ?? _brands['default']!;
    
    return BrandThemes.buildBrandTheme(
      primaryColor: brand.primaryColor,
      secondaryColor: brand.secondaryColor,
      accentColor: brand.accentColor,
      fontFamily: brand.fontFamily,
      logoFontFamily: brand.logoFontFamily,
    );
  }
}

class BrandConfig {
  final Color primaryColor;
  final Color secondaryColor;
  final Color? accentColor;
  final String fontFamily;
  final String? logoFontFamily;

  const BrandConfig({
    required this.primaryColor,
    required this.secondaryColor,
    this.accentColor,
    required this.fontFamily,
    this.logoFontFamily,
  });
}
```

## 🔍 Theme Testing and Validation

### Theme Validator
```dart
class ThemeValidator {
  static List<String> validateTheme(ThemeData theme) {
    final issues = <String>[];
    final colorScheme = theme.colorScheme;
    
    // Check contrast ratios
    final primaryContrast = _calculateContrast(
      colorScheme.primary,
      colorScheme.onPrimary,
    );
    if (primaryContrast < 4.5) {
      issues.add('Primary color contrast ratio too low: $primaryContrast');
    }
    
    final surfaceContrast = _calculateContrast(
      colorScheme.surface,
      colorScheme.onSurface,
    );
    if (surfaceContrast < 4.5) {
      issues.add('Surface color contrast ratio too low: $surfaceContrast');
    }
    
    // Check for missing theme properties
    if (theme.textTheme.bodyLarge == null) {
      issues.add('Missing body text style');
    }
    
    if (theme.appBarTheme.backgroundColor == null) {
      issues.add('Missing app bar background color');
    }
    
    return issues;
  }

  static double _calculateContrast(Color color1, Color color2) {
    // Simplified contrast calculation
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
}
```

### Theme Preview Widget
```dart
class ThemePreview extends StatelessWidget {
  final ThemeData theme;
  final String themeName;
  
  const ThemePreview({
    super.key,
    required this.theme,
    required this.themeName,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Builder(
        builder: (themedContext) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    themeName,
                    style: Theme.of(themedContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  // Color swatches
                  _buildColorRow(
                    themedContext,
                    'Primary',
                    theme.colorScheme.primary,
                  ),
                  _buildColorRow(
                    themedContext,
                    'Secondary',
                    theme.colorScheme.secondary,
                  ),
                  _buildColorRow(
                    themedContext,
                    'Surface',
                    theme.colorScheme.surface,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Sample components
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Outlined'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorRow(BuildContext context, String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
```

## 🔗 Related Documentation

- [Colors](colors.md) - Color system fundamentals
- [Typography](typography.md) - Text styling and fonts
- [Material You](material-you.md) - Dynamic theming
- [Components](../components/) - Themed components usage

## 📋 Complete Custom Theme Example

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Complete app with custom theme system
class CustomThemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Custom Theme Demo',
            theme: themeManager.lightTheme,
            darkTheme: themeManager.darkTheme,
            themeMode: themeManager.themeMode,
            home: const ThemeShowcasePage(),
          );
        },
      ),
    );
  }
}

class ThemeShowcasePage extends StatelessWidget {
  const ThemeShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Themes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => _showThemeSelector(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Theme',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Primary: #${theme.colorScheme.primary.value.toRadixString(16).toUpperCase()}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Surface: #${theme.colorScheme.surface.value.toRadixString(16).toUpperCase()}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Component examples
            Text(
              'Component Examples',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Elevated Button'),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Filled Button'),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Outlined Button'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Text Button'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Cards
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Card',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is an example of how cards look with the current theme.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Form elements
            TextField(
              decoration: const InputDecoration(
                labelText: 'Sample Input',
                hintText: 'Enter some text',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: ThemeSelector(),
      ),
    );
  }
}
```

This comprehensive custom theme system provides flexibility, consistency, and excellent user experience while maintaining accessibility and performance standards.
