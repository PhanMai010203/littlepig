import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Platform detection and device capabilities service for animation framework
/// Based on the plan specifications for Phase 1
enum PlatformOS {
  isIOS,
  isAndroid,
  isWeb,
  isDesktop,
  isLinux,
  isMacOS,
  isWindows,
}

/// Platform service for centralized platform detection and capabilities
class PlatformService {
  static PlatformOS _cachedPlatform = _detectPlatform();

  /// Get the current platform
  static PlatformOS getPlatform() {
    return _cachedPlatform;
  }

  /// Detect platform at startup
  static PlatformOS _detectPlatform() {
    if (kIsWeb) {
      return PlatformOS.isWeb;
    }

    if (Platform.isIOS) {
      return PlatformOS.isIOS;
    }

    if (Platform.isAndroid) {
      return PlatformOS.isAndroid;
    }

    if (Platform.isMacOS) {
      return PlatformOS.isMacOS;
    }

    if (Platform.isWindows) {
      return PlatformOS.isWindows;
    }

    if (Platform.isLinux) {
      return PlatformOS.isLinux;
    }

    // Fallback to desktop for unknown platforms
    return PlatformOS.isDesktop;
  }

  /// Check if the current platform is mobile
  static bool get isMobile {
    final platform = getPlatform();
    return platform == PlatformOS.isIOS || platform == PlatformOS.isAndroid;
  }

  /// Check if the current platform is desktop
  static bool get isDesktop {
    final platform = getPlatform();
    return platform == PlatformOS.isMacOS ||
        platform == PlatformOS.isWindows ||
        platform == PlatformOS.isLinux ||
        platform == PlatformOS.isDesktop;
  }

  /// Check if the current platform is web
  static bool get isWeb {
    return getPlatform() == PlatformOS.isWeb;
  }

  /// Check if the current platform supports material design 3 fully
  static bool get supportsMaterial3 {
    // All platforms support Material 3, but with different implementations
    return true;
  }

  /// Check if the platform supports complex animations
  static bool get supportsComplexAnimations {
    // Web and older devices might have performance limitations
    if (isWeb) return false; // Conservative for web
    return true; // Mobile and desktop support complex animations
  }

  /// Get platform-specific animation curve preferences
  static Curve get platformCurve {
    switch (getPlatform()) {
      case PlatformOS.isIOS:
        return Curves.easeInOutCubic; // iOS prefers smoother curves
      case PlatformOS.isAndroid:
        return Curves.easeInOutCubicEmphasized; // Material Design 3 curve
      case PlatformOS.isWeb:
        return Curves.easeInOut; // Simpler curves for web performance
      default:
        return Curves.easeInOutCubic; // Default for desktop
    }
  }

  /// Get platform-specific default animation duration
  static Duration get platformAnimationDuration {
    switch (getPlatform()) {
      case PlatformOS.isIOS:
        return const Duration(milliseconds: 350); // iOS standard
      case PlatformOS.isAndroid:
        return const Duration(milliseconds: 300); // Material Design standard
      case PlatformOS.isWeb:
        return const Duration(milliseconds: 200); // Faster for web
      default:
        return const Duration(milliseconds: 250); // Desktop standard
    }
  }

  /// Check if the current screen size indicates a full-screen device
  static bool getIsFullScreen(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    // Check for notch or dynamic island (iOS)
    if (getPlatform() == PlatformOS.isIOS) {
      return padding.top > 30; // Devices with notch/dynamic island
    }

    // Check for full screen Android devices
    if (getPlatform() == PlatformOS.isAndroid) {
      final aspectRatio = size.height / size.width;
      return aspectRatio > 2.0; // Modern full-screen Android devices
    }

    // For desktop/web, consider full screen if maximized
    if (isDesktop || isWeb) {
      return size.width > 1200 && size.height > 800;
    }

    return false;
  }

  /// Get platform-specific safe padding considerations
  static EdgeInsets getPlatformSafePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;

    switch (getPlatform()) {
      case PlatformOS.isIOS:
        // iOS handles safe areas well, trust the system
        return EdgeInsets.fromLTRB(
            padding.left, padding.top, padding.right, padding.bottom);

      case PlatformOS.isAndroid:
        // Android might need additional bottom padding for gesture navigation
        return EdgeInsets.fromLTRB(padding.left, padding.top, padding.right,
            padding.bottom + (padding.bottom > 0 ? 8 : 0));

      default:
        // Desktop/web typically don't need safe area padding
        return EdgeInsets.zero;
    }
  }

  /// Check if platform supports haptic feedback
  static bool get supportsHaptics {
    return isMobile; // Only mobile devices typically support haptics
  }

  /// Get platform-specific dialog positioning preference
  static bool get prefersCenteredDialogs {
    // iOS prefers centered dialogs, Android can use bottom sheets
    return getPlatform() == PlatformOS.isIOS || isDesktop;
  }

  /// Debug information about current platform
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': getPlatform().toString(),
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isWeb': isWeb,
      'supportsComplexAnimations': supportsComplexAnimations,
      'supportsMaterial3': supportsMaterial3,
      'supportsHaptics': supportsHaptics,
      'prefersCenteredDialogs': prefersCenteredDialogs,
      'platformCurve': platformCurve.toString(),
      'platformAnimationDuration': platformAnimationDuration.inMilliseconds,
    };
  }
}
