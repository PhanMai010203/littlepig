import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
// Phase 5 imports
import '../../../../shared/utils/performance_optimization.dart';
import '../../../../core/services/platform_service.dart';

class AnimatedGooBackground extends StatelessWidget {
  const AnimatedGooBackground({super.key, required this.baseColor, required this.randomOffset});

  final Color baseColor;
  final int randomOffset;

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final brightness = Theme.of(context).brightness;
    
    // Phase 5: Adaptive performance based on actual device capabilities (Phase 5 pattern)
    final isLowEndDevice = PlatformService.isLowEndDevice;
    
    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization(
      'AnimatedGooBackground', 
      'RepaintBoundary+AdaptivePerformance+ThemeCaching'
    );
    
    // Phase 5: Optimized color with theme-appropriate alpha values for proper contrast
    final optimizedColor = brightness == Brightness.light
        ? baseColor.withValues(alpha: 0.20) // Light theme: lower alpha for better contrast
        : baseColor.withValues(alpha: 0.35); // Dark theme: higher alpha for visibility

    // Phase 5: Use RepaintBoundary for expensive animation (Phase 4 pattern)
    return RepaintBoundary(
      child: Transform(
        transform: Matrix4.skewX(0.001),
        child: PlasmaRenderer(
          type: PlasmaType.infinity,
          particles: isLowEndDevice ? 6 : 10, // Adaptive performance
          color: optimizedColor,
          blur: 0.30,
          size: 1.30,
          speed: isLowEndDevice ? 3.0 : 5.30, // Adaptive animation speed
          offset: 0,
          blendMode: brightness == Brightness.light
              ? BlendMode.multiply
              : BlendMode.screen,
          particleType: ParticleType.atlas,
          rotation: (randomOffset % 360).toDouble(),
        ),
      ),
    );
  }
} 