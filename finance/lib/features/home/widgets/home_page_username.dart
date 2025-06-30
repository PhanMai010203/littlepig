import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
// Phase 5 imports
import '../../../core/services/platform_service.dart';

class HomePageUsername extends StatelessWidget {
  final ScrollController scrollController;
  final double shrinkScrollOffset;

  const HomePageUsername({
    super.key,
    required this.scrollController,
    this.shrinkScrollOffset = 420.0,
  });

  @override
  Widget build(BuildContext context) {
    // Phase 5: Cache theme data for performance (Phase 1 pattern)
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // Phase 5: Platform-optimized text scaling
    final platform = PlatformService.getPlatform();
    final textScaleFactor = platform == PlatformOS.isIOS ? 1.0 : 0.95;
    
    // Phase 5: Component optimization tracking removed

    return AnimatedBuilder(
      animation: scrollController,
      builder: (_, child) {
        final scrollOffset =
            scrollController.hasClients ? scrollController.offset : 0.0;
        // Shrink from 1.0 to 0.7 over `shrinkScrollOffset` pixels of scrolling
        final scale =
            (1 - (scrollOffset / shrinkScrollOffset)).clamp(0.7, 1.0);

        return Transform.scale(
          alignment: AlignmentDirectional.bottomStart,
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 0),
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: Text(
            "navigation.home".tr(),
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ),
      ),
    );
  }
}
