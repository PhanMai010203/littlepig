import 'package:flutter/material.dart';
// Phase 5 imports
import 'animations/fade_in.dart';
import 'animations/animation_utils.dart';

const double _kDefaultExpandedHeight = 120.0;
const double _kDefaultToolbarHeight = 60.0;

/// Enhanced PageTemplate for Phase 5
///
/// Now includes:
/// - FadeIn animation wrapper for page entrances
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
    this.expandedHeight = _kDefaultExpandedHeight,
    this.toolbarHeight = _kDefaultToolbarHeight,
    this.titleTextStyle,
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
  final double expandedHeight;
  final double toolbarHeight;
  final TextStyle? titleTextStyle;

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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (widget.title != null)
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final appBarOpacity = _scrollController.hasClients
                    ? (_scrollController.offset /
                            (widget.expandedHeight - widget.toolbarHeight))
                        .clamp(0.0, 1.0)
                    : 0.0;

                return SliverAppBar(
                  pinned: true,
                  expandedHeight: widget.expandedHeight,
                  toolbarHeight: widget.toolbarHeight,
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
                          style: widget.titleTextStyle ??
                              theme.textTheme.titleLarge?.copyWith(
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
    );
  }
}
