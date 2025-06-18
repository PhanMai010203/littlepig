import 'package:flutter/material.dart';
// Phase 5 imports
import 'animations/fade_in.dart';
import 'animations/animation_utils.dart';

/// Enhanced PageTemplate for Phase 5
/// 
/// Now includes:
/// - FadeIn animation wrapper for page entrances
/// - AnimatedSwitcher for smooth title transitions
/// - Enhanced customization options
/// - Back button with animation support
/// - Integration with the animation framework
class PageTemplate extends StatelessWidget {
  const PageTemplate({
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.customAppBar,
    super.key,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? customAppBar;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Scaffold(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
        appBar: customAppBar ?? (title != null ? AppBar(
          title: AnimatedSwitcher(
            duration: AnimationUtils.getDuration(
              const Duration(milliseconds: 200),
            ),
            child: Text(
              title!,
              key: ValueKey(title),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          actions: actions,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null,
        ) : null),
        body: body,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
} 