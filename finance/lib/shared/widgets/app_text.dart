import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../core/theme/app_colors.dart';
import '../../core/settings/app_settings.dart';

/// Fallback fonts for specific locales (Asian languages)
const Set<String> fallbackFontLocales = {
  "zh",
  "zh_Hant", 
  "ja",
  "ko",
};

/// Custom text widget with theme integration and advanced features
/// Based on the budget app's TextFont widget
class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;
  final String? colorName; // Use named colors from theme
  final TextAlign textAlign;
  final int? maxLines;
  final bool? shadow;
  final bool autoSizeText;
  final double? minFontSize;
  final double? maxFontSize;
  final TextOverflow? overflow;
  final Widget? overflowReplacement;
  final bool? softWrap;
  final List<TextSpan>? richTextSpan;
  final bool selectableText;
  final double? letterSpacing;
  final double? height;
  const AppText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.textColor,
    this.colorName,
    this.maxLines,
    this.shadow = false,
    this.selectableText = false,
    this.richTextSpan,
    this.autoSizeText = false,
    this.maxFontSize,
    this.minFontSize,
    this.overflow,
    this.softWrap,    this.overflowReplacement,
    this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Determine final text color
    Color finalTextColor = textColor ?? 
        (colorName != null ? getColor(context, colorName!) : getColor(context, "text"));
    
    // Apply contrast enhancement if enabled
    if (AppSettings.getWithDefault<bool>('increaseTextContrast', false)) {      double threshold = Theme.of(context).brightness == Brightness.light ? 0.7 : 0.65;
      if ((finalTextColor.a * 255.0).round() < (255 * threshold).round()) {
        finalTextColor = finalTextColor.withValues(alpha: threshold);
      }
    }

    // Get current locale and font settings
    String locale = AppSettings.getWithDefault<String>('locale', 'system');
    String fontFamily = AppSettings.getWithDefault<String>('font', 'Inter');
    
    // Smart font fallback system (like budget app)
    String finalFontFamily = _getFinalFontFamily(fontFamily, locale);
    List<String> fontFallbacks = _getFontFallbacks(fontFamily, locale);

    final TextStyle textStyle = TextStyle(
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      fontSize: fontSize,
      fontFamily: finalFontFamily == 'system' ? null : finalFontFamily,
      fontFamilyFallback: fontFallbacks,
      color: finalTextColor,
      height: height,
      shadows: shadow == true
          ? [
              const Shadow(
                offset: Offset(0.0, 0.5),
                blurRadius: 8.0,
                color: Color(0x65000000),
              ),
            ]
          : null,
    );

    // Calculate font offset for certain fonts (like Avenir in budget app)
    double fontOffset = 0;
    if (finalFontFamily == 'Avenir' && !fallbackFontLocales.contains(locale)) {
      fontOffset = fontSize * 0.1;
    }

    Widget textWidget = Transform.translate(
      offset: Offset(0, fontOffset),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: textStyle,
        child: _buildTextChild(),
      ),
    );

    return textWidget;
  }

  Widget _buildTextChild() {
    if (selectableText) {
      return SelectableText(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
      );
    }

    if (richTextSpan != null && richTextSpan!.isNotEmpty) {
      return RichText(
        text: TextSpan(children: richTextSpan),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
        softWrap: softWrap ?? true,
      );
    }

    if (autoSizeText) {
      return AutoSizeText(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        minFontSize: minFontSize ?? 12,
        maxFontSize: maxFontSize ?? 30,
        overflow: overflow ?? TextOverflow.ellipsis,
        overflowReplacement: overflowReplacement,
        softWrap: softWrap ?? true,
      );
    }

    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  /// Get the final font family based on settings and locale
  String _getFinalFontFamily(String fontFamily, String locale) {
    // Use system font for Asian locales to ensure proper character support
    if (fallbackFontLocales.contains(locale)) {
      return 'system';
    }

    return fontFamily;
  }

  /// Get font fallbacks based on the primary font and locale
  List<String> _getFontFallbacks(String fontFamily, String locale) {
    List<String> fallbacks = [];

    // Add locale-specific fallbacks first
    if (fallbackFontLocales.contains(locale)) {
      switch (locale) {
        case 'zh':
        case 'zh_Hant':
          fallbacks.addAll(['PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei']);
          break;
        case 'ja':
          fallbacks.addAll(['Hiragino Kaku Gothic ProN', 'Yu Gothic', 'Meiryo']);
          break;
        case 'ko':
          fallbacks.addAll(['Apple SD Gothic Neo', 'Malgun Gothic', 'Noto Sans CJK KR']);
          break;
      }
    }

    // Add general fallbacks based on font family
    switch (fontFamily) {
      case 'Avenir':
        fallbacks.addAll(['Avenir Next', 'Helvetica Neue', 'Helvetica', 'Arial']);
        break;
      case 'Inter':
        fallbacks.addAll(['SF Pro Text', 'Roboto', 'Helvetica Neue', 'Arial']);
        break;
      case 'DMSans':
        fallbacks.addAll(['DM Sans', 'Roboto', 'Helvetica Neue', 'Arial']);
        break;
      default:
        fallbacks.addAll(['SF Pro Text', 'Roboto', 'Helvetica Neue', 'Arial']);
    }

    return fallbacks;
  }
}

/// Convenience methods for common text styles
class AppTextStyles {
  static Widget heading(String text, {
    String? colorName,
    Color? textColor,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return AppText(
      text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      colorName: colorName,
      textColor: textColor,
    );
  }

  static Widget subheading(String text, {
    String? colorName,
    Color? textColor,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return AppText(
      text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      colorName: colorName,
      textColor: textColor,
    );
  }

  static Widget body(String text, {
    String? colorName,
    Color? textColor,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return AppText(
      text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      colorName: colorName,
      textColor: textColor,
    );
  }

  static Widget caption(String text, {
    String? colorName,
    Color? textColor,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return AppText(
      text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      colorName: colorName ?? 'textLight',
      textColor: textColor,
    );
  }

  static Widget button(String text, {
    String? colorName,
    Color? textColor,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return AppText(
      text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      colorName: colorName,
      textColor: textColor,
    );
  }
}
