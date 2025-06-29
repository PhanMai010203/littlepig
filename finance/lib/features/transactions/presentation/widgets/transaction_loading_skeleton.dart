import 'package:flutter/material.dart';
import '../../../../shared/widgets/animations/animation_utils.dart';

/// Skeleton loading widget that matches the transaction list layout
/// Provides shimmer effects for better perceived performance during loading
/// Part of Phase 3 UI State Management Improvements
class TransactionLoadingSkeleton extends StatefulWidget {
  const TransactionLoadingSkeleton({
    super.key,
    this.itemCount = 8,
    this.showMonthSelector = true,
  });

  final int itemCount;
  final bool showMonthSelector;

  @override
  State<TransactionLoadingSkeleton> createState() => _TransactionLoadingSkeletonState();
}

class _TransactionLoadingSkeletonState extends State<TransactionLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    
    _shimmerController = AnimationUtils.createController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      debugLabel: 'TransactionLoadingSkeleton',
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(AnimationUtils.createCurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (AnimationUtils.shouldAnimate()) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showMonthSelector)
          _buildMonthSelectorSkeleton(context),
        Expanded(
          child: _buildTransactionListSkeleton(context),
        ),
      ],
    );
  }

  Widget _buildMonthSelectorSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShimmerBox(width: 40, height: 24),
          _buildShimmerBox(width: 120, height: 24),
          _buildShimmerBox(width: 40, height: 24),
        ],
      ),
    );
  }

  Widget _buildTransactionListSkeleton(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            // Show date header every 3-4 items to simulate grouped transactions
            final shouldShowDateHeader = index == 0 || (index % 4 == 0);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (shouldShowDateHeader)
                  _buildDateHeaderSkeleton(),
                _buildTransactionTileSkeleton(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateHeaderSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildShimmerBox(width: 160, height: 16),
          _buildShimmerBox(width: 80, height: 16),
        ],
      ),
    );
  }

  Widget _buildTransactionTileSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        type: MaterialType.card,
        elevation: 2.0,
        shadowColor: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category circle skeleton
              _buildShimmerCircle(radius: 28),
              const SizedBox(width: 5),
              // Action button skeleton
              _buildShimmerCircle(radius: 20),
            ],
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(width: 120, height: 16),
              const SizedBox(height: 4),
              _buildShimmerBox(width: 80, height: 12),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShimmerBox(width: 16, height: 16), // Note icon
              const SizedBox(width: 8),
              _buildShimmerBox(width: 16, height: 16), // Arrow icon
              const SizedBox(width: 8),
              _buildShimmerBox(width: 80, height: 16), // Amount
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    double borderRadius = 4.0,
  }) {
    if (!AnimationUtils.shouldAnimate()) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      );
    }

    return AnimationUtils.animatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                0.0,
                _shimmerAnimation.value * 0.5 + 0.5,
                1.0,
              ],
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerCircle({required double radius}) {
    if (!AnimationUtils.shouldAnimate()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      );
    }

    return AnimationUtils.animatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(_shimmerAnimation.value * 0.5, 0),
              radius: 1.0,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Extension to easily create skeleton loading states
extension TransactionLoadingSkeletonExtension on Widget {
  /// Wraps this widget with a skeleton loading overlay
  Widget withSkeleton({
    bool showSkeleton = false,
    int itemCount = 8,
    bool showMonthSelector = true,
  }) {
    if (!showSkeleton) return this;
    
    return TransactionLoadingSkeleton(
      itemCount: itemCount,
      showMonthSelector: showMonthSelector,
    );
  }
}