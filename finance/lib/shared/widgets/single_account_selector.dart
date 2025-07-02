import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../core/theme/app_colors.dart';
import 'app_text.dart';
import 'dialogs/bottom_sheet_service.dart';
import 'animations/tappable_widget.dart';

/// A selector widget for choosing a single account
/// Displays selected account and opens a modal for selection
class SingleAccountSelector extends StatelessWidget {
  final List<Account> availableAccounts;
  final Account? selectedAccount;
  final ValueChanged<Account> onSelectionChanged;
  final String title;
  final String? subtitle;
  final bool isLoading;
  final bool isRequired;
  final String? errorText;

  const SingleAccountSelector({
    super.key,
    required this.availableAccounts,
    this.selectedAccount,
    required this.onSelectionChanged,
    this.title = 'Select Account',
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
          onTap: isLoading ? null : () => _showAccountSelectionModal(context),
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
    if (selectedAccount == null) {
      return AppText(
        'accounts.no_account_selected'.tr(),
        fontSize: 14,
        textColor: getColor(context, "textLight"),
      );
    }

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: selectedAccount!.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            selectedAccount!.name,
            fontSize: 14,
            textColor: getColor(context, "textSecondary"),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        AppText(
          selectedAccount!.currency,
          fontSize: 12,
          textColor: getColor(context, "textLight"),
        ),
      ],
    );
  }

  void _showAccountSelectionModal(BuildContext context) {
    Account? tempSelectedAccount = selectedAccount;

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
                        // Account Options
                        ...availableAccounts.map((account) {
                          return RadioListTile<Account>(
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
                            subtitle: Row(
                              children: [
                                AppText(
                                  account.currency,
                                  fontSize: 12,
                                  textColor: getColor(context, "textSecondary"),
                                ),
                                const SizedBox(width: 8),
                                if (account.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: getColor(context, "primary").withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: AppText(
                                      'accounts.default'.tr(),
                                      fontSize: 10,
                                      textColor: getColor(context, "primary"),
                                    ),
                                  ),
                              ],
                            ),
                            value: account,
                            groupValue: tempSelectedAccount,
                            onChanged: (Account? value) {
                              setState(() {
                                tempSelectedAccount = value;
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
                        onPressed: tempSelectedAccount != null 
                            ? () {
                                onSelectionChanged(tempSelectedAccount!);
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