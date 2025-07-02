import 'package:flutter/material.dart';
import '../../widgets/app_text.dart';

/// A reusable popup for displaying short notes at a custom position using an overlay.
/// Call NotePopup.show(context, note, position, size) to display.
class NotePopup {
  static OverlayEntry? _noteOverlayEntry;
  static AnimationController? _noteAnimationController;
  static VoidCallback? _scrollListener;
  static ScrollPosition? _scrollPosition;

  /// Shows a note popup near the given position (typically from a tapped icon).
  /// [context]: BuildContext for overlay and theme
  /// [note]: The note text to display
  /// [position]: The global position (Offset) to anchor the popup
  /// [size]: The size of the anchor widget
  static void show(
    BuildContext context,
    String note,
    Offset position,
    Size size, {
    Duration duration = const Duration(seconds: 3),
    Color? textColor,
    VoidCallback? onTap,
  }) {
    _dismissCurrentPopup();
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final screenSize = MediaQuery.of(context).size;
    const double popupMaxWidth = 250.0;
    const double popupPadding = 16.0;
    const double verticalOffset = 8.0;

    double left = position.dx + (size.width / 2) - (popupMaxWidth / 2);
    double top = position.dy + size.height + verticalOffset;

    if (left + popupMaxWidth + popupPadding > screenSize.width) {
      left = screenSize.width - popupMaxWidth - popupPadding;
    }
    if (left < popupPadding) left = popupPadding;

    if (top + 100 > screenSize.height - popupPadding) {
      top = position.dy - 100 - verticalOffset;
    }
    if (top < popupPadding) top = popupPadding;

    final controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: Navigator.of(context),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        child: IgnorePointer(
          ignoring: onTap == null,
          child: GestureDetector(
            onTap: onTap != null ? () {
              onTap();
              _dismissCurrentPopup();
            } : null,
            child: FadeTransition(
              opacity: CurvedAnimation(parent: controller, curve: Curves.easeInOut),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: popupMaxWidth,
                    minWidth: 120.0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: AppText(
                    note,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14,
                    textColor: textColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _noteOverlayEntry = entry;
    _noteAnimationController = controller;
    overlay.insert(entry);
    controller.forward();

    _scrollPosition = Scrollable.of(context)?.position;
    if (_scrollPosition != null) {
      _scrollListener = () => _dismissCurrentPopup();
      _scrollPosition!.addListener(_scrollListener!);
    }

    Future.delayed(duration, _dismissCurrentPopup);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _noteOverlayEntry?.remove();
        _noteOverlayEntry = null;
        controller.dispose();
        _noteAnimationController = null;
        if (_scrollPosition != null && _scrollListener != null) {
          _scrollPosition!.removeListener(_scrollListener!);
        }
        _scrollPosition = null;
        _scrollListener = null;
      }
    });
  }

  /// Dismisses the current popup (if any) with a fade-out animation.
  static void _dismissCurrentPopup() {
    if (_noteAnimationController == null) return;
    if (_noteAnimationController!.status == AnimationStatus.reverse ||
        _noteAnimationController!.status == AnimationStatus.dismissed) {
      return;
    }
    _noteAnimationController!.reverse();
  }
} 