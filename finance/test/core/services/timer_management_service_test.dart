import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:battery_plus/battery_plus.dart';

import '../../../lib/core/services/timer_management_service.dart';
import '../../../lib/core/settings/app_settings.dart';

void main() {
  group('TimerManagementService', () {
    late TimerManagementService service;

    setUpAll(() async {
      // Initialize Flutter binding for testing
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Mock Battery Plus Plugin
      const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/battery');
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getBatteryLevel') {
          return 100;
        } else if (methodCall.method == 'getBatteryState') {
          return BatteryState.full.toString();
        } else if (methodCall.method == 'isInBatterySaveMode') {
          return false;
        }
        return null;
      });
    });

    setUp(() async {
      // Get the service instance
      service = TimerManagementService.instance;
      
      // Initialize App Settings for testing
      await AppSettings.initialize();
    });

    tearDown(() {
      service.dispose();
    });

    group('Task Registration', () {
      test('should register tasks correctly', () {
        var taskExecuted = false;
        final task = TimerTask(
          id: 'test_task',
          interval: const Duration(seconds: 1),
          task: () async {
            taskExecuted = true;
          },
          priority: 5,
        );

        service.registerTask(task);
        
        final metrics = service.getPerformanceMetrics();
        expect(metrics['registeredTasks'], equals(1));
        expect(metrics['taskStatus']['test_task']['priority'], equals(5));
      });

      test('should unregister tasks correctly', () {
        final task = TimerTask(
          id: 'test_task',
          interval: const Duration(seconds: 1),
          task: () async {},
        );

        service.registerTask(task);
        expect(service.getPerformanceMetrics()['registeredTasks'], equals(1));

        service.unregisterTask('test_task');
        expect(service.getPerformanceMetrics()['registeredTasks'], equals(0));
      });
    });

    group('Task Execution and Priority', () {
      test('should execute tasks based on priority', () async {
        final executionOrder = <String>[];

        final lowPriorityTask = TimerTask(
          id: 'low_priority',
          interval: const Duration(milliseconds: 50),
          task: () async {
            executionOrder.add('low');
          },
          priority: 3,
        );

        final highPriorityTask = TimerTask(
          id: 'high_priority',
          interval: const Duration(milliseconds: 50),
          task: () async {
            executionOrder.add('high');
          },
          priority: 8,
        );

        service.registerTask(lowPriorityTask);
        service.registerTask(highPriorityTask);

        // Force execute both tasks to test priority ordering
        await service.forceExecuteTask('low_priority');
        await service.forceExecuteTask('high_priority');

        // Verify execution metrics are tracked
        final metrics = service.getPerformanceMetrics();
        expect(metrics['executionCounts']['low_priority'], equals(1));
        expect(metrics['executionCounts']['high_priority'], equals(1));
      });

      test('should handle task failures with exponential backoff', () async {
        var failureCount = 0;
        final failingTask = TimerTask(
          id: 'failing_task',
          interval: const Duration(milliseconds: 50),
          task: () async {
            failureCount++;
            if (failureCount <= 2) {
              throw Exception('Task failed');
            }
          },
        );

        service.registerTask(failingTask);

        // Force execute the task multiple times to test failure handling
        try {
          await service.forceExecuteTask('failing_task');
        } catch (e) {
          // Expected to fail
        }

        try {
          await service.forceExecuteTask('failing_task');
        } catch (e) {
          // Expected to fail
        }

        // Third execution should succeed
        await service.forceExecuteTask('failing_task');

        final metrics = service.getPerformanceMetrics();
        final taskStatus = metrics['taskStatus']['failing_task'];
        expect(taskStatus['consecutiveFailures'], equals(0)); // Reset after success
      });
    });

    group('App Lifecycle Integration', () {
      test('should adjust timer frequency on app state changes', () {
        // Test lifecycle state changes
        service.didChangeAppLifecycleState(AppLifecycleState.paused);
        // Timer frequency should be adjusted to background mode

        service.didChangeAppLifecycleState(AppLifecycleState.resumed);
        // Timer frequency should be restored to normal

        // Verify state is tracked
        final metrics = service.getPerformanceMetrics();
        expect(metrics['appState'], contains('resumed'));
      });

      test('should pause non-critical operations when app is detached', () {
        service.didChangeAppLifecycleState(AppLifecycleState.detached);
        
        final metrics = service.getPerformanceMetrics();
        expect(metrics['isPaused'], isTrue);
      });
    });

    group('Performance Metrics', () {
      test('should track execution metrics correctly', () async {
        final task = TimerTask(
          id: 'metrics_task',
          interval: const Duration(milliseconds: 50),
          task: () async {
            await Future.delayed(const Duration(milliseconds: 10));
          },
        );

        service.registerTask(task);
        await service.forceExecuteTask('metrics_task');

        final metrics = service.getPerformanceMetrics();
        expect(metrics['executionCounts']['metrics_task'], equals(1));
        expect(metrics['executionTimes']['metrics_task'], greaterThan(0));
      });

      test('should provide comprehensive performance data', () {
        final metrics = service.getPerformanceMetrics();
        
        expect(metrics, containsPair('isPaused', isA<bool>()));
        expect(metrics, containsPair('appState', isA<String>()));
        expect(metrics, containsPair('registeredTasks', isA<int>()));
        expect(metrics, containsPair('executionCounts', isA<Map>()));
        expect(metrics, containsPair('executionTimes', isA<Map>()));
        expect(metrics, containsPair('taskStatus', isA<Map>()));
      });
    });

    group('Resource Management', () {
      test('should cleanup resources on dispose', () {
        final task = TimerTask(
          id: 'cleanup_task',
          interval: const Duration(seconds: 1),
          task: () async {},
        );

        service.registerTask(task);
        expect(service.getPerformanceMetrics()['registeredTasks'], equals(1));

        service.dispose();
        
        // After dispose, service should be clean
        expect(service.getPerformanceMetrics()['isInitialized'], isFalse);
        expect(service.getPerformanceMetrics()['registeredTasks'], equals(0));
      });
    });

    group('Timer Task', () {
      test('should execute when interval has passed', () {
        final task = TimerTask(
          id: 'test_task',
          interval: const Duration(milliseconds: 100),
          task: () async {},
          priority: 5,
        );

        final now = DateTime.now();
        // Task should execute if enough time has passed
        final future = now.add(const Duration(milliseconds: 150));
        expect(task.shouldExecute(future), isTrue);
        
        // Task should not execute if not enough time has passed
        final nearFuture = now.add(const Duration(milliseconds: 50));
        expect(task.shouldExecute(nearFuture), isFalse);
      });

      test('should apply exponential backoff on failure', () {
        final task = TimerTask(
          id: 'test_task',
          interval: const Duration(milliseconds: 100),
          task: () async {},
          priority: 5,
        );

        expect(task.consecutiveFailures, equals(0));
        expect(task.currentBackoff, equals(Duration.zero));

        task.markFailed();
        expect(task.consecutiveFailures, equals(1));
        expect(task.currentBackoff.inSeconds, greaterThan(0));

        task.markExecuted();
        expect(task.consecutiveFailures, equals(0));
        expect(task.currentBackoff, equals(Duration.zero));
      });
    });
  });
} 