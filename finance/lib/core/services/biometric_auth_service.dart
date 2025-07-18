import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../settings/app_settings.dart';

@lazySingleton
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enrolled and enabled in settings
  Future<bool> isBiometricSetup() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      final bool isEnabled = AppSettings.biometricEnabled;

      return availableBiometrics.isNotEmpty && isEnabled;
    } catch (e) {
      print('Error checking biometric setup: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometric authentication
  Future<bool> authenticate({
    String? reason,
    bool biometricOnly = false,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if biometric is available and enabled
      final bool isSetup = await isBiometricSetup();
      if (!isSetup) {
        print('Biometric authentication not available or not enabled');
        return false;
      }

      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Please authenticate to access the app',
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
        ),
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication in your device settings',
            biometricHint: 'Touch sensor',
            biometricNotRecognized: 'Biometric not recognized, try again',
            biometricRequiredTitle: 'Biometric Required',
            biometricSuccess: 'Biometric authentication successful',
            deviceCredentialsRequiredTitle: 'Device Credentials Required',
            deviceCredentialsSetupDescription: 'Please set up device credentials in your device settings',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication in your device settings',
            lockOut: 'Biometric authentication is locked out. Please try again later.',
          ),
        ],
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Authentication error: ${e.code} - ${e.message}');
      return _handleAuthenticationError(e);
    } catch (e) {
      print('Unexpected authentication error: $e');
      return false;
    }
  }

  /// Handle authentication errors
  bool _handleAuthenticationError(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        print('Biometric authentication not available');
        return false;
      case auth_error.notEnrolled:
        print('No biometrics enrolled');
        return false;
      case auth_error.lockedOut:
        print('Authentication temporarily locked out');
        return false;
      case auth_error.permanentlyLockedOut:
        print('Authentication permanently locked out');
        return false;
      default:
        print('Authentication error: ${e.code} - ${e.message}');
        return false;
    }
  }

  /// Quick authentication check for app lock
  Future<bool> quickAuthenticate() async {
    return await authenticate(
      reason: 'Unlock the app to continue',
      biometricOnly: true,
      stickyAuth: false,
    );
  }

  /// Check if app lock is enabled
  bool get isAppLockEnabled => AppSettings.biometricAppLock;

  /// Enable/disable app lock
  Future<void> setAppLockEnabled(bool enabled) async {
    await AppSettings.setBiometricAppLock(enabled);
  }

  /// Enable/disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await AppSettings.setBiometricEnabled(enabled);
  }

  /// Get biometric enabled status
  bool get isBiometricEnabled => AppSettings.biometricEnabled;

  /// Get a user-friendly description of available biometrics
  Future<String> getBiometricDescription() async {
    final List<BiometricType> biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
      return 'No biometric authentication available';
    }

    final List<String> descriptions = [];
    
    for (final BiometricType biometric in biometrics) {
      switch (biometric) {
        case BiometricType.face:
          descriptions.add('Face ID');
          break;
        case BiometricType.fingerprint:
          descriptions.add('Fingerprint');
          break;
        case BiometricType.iris:
          descriptions.add('Iris');
          break;
        case BiometricType.strong:
          descriptions.add('Strong biometric');
          break;
        case BiometricType.weak:
          descriptions.add('Weak biometric');
          break;
      }
    }

    return descriptions.join(', ');
  }
}
