import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../core/di/injection.dart';

import '../bloc/transaction_detail_bloc.dart';
import '../bloc/transaction_detail_event.dart';
import '../bloc/transaction_detail_state.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/transaction_enums.dart';

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
          title: 'Transaction Details',
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
                          child: const AppText('Retry'),
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
      IconButton(
        onPressed: () {
          // TODO: Navigate to edit page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit functionality coming soon')),
          );
        },
        icon: const Icon(Icons.edit),
      ),
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
                const SnackBar(content: Text('Duplicate functionality coming soon')),
              );
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'duplicate',
            child: ListTile(
              leading: Icon(Icons.copy),
              title: Text('Duplicate'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
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
                      color: state.transaction.isIncome
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
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
              const AppText(
                'Details',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Date',
                DateFormat('MMM dd, yyyy').format(state.transaction.date),
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Category',
                state.category?.name ?? 'Unknown',
                Icons.category,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Account',
                state.account?.name ?? 'Unknown',
                Icons.account_balance_wallet,
              ),
              if (state.transaction.note?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Note',
                  state.transaction.note!,
                  Icons.note,
                ),
              ],
              if (state.transaction.isRecurring) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Recurrence',
                  _getRecurrenceText(state.transaction.recurrence),
                  Icons.repeat,
                ),
              ],
              if (state.transaction.transactionState != TransactionState.completed) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Status',
                  _getTransactionStateText(state.transaction.transactionState),
                  Icons.info,
                ),
              ],
            ],
          ),
        ),
      ),

      // Attachments Section
      if (state.attachments.isNotEmpty)
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
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
                Row(
                  children: [
                    const AppText(
                      'Attachments',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText(
                        '${state.attachments.length}',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        textColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAttachmentGrid(state.attachments),
              ],
            ),
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

  Widget _buildAttachmentGrid(List<Attachment> attachments) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        return TappableWidget(
          onTap: () {
            // TODO: Open attachment preview/download
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Opening ${attachment.fileName}')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  attachment.isImage ? Icons.image : Icons.description,
                  size: 32,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AppText(
                    attachment.fileName,
                    fontSize: 10,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
        label = 'Pay';
        color = Colors.green;
        break;
      case TransactionAction.skip:
        icon = Icons.skip_next;
        label = 'Skip';
        color = Colors.orange;
        break;
      case TransactionAction.collect:
        icon = Icons.account_balance;
        label = 'Collect';
        color = Colors.blue;
        break;
      case TransactionAction.settle:
        icon = Icons.handshake;
        label = 'Settle';
        color = Colors.purple;
        break;
      case TransactionAction.edit:
        icon = Icons.edit;
        label = 'Edit';
        break;
      case TransactionAction.delete:
        icon = Icons.delete;
        label = 'Delete';
        color = Colors.red;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement action handlers
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label action coming soon')),
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
        return 'Daily';
      case TransactionRecurrence.weekly:
        return 'Weekly';
      case TransactionRecurrence.monthly:
        return 'Monthly';
      case TransactionRecurrence.yearly:
        return 'Yearly';
      case TransactionRecurrence.none:
        return 'One-time';
    }
  }

  String _getTransactionStateText(TransactionState state) {
    switch (state) {
      case TransactionState.pending:
        return 'Pending';
      case TransactionState.scheduled:
        return 'Scheduled';
      case TransactionState.cancelled:
        return 'Cancelled';
      case TransactionState.actionRequired:
        return 'Action Required';
      case TransactionState.completed:
        return 'Completed';
    }
  }

  void _showDeleteConfirmation(BuildContext context, TransactionDetailBloc bloc, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete "${transaction.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(DeleteTransactionDetail(transaction.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}