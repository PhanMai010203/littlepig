import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/file_picker_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/transaction_detail_bloc.dart';
import '../bloc/transaction_detail_event.dart';
import '../bloc/transaction_detail_state.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';
import '../widgets/inline_note_editor.dart';
import '../widgets/inline_attachment_manager.dart';

class TransactionDetailPage extends StatelessWidget {
  final int transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionDetailBloc(
        transactionRepository: getIt<TransactionRepository>(),
        attachmentRepository: getIt<AttachmentRepository>(),
        categoryRepository: getIt<CategoryRepository>(),
        accountRepository: getIt<AccountRepository>(),
        filePickerService: getIt<FilePickerService>(),
        googleSignIn: getIt<GoogleSignIn>(),
        imagePicker: getIt<ImagePicker>(),
      )..add(LoadTransactionDetail(transactionId)),
      child: const _TransactionDetailView(),
    );
  }
}

class _TransactionDetailView extends StatelessWidget {
  const _TransactionDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionDetailBloc, TransactionDetailState>(
      listener: (context, state) {
        if (state is TransactionDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is TransactionDetailActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          if (state.message.contains('deleted')) {
            context.pop(); // Go back if transaction was deleted
          }
        }
      },
      builder: (context, state) {
        return PageTemplate(
          title: 'transactions.title'.tr(),
          actions: _buildAppBarActions(context, state),
          slivers: [
            if (state is TransactionDetailLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (state is TransactionDetailError)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.error,
                            size: 64,
                            color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        AppText(state.message, colorName: 'error'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context
                              .read<TransactionDetailBloc>()
                              .add(LoadTransactionDetail(
                                  (context.read<TransactionDetailBloc>().state
                                              as TransactionDetailLoaded?)
                                          ?.transaction
                                          .id ??
                                      0)),
                          child: AppText('common.retry'.tr()),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (state is TransactionDetailLoaded)
              ..._buildTransactionDetails(context, state),
          ],
        );
      },
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, TransactionDetailState state) {
    if (state is! TransactionDetailLoaded) return [];
    
    return [
      PopupMenuButton<String>(
        onSelected: (value) {
          final bloc = context.read<TransactionDetailBloc>();
          switch (value) {
            case 'delete':
              _showDeleteConfirmation(context, bloc, state.transaction);
              break;
            case 'duplicate':
              // TODO: Implement duplicate functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('transactions.duplicate_functionality_coming_soon'.tr())),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'duplicate',
            child: ListTile(
              leading: const Icon(Icons.copy),
              title: Text('transactions.duplicate'.tr()),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('transactions.delete'.tr(), style: const TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildTransactionDetails(BuildContext context, TransactionDetailLoaded state) {
    return [
      // Transaction Header with Amount and Title
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.category?.color.withValues(alpha: 0.1) ?? 
                          (state.transaction.isIncome
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: state.category != null
                        ? Text(
                            state.category!.icon,
                            style: const TextStyle(fontSize: 24),
                          )
                        : Icon(
                            state.transaction.isIncome
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: state.transaction.isIncome
                                ? Colors.green
                                : Colors.red,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          state.transaction.title,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          NumberFormat.currency(symbol: '\$')
                              .format(state.transaction.amount.abs()),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          textColor: state.transaction.isIncome
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Transaction Info
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'transactions.details'.tr(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'common.date'.tr(),
                DateFormat('MMM dd, yyyy').format(state.transaction.date),
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildCategoryRow(state.category),
              const SizedBox(height: 12),
              _buildInfoRow(
                'transactions.account'.tr(),
                state.account?.name ?? 'transactions.unknown'.tr(),
                Icons.account_balance_wallet,
              ),
              if (state.transaction.isRecurring) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'transactions.recurrence'.tr(),
                  _getRecurrenceText(state.transaction.recurrence),
                  Icons.repeat,
                ),
              ],
              if (state.transaction.transactionState != TransactionState.completed) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'transactions.status'.tr(),
                  _getTransactionStateText(state.transaction.transactionState),
                  Icons.info,
                ),
              ],
            ],
          ),
        ),
      ),

      // Inline Note Editor
      SliverToBoxAdapter(
        child: InlineNoteEditor(
          transactionId: state.transaction.id!,
          initialNote: state.transaction.note,
          isLoading: state.isNoteSaving,
        ),
      ),

      // Attachments Section
      SliverToBoxAdapter(
        child: InlineAttachmentManager(
          transactionId: state.transaction.id!,
          attachments: state.attachments,
          isLoading: state.isAttachmentLoading,
          isGoogleDriveAuthenticated: state.isGoogleDriveAuthenticated,
          isAuthenticating: state.isAuthenticating,
        ),
      ),


      // Action Buttons
      if (state.transaction.availableActions.isNotEmpty)
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: _buildActionButtons(context, state.transaction),
          ),
        ),

      // Add some bottom padding
      const SliverToBoxAdapter(
        child: SizedBox(height: 32),
      ),
    ];
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                fontSize: 12,
                textColor: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 2),
              AppText(
                value,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(Category? category) {
    return Row(
      children: [
        Icon(Icons.category, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'transactions.category'.tr(),
                fontSize: 12,
                textColor: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (category != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            category.icon,
                            fontSize: 12,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            category.name,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            textColor: category.color,
                          ),
                        ],
                      ),
                    ),
                  ] else
                    AppText(
                      'common.unknown'.tr(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: Colors.grey[600],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildActionButtons(BuildContext context, Transaction transaction) {
    final actions = transaction.availableActions;
    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        return _buildActionButton(context, action, transaction);
      }).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context, TransactionAction action, Transaction transaction) {
    IconData icon;
    String label;
    Color? color;

    switch (action) {
      case TransactionAction.pay:
        icon = Icons.payment;
        label = 'transactions.actions.pay'.tr();
        color = Colors.green;
        break;
      case TransactionAction.skip:
        icon = Icons.skip_next;
        label = 'transactions.actions.skip'.tr();
        color = Colors.orange;
        break;
      case TransactionAction.collect:
        icon = Icons.account_balance;
        label = 'transactions.actions.collect'.tr();
        color = Colors.blue;
        break;
      case TransactionAction.settle:
        icon = Icons.handshake;
        label = 'transactions.actions.settle'.tr();
        color = Colors.purple;
        break;
      case TransactionAction.edit:
        icon = Icons.edit;
        label = 'transactions.actions.edit'.tr();
        break;
      case TransactionAction.delete:
        icon = Icons.delete;
        label = 'transactions.actions.delete'.tr();
        color = Colors.red;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement action handlers
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('transactions.actions.coming_soon'.tr(namedArgs: {'action': label}))),
        );
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: color ?? Theme.of(context).primaryColor,
        backgroundColor: (color ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  String _getRecurrenceText(TransactionRecurrence recurrence) {
    switch (recurrence) {
      case TransactionRecurrence.daily:
        return 'transactions.recurrence_daily'.tr();
      case TransactionRecurrence.weekly:
        return 'transactions.recurrence_weekly'.tr();
      case TransactionRecurrence.monthly:
        return 'transactions.recurrence_monthly'.tr();
      case TransactionRecurrence.yearly:
        return 'transactions.recurrence_yearly'.tr();
      case TransactionRecurrence.none:
        return 'transactions.one_time'.tr();
    }
  }

  String _getTransactionStateText(TransactionState state) {
    switch (state) {
      case TransactionState.pending:
        return 'transactions.state.pending'.tr();
      case TransactionState.scheduled:
        return 'transactions.state.scheduled'.tr();
      case TransactionState.cancelled:
        return 'transactions.state.cancelled'.tr();
      case TransactionState.actionRequired:
        return 'transactions.state.action_required'.tr();
      case TransactionState.completed:
        return 'transactions.state.completed'.tr();
    }
  }

  void _showDeleteConfirmation(BuildContext context, TransactionDetailBloc bloc, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('transactions.delete_transaction'.tr()),
        content: Text('transactions.delete_confirmation'.tr(namedArgs: {'title': transaction.title})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteTransactionDetail(transaction.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}