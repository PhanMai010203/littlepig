import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../core/theme/app_colors.dart';
import 'app_text.dart';
import 'dialogs/bottom_sheet_service.dart';
import 'animations/tappable_widget.dart';

/// A selector widget for choosing a single category
/// Displays selected category and opens a modal for selection
class SingleCategorySelector extends StatelessWidget {
  final List<Category> availableCategories;
  final Category? selectedCategory;
  final ValueChanged<Category> onSelectionChanged;
  final String title;
  final String? subtitle;
  final bool isLoading;
  final bool isRequired;
  final String? errorText;

  const SingleCategorySelector({
    super.key,
    required this.availableCategories,
    this.selectedCategory,
    required this.onSelectionChanged,
    this.title = 'Select Category',
    this.subtitle,
    this.isLoading = false,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TappableWidget(
          onTap: isLoading ? null : () => _showCategorySelectionModal(context),
          animationType: TapAnimationType.scale,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getColor(context, "surfaceContainer"),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError 
                    ? getColor(context, "error") 
                    : getColor(context, "border"),
                width: hasError ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          AppText(
                            title,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            textColor: getColor(context, "primary"),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 4),
                            AppText(
                              '*',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              textColor: getColor(context, "error"),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (subtitle != null)
                        AppText(
                          subtitle!,
                          fontSize: 12,
                          textColor: getColor(context, "textSecondary"),
                        )
                      else
                        _buildSelectionSummary(context),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        getColor(context, "primary"),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: getColor(context, "textSecondary"),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppText(
              errorText!,
              fontSize: 12,
              textColor: getColor(context, "error"),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    if (selectedCategory == null) {
      return AppText(
        'categories.no_category_selected'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textLight"),
      );
    }

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: selectedCategory!.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              selectedCategory!.icon,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppText(
            selectedCategory!.name,
            fontSize: 14,
            textColor: getColor(context, "textSecondary"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showCategorySelectionModal(BuildContext context) {
    Category? tempSelectedCategory = selectedCategory;

    BottomSheetService.showCustomBottomSheet(
      context,
      StatefulBuilder(
        builder: (context, setState) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category Options
                        ...availableCategories.map((category) {
                          return RadioListTile<Category>(
                            title: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppText(
                                    category.name,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: category.isDefault
                                ? AppText(
                                    'categories.default'.tr(),
                                    fontSize: 12,
                                    textColor: getColor(context, "textSecondary"),
                                  )
                                : null,
                            value: category,
                            groupValue: tempSelectedCategory,
                            onChanged: (Category? value) {
                              setState(() {
                                tempSelectedCategory = value;
                              });
                            },
                            activeColor: getColor(context, "primary"),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: AppText(
                          'actions.cancel'.tr(),
                          textColor: getColor(context, "textSecondary"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: tempSelectedCategory != null 
                            ? () {
                                onSelectionChanged(tempSelectedCategory!);
                                Navigator.pop(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getColor(context, "primary"),
                          foregroundColor: getColor(context, "white"),
                        ),
                        child: AppText(
                          'actions.save'.tr(),
                          textColor: getColor(context, "white"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      title: title,
      isScrollControlled: true,
      resizeForKeyboard: false,
    );
  }
}