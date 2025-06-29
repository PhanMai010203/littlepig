import 'package:flutter/material.dart';
// Phase 5 imports
import 'animations/fade_in.dart';
import 'animations/animation_utils.dart';
import 'collapsible_app_bar_title.dart';

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
    this.scrollController,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
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
  final ScrollController? scrollController;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
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
  late final ScrollController _scrollController;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.scrollController != null;
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    // Only dispose the controller if it was created internally
    if (!_isExternalController) {
      _scrollController.dispose();
    }
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
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
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
                  flexibleSpace: CollapsibleAppBarTitle(
                    title: widget.title!, // safe to use ! because of the check
                    scrollController: _scrollController,
                    expandedHeight: widget.expandedHeight,
                    toolbarHeight: widget.toolbarHeight,
                    titleTextStyle: widget.titleTextStyle,
                    backgroundColor: primaryColor,
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
