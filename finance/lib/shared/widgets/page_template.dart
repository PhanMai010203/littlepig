import 'package:flutter/material.dart';
// Phase 5 imports
import 'animations/fade_in.dart';
import 'animations/animation_utils.dart';

const double _kExpandedHeight = 120.0;
const double _kToolbarHeight = 60.0;

/// Enhanced PageTemplate for Phase 5
///
/// Now includes:
/// - FadeIn animation wrapper for page entrances
/// - AnimatedSwitcher for smooth title transitions
/// - Enhanced customization options
/// - Back button with animation support
/// - Integration with the animation framework
class PageTemplate extends StatefulWidget {
  const PageTemplate({
    this.title,
    required this.slivers,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.showBackButton = true,
    this.onBackPressed,
    this.customAppBar,
    super.key,
  });

  final String? title;
  final List<Widget> slivers;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? customAppBar;

  @override
  State<PageTemplate> createState() => _PageTemplateState();
}

class _PageTemplateState extends State<PageTemplate> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    // Workaround
    final primaryColor = theme.colorScheme.primaryContainer;

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? surfaceColor,
      floatingActionButton: widget.floatingActionButton,
      body: FadeIn(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (widget.title != null)
              AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  final appBarOpacity = _scrollController.hasClients
                      ? (_scrollController.offset /
                              (_kExpandedHeight - _kToolbarHeight))
                          .clamp(0.0, 1.0)
                      : 0.0;

                  return SliverAppBar(
                    pinned: true,
                    expandedHeight: _kExpandedHeight,
                    toolbarHeight: _kToolbarHeight,
                    actions: widget.actions,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: appBarOpacity > 0.95 ? 1 : 0,
                    leading: widget.showBackButton && Navigator.canPop(context)
                        ? IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: widget.onBackPressed ??
                                () => Navigator.pop(context),
                          )
                        : null,
                    flexibleSpace: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background that fades in/out with scroll
                        Container(
                            color: primaryColor
                                .withAlpha((255 * appBarOpacity).toInt())),
                        // Title & collapse handling
                        FlexibleSpaceBar(
                          titlePadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          centerTitle: false,
                          title: Text(
                            widget.title!, // safe to use ! because of the check
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: onSurfaceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ...widget.slivers,
          ],
        ),
      ),
    );
  }
}
