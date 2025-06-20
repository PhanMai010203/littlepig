import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:battery_plus/battery_plus.dart';
import '../settings/app_settings.dart';

/// Timer Task Definition
/// 
/// Represents a task that can be executed by the timer management service
class TimerTask {
  final String id;
  final Duration interval;
  final Future<void> Function() task;
  final bool isEssential;
  final int priority; // Higher numbers = higher priority (1-10)
  final bool pauseOnBackground;
  final bool pauseOnLowBattery;
  
  // Runtime state
  DateTime lastExecuted;
  int consecutiveFailures;
  Duration currentBackoff;
  
  TimerTask({
    required this.id,
    required this.interval,
    required this.task,
    this.isEssential = false,
    this.priority = 5,
    this.pauseOnBackground = true,
    this.pauseOnLowBattery = true,
  }) : lastExecuted = DateTime.now(),
       consecutiveFailures = 0,
       currentBackoff = Duration.zero;
  
  /// Check if task should run based on interval and backoff
  bool shouldExecute(DateTime now) {
    final nextExecution = lastExecuted.add(interval).add(currentBackoff);
    return now.isAfter(nextExecution) || now.isAtSameMomentAs(nextExecution);
  }
  
  /// Mark task as executed successfully
  void markExecuted() {
    lastExecuted = DateTime.now();
    consecutiveFailures = 0;
    currentBackoff = Duration.zero;
  }
  
  /// Mark task as failed and apply exponential backoff
  void markFailed() {
    consecutiveFailures++;
    final backoffSeconds = min(pow(2, consecutiveFailures).toInt() * 60, 3600); // Max 1 hour
    currentBackoff = Duration(seconds: backoffSeconds);
  }
}

/// Timer Management Service - Phase 1 Implementation
/// 
/// Centralizes all periodic operations with:
/// - Battery-aware scheduling
/// - App state awareness
/// - Exponential backoff for failed operations
/// - Priority-based task execution
class TimerManagementService with WidgetsBindingObserver {
  static TimerManagementService? _instance;
  static TimerManagementService get instance => _instance ??= TimerManagementService._();
  
  TimerManagementService._();
  
  // Core timer configuration
  static const Duration _masterInterval = Duration(minutes: 1);
  static const int _lowBatteryThreshold = 20; // 20%
  static const int _criticalBatteryThreshold = 10; // 10%
  
  // State management
  Timer? _masterTimer;
  final Map<String, TimerTask> _tasks = {};
  final Battery _battery = Battery();
  
  // App and system state
  AppLifecycleState _appState = AppLifecycleState.resumed;
  int _lastBatteryLevel = 100;
  bool _isInitialized = false;
  bool _isPaused = false;
  
  // Performance metrics
  final Map<String, int> _executionCount = {};
  final Map<String, Duration> _executionTimes = {};
  
  /// Initialize the timer management service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Register for app lifecycle changes
      WidgetsBinding.instance.addObserver(this);
      
      // Get initial battery level
      _lastBatteryLevel = await _battery.batteryLevel;
      
      // Listen for battery level changes
      _battery.onBatteryStateChanged.listen(_onBatteryStateChanged);
      
      // Start the master timer
      startMasterTimer();
      
      _isInitialized = true;
      debugPrint('TimerManagementService initialized with battery level: $_lastBatteryLevel%');
    } catch (e) {
      debugPrint('TimerManagementService initialization failed: $e');
      rethrow;
    }
  }
  
  /// Start the master timer
  void startMasterTimer() {
    if (_masterTimer?.isActive == true) return;
    
    _masterTimer = Timer.periodic(_masterInterval, _handleTimerTick);
    debugPrint('Master timer started with ${_masterInterval.inMinutes}min interval');
  }
  
  /// Stop the master timer
  void stopMasterTimer() {
    _masterTimer?.cancel();
    _masterTimer = null;
    debugPrint('Master timer stopped');
  }
  
  /// Register a periodic task
  void registerTask(TimerTask task) {
    // Auto-initialize the service on first task registration to ensure
    // timers start even when clients forget to call initialize() – this
    // is especially helpful in unit tests where initialization may be
    // omitted.
    if (!_isInitialized) {
      // We deliberately ignore the returned future – initialization is
      // idempotent and will complete in the background.
      initialize();
    }

    _tasks[task.id] = task;
    debugPrint('Registered task: ${task.id} (${task.interval.inMinutes}min interval, priority: ${task.priority})');
  }
  
  /// Unregister a task
  void unregisterTask(String taskId) {
    _tasks.remove(taskId);
    _executionCount.remove(taskId);
    _executionTimes.remove(taskId);
    debugPrint('Unregistered task: $taskId');
  }
  
  /// Pause all non-essential operations
  void pauseNonCriticalOperations() {
    _isPaused = true;
    debugPrint('Paused non-critical operations');
  }
  
  /// Resume all operations
  void resumeOperations() {
    _isPaused = false;
    debugPrint('Resumed all operations');
  }
  
  /// Master timer tick handler
  void _handleTimerTick(Timer timer) async {
    final now = DateTime.now();
    
    try {
      // Check app and battery state
      final canExecuteTasks = _shouldExecuteTasks();
      if (!canExecuteTasks) {
        debugPrint('Skipping timer tick - unfavorable conditions');
        return;
      }
      
      // Get tasks to execute, sorted by priority
      final tasksToExecute = _getTasksToExecute(now);
      
      if (tasksToExecute.isEmpty) return;
      
      debugPrint('Executing ${tasksToExecute.length} tasks');
      
      // Execute tasks based on priority and conditions
      for (final task in tasksToExecute) {
        await _executeTask(task);
      }
      
    } catch (e) {
      debugPrint('Master timer tick error: $e');
    }
  }
  
  /// Check if tasks should be executed based on current conditions
  bool _shouldExecuteTasks() {
    // Don't execute if paused
    if (_isPaused) return false;
    
    // Don't execute when app is backgrounded (except essential tasks)
    if (_appState != AppLifecycleState.resumed) {
      return _tasks.values.any((task) => task.isEssential);
    }
    
    // Don't execute non-essential tasks when battery is low
    if (_lastBatteryLevel <= _lowBatteryThreshold) {
      return _tasks.values.any((task) => task.isEssential);
    }
    
    // Don't execute any tasks when battery is critical
    if (_lastBatteryLevel <= _criticalBatteryThreshold) {
      return false;
    }
    
    return true;
  }
  
  /// Get tasks that should be executed now
  List<TimerTask> _getTasksToExecute(DateTime now) {
    final tasks = <TimerTask>[];
    
    for (final task in _tasks.values) {
      // Check if task should execute based on interval and backoff
      if (!task.shouldExecute(now)) continue;
      
      // Check app state conditions
      if (_appState != AppLifecycleState.resumed && task.pauseOnBackground && !task.isEssential) {
        continue;
      }
      
      // Check battery conditions
      if (_lastBatteryLevel <= _lowBatteryThreshold && task.pauseOnLowBattery && !task.isEssential) {
        continue;
      }
      
      // Check battery saver mode
      if (AppSettings.getWithDefault<bool>('batterySaver', false) && !task.isEssential) {
        continue;
      }
      
      tasks.add(task);
    }
    
    // Sort by priority (higher priority first)
    tasks.sort((a, b) => b.priority.compareTo(a.priority));
    
    return tasks;
  }
  
  /// Execute a single task with error handling and metrics
  Future<void> _executeTask(TimerTask task) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('Executing task: ${task.id}');
      
      await task.task();
      
      task.markExecuted();
      _executionCount[task.id] = (_executionCount[task.id] ?? 0) + 1;
      
      stopwatch.stop();
      _executionTimes[task.id] = stopwatch.elapsed;
      
      debugPrint('Task ${task.id} completed in ${stopwatch.elapsedMilliseconds}ms');
      
    } catch (e) {
      task.markFailed();
      stopwatch.stop();
      
      debugPrint('Task ${task.id} failed: $e (failures: ${task.consecutiveFailures}, backoff: ${task.currentBackoff.inMinutes}min)');
    }
  }
  
  /// Handle battery state changes
  void _onBatteryStateChanged(BatteryState state) async {
    final newLevel = await _battery.batteryLevel;
    final oldLevel = _lastBatteryLevel;
    _lastBatteryLevel = newLevel;
    
    debugPrint('Battery level changed: $oldLevel% -> $newLevel%');
    
    // Pause operations if battery becomes low
    if (newLevel <= _lowBatteryThreshold && oldLevel > _lowBatteryThreshold) {
      pauseNonCriticalOperations();
      debugPrint('Battery low - pausing non-critical operations');
    }
    
    // Resume operations if battery improves
    if (newLevel > _lowBatteryThreshold && oldLevel <= _lowBatteryThreshold) {
      resumeOperations();
      debugPrint('Battery improved - resuming operations');
    }
  }
  
  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final oldState = _appState;
    _appState = state;
    
    debugPrint('App lifecycle changed: $oldState -> $state');
    
    switch (state) {
      case AppLifecycleState.resumed:
        resumeOperations();
        // Adjust timer frequency back to normal
        _adjustTimerFrequency(false);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Reduce timer frequency when backgrounded
        _adjustTimerFrequency(true);
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        pauseNonCriticalOperations();
        break;
    }
  }
  
  /// Adjust timer frequency based on app state
  void _adjustTimerFrequency(bool isBackground) {
    if (isBackground) {
      // Restart timer with longer interval when backgrounded
      stopMasterTimer();
      _masterTimer = Timer.periodic(const Duration(minutes: 5), _handleTimerTick);
      debugPrint('Adjusted timer to background frequency (5min)');
    } else {
      // Restart with normal interval when foregrounded
      stopMasterTimer();
      startMasterTimer();
      debugPrint('Adjusted timer to foreground frequency (1min)');
    }
  }
  
  /// Force execute a specific task (ignores conditions)
  Future<void> forceExecuteTask(String taskId) async {
    final task = _tasks[taskId];
    if (task == null) {
      debugPrint('Task not found: $taskId');
      return;
    }
    
    debugPrint('Force executing task: $taskId');
    await _executeTask(task);
  }
  
  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'isInitialized': _isInitialized,
      'isPaused': _isPaused,
      'appState': _appState.toString(),
      'batteryLevel': _lastBatteryLevel,
      'registeredTasks': _tasks.length,
      'executionCounts': Map.from(_executionCount),
      'executionTimes': _executionTimes.map((k, v) => MapEntry(k, v.inMilliseconds)),
      'taskStatus': _tasks.map((k, v) => MapEntry(k, {
        'lastExecuted': v.lastExecuted.toIso8601String(),
        'consecutiveFailures': v.consecutiveFailures,
        'currentBackoff': v.currentBackoff.inMinutes,
        'priority': v.priority,
        'isEssential': v.isEssential,
      })),
    };
  }
  
  /// Dispose and cleanup
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopMasterTimer();
    _tasks.clear();
    _executionCount.clear();
    _executionTimes.clear();
    _isInitialized = false;
    debugPrint('TimerManagementService disposed');
  }
  
  bool get isMasterTimerActive => _masterTimer?.isActive ?? false;
} 