import 'package:flutter/material.dart';

class TextFont extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  
  const TextFont(this.text, {
    this.fontSize,
    this.fontWeight, 
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}