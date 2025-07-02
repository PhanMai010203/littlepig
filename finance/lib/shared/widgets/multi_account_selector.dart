import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../core/theme/app_colors.dart';
import 'app_text.dart';
import 'dialogs/bottom_sheet_service.dart';
import 'animations/tappable_widget.dart';

/// A selector widget for choosing multiple accounts or all accounts
/// Displays selected accounts in a collapsed state and opens a modal for selection
class MultiAccountSelector extends StatelessWidget {
  final List<Account> availableAccounts;
  final List<Account> selectedAccounts;
  final bool isAllSelected;
  final ValueChanged<List<Account>> onSelectionChanged;
  final VoidCallback onAllSelected;
  final String title;
  final String? subtitle;
  final bool isLoading;

  const MultiAccountSelector({
    super.key,
    required this.availableAccounts,
    required this.selectedAccounts,
    required this.isAllSelected,
    required this.onSelectionChanged,
    required this.onAllSelected,
    this.title = 'Select Accounts',
    this.subtitle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return TappableWidget(
      onTap: isLoading ? null : () => _showAccountSelectionModal(context),
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
    );
  }

  Widget _buildSelectionSummary(BuildContext context) {
    if (isAllSelected) {
      return AppText(
        'accounts.all_accounts'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textSecondary"),
      );
    }

    if (selectedAccounts.isEmpty) {
      return AppText(
        'accounts.no_accounts_selected'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textLight"),
      );
    }

    if (selectedAccounts.length == 1) {
      return AppText(
        selectedAccounts.first.name,
        fontSize: 14,
        textColor: getColor(context, "textSecondary"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AppText(
      'accounts.accounts_selected'.plural(
        selectedAccounts.length,
        args: [selectedAccounts.length.toString()],
      ),
      fontSize: 14,
      textColor: getColor(context, "textSecondary"),
    );
  }

  void _showAccountSelectionModal(BuildContext context) {
    final List<Account> tempSelectedAccounts = List.from(selectedAccounts);
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
                        // All Accounts Option
                        CheckboxListTile(
                          title: AppText(
                            'accounts.all_accounts'.tr(),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          subtitle: tempIsAllSelected
                              ? AppText(
                                  'accounts.all_accounts_description'.tr(),
                                  fontSize: 12,
                                  textColor: getColor(context, "textSecondary"),
                                )
                              : null,
                          value: tempIsAllSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              tempIsAllSelected = value ?? false;
                              if (tempIsAllSelected) {
                                tempSelectedAccounts.clear();
                              }
                            });
                          },
                          activeColor: getColor(context, "primary"),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const Divider(),
                        // Individual Account Options
                        ...availableAccounts.map((account) {
                          final isSelected = tempSelectedAccounts.contains(account);
                          final isEnabled = !tempIsAllSelected;
                          return Opacity(
                            opacity: isEnabled ? 1.0 : 0.5,
                            child: CheckboxListTile(
                              title: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: account.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: AppText(
                                      account.name,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: AppText(
                                account.currency,
                                fontSize: 12,
                                textColor: getColor(context, "textSecondary"),
                              ),
                              value: isSelected,
                              onChanged: isEnabled
                                  ? (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          if (!tempSelectedAccounts.contains(account)) {
                                            tempSelectedAccounts.add(account);
                                          }
                                        } else {
                                          tempSelectedAccounts.remove(account);
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
                          if (tempIsAllSelected) {
                            onAllSelected();
                          } else {
                            onSelectionChanged(tempSelectedAccounts);
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