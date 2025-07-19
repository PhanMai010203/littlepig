import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import 'sheep_premium_background.dart';
import 'sheep_pro_banner.dart';

class SheepPremiumBanner extends StatelessWidget {
  const SheepPremiumBanner({super.key});

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 15;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
      child: TappableWidget(
        onTap: () {
          context.push('/premium');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Animated background
                Positioned.fill(
                  child: Opacity(
                    opacity: Theme.of(context).brightness == Brightness.light
                        ? 0.7
                        : 0.9,
                    child: SheepPremiumBackground(
                      disableAnimation: false, // Enable animations for banner
                    ),
                  ),
                ),
                
                // Content overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 17,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SheepProBanner(),
                              const SizedBox(height: 4),
                              Text(
                                'Budget like a pro with Sheep Pro',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Right arrow
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}