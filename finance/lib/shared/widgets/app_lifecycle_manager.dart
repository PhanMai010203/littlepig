import 'package:flutter/material.dart';
import '../../core/services/platform_service.dart';

/// App lifecycle manager that handles app state changes
/// Particularly useful for setting high refresh rate when app resumes
class AppLifecycleManager extends StatefulWidget {
  const AppLifecycleManager({
    super.key,
    required this.child,
    this.onAppResume,
  });

  final Widget child;
  final VoidCallback? onAppResume;

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('App resumed - setting high refresh rate');
        // Set high refresh rate when app resumes
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        debugPrint('App paused');
        break;
      case AppLifecycleState.inactive:
        debugPrint('App inactive');
        break;
      case AppLifecycleState.detached:
        debugPrint('App detached');
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
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
} 