import 'package:flutter/material.dart';
import 'package:sa3_liquid/sa3_liquid.dart';
import '../../../../shared/widgets/breathing_animation.dart';

class SheepPremiumBackground extends StatelessWidget {
  const SheepPremiumBackground({
    this.disableAnimation = false,
    this.purchased = false,
    super.key,
  });
  
  final bool disableAnimation;
  final bool purchased;

  @override
  Widget build(BuildContext context) {
    Widget background = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          tileMode: TileMode.mirror,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            _getDynamicColor(
              context,
              Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary,
            ),
            _getDynamicColor(
              context,
              Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.primary,
            ),
            _getDynamicColor(
              context,
              Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary,
            ),
          ],
          stops: disableAnimation
              ? [0, 0.4, 2.5]
              : [0, 0.3, 1.3],
        ),
        backgroundBlendMode: BlendMode.srcOver,
      ),
      child: disableAnimation
          ? Container()
          : PlasmaRenderer(
              type: PlasmaType.infinity,
              particles: 7,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0x28B4B4B4)
                  : const Color(0x44B6B6B6),
              blur: 0.4,
              size: 0.8,
              speed: Theme.of(context).brightness == Brightness.light ? 4 : 3,
              offset: 0,
              blendMode: BlendMode.plus,
              particleType: ParticleType.atlas,
              variation1: 0,
              variation2: 0,
              variation3: 0,
              rotation: 0,
            ),
    );
    
    if (disableAnimation) {
      return BreathingWidget(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 1000),
        endScale: 1.7,
        child: background,
      );
    } else {
      return background;
    }
  }

  Color _getDynamicColor(BuildContext context, Color baseColor) {
    // Simple dynamic color adjustment based on brightness
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.light) {
      return Color.lerp(baseColor, Colors.white, 0.4) ?? baseColor;
    } else {
      return baseColor;
    }
  }
}