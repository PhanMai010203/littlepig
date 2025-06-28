import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum TextInputStyle { bubble, underline }

class TextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool autofocus;
  final TextInputStyle style;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;

  const TextInput({
    super.key,
    this.controller,
    this.hintText,
    this.autofocus = false,
    this.style = TextInputStyle.bubble,
    this.onChanged,
    this.textInputAction,
    this.obscureText = false,
    this.focusNode,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: textInputAction,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        filled: style == TextInputStyle.bubble,
        fillColor: getColor(context, "surfaceContainerHigh"),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: style == TextInputStyle.bubble
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: getColor(context, "border")),
              ),
        enabledBorder: style == TextInputStyle.bubble
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              )
            : UnderlineInputBorder(
                borderSide: BorderSide(color: getColor(context, "border")),
              ),
        focusedBorder: style == TextInputStyle.bubble
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: getColor(context, "primary"), width: 2),
              )
            : UnderlineInputBorder(
                borderSide:
                    BorderSide(color: getColor(context, "primary"), width: 2),
              ),
      ),
    );
  }
} 