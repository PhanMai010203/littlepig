import 'package:flutter/material.dart';
import '../../../core/services/animation_performance_service.dart';
import '../../../core/services/timer_management_service.dart';
import 'animation_utils.dart';
import 'dart:async';

/// Position options for floating performance monitor
enum FloatingMonitorPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  centerLeft,
  centerRight,
}

/// AnimationPerformanceMonitor Widget - Phase 6.2 Implementation
///
/// A real-time monitor for animation performance metrics
/// Displays current animation state, frame rates, and optimization info
class AnimationPerformanceMonitor extends StatefulWidget {
  const AnimationPerformanceMonitor({
    this.refreshInterval = const Duration(milliseconds: 1000), // Phase 1: Optimized from 250ms to 1000ms
    this.showFullDetails = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(8.0),
    this.textStyle,
    super.key,
  });

  /// How often to refresh the performance data (Phase 1: Optimized from 250ms to 1000ms)
  final Duration refreshInterval;

  /// Whether to show detailed metrics or just summary
  final bool showFullDetails;

  /// Background color for the monitor
  final Color? backgroundColor;

  /// Text color for the monitor
  final Color? textColor;

  /// Border color for the monitor
  final Color? borderColor;

  /// Border radius for the monitor
  final double borderRadius;

  /// Padding inside the monitor
  final EdgeInsets padding;

  /// Text style for the monitor
  final TextStyle? textStyle;

  @override
  State<AnimationPerformanceMonitor> createState() =>
      _AnimationPerformanceMonitorState();
}

class _AnimationPerformanceMonitorState
    extends State<AnimationPerformanceMonitor> {
  Map<String, dynamic> _currentMetrics = {};
  String? _timerTaskId;

  @override
  void initState() {
    super.initState();
    // Listen to performance service updates for real-time UI refresh
    AnimationPerformanceService.addListener(_updateMetrics);
    _updateMetrics();
    _setupTimerManagement();
  }

  @override
  void dispose() {
    if (_timerTaskId != null) {
      TimerManagementService.instance.unregisterTask(_timerTaskId!);
    }
    AnimationPerformanceService.removeListener(_updateMetrics);
    super.dispose();
  }
  
  void _setupTimerManagement() {
    _timerTaskId = 'animation_performance_monitor_${hashCode}';
    
    final performanceTask = TimerTask(
      id: _timerTaskId!,
      interval: widget.refreshInterval,
      task: _updateMetricsAsync,
      isEssential: false, // Performance monitoring is not essential
      priority: 2, // Very low priority
      pauseOnBackground: true, // Pause when backgrounded
      pauseOnLowBattery: true, // Pause when battery is low
    );
    
    TimerManagementService.instance.registerTask(performanceTask);
  }
  
  Future<void> _updateMetricsAsync() async {
    if (mounted) {
      _updateMetrics();
    }
  }

  void _updateMetrics() {
    if (mounted) {
      setState(() {
        _currentMetrics = {
          ...AnimationPerformanceService.performanceMetrics,
          'profile': AnimationPerformanceService.getPerformanceProfile(),
          'utils': AnimationUtils.getPerformanceMetrics(),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = widget.backgroundColor ??
        (isDark ? Colors.black87 : Colors.white.withOpacity(0.9));
    final textColor =
        widget.textColor ?? (isDark ? Colors.white : Colors.black87);
    final borderColor =
        widget.borderColor ?? (isDark ? Colors.white24 : Colors.black12);

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: widget.showFullDetails
          ? _buildDetailedView(textColor)
          : _buildSummaryView(textColor),
    );
  }

  Widget _buildSummaryView(Color textColor) {
    final activeAnimations = _currentMetrics['currentActiveAnimations'] ?? 0;
    final maxAnimations = AnimationPerformanceService.maxSimultaneousAnimations;
    final frameTime = _currentMetrics['averageFrameTimeMs'] ?? 16;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$activeAnimations / $maxAnimations',
          style: widget.textStyle?.copyWith(color: textColor) ??
              TextStyle(
                  color: textColor, fontSize: 12, fontFamily: 'monospace'),
        ),
        Text(
          '${frameTime}ms',
          style: widget.textStyle?.copyWith(color: textColor) ??
              TextStyle(
                  color: textColor, fontSize: 10, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildDetailedView(Color textColor) {
    final profile = _currentMetrics['profile'] as Map<String, dynamic>? ?? {};
    final activeAnimations = _currentMetrics['currentActiveAnimations'] ?? 0;
    final maxAnimations = AnimationPerformanceService.maxSimultaneousAnimations;
    final frameTime = _currentMetrics['averageFrameTimeMs'] ?? 16;
    final isGood = _currentMetrics['isPerformanceGood'] ?? true;
    final animationLevel = profile['animationLevel'] ?? 'normal';
    final batterySaver = profile['batterySaver'] ?? false;

    final baseTextStyle = widget.textStyle?.copyWith(color: textColor) ??
        TextStyle(color: textColor, fontSize: 10, fontFamily: 'monospace');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Animations: $activeAnimations / $maxAnimations',
            style: baseTextStyle),
        Text('Frame Time: ${frameTime}ms', style: baseTextStyle),
        Text('Performance: ${isGood ? "Good" : "Poor"}', style: baseTextStyle),
        Text('Level: $animationLevel', style: baseTextStyle),
        if (batterySaver)
          Text('Battery Saver: ON',
              style: baseTextStyle.copyWith(color: Colors.orange)),
      ],
    );
  }
}

/// Floating performance monitor that can be positioned anywhere
class FloatingPerformanceMonitor extends StatelessWidget {
  const FloatingPerformanceMonitor({
    this.position = FloatingMonitorPosition.topRight,
    this.showFullDetails = false,
    this.margin = const EdgeInsets.all(16.0),
    this.refreshInterval = const Duration(milliseconds: 250),
    super.key,
  });

  final FloatingMonitorPosition position;
  final bool showFullDetails;
  final EdgeInsets margin;
  final Duration refreshInterval;

  @override
  Widget build(BuildContext context) {
    final positionArgs = _getPositionArgs();
    return Positioned(
      top: positionArgs['top'],
      bottom: positionArgs['bottom'],
      left: positionArgs['left'],
      right: positionArgs['right'],
      child: AnimationPerformanceMonitor(
        showFullDetails: showFullDetails,
        refreshInterval: refreshInterval,
      ),
    );
  }

  Map<String, double?> _getPositionArgs() {
    switch (position) {
      case FloatingMonitorPosition.topLeft:
        return {'top': margin.top, 'left': margin.left};
      case FloatingMonitorPosition.topRight:
        return {'top': margin.top, 'right': margin.right};
      case FloatingMonitorPosition.bottomLeft:
        return {'bottom': margin.bottom, 'left': margin.left};
      case FloatingMonitorPosition.bottomRight:
        return {'bottom': margin.bottom, 'right': margin.right};
      case FloatingMonitorPosition.centerLeft:
        return {'top': 0, 'bottom': 0, 'left': margin.left};
      case FloatingMonitorPosition.centerRight:
        return {'top': 0, 'bottom': 0, 'right': margin.right};
    }
  }
}

/// Extension to easily add performance monitoring to any widget
extension PerformanceMonitorExtension on Widget {
  /// Wraps this widget with a floating performance monitor
  Widget withPerformanceMonitor({
    FloatingMonitorPosition position = FloatingMonitorPosition.topRight,
    bool showFullDetails = false,
    EdgeInsets margin = const EdgeInsets.all(16.0),
    Duration refreshInterval = const Duration(milliseconds: 250),
    bool enabled = true,
  }) {
    if (!enabled) {
      return this;
    }

    return Stack(
      children: [
        this,
        FloatingPerformanceMonitor(
          position: position,
          showFullDetails: showFullDetails,
          margin: margin,
          refreshInterval: refreshInterval,
        ),
      ],
    );
  }
}
