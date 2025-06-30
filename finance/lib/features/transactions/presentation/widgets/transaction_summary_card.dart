import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../domain/entities/transaction_card_data.dart';

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
      onTap: () => _showNotePopup(context),
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

  void _showNotePopup(BuildContext context) {
    if (transactionData.displayNote == null) return;
    
    final screenSize = MediaQuery.of(context).size;
    const double popupMaxWidth = 250.0;
    const double popupPadding = 16.0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: <Widget>[
            Positioned(
              left: popupPadding,
              right: popupPadding,
              top: screenSize.height * 0.3,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: popupMaxWidth,
                    minWidth: 120.0,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: AppText(
                    transactionData.displayNote!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
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