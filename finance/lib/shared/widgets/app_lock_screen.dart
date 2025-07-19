import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/services/app_lock_service.dart';
import '../../core/services/biometric_auth_service.dart';
import 'animations/tappable_widget.dart';
import 'animations/fade_in.dart';
import 'animations/scale_in.dart';

class AppLockScreen extends StatefulWidget {
  final AppLockService appLockService;
  final BiometricAuthService biometricAuthService;
  final VoidCallback? onUnlocked;

  const AppLockScreen({
    super.key,
    required this.appLockService,
    required this.biometricAuthService,
    this.onUnlocked,
  });

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> with TickerProviderStateMixin {
  bool _isAuthenticating = false;
  String _errorMessage = '';
  List<BiometricType> _availableBiometrics = [];
  late AnimationController _pulseController;
  late AnimationController _errorController;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _loadAvailableBiometrics();
    
    // Auto-trigger authentication on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _errorController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableBiometrics() async {
    try {
      final biometrics = await widget.biometricAuthService.getAvailableBiometrics();
      setState(() {
        _availableBiometrics = biometrics;
      });
    } catch (e) {
      debugPrint('Error loading biometrics: $e');
    }
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final bool authenticated = await widget.appLockService.authenticateAndUnlock();
      
      if (authenticated) {
        // Add haptic feedback for successful authentication
        HapticFeedback.lightImpact();
        
        // Call the unlock callback
        widget.onUnlocked?.call();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
        });
        
        // Trigger error animation
        _errorController.forward().then((_) {
          _errorController.reverse();
        });
        
        // Add haptic feedback for failed authentication
        HapticFeedback.vibrate();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication error: ${e.toString()}';
      });
      
      // Trigger error animation
      _errorController.forward().then((_) {
        _errorController.reverse();
      });
      
      // Add haptic feedback for error
      HapticFeedback.vibrate();
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Widget _buildBiometricIcon() {
    if (_availableBiometrics.isEmpty) {
      return const Icon(
        Icons.lock,
        size: 80,
        color: Colors.grey,
      );
    }

    IconData iconData = Icons.fingerprint;
    
    // Choose the most appropriate icon based on available biometrics
    if (_availableBiometrics.contains(BiometricType.face)) {
      iconData = Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      iconData = Icons.fingerprint;
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      iconData = Icons.visibility;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.1),
          child: Icon(
            iconData,
            size: 80,
            color: colorScheme.primary.withOpacity(0.8 + (_pulseController.value * 0.2)),
          ),
        );
      },
    );
  }

  String _getBiometricTitle() {
    if (_availableBiometrics.isEmpty) {
      return 'Unlock Required';
    }

    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Scan';
    }

    return 'Biometric Authentication';
  }

  String _getBiometricSubtitle() {
    if (_availableBiometrics.isEmpty) {
      return 'Please set up biometric authentication to use this feature';
    }

    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Look at your device to unlock';
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Touch the fingerprint sensor to unlock';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Look at the camera to unlock';
    }

    return 'Use biometric authentication to unlock';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            
            return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              
              // App Logo/Icon
              FadeIn(
                delay: const Duration(milliseconds: 200),
                child: ScaleIn(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 50,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              FadeIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  'Finance',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Biometric Icon
              FadeIn(
                delay: const Duration(milliseconds: 800),
                child: ScaleIn(
                  delay: const Duration(milliseconds: 1000),
                  child: _buildBiometricIcon(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              FadeIn(
                delay: const Duration(milliseconds: 1200),
                child: Text(
                  _getBiometricTitle(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Subtitle
              FadeIn(
                delay: const Duration(milliseconds: 1400),
                child: Text(
                  _getBiometricSubtitle(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Error Message
              if (_errorMessage.isNotEmpty)
                FadeIn(
                  child: AnimatedBuilder(
                    animation: _errorController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_errorController.value * 10 * (1 - _errorController.value * 2), 0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.error.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  _errorMessage,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Try Again Button
              FadeIn(
                delay: const Duration(milliseconds: 1600),
                child: TappableWidget(
                  onTap: _isAuthenticating ? null : _authenticate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isAuthenticating)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        else
                          Icon(
                            Icons.lock_open,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
                        const SizedBox(width: 12),
                        Text(
                          _isAuthenticating ? 'Authenticating...' : 'Try Again',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ));
          },
        ),
      ),
    );
  }
}
