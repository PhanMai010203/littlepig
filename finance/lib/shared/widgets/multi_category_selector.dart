import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../core/theme/app_colors.dart';
import 'app_text.dart';
import 'dialogs/bottom_sheet_service.dart';
import 'animations/tappable_widget.dart';

/// A selector widget for choosing multiple categories or all categories
/// Supports include/exclude modes with visual opacity interaction
class MultiCategorySelector extends StatelessWidget {
  final List<Category> availableCategories;
  final List<Category> selectedCategories;
  final bool isAllSelected;
  final ValueChanged<List<Category>> onSelectionChanged;
  final VoidCallback onAllSelected;
  final String title;
  final String? subtitle;
  final bool isLoading;
  final bool isExcludeMode;
  final bool isOpacityReduced;

  const MultiCategorySelector({
    super.key,
    required this.availableCategories,
    required this.selectedCategories,
    required this.isAllSelected,
    required this.onSelectionChanged,
    required this.onAllSelected,
    this.title = 'Select Categories',
    this.subtitle,
    this.isLoading = false,
    this.isExcludeMode = false,
    this.isOpacityReduced = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isOpacityReduced ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: TappableWidget(
        onTap: (isLoading || isOpacityReduced) ? null : () => _showCategorySelectionModal(context),
        animationType: TapAnimationType.scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getColor(context, "surfaceContainer"),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: getColor(context, "border"),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      title,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      textColor: getColor(context, "primary"),
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
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    if (isOpacityReduced) {
      return AppText(
        'categories.disabled_by_exclude'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textLight"),
      );
    }

    if (isAllSelected && !isExcludeMode) {
      return AppText(
        'categories.all_categories'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textSecondary"),
      );
    }

    if (selectedCategories.isEmpty) {
      return AppText(
        isExcludeMode 
            ? 'categories.no_categories_excluded'.tr()
            : 'categories.no_categories_selected'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textLight"),
      );
    }

    if (selectedCategories.length == 1) {
      return Row(
        children: [
          Text(
            selectedCategories.first.icon,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: AppText(
              selectedCategories.first.name,
              fontSize: 14,
              textColor: getColor(context, "textSecondary"),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return AppText(
      isExcludeMode
          ? '${selectedCategories.length} categories.categories_excluded'.tr()
          : '${selectedCategories.length} categories.categories_selected'.tr(),
      fontSize: 14,
      textColor: getColor(context, "textSecondary"),
    );
  }

  void _showCategorySelectionModal(BuildContext context) {
    final List<Category> tempSelectedCategories = List.from(selectedCategories);
    bool tempIsAllSelected = isAllSelected;

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
                        // All Categories Option (only for include mode)
                        if (!isExcludeMode) ...[
                          CheckboxListTile(
                            title: AppText(
                              'categories.all_categories'.tr(),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            subtitle: tempIsAllSelected
                                ? AppText(
                                    'categories.all_categories_description'.tr(),
                                    fontSize: 12,
                                    textColor: getColor(context, "textSecondary"),
                                  )
                                : null,
                            value: tempIsAllSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                tempIsAllSelected = value ?? false;
                                if (tempIsAllSelected) {
                                  tempSelectedCategories.clear();
                                }
                              });
                            },
                            activeColor: getColor(context, "primary"),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const Divider(),
                        ],
                        // Individual Category Options
                        ...availableCategories.map((category) {
                          final isSelected = tempSelectedCategories.contains(category);
                          final isEnabled = isExcludeMode || !tempIsAllSelected;
                          return Opacity(
                            opacity: isEnabled ? 1.0 : 0.5,
                            child: CheckboxListTile(
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
                              value: isSelected,
                              onChanged: isEnabled
                                  ? (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          if (!tempSelectedCategories.contains(category)) {
                                            tempSelectedCategories.add(category);
                                          }
                                        } else {
                                          tempSelectedCategories.remove(category);
                                        }
                                      });
                                    }
                                  : null,
                              activeColor: getColor(context, "primary"),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
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
                        onPressed: () {
                          if (!isExcludeMode && tempIsAllSelected) {
                            onAllSelected();
                          } else {
                            onSelectionChanged(tempSelectedCategories);
                          }
                          Navigator.pop(context);
                        },
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