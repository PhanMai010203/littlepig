import 'package:flutter/material.dart';
import '../../core/services/platform_service.dart';
import '../../core/services/timer_management_service.dart';

/// App lifecycle manager that handles app state changes
/// Enhanced in Phase 1 to coordinate with TimerManagementService
class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({
    super.key,
    required this.child,
    this.onAppResume,
    this.enableTimerCoordination = true,
  });

  final Widget child;
  final VoidCallback? onAppResume;
  final bool enableTimerCoordination;

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize TimerManagementService if coordination is enabled
    if (widget.enableTimerCoordination) {
      _initializeTimerService();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeTimerService() async {
    try {
      await TimerManagementService.instance.initialize();
    } catch (e) {
      debugPrint('Failed to initialize TimerManagementService: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('App resumed - setting high refresh rate');
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        debugPrint('App paused - reducing timer frequency');
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        debugPrint('App inactive');
        break;
      case AppLifecycleState.detached:
        debugPrint('App detached');
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        debugPrint('App hidden');
        break;
    }
  }

  Future<void> _onAppResumed() async {
    // Call custom callback if provided
    widget.onAppResume?.call();
    
    // Always try to set high refresh rate when app resumes
    await PlatformService.setHighRefreshRate();
    
    // Resume timer operations if coordination is enabled
    if (widget.enableTimerCoordination) {
      TimerManagementService.instance.resumeOperations();
    }
  }

  void _onAppPaused() {
    // Timer frequency adjustment is handled by TimerManagementService itself
    // through its own WidgetsBindingObserver implementation
  }

  void _onAppDetached() {
    // Pause non-critical operations when app is being terminated
    if (widget.enableTimerCoordination) {
      TimerManagementService.instance.pauseNonCriticalOperations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 