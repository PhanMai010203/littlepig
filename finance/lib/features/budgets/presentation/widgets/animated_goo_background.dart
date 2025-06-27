import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';

class AnimatedGooBackground extends StatelessWidget {
  const AnimatedGooBackground({super.key, required this.baseColor, required this.randomOffset});

  final Color baseColor;
  final int randomOffset;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final color = brightness == Brightness.light
        ? baseColor.withOpacity(0.20)
        : baseColor.withOpacity(0.20); // Reduced opacity for dark theme

    return Transform(
      transform: Matrix4.skewX(0.001),
      child: PlasmaRenderer(
        type: PlasmaType.infinity,
        particles: 10,
        color: color,
        blur: 0.30,
        size: 1.30,
        speed: 5.30,
        offset: 0,
        blendMode: brightness == Brightness.light
            ? BlendMode.multiply
            : BlendMode.screen, // Better blend mode for dark backgrounds
        particleType: ParticleType.atlas,
        rotation: (randomOffset % 360).toDouble(),
      ),
    );
  }
} 