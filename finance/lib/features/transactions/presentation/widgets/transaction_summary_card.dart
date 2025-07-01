import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../domain/entities/transaction_card_data.dart';
import '../../../../shared/widgets/dialogs/note_popup.dart';

/// Simplified transaction card widget for homepage display
/// 
/// This widget displays transaction information in a compact format
/// for horizontal scrolling on the homepage. It follows the same pattern
/// as BudgetSummaryCard, using pre-calculated data without BLoC dependencies.
class TransactionSummaryCard extends StatelessWidget {
  const TransactionSummaryCard({
    super.key,
    required this.transactionData,
    this.onTap,
  });

  final TransactionCardData transactionData;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    
    return Container(
      width: 280, // Fixed width for horizontal scrolling
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Material(
        type: MaterialType.card,
        elevation: 2.0,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: TappableWidget(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category icon section
                _buildCategoryIcon(),
                const SizedBox(width: 16),
                
                // Transaction details section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title and note indicator
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              transactionData.transaction.title,
                              fontWeight: FontWeight.w600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (transactionData.hasNote) ...[
                            const SizedBox(width: 8),
                            _buildNoteIcon(context),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Date and category
                      Row(
                        children: [
                          AppText(
                            transactionData.formattedDate,
                            fontSize: 12,
                            colorName: "textSecondary",
                          ),
                          if (transactionData.category != null) ...[
                            AppText(
                              " • ${transactionData.category!.name}",
                              fontSize: 12,
                              colorName: "textSecondary",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Amount section
                _buildAmountSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return CircleAvatar(
      radius: 24,
      backgroundColor: transactionData.categoryColor,
      child: Text(
        transactionData.categoryIcon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildNoteIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        if (transactionData.displayNote != null) {
          NotePopup.show(context, transactionData.displayNote!, position, size);
        }
      },
      child: SvgPicture.asset(
        'assets/icons/icon_note.svg',
        width: 16,
        height: 16,
        colorFilter: ColorFilter.mode(
          Theme.of(context).colorScheme.primary,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Direction arrow
        SvgPicture.asset(
          transactionData.isIncome
              ? 'assets/icons/arrow_up.svg'
              : 'assets/icons/arrow_down.svg',
          width: 12,
          height: 12,
          colorFilter: ColorFilter.mode(
            transactionData.amountColor,
            BlendMode.srcIn,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Amount
        AppText(
          transactionData.formattedAmount,
          fontWeight: FontWeight.bold,
          textColor: transactionData.amountColor,
          fontSize: 14,
        ),
      ],
    );
  }
}

/// Add transaction card for the end of the list
class AddTransactionCard extends StatelessWidget {
  const AddTransactionCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 140, // Smaller width than transaction cards
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Material(
        type: MaterialType.card,
        elevation: 1.0,
        shadowColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: TappableWidget(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 32,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 8),
                AppText(
                  'common.add'.tr(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  colorName: "textSecondary",
                  textAlign: TextAlign.center,
                ),
                AppText(
                  'transactions.title'.tr(),
                  fontSize: 10,
                  colorName: "textLight",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}