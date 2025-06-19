import 'package:flutter/material.dart';
import '../../../core/services/animation_performance_service.dart';
import 'animation_utils.dart';
import 'fade_in.dart';

/// AnimationPerformanceMonitor - Phase 6.2 Implementation
/// 
/// A debug widget that displays real-time animation performance information
/// Useful for developers and power users to monitor animation performance
class AnimationPerformanceMonitor extends StatefulWidget {
  const AnimationPerformanceMonitor({
    this.showFullDetails = false,
    this.refreshInterval = const Duration(milliseconds: 500),
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  /// Whether to show full details or just basic metrics
  final bool showFullDetails;
  
  /// How often to refresh the performance data
  final Duration refreshInterval;
  
  /// Background color for the monitor widget
  final Color? backgroundColor;
  
  /// Text color for the performance information
  final Color? textColor;

  @override
  State<AnimationPerformanceMonitor> createState() => _AnimationPerformanceMonitorState();
}

class _AnimationPerformanceMonitorState extends State<AnimationPerformanceMonitor>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  Map<String, dynamic>? _performanceData;
  
  @override
  void initState() {
    super.initState();
    
    _refreshController = AnimationUtils.createController(
      vsync: this,
      duration: widget.refreshInterval,
      debugLabel: 'PerformanceMonitorRefresh',
    );
    
    _refreshController.addListener(_updatePerformanceData);
    _refreshController.repeat();
    _updatePerformanceData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _updatePerformanceData() {
    if (mounted) {
      setState(() {
        _performanceData = AnimationUtils.getPerformanceMetrics();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_performanceData == null) {
      return const SizedBox.shrink();
    }

    return FadeIn(
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? 
                 Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            if (widget.showFullDetails) 
              _buildFullDetails(context)
            else
              _buildBasicMetrics(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isPerformanceGood = _performanceData!['performanceProfile']
        ['performanceMetrics']['isPerformanceGood'] as bool;
    
    return Row(
      children: [
        Icon(
          Icons.speed,
          size: 16,
          color: widget.textColor ?? Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Text(
          'Animation Performance',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: widget.textColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isPerformanceGood ? Colors.green : Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicMetrics(BuildContext context) {
    final metrics = _performanceData!['performanceProfile']['performanceMetrics'] 
        as Map<String, dynamic>;
    final activeAnimations = _performanceData!['activeAnimations'] as int;
    final maxAnimations = _performanceData!['maxSimultaneousAnimations'] as int;
    final frameTime = metrics['averageFrameTimeMs'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricRow(
          context,
          'Active Animations',
          '$activeAnimations / $maxAnimations',
          activeAnimations <= maxAnimations ? Colors.green : Colors.red,
        ),
        _buildMetricRow(
          context,
          'Frame Time',
          '${frameTime}ms',
          frameTime <= 16 ? Colors.green : frameTime <= 20 ? Colors.orange : Colors.red,
        ),
        _buildMetricRow(
          context,
          'Performance',
          metrics['isPerformanceGood'] ? 'Good' : 'Degraded',
          metrics['isPerformanceGood'] ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildFullDetails(BuildContext context) {
    final metrics = _performanceData!['performanceProfile']['performanceMetrics'] 
        as Map<String, dynamic>;
    final profile = _performanceData!['performanceProfile'] as Map<String, dynamic>;
    final animationMetrics = _performanceData!['animationMetrics'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBasicMetrics(context),
        const SizedBox(height: 12),
        
        // Performance Profile
        _buildSectionHeader(context, 'Performance Profile'),
        _buildMetricRow(context, 'Animation Level', profile['animationLevel']),
        _buildMetricRow(context, 'Battery Saver', profile['batterySaver'].toString()),
        _buildMetricRow(context, 'Complex Animations', 
                       profile['shouldUseComplexAnimations'].toString()),
        _buildMetricRow(context, 'Staggered Animations', 
                       profile['shouldUseStaggeredAnimations'].toString()),
        
        const SizedBox(height: 12),
        
        // Animation Statistics
        _buildSectionHeader(context, 'Animation Statistics'),
        _buildMetricRow(context, 'Total Created', 
                       metrics['totalAnimationsCreated'].toString()),
        _buildMetricRow(context, 'Performance Scale', 
                       '${(metrics['performanceScale'] * 100).toInt()}%'),
        
        if (animationMetrics.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSectionHeader(context, 'Animation Types'),
          ...animationMetrics.entries.map((entry) =>
            _buildMetricRow(context, entry.key, entry.value.toString()),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: (widget.textColor ?? Theme.of(context).colorScheme.onSurface)
                 .withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: (widget.textColor ?? Theme.of(context).colorScheme.onSurface)
                     .withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: valueColor ?? 
                     (widget.textColor ?? Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple floating performance monitor for debugging
class FloatingPerformanceMonitor extends StatelessWidget {
  const FloatingPerformanceMonitor({
    this.position = FloatingMonitorPosition.topRight,
    this.showFullDetails = false,
    super.key,
  });

  final FloatingMonitorPosition position;
  final bool showFullDetails;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position == FloatingMonitorPosition.topLeft || 
           position == FloatingMonitorPosition.topRight ? 50 : null,
      bottom: position == FloatingMonitorPosition.bottomLeft || 
              position == FloatingMonitorPosition.bottomRight ? 50 : null,
      left: position == FloatingMonitorPosition.topLeft || 
            position == FloatingMonitorPosition.bottomLeft ? 16 : null,
      right: position == FloatingMonitorPosition.topRight || 
             position == FloatingMonitorPosition.bottomRight ? 16 : null,
      child: AnimationPerformanceMonitor(
        showFullDetails: showFullDetails,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
      ),
    );
  }
}

enum FloatingMonitorPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Extension to easily add performance monitoring to any widget tree
extension PerformanceMonitorExtension on Widget {
  /// Add a floating performance monitor to this widget
  Widget withPerformanceMonitor({
    FloatingMonitorPosition position = FloatingMonitorPosition.topRight,
    bool showFullDetails = false,
    bool enabled = true,
  }) {
    if (!enabled) return this;
    
    return Stack(
      children: [
        this,
        FloatingPerformanceMonitor(
          position: position,
          showFullDetails: showFullDetails,
        ),
      ],
    );
  }
} 