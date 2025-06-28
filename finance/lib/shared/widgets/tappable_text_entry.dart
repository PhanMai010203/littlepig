import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'animations/tappable_widget.dart';
import 'animations/animated_size_switcher.dart';
import 'app_text.dart';

/// A widget that displays a placeholder or a value, and triggers a callback on tap.
/// It's designed for smooth inline-editing-like experiences with enhanced animations and features.
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
  final bool autoSizeText;
  final String? showPlaceHolderWhenTextEquals;
  final bool disabled;
  final Function(Widget Function(String? titlePassed) titleBuilder)? customTitleBuilder;

  const TappableTextEntry({
    super.key,
    this.title,
    required this.placeholder,
    required this.onTap,
    this.padding = const EdgeInsetsDirectional.symmetric(vertical: 0),
    this.internalPadding =
        const EdgeInsetsDirectional.symmetric(vertical: 6, horizontal: 12),
    this.fontSize,
    this.fontWeight,
    this.enableAnimatedSwitcher = true,
    this.addTappableBackground = false,
    this.autoSizeText = false,
    this.showPlaceHolderWhenTextEquals,
    this.disabled = false,
    this.customTitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleBuilder(String? titlePassed) {
      return AppText(
        titlePassed == null ||
                titlePassed == "" ||
                titlePassed == showPlaceHolderWhenTextEquals
            ? placeholder
            : titlePassed,
        autoSizeText: autoSizeText,
        maxLines: 2,
        minFontSize: 16,
        fontSize: fontSize ?? 35,
        fontWeight: fontWeight ?? FontWeight.bold,
        textColor: titlePassed == null ||
                titlePassed == "" ||
                titlePassed == showPlaceHolderWhenTextEquals
            ? getColor(context, "textLight")
            : getColor(context, "text"),
        textAlign: TextAlign.start,
      );
    }

    return Stack(
      children: [
        if (addTappableBackground)
          PositionedDirectional(
            top: padding.top + 3,
            bottom: padding.bottom + 4,
            end: padding.end - 1,
            start: padding.start - 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(5),
                color: getColor(context, "surfaceContainer"),
              ),
            ),
          ),
        enableAnimatedSwitcher 
            ? AnimatedSizeSwitcher(
                child: TappableWidget(
                  key: ValueKey(title),
                  onTap: disabled ? null : onTap,
                  animationType: TapAnimationType.scale,
                  scaleFactor: 0.98,
                  child: Padding(
                    padding: padding,
                    child: AnimatedContainer(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 250),
                      padding: internalPadding,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: disabled ? 0 : 1.5,
                            color: disabled
                                ? Colors.transparent
                                : getColor(context, "primary").withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: IntrinsicWidth(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: customTitleBuilder != null
                              ? customTitleBuilder!(titleBuilder)
                              : titleBuilder(title),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : TappableWidget(
                key: ValueKey(title),
                onTap: disabled ? null : onTap,
                animationType: TapAnimationType.scale,
                scaleFactor: 0.98,
                child: Padding(
                  padding: padding,
                  child: AnimatedContainer(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 250),
                    padding: internalPadding,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: disabled ? 0 : 1.5,
                          color: disabled
                              ? Colors.transparent
                              : getColor(context, "primary").withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: IntrinsicWidth(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: customTitleBuilder != null
                            ? customTitleBuilder!(titleBuilder)
                            : titleBuilder(title),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
} 