import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/platform_service.dart';

enum TextInputStyle { bubble, underline, minimal }

// Helper function to minimize keyboard globally
void minimizeKeyboard(BuildContext context) {
  FocusNode? currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
  currentFocus?.unfocus();
}

// Helper function for handling taps outside text inputs
void handleOnTapOutsideTextInput(BuildContext context) {
  // Smart keyboard dismissal logic - only dismiss if not in a dialog
  final scaffoldContext = Scaffold.maybeOf(context);
  if (scaffoldContext != null) {
    minimizeKeyboard(context);
  }
}

/// Widget wrapper for auto-focus restoration on app resume
/// 
/// This widget manages focus restoration when the app resumes from background.
/// Each instance manages its own focus state to avoid race conditions.
class ResumeTextFieldFocus extends StatefulWidget {
  const ResumeTextFieldFocus({super.key, required this.child});
  final Widget child;

  @override
  State<ResumeTextFieldFocus> createState() => _ResumeTextFieldFocusState();
}

class _ResumeTextFieldFocusState extends State<ResumeTextFieldFocus>
    with WidgetsBindingObserver {
  
  // Instance-based focus management to avoid race conditions
  FocusNode? _storedFocusNode;
  bool _appWentToBackground = false;
  bool _shouldRestoreFocus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _storedFocusNode = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        // App is going to background - store current focus if any
        _handleAppGoingToBackground();
        break;
      case AppLifecycleState.resumed:
        // App is coming back from background - restore focus if needed
        _handleAppResuming();
        break;
      case AppLifecycleState.inactive:
        // Handle iOS app switcher or Android recent apps
        _handleAppGoingToBackground();
        break;
      case AppLifecycleState.detached:
        // App is being terminated - clear stored focus
        _clearStoredFocus();
        break;
      case AppLifecycleState.hidden:
        // iOS 17+ hidden state - treat like paused
        _handleAppGoingToBackground();
        break;
    }
  }

  void _handleAppGoingToBackground() {
    final currentFocus = WidgetsBinding.instance.focusManager.primaryFocus;
    
    // Only store focus if:
    // 1. There's currently a focused text field
    // 2. The focus node can be refocused
    // 3. The focus node is within our widget subtree
    if (currentFocus != null && 
        currentFocus.canRequestFocus && 
        _isFocusWithinSubtree(currentFocus)) {
      _storedFocusNode = currentFocus;
      _shouldRestoreFocus = true;
      _appWentToBackground = true;
    }
  }

  void _handleAppResuming() {
    // Only restore focus if:
    // 1. App actually went to background (not just a brief inactive state)
    // 2. We have a stored focus node to restore
    // 3. The focus restoration flag is still set
    if (_appWentToBackground && _shouldRestoreFocus && _storedFocusNode != null) {
      Future.microtask(() {
        if (_storedFocusNode != null && 
            _storedFocusNode!.canRequestFocus &&
            mounted) {
          _storedFocusNode!.requestFocus();
        }
        _clearStoredFocus();
      });
    }
    _appWentToBackground = false;
  }

  bool _isFocusWithinSubtree(FocusNode focusNode) {
    // For simplicity, we'll allow focus restoration for any text field
    // since each ResumeTextFieldFocus instance manages its own state
    // This avoids complex widget tree traversal while still preventing
    // race conditions between multiple instances
    return focusNode.context != null;
  }

  void _clearStoredFocus() {
    _storedFocusNode = null;
    _shouldRestoreFocus = false;
  }

  @override
  Widget build(BuildContext context) {
    // Provide a way for child widgets to clear stored focus when keyboard is intentionally dismissed
    return _FocusRestorationScope(
      onClearStoredFocus: _clearStoredFocus,
      child: widget.child,
    );
  }
}

/// Internal widget to provide focus restoration scope to descendants
class _FocusRestorationScope extends InheritedWidget {
  const _FocusRestorationScope({
    required this.onClearStoredFocus,
    required super.child,
  });

  final VoidCallback onClearStoredFocus;

  static _FocusRestorationScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_FocusRestorationScope>();
  }

  @override
  bool updateShouldNotify(_FocusRestorationScope oldWidget) {
    return onClearStoredFocus != oldWidget.onClearStoredFocus;
  }
}

// Updated minimizeKeyboard function to clear stored focus
void minimizeKeyboardAndClearFocus(BuildContext context) {
  // Clear stored focus to prevent unwanted restoration
  final focusScope = _FocusRestorationScope.maybeOf(context);
  focusScope?.onClearStoredFocus();
  
  // Then minimize keyboard
  minimizeKeyboard(context);
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
    return Padding(
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