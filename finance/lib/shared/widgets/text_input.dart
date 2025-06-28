import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/platform_service.dart';

enum TextInputStyle { bubble, underline, minimal }

// Global focus management for auto-restore functionality
FocusNode? _currentTextInputFocus;
bool _shouldAutoRefocus = false;

void minimizeKeyboard(BuildContext context) {
  FocusNode? currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
  currentFocus?.unfocus();
  Future.delayed(const Duration(milliseconds: 10), () {
    // shouldAutoRefocus = false;
  });
}

void handleOnTapOutsideTextInput(BuildContext context) {
  // Smart keyboard dismissal logic - only dismiss if not in a dialog
  final scaffoldContext = Scaffold.maybeOf(context);
  if (scaffoldContext != null) {
    minimizeKeyboard(context);
  }
}

/// Widget wrapper for auto-focus restoration on app resume
class ResumeTextFieldFocus extends StatefulWidget {
  const ResumeTextFieldFocus({super.key, required this.child});
  final Widget child;

  @override
  State<ResumeTextFieldFocus> createState() => _ResumeTextFieldFocusState();
}

class _ResumeTextFieldFocusState extends State<ResumeTextFieldFocus>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Observe lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Track focus changes globally so we know which TextField had focus last
    WidgetsBinding.instance.focusManager.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WidgetsBinding.instance.focusManager.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    _currentTextInputFocus = WidgetsBinding.instance.focusManager.primaryFocus;
    // If focus is lost because app goes to background, remember to restore
    if (_currentTextInputFocus == null) {
      _shouldAutoRefocus = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldAutoRefocus) {
      // Attempt to restore focus if possible
      if (_currentTextInputFocus != null &&
          _currentTextInputFocus!.canRequestFocus) {
        Future.microtask(() => _currentTextInputFocus!.requestFocus());
      }
      _shouldAutoRefocus = false;
    } else if (state == AppLifecycleState.paused) {
      // Flag that we may need to restore focus when coming back
      _shouldAutoRefocus = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only apply focus restoration on Android where keyboard is usually dismissed
    if (PlatformService.getPlatform() == PlatformOS.isAndroid) {
      return widget.child;
    }
    return widget.child;
  }
}

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool autofocus;
  final TextInputStyle style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool autoCorrect;
  final bool enableIMEPersonalizedLearning;
  final bool handleOnTapOutside;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ScrollController? scrollController;
  final double? topContentPadding;
  final String? prefix;
  final String? suffix;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final EdgeInsetsDirectional padding;
  final Color? backgroundColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final BorderRadius? borderRadius;
  final TextAlign textAlign;
  final int? maxLength;
  final VoidCallback? onEditingComplete;

  const TextInput({
    super.key,
    this.controller,
    this.hintText,
    this.autofocus = false,
    this.style = TextInputStyle.bubble,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textInputAction,
    this.obscureText = false,
    this.focusNode,
    this.keyboardType,
    this.autoCorrect = true,
    this.enableIMEPersonalizedLearning = true,
    this.handleOnTapOutside = true,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.scrollController,
    this.topContentPadding,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.minLines = 1,
    this.maxLines = 1,
    this.padding = const EdgeInsetsDirectional.all(16),
    this.backgroundColor,
    this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.borderRadius,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ResumeTextFieldFocus(
      child: Padding(
        padding: padding,
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: borderRadius ?? _getDefaultBorderRadius(),
          ),
          child: TextFormField(
            onTapOutside: handleOnTapOutside 
                ? (event) => handleOnTapOutsideTextInput(context)
                : null,
            scrollController: scrollController,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
            scrollPadding: const EdgeInsets.only(bottom: 80),
            focusNode: focusNode,
            controller: controller,
            autofocus: autofocus,
            keyboardType: keyboardType,
            maxLines: maxLines,
            minLines: minLines,
            onTap: onTap,
            readOnly: readOnly,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            onEditingComplete: onEditingComplete,
            textAlign: textAlign,
            autocorrect: autoCorrect,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: fontSize ?? (style == TextInputStyle.minimal ? 18 : 15),
              fontWeight: fontWeight,
            ),
            cursorColor: getColor(context, "primary"),
            decoration: InputDecoration(
              counterText: "",
              hintText: hintText,
              hintStyle: TextStyle(color: getColor(context, "textLight")),
              alignLabelWithHint: true,
              prefix: prefix != null ? Text(prefix!) : null,
              suffix: suffix != null ? Text(suffix!) : null,
              contentPadding: _getContentPadding(),
              filled: _shouldFill(),
              fillColor: Colors.transparent,
              isDense: true,
              border: _getBorder(context),
              enabledBorder: _getEnabledBorder(context),
              focusedBorder: _getFocusedBorder(context),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor(BuildContext context) {
    if (style == TextInputStyle.minimal) return Colors.transparent;
    return backgroundColor ?? getColor(context, "surfaceContainer");
  }

  BorderRadius _getDefaultBorderRadius() {
    switch (PlatformService.getPlatform()) {
      case PlatformOS.isIOS:
        return BorderRadius.circular(8);
      default:
        return BorderRadius.circular(15);
    }
  }

  EdgeInsets _getContentPadding() {
    return EdgeInsets.only(
      left: style == TextInputStyle.minimal ? 8 : 18,
      right: style == TextInputStyle.minimal ? 8 : 18,
      top: topContentPadding ?? (style == TextInputStyle.minimal ? 15 : 18),
      bottom: style == TextInputStyle.minimal ? 5 : 18,
    );
  }

  bool _shouldFill() {
    return style == TextInputStyle.minimal;
  }

  InputBorder _getBorder(BuildContext context) {
    switch (style) {
      case TextInputStyle.bubble:
        return OutlineInputBorder(
          borderRadius: borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide.none,
        );
      case TextInputStyle.underline:
        return UnderlineInputBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          borderSide: BorderSide(
            color: getColor(context, "border").withValues(alpha: 0.2),
            width: 2,
          ),
        );
      case TextInputStyle.minimal:
        return InputBorder.none;
    }
  }

  InputBorder _getEnabledBorder(BuildContext context) {
    switch (style) {
      case TextInputStyle.bubble:
        return OutlineInputBorder(
          borderRadius: borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide.none,
        );
      case TextInputStyle.underline:
        return UnderlineInputBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          borderSide: BorderSide(
            color: getColor(context, "border").withValues(alpha: 0.2),
            width: 2,
          ),
        );
      case TextInputStyle.minimal:
        return const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        );
    }
  }

  InputBorder _getFocusedBorder(BuildContext context) {
    switch (style) {
      case TextInputStyle.bubble:
        return OutlineInputBorder(
          borderRadius: borderRadius ?? _getDefaultBorderRadius(),
          borderSide: BorderSide(color: getColor(context, "primary"), width: 2),
        );
      case TextInputStyle.underline:
        return UnderlineInputBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          borderSide: BorderSide(
            color: getColor(context, "primary"),
            width: 2,
          ),
        );
      case TextInputStyle.minimal:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: getColor(context, "primary"),
            width: 2,
          ),
        );
    }
  }
} 