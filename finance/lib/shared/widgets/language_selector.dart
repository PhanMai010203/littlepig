import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../shared/widgets/app_text.dart';
import '../../../core/theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'settings.language'.tr(),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: getColor(context, 'outline')),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(              children: [
                _buildLanguageOption(
                  context,
                  const Locale('en'),
                  'English',
                  'English',
                  currentLocale,
                ),
                Divider(
                  height: 1,
                  color: getColor(context, 'outline'),
                ),
                _buildLanguageOption(
                  context,
                  const Locale('vi'),
                  'Tiếng Việt',
                  'Vietnamese',
                  currentLocale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    Locale locale,
    String nativeName,
    String englishName,
    Locale currentLocale,
  ) {
    final isSelected = locale == currentLocale;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected 
            ? getColor(context, 'primary')
            : getColor(context, 'surfaceContainer'),
        child: Text(
          _getLanguageFlag(locale),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      title: AppText(
        nativeName,
        fontSize: 16,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        colorName: isSelected ? 'primary' : null,
      ),
      subtitle: AppText(
        englishName,
        fontSize: 12,
        colorName: 'textLight',
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: getColor(context, 'primary'),
            )
          : null,
      onTap: () async {
        await context.setLocale(locale);
        // You might want to save this to SharedPreferences as well
        // for persistence across app restarts
      },
    );
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'vi':
        return '🇻🇳';
      default:
        return '🌐';
    }
  }
}
