# 🎨 Material You Integration

Material You brings dynamic theming and personalization to your Flutter app, automatically adapting colors based on the user's wallpaper and preferences.

## 🎯 Overview

Material You features included:
- **Dynamic color extraction** - Colors from user's wallpaper
- **Automatic theme generation** - Light and dark variants
- **Color harmonization** - Cohesive color palettes
- **Accessibility compliance** - Proper contrast ratios

## 🚀 Setting Up Material You

### Basic Configuration
```dart
// main.dart
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightScheme;
        ColorScheme darkScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // Use dynamic colors if available
          lightScheme = lightDynamic.harmonized();
          darkScheme = darkDynamic.harmonized();
        } else {
          // Fallback to default color scheme
          lightScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
          );
          darkScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'Material You App',
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme,
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
```

### Advanced Setup with Custom Fallbacks
```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          theme: _buildTheme(lightDynamic, Brightness.light),
          darkTheme: _buildTheme(darkDynamic, Brightness.dark),
          themeMode: ThemeMode.system,
          home: const HomePage(),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme? dynamicScheme, Brightness brightness) {
    ColorScheme scheme;
    
    if (dynamicScheme != null) {
      // Use dynamic colors with harmonization
      scheme = dynamicScheme.harmonized();
    } else {
      // Custom fallback colors
      scheme = ColorScheme.fromSeed(
        seedColor: _getBrandColor(),
        brightness: brightness,
      );
    }

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      
      // Custom component themes
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      
      cardTheme: CardTheme(
        color: scheme.surfaceVariant,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Color _getBrandColor() {
    // Your brand color as fallback
    return const Color(0xFF6750A4);
  }
}
```

## 🎨 Dynamic Color Usage

### Accessing Dynamic Colors
```dart
class DynamicColorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Dynamic Color Card',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              textColor: colorScheme.onPrimary,
            ),
            AppText(
              'This card adapts to the user\'s system colors',
              fontSize: 14,
              textColor: colorScheme.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Material You Color Roles
```dart
class MaterialYouColorShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Column(
      children: [
        _buildColorRow(
          'Primary',
          scheme.primary,
          scheme.onPrimary,
        ),
        _buildColorRow(
          'Primary Container',
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
        ),
        _buildColorRow(
          'Secondary',
          scheme.secondary,
          scheme.onSecondary,
        ),
        _buildColorRow(
          'Secondary Container',
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
        _buildColorRow(
          'Tertiary',
          scheme.tertiary,
          scheme.onTertiary,
        ),
        _buildColorRow(
          'Surface',
          scheme.surface,
          scheme.onSurface,
        ),
        _buildColorRow(
          'Error',
          scheme.error,
          scheme.onError,
        ),
      ],
    );
  }

  Widget _buildColorRow(String name, Color backgroundColor, Color textColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            name,
            fontWeight: FontWeight.w500,
            textColor: textColor,
          ),
          AppText(
            '#${backgroundColor.value.toRadixString(16).toUpperCase()}',
            fontFamily: 'Inconsolata',
            fontSize: 12,
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}
```

## 🔄 Color Harmonization

### Custom Harmonization
```dart
extension ColorSchemeHarmonization on ColorScheme {
  ColorScheme harmonized() {
    return copyWith(
      // Harmonize secondary colors with primary
      secondary: Color.alphaBlend(
        primary.withOpacity(0.15),
        secondary,
      ),
      
      // Harmonize tertiary colors
      tertiary: Color.alphaBlend(
        primary.withOpacity(0.1),
        tertiary,
      ),
      
      // Harmonize error color slightly
      error: Color.alphaBlend(
        primary.withOpacity(0.05),
        error,
      ),
    );
  }
}
```

### Contextual Color Harmonization
```dart
class HarmonizedWidget extends StatelessWidget {
  final Color baseColor;
  final Widget child;
  
  const HarmonizedWidget({
    super.key,
    required this.baseColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    // Harmonize the base color with the current scheme
    final harmonizedColor = Color.alphaBlend(
      scheme.primary.withOpacity(0.1),
      baseColor,
    );
    
    return Container(
      decoration: BoxDecoration(
        color: harmonizedColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
```

## 📱 Platform Integration

### Android Dynamic Colors
```dart
class AndroidDynamicColors {
  static bool isSupported() {
    // Check if Android 12+ (API level 31+)
    return Platform.isAndroid; // Add proper version check
  }
  
  static Future<ColorScheme?> getSystemColorScheme(Brightness brightness) async {
    if (!isSupported()) return null;
    
    try {
      // This would use platform channels to get system colors
      final dynamic colorData = await _getSystemColors();
      
      if (colorData != null) {
        return ColorScheme.fromSeed(
          seedColor: Color(colorData['accent']),
          brightness: brightness,
        );
      }
    } catch (e) {
      print('Error getting system colors: $e');
    }
    
    return null;
  }
  
  static Future<Map<String, dynamic>?> _getSystemColors() async {
    // Implementation would use platform channels
    // This is a placeholder
    return null;
  }
}
```

### iOS Dynamic Colors (Future Support)
```dart
class iOSDynamicColors {
  static bool isSupported() {
    // When iOS supports Material You-style dynamic colors
    return false; // Platform.isIOS && version >= someVersion;
  }
  
  static Future<ColorScheme?> getSystemColorScheme(Brightness brightness) async {
    // Future implementation for iOS dynamic colors
    return null;
  }
}
```

## 🎯 Custom Material You Implementation

### Color Extraction from Images
```dart
import 'package:material_color_utilities/material_color_utilities.dart';

class CustomColorExtraction {
  static Future<ColorScheme> extractFromImage(
    ImageProvider imageProvider,
    Brightness brightness,
  ) async {
    try {
      // Load the image
      final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
      final Completer<ImageInfo> completer = Completer();
      
      late ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info);
        stream.removeListener(listener);
      });
      
      stream.addListener(listener);
      final ImageInfo imageInfo = await completer.future;
      
      // Extract pixels
      final ByteData? byteData = await imageInfo.image.toByteData();
      if (byteData == null) throw Exception('Could not extract image data');
      
      final List<int> pixels = byteData.buffer.asUint8List();
      
      // Use Material Color Utilities to extract colors
      final QuantizerResult result = await QuantizerCelebi().quantize(pixels, 128);
      final CorePalette palette = CorePalette.of(result.colorToCount.keys.first);
      
      // Generate color scheme
      return ColorScheme.fromSeed(
        seedColor: Color(palette.primary.get(40)),
        brightness: brightness,
      );
    } catch (e) {
      print('Error extracting colors: $e');
      // Fallback to default
      return ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        brightness: brightness,
      );
    }
  }
}
```

### Dynamic Theme Switching
```dart
class DynamicThemeManager extends ChangeNotifier {
  ColorScheme? _lightScheme;
  ColorScheme? _darkScheme;
  bool _isDynamicColorsEnabled = true;
  
  ColorScheme? get lightScheme => _lightScheme;
  ColorScheme? get darkScheme => _darkScheme;
  bool get isDynamicColorsEnabled => _isDynamicColorsEnabled;
  
  Future<void> updateDynamicColors() async {
    if (!_isDynamicColorsEnabled) return;
    
    try {
      // Get system colors if available
      final lightDynamic = await AndroidDynamicColors.getSystemColorScheme(Brightness.light);
      final darkDynamic = await AndroidDynamicColors.getSystemColorScheme(Brightness.dark);
      
      if (lightDynamic != null && darkDynamic != null) {
        _lightScheme = lightDynamic.harmonized();
        _darkScheme = darkDynamic.harmonized();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating dynamic colors: $e');
    }
  }
  
  void setDynamicColorsEnabled(bool enabled) {
    _isDynamicColorsEnabled = enabled;
    notifyListeners();
  }
  
  Future<void> extractColorsFromWallpaper(ImageProvider wallpaper) async {
    try {
      _lightScheme = await CustomColorExtraction.extractFromImage(
        wallpaper,
        Brightness.light,
      );
      _darkScheme = await CustomColorExtraction.extractFromImage(
        wallpaper,
        Brightness.dark,
      );
      notifyListeners();
    } catch (e) {
      print('Error extracting wallpaper colors: $e');
    }
  }
}
```

## 🎨 Material You Components

### Dynamic Floating Action Button
```dart
class DynamicFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  
  const DynamicFAB({
    super.key,
    this.onPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      elevation: 3,
      child: child ?? Icon(Icons.add),
    );
  }
}
```

### Material You Navigation Bar
```dart
class DynamicNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItem> items;
  
