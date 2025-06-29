import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';

import '../../core/theme/app_colors.dart';
import 'app_text.dart';
import 'animations/tappable_widget.dart';
import 'animations/animation_utils.dart';

/// Configuration class for each selector option
class SelectorOption<T> {
  final T value;
  final String label;
  final String? iconPath;
  final Color? activeIconColor;
  final Color? activeTextColor;
  final Color? activeBackgroundColor;

  const SelectorOption({
    required this.value,
    required this.label,
    this.iconPath,
    this.activeIconColor,
    this.activeTextColor,
    this.activeBackgroundColor,
  });
}

/// A flexible selector widget that supports multiple options with smooth animations
/// 
/// This widget follows the project's animation framework and can be used for
/// any multi-option selection needs. It supports icons, custom colors, and
/// callbacks for each option.
class SelectorWidget<T> extends StatefulWidget {
  final T selectedValue;
  final List<SelectorOption<T>> options;
  final ValueChanged<T> onSelectionChanged;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? indicatorColor;
  final double borderWidth;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool hapticFeedback;
  final MainAxisAlignment alignment;
  final bool expandOptions;

  const SelectorWidget({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onSelectionChanged,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.indicatorColor,
    this.borderWidth = 1,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOut,
    this.hapticFeedback = true,
    this.alignment = MainAxisAlignment.spaceEvenly,
    this.expandOptions = true,
  }) : assert(options.length >= 2, 'SelectorWidget requires at least 2 options');

  @override
  State<SelectorWidget<T>> createState() => _SelectorWidgetState<T>();
}

class _SelectorWidgetState<T> extends State<SelectorWidget<T>>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _getSelectedIndex();
    _controller = TabController(
      length: widget.options.length,
      vsync: this,
      initialIndex: _selectedIndex,
      animationDuration: AnimationUtils.getDuration(widget.animationDuration),
    );
  }

  @override
  void didUpdateWidget(SelectorWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newIndex = _getSelectedIndex();
    if (_selectedIndex != newIndex) {
      _selectedIndex = newIndex;
      if (_selectedIndex >= 0 && _selectedIndex < _controller.length) {
        _controller.animateTo(_selectedIndex);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _getSelectedIndex() {
    final index = widget.options.indexWhere(
      (option) => option.value == widget.selectedValue,
    );
    return index == -1 ? 0 : index;
  }

  Color _getBackgroundColor() {
    return widget.backgroundColor ?? getColor(context, "surfaceContainer");
  }

  Color _getBorderColor() {
    return widget.borderColor ?? getColor(context, "border");
  }

  Color _getIndicatorColor() {
    if (widget.indicatorColor != null) return widget.indicatorColor!;
    
    final selectedOption = widget.options[_selectedIndex];
    return selectedOption.activeBackgroundColor ?? getColor(context, "primary");
  }

  BorderRadius _getBorderRadius() {
    return widget.borderRadius ?? BorderRadius.circular(12);
  }

  EdgeInsets _getPadding() {
    return widget.padding ?? EdgeInsets.zero;
  }

  void _handleOptionTap(int index) {
    if (_selectedIndex == index) return;

    final option = widget.options[index];
    widget.onSelectionChanged(option.value);

    // Add haptic feedback following project patterns
    if (widget.hapticFeedback && AnimationUtils.shouldAnimate()) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Platform-aware splash factory - consistent with app theme
    final splashFactory = defaultTargetPlatform == TargetPlatform.iOS
        ? NoSplash.splashFactory
        : InkRipple.splashFactory;

    return Container(
      height: widget.height,
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: _getBorderRadius(),
        border: Border.all(
          color: _getBorderColor(),
          width: widget.borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getBorderRadius().topLeft.x - 1),
        child: TabBar(
          controller: _controller,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: _getIndicatorColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          splashFactory: splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.zero,
          onTap: _handleOptionTap,
          tabs: widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            return _buildOptionTab(option, index == _selectedIndex);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOptionTab(SelectorOption<T> option, bool isSelected) {
    final Color textColor = isSelected 
        ? (option.activeTextColor ?? getColor(context, "textSecondary"))
        : getColor(context, "textLight");
    
    final Color? iconColor = option.iconPath != null
        ? (isSelected 
            ? (option.activeIconColor ?? getColor(context, "primary"))
            : getColor(context, "textLight"))
        : null;

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.expandOptions ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (option.iconPath != null) ...[
          AnimationUtils.animatedContainer(
            duration: widget.animationDuration,
            curve: AnimationUtils.getCurve(widget.animationCurve),
            child: SvgPicture.asset(
              option.iconPath!,
              width: 16,
              height: 16,
              colorFilter: iconColor != null
                  ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                  : null,
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (widget.expandOptions)
          Flexible(
            child: _buildAnimatedText(option.label, textColor, isSelected),
          )
        else
          _buildAnimatedText(option.label, textColor, isSelected),
      ],
    );

    return TappableWidget(
      animationType: TapAnimationType.scale,
      scaleFactor: 0.98,
      duration: AnimationUtils.getDuration(const Duration(milliseconds: 150)),
      hapticFeedback: false, // Handle haptic feedback in _handleOptionTap
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: widget.alignment == MainAxisAlignment.center
            ? Center(child: content)
            : content,
      ),
    );
  }

  Widget _buildAnimatedText(String text, Color textColor, bool isSelected) {
    return AnimationUtils.animatedContainer(
      duration: widget.animationDuration,
      curve: AnimationUtils.getCurve(widget.animationCurve),
      child: AppText(
        text,
        fontSize: 14,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        textColor: textColor,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Extension to easily convert enum values to selector options
extension EnumToSelectorOption<T extends Enum> on List<T> {
  List<SelectorOption<T>> toSelectorOptions({
    String Function(T)? labelBuilder,
    String Function(T)? iconPathBuilder,
    Color Function(T)? activeIconColorBuilder,
    Color Function(T)? activeTextColorBuilder,
    Color Function(T)? activeBackgroundColorBuilder,
  }) {
    return map((value) => SelectorOption<T>(
      value: value,
      label: labelBuilder?.call(value) ?? value.name,
      iconPath: iconPathBuilder?.call(value),
      activeIconColor: activeIconColorBuilder?.call(value),
      activeTextColor: activeTextColorBuilder?.call(value),
      activeBackgroundColor: activeBackgroundColorBuilder?.call(value),
    )).toList();
  }
} 