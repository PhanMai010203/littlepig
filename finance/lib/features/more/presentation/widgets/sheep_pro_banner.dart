import 'package:flutter/material.dart';

class SheepProBanner extends StatelessWidget {
  const SheepProBanner({
    this.large = false,
    this.fontColor,
    super.key,
  });
  
  final bool large;
  final Color? fontColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Sheep',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: large ? 35 : 23,
            color: fontColor ?? Colors.black,
          ),
        ),
        const SizedBox(width: 2),
        TextPill(fontSize: large ? 21 : 15, text: "Pro"),
      ],
    );
  }
}

class TextPill extends StatelessWidget {
  const TextPill({
    required this.text,
    required this.fontSize,
    super.key,
  });
  
  final String text;
  final double fontSize;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 5),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadiusDirectional.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}