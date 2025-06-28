import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// Phase 5 imports
import '../../../shared/utils/performance_optimization.dart';
import '../../../core/services/platform_service.dart';

class HomePageUsername extends StatelessWidget {
  final AnimationController animationController;

  const HomePageUsername({
    super.key,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // Phase 5: Platform-optimized text scaling
    final platform = PlatformService.getPlatform();
    final textScaleFactor = platform == PlatformOS.isIOS ? 1.0 : 0.95;
    
    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization(
      'HomePageUsername', 
      'ThemeCaching+PlatformTextOptimization+AnimationOptimization'
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (_, child) {
        return Transform.scale(
          alignment: AlignmentDirectional.bottomStart,
          scale: animationController.value < 0.5
              ? 0.5 * 0.4 + 0.6
              : (animationController.value) * 0.4 + 0.6,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 9),
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Text(
            "navigation.home".tr(),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 50,
            ),
          ),
        ),
      ),
    );
  }
}
