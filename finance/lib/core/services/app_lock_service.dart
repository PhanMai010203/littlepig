import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'biometric_auth_service.dart';
import '../settings/app_settings.dart';

@singleton
class AppLockService with WidgetsBindingObserver {
  final BiometricAuthService _biometricAuthService;
  
  // Stream controllers for app lock state
  final BehaviorSubject<bool> _isLockedSubject = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> _isAuthenticatingSubject = BehaviorSubject<bool>.seeded(false);
  
  // Private variables
  bool _isInitialized = false;
  DateTime? _lastBackgroundTime;
  
  AppLockService(this._biometricAuthService);

  /// Initialize the app lock service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Add this class as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    
    // Check if app should be locked on startup
    final bool shouldLockOnStartup = AppSettings.biometricAppLock && 
                                    AppSettings.biometricEnabled;
    
    if (shouldLockOnStartup) {
      final bool isBiometricSetup = await _biometricAuthService.isBiometricSetup();
      if (isBiometricSetup) {
        _isLockedSubject.add(true);
      }
    }
    
    _isInitialized = true;
    debugPrint('AppLockService initialized');
  }

  /// Dispose the service
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isLockedSubject.close();
    _isAuthenticatingSubject.close();
  }

  /// Stream to listen to app lock state changes
  Stream<bool> get isLockedStream => _isLockedSubject.stream;

  /// Stream to listen to authentication state changes
  Stream<bool> get isAuthenticatingStream => _isAuthenticatingSubject.stream;

  /// Check if app is currently locked
  bool get isLocked => _isLockedSubject.value;

  /// Check if authentication is in progress
  bool get isAuthenticating => _isAuthenticatingSubject.value;

  /// Lock the app
  void lockApp() {
    if (!_isLockedSubject.value) {
      _isLockedSubject.add(true);
      debugPrint('App locked');
    }
  }

  /// Unlock the app
  void unlockApp() {
    if (_isLockedSubject.value) {
      _isLockedSubject.add(false);
      debugPrint('App unlocked');
    }
  }

  /// Authenticate and unlock the app
  Future<bool> authenticateAndUnlock() async {
    if (!_isLockedSubject.value) {
      return true; // Already unlocked
    }

    if (_isAuthenticatingSubject.value) {
      return false; // Already authenticating
    }

    _isAuthenticatingSubject.add(true);
    
    try {
      final bool authenticated = await _biometricAuthService.quickAuthenticate();
      
      if (authenticated) {
        unlockApp();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    } finally {
      _isAuthenticatingSubject.add(false);
    }
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Only process if app lock is enabled
    if (!AppSettings.biometricAppLock || !AppSettings.biometricEnabled) {
      return;
    }

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _onAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _onAppBackgrounded();
        break;
    }
  }

  /// Handle app going to background
  void _onAppBackgrounded() {
    _lastBackgroundTime = DateTime.now();
    debugPrint('App backgrounded at: $_lastBackgroundTime');
    
    // Lock the app immediately when it goes to background
    lockApp();
  }

  /// Handle app coming to foreground
  void _onAppResumed() {
    final DateTime now = DateTime.now();
    debugPrint('App resumed at: $now');
    
    // If app was backgrounded and app lock is enabled, require authentication
    if (_lastBackgroundTime != null && AppSettings.biometricAppLock) {
      final Duration timeSinceBackground = now.difference(_lastBackgroundTime!);
      debugPrint('Time since background: ${timeSinceBackground.inSeconds} seconds');
      
      // For now, always require authentication regardless of time
      // In the future, we could add a timeout setting
      lockApp();
    }
  }

  /// Enable or disable app lock
  Future<void> setAppLockEnabled(bool enabled) async {
    await _biometricAuthService.setAppLockEnabled(enabled);
    
    // If disabling, unlock the app
    if (!enabled && _isLockedSubject.value) {
      unlockApp();
    }
    
    // If enabling, check if we should lock immediately
    if (enabled && AppSettings.biometricEnabled) {
      final bool isBiometricSetup = await _biometricAuthService.isBiometricSetup();
      if (isBiometricSetup) {
        lockApp();
      }
    }
  }

  /// Check if app lock is available (biometric is set up)
  Future<bool> isAppLockAvailable() async {
    return await _biometricAuthService.isBiometricSetup();
  }

  /// Force authentication (used for testing or manual triggers)
  Future<bool> forceAuthentication() async {
    return await _biometricAuthService.authenticate(
      reason: 'Please authenticate to continue',
    );
  }
}
