import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'animations/animation_utils.dart';
import 'animations/tappable_widget.dart';
import 'app_text.dart';

/// A widget that displays a placeholder or a value, and triggers a callback on tap.
/// It's designed for smooth inline-editing-like experiences.
class TappableTextEntry extends StatelessWidget {
  final String? title;
  final String placeholder;
  final VoidCallback onTap;
  final EdgeInsetsDirectional padding;
  final EdgeInsetsDirectional internalPadding;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool enableAnimatedSwitcher;
  final bool addTappableBackground;

  const TappableTextEntry({
    super.key,
    this.title,
    required this.placeholder,
    required this.onTap,
    this.padding = const EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
    this.internalPadding =
        const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
    this.fontSize,
    this.fontWeight,
    this.enableAnimatedSwitcher = true,
    this.addTappableBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue = title != null && title!.isNotEmpty;
    final textWidget = AppText(
      hasValue ? title! : placeholder,
      fontSize: fontSize ?? 24,
      fontWeight: fontWeight ?? (hasValue ? FontWeight.w600 : FontWeight.w500),
      textColor:
          hasValue ? getColor(context, "text") : getColor(context, "textLight"),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final content = TappableWidget(
      onTap: onTap,
      animationType: TapAnimationType.scale,
      scaleFactor: 0.98,
      child: Container(
        padding: internalPadding,
        decoration: BoxDecoration(
          color: addTappableBackground
              ? getColor(context, "surfaceContainer")
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            bottom: BorderSide(
              color: hasValue
                  ? getColor(context, "primary").withOpacity(0.5)
                  : getColor(context, "border"),
              width: 1.5,
            ),
          ),
        ),
        child: IntrinsicWidth(
          child: textWidget,
        ),
      ),
    );

    if (enableAnimatedSwitcher) {
      return Padding(
        padding: padding,
        child: AnimatedSwitcher(
          duration:
              AnimationUtils.getDuration(const Duration(milliseconds: 300)),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<String>(title ?? ""),
            child: content,
          ),
        ),
      );
    }

    return Padding(padding: padding, child: content);
  }
} 