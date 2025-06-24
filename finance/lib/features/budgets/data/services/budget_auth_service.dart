import 'package:local_auth/local_auth.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class BudgetAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> authenticateForBudgetAccess() async {
    try {
      // Check if biometric authentication is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        return false; // Fallback to no authentication if not available
      }

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return false; // No biometric methods available
      }

      // Attempt authentication
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access sensitive budget information',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print('Biometric authentication error: $e');
      return false; // Fallback to no authentication on error
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
