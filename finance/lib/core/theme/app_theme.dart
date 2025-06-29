import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';
import '../settings/app_settings.dart';
import 'material_you.dart';

/// Main theme configuration class
class AppTheme {
  /// Get platform-appropriate splash factory
  /// Keeps Material splash effects on Android, removes them on iOS
  static InteractiveInkFeatureFactory get _platformSplashFactory {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return NoSplash.splashFactory;
    }
    return InkRipple.splashFactory; // Material Design default
  }

  /// Create light theme
  static ThemeData light({Color? accentColor}) {
    final accent = accentColor ?? MaterialYouManager.getAccentColor();

    final colorScheme = MaterialYouManager.createColorScheme(
      brightness: Brightness.light,
      fallbackSeedColor: accent,
    );

    final themeData = ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      useMaterial3: true,
      textTheme: AppTextTheme.textTheme,
      fontFamily: 'Inter',

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: accent,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
      ),

      // Platform-aware splash effects: disabled on iOS, enabled on Android
      splashFactory: _platformSplashFactory,
      
      // Keep Material ink effects for better touch feedback
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    // Add custom colors extension
    return themeData.copyWith(
      extensions: [
        getAppColors(
          brightness: Brightness.light,
          themeData: themeData,
          accentColor: accent,
        ),
      ],
    );
  }

  /// Create dark theme
  static ThemeData dark({Color? accentColor}) {
    final accent = accentColor ?? MaterialYouManager.getAccentColor();

    final colorScheme = MaterialYouManager.createColorScheme(
      brightness: Brightness.dark,
      fallbackSeedColor: accent,
    );

    final themeData = ThemeData(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      useMaterial3: true,
      textTheme: AppTextTheme.textTheme,
      fontFamily: 'Inter',

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          splashFactory: _platformSplashFactory,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: accent,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        elevation: 8,
      ),

      // Platform-aware splash effects: disabled on iOS, enabled on Android
      splashFactory: _platformSplashFactory,
      
      // Keep Material ink effects for better touch feedback
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    // Add custom colors extension
    return themeData.copyWith(
      extensions: [
        getAppColors(
          brightness: Brightness.dark,
          themeData: themeData,
          accentColor: accent,
        ),
      ],
    );
  }

  /// Get current theme mode from settings
  static ThemeMode get themeMode => AppSettings.themeMode;

  /// Update theme and notify app
  static Future<void> setThemeMode(ThemeMode mode) async {
    await AppSettings.setThemeMode(mode);
  }

  /// Update accent color and notify app
  static Future<void> setAccentColor(Color color) async {
    await AppSettings.setAccentColor(color);
  }

  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get text theme for current context
  static TextTheme getTextTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  /// Get color scheme for current context
  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }
}
