import 'package:flutter/material.dart';
import '../services/app_lock_service.dart';
import '../services/biometric_auth_service.dart';
import '../di/injection.dart';
import '../../shared/widgets/app_lock_screen.dart';

/// Widget that wraps the app and shows lock screen when needed
class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  late final AppLockService _appLockService;
  late final BiometricAuthService _biometricAuthService;

  @override
  void initState() {
    super.initState();
    _appLockService = getIt<AppLockService>();
    _biometricAuthService = getIt<BiometricAuthService>();
    
    // Initialize the app lock service
    _appLockService.initialize();
  }

  @override
  void dispose() {
    _appLockService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _appLockService.isLockedStream,
      initialData: _appLockService.isLocked,
      builder: (context, snapshot) {
        final isLocked = snapshot.data ?? false;
        
        if (isLocked) {
          return AppLockScreen(
            appLockService: _appLockService,
            biometricAuthService: _biometricAuthService,
            onUnlocked: () {
              // The app lock screen will handle unlocking via the service
              // This callback is for any additional logic if needed
            },
          );
        }
        
        return widget.child;
      },
    );
  }
}
