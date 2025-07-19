import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:easy_localization/easy_localization.dart';
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
        print('biometric.not_available_or_enabled'.tr());
        return false;
      }

      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'biometric.authenticate_reason_default'.tr(),
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'biometric.authentication_title'.tr(),
            cancelButton: 'biometric.cancel_button'.tr(),
            goToSettingsButton: 'biometric.settings_button'.tr(),
            goToSettingsDescription: 'biometric.setup_description'.tr(),
            biometricHint: 'biometric.touch_sensor_hint'.tr(),
            biometricNotRecognized: 'biometric.not_recognized'.tr(),
            biometricRequiredTitle: 'biometric.biometric_required_title'.tr(),
            biometricSuccess: 'biometric.authentication_successful'.tr(),
            deviceCredentialsRequiredTitle: 'biometric.device_credentials_required_title'.tr(),
            deviceCredentialsSetupDescription: 'biometric.device_credentials_setup_description'.tr(),
          ),
          IOSAuthMessages(
            cancelButton: 'biometric.cancel_button'.tr(),
            goToSettingsButton: 'biometric.settings_button'.tr(),
            goToSettingsDescription: 'biometric.setup_description'.tr(),
            lockOut: 'biometric.locked_out'.tr(),
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

  /// Authenticate for initial setup - bypasses app setting check
  Future<bool> authenticateForSetup({
    String? reason,
    bool biometricOnly = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Only check if biometric is available on device (not app setting)
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('biometric.not_available_on_device'.tr());
        return false;
      }

      // Check if biometrics are enrolled
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('biometric.no_biometrics_enrolled'.tr());
        return false;
      }

      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'biometric.authenticate_reason_setup'.tr(),
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'biometric.enable_security_title'.tr(),
            cancelButton: 'biometric.cancel_button'.tr(),
            goToSettingsButton: 'biometric.settings_button'.tr(),
            goToSettingsDescription: 'biometric.setup_description'.tr(),
            biometricHint: 'biometric.touch_sensor_setup_hint'.tr(),
            biometricNotRecognized: 'biometric.not_recognized'.tr(),
            biometricRequiredTitle: 'biometric.biometric_required_title'.tr(),
            biometricSuccess: 'biometric.security_enabled_successful'.tr(),
            deviceCredentialsRequiredTitle: 'biometric.device_credentials_required_title'.tr(),
            deviceCredentialsSetupDescription: 'biometric.device_credentials_setup_description'.tr(),
          ),
          IOSAuthMessages(
            cancelButton: 'biometric.cancel_button'.tr(),
            goToSettingsButton: 'biometric.settings_button'.tr(),
            goToSettingsDescription: 'biometric.setup_description'.tr(),
            lockOut: 'biometric.locked_out'.tr(),
          ),
        ],
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Setup authentication error: ${e.code} - ${e.message}');
      return _handleAuthenticationError(e);
    } catch (e) {
      print('Unexpected setup authentication error: $e');
      return false;
    }
  }

  /// Handle authentication errors
  bool _handleAuthenticationError(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        print('biometric.not_available'.tr());
        return false;
      case auth_error.notEnrolled:
        print('biometric.not_enrolled'.tr());
        return false;
      case auth_error.lockedOut:
        print('biometric.temporarily_locked_out'.tr());
        return false;
      case auth_error.permanentlyLockedOut:
        print('biometric.permanently_locked_out'.tr());
        return false;
      default:
        print('Authentication error: ${e.code} - ${e.message}');
        return false;
    }
  }

  /// Quick authentication check for app lock
  Future<bool> quickAuthenticate() async {
    try {
      // Use device-level authentication for app unlock
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('biometric.not_available_on_device'.tr());
        return false;
      }

      // Check if biometrics are enrolled
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('biometric.no_biometrics_enrolled'.tr());
        return false;
      }

      // Perform authentication
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'biometric.authenticate_reason_unlock'.tr(),
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: false,
          useErrorDialogs: true,
        ),
        authMessages: <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'biometric.unlock_app_title'.tr(),
            cancelButton: 'biometric.cancel_button'.tr(),
            goToSettingsButton: 'biometric.settings_button'.tr(),
            goToSettingsDescription: 'biometric.setup_description'.tr(),
            biometricHint: 'biometric.touch_sensor_unlock_hint'.tr(),
            biometricNotRecognized: 'biometric.not_recognized'.tr(),
            biometricRequiredTitle: 'biometric.unlock_required_title'.tr(),
            biometricSuccess: 'biometric.unlock_successful'.tr(),
            deviceCredentialsRequiredTitle: 'biometric.device_credentials_required_title'.tr(),
            deviceCredentialsSetupDescription: 'biometric.device_credentials_setup_description'.tr(),
          ),
          IOSAuthMessages(
            cancelButton: 'biometric.cancel_button'.tr(),
            goToSettingsButton: 'biometric.settings_button'.tr(),
            goToSettingsDescription: 'biometric.setup_description'.tr(),
            lockOut: 'biometric.locked_out'.tr(),
          ),
        ],
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Quick authentication error: ${e.code} - ${e.message}');
      return _handleAuthenticationError(e);
    } catch (e) {
      print('Unexpected quick authentication error: $e');
      return false;
    }
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
      return 'biometric.no_biometric_available'.tr();
    }

    final List<String> descriptions = [];
    
    for (final BiometricType biometric in biometrics) {
      switch (biometric) {
        case BiometricType.face:
          descriptions.add('biometric.face_id'.tr());
          break;
        case BiometricType.fingerprint:
          descriptions.add('biometric.fingerprint'.tr());
          break;
        case BiometricType.iris:
          descriptions.add('biometric.iris'.tr());
          break;
        case BiometricType.strong:
          descriptions.add('biometric.strong_biometric'.tr());
          break;
        case BiometricType.weak:
          descriptions.add('biometric.weak_biometric'.tr());
          break;
      }
    }

    return descriptions.join(', ');
  }
}