  const DynamicNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon ?? item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }
}
```

### Dynamic Card Design
```dart
class MaterialYouCard extends StatelessWidget {
  final Widget child;
  final bool isElevated;
  
  const MaterialYouCard({
    super.key,
    required this.child,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      color: isElevated ? scheme.surfaceVariant : scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      elevation: isElevated ? 6 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
```

## 🔧 Migration from Legacy Themes

### Migrating Color References
```dart
// Before (Legacy)
Container(
  color: Colors.blue,
  child: Text(
    'Legacy styling',
    style: TextStyle(color: Colors.white),
  ),
)

// After (Material You)
Container(
  color: getColor(context, 'primary'),
  child: AppText(
    'Material You styling',
    colorName: 'onPrimary',
  ),
)

// Or using Theme.of(context)
Container(
  color: Theme.of(context).colorScheme.primary,
  child: Text(
    'Material You styling',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onPrimary,
    ),
  ),
)
```

### Component Migration
```dart
// Before
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    primary: Colors.blue,
    onPrimary: Colors.white,
  ),
  child: Text('Button'),
)

// After
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
  ),
  child: Text('Button'),
)
```

## 🔗 Related Documentation

- [Colors](colors.md) - Color system fundamentals
- [Typography](typography.md) - Text styling integration
- [Custom Themes](custom-themes.md) - Creating custom themes
- [Components](../components/) - Material You components

## 📋 Complete Material You Example

```dart
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/page_template.dart';

class MaterialYouShowcase extends StatelessWidget {
  const MaterialYouShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          theme: _buildTheme(lightDynamic, Brightness.light),
          darkTheme: _buildTheme(darkDynamic, Brightness.dark),
          home: const MaterialYouDemo(),
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme? dynamicScheme, Brightness brightness) {
    ColorScheme scheme = dynamicScheme?.harmonized() ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: brightness,
        );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
    );
  }
}

class MaterialYouDemo extends StatefulWidget {
  const MaterialYouDemo({super.key});

  @override
  State<MaterialYouDemo> createState() => _MaterialYouDemoState();
}

class _MaterialYouDemoState extends State<MaterialYouDemo> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: PageTemplate(
        title: 'Material You',
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section with dynamic colors
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scheme.primary,
                      scheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Dynamic Colors',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      textColor: scheme.onPrimary,
                    ),
                    AppText(
                      'Adapts to your wallpaper and preferences',
                      fontSize: 16,
                      textColor: scheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Color palette grid
              AppText(
                'Color Palette',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2,
                children: [
                  _buildColorCard('Primary', scheme.primary, scheme.onPrimary),
                  _buildColorCard('Secondary', scheme.secondary, scheme.onSecondary),
                  _buildColorCard('Tertiary', scheme.tertiary, scheme.onTertiary),
                  _buildColorCard('Surface', scheme.surface, scheme.onSurface),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Component examples
              AppText(
                'Components',
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Elevated'),
                  ),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Filled'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Cards with different elevations
              Card(
                color: scheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppText(
                    'Surface Variant Card',
                    textColor: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Card(
                elevation: 6,
                surfaceTintColor: scheme.surfaceTint,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppText(
                    'Elevated Card with Surface Tint',
                    textColor: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: const Icon(Icons.palette),
      ),
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: 'Colors',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(String name, Color color, Color onColor) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: AppText(
          name,
          fontWeight: FontWeight.w500,
          textColor: onColor,
        ),
      ),
    );
  }
}
```

This Material You integration provides a modern, personalized experience that adapts to each user's preferences while maintaining accessibility and design consistency.
