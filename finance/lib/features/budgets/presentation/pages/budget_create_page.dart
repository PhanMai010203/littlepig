import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/fade_in.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';

/// Full-screen page for creating a new budget
/// This page overlaps and hides the navbar for a focused creation experience
class BudgetCreatePage extends StatefulWidget {
  const BudgetCreatePage({super.key});

  @override
  State<BudgetCreatePage> createState() => _BudgetCreatePageState();
}

class _BudgetCreatePageState extends State<BudgetCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _isIncomeBudget = false;
  bool _excludeDebtCredit = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getColor(context, 'background'),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AppText(
        'budgets.form.create_new_budget'.tr(),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        colorName: 'text',
      ),
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: getColor(context, 'text'),
        ),
        onPressed: _isSubmitting ? null : () => context.pop(),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getColor(context, 'primary'),
                    ),
                  ),
                )
              : AppText(
                  'common.save'.tr(),
                  colorName: 'primary',
                  fontWeight: FontWeight.w600,
                ),
        ),
        const SizedBox(width: 8),
      ],
      backgroundColor: getColor(context, 'surface'),
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              _buildHeader(),
              const SizedBox(height: 32),

              // Budget name field
              _buildNameField(),
              const SizedBox(height: 24),

              // Amount field
              _buildAmountField(),
              const SizedBox(height: 24),

              // Period selection
              _buildPeriodField(),
              const SizedBox(height: 24),

              // Budget type toggle
              _buildBudgetTypeToggle(),
              const SizedBox(height: 24),

              // Advanced options
              _buildAdvancedOptions(),
              
              // Add some bottom padding for better scrolling experience
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: getColor(context, 'primary').withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: 32,
            color: getColor(context, 'primary'),
          ),
        ),
        const SizedBox(height: 16),
        AppText(
          'budgets.form.create_subtitle'.tr(),
          fontSize: 16,
          colorName: 'textSecondary',
          height: 1.4,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'budgets.form.name'.tr(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          colorName: 'text',
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'budgets.form.name_hint'.tr(),
            hintStyle: TextStyle(
              color: getColor(context, 'textSecondary'),
            ),
            prefixIcon: Icon(
              Icons.label_outline,
              color: getColor(context, 'primary'),
            ),
            filled: true,
            fillColor: getColor(context, 'surface'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'border'),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'border'),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'primary'),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'budgets.form.name_required'.tr();
            }
            if (value.trim().length < 2) {
              return 'budgets.form.name_too_short'.tr();
            }
            return null;
          },
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          _isIncomeBudget 
            ? 'budgets.form.target_amount'.tr()
            : 'budgets.form.budget_amount'.tr(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          colorName: 'text',
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              color: getColor(context, 'textSecondary'),
            ),
            prefixIcon: Icon(
              _isIncomeBudget ? Icons.trending_up : Icons.account_balance_wallet,
              color: getColor(context, 'primary'),
            ),
            prefixText: '\$ ',
            filled: true,
            fillColor: getColor(context, 'surface'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'border'),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'border'),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'primary'),
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'budgets.form.amount_required'.tr();
            }
            final amount = double.tryParse(value.trim());
            if (amount == null || amount <= 0) {
              return 'budgets.form.amount_invalid'.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPeriodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'budgets.form.period'.tr(),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          colorName: 'text',
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<BudgetPeriod>(
          value: _selectedPeriod,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.calendar_today,
              color: getColor(context, 'primary'),
            ),
            filled: true,
            fillColor: getColor(context, 'surface'),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'border'),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'border'),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: getColor(context, 'primary'),
                width: 2,
              ),
            ),
          ),
          items: BudgetPeriod.values.map((period) {
            return DropdownMenuItem(
              value: period,
              child: AppText(
                'budgets.period.${period.name}'.tr(),
                fontSize: 16,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPeriod = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBudgetTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: getColor(context, 'surface'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getColor(context, 'border'),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (_isIncomeBudget 
                ? getColor(context, 'success')
                : getColor(context, 'primary')).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isIncomeBudget ? Icons.trending_up : Icons.trending_down,
              color: _isIncomeBudget 
                ? getColor(context, 'success')
                : getColor(context, 'primary'),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  _isIncomeBudget 
                    ? 'budgets.form.income_budget'.tr()
                    : 'budgets.form.expense_budget'.tr(),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  colorName: 'text',
                ),
                const SizedBox(height: 4),
                AppText(
                  _isIncomeBudget 
                    ? 'budgets.form.income_description'.tr()
                    : 'budgets.form.expense_description'.tr(),
                  fontSize: 14,
                  colorName: 'textSecondary',
                  height: 1.3,
                ),
              ],
            ),
          ),
          Switch(
            value: _isIncomeBudget,
            onChanged: (value) {
              setState(() {
                _isIncomeBudget = value;
              });
            },
            activeColor: getColor(context, 'success'),
          ),
        ],
      ).tappable(
        onTap: () {
          setState(() {
            _isIncomeBudget = !_isIncomeBudget;
          });
        },
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: getColor(context, 'surface'),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: getColor(context, 'border'),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'budgets.form.advanced_options'.tr(),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            colorName: 'text',
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _excludeDebtCredit,
            onChanged: (value) {
              setState(() {
                _excludeDebtCredit = value ?? true;
              });
            },
            title: AppText(
              'budgets.form.exclude_debt_credit'.tr(),
              fontSize: 15,
              colorName: 'text',
            ),
            subtitle: AppText(
              'budgets.form.exclude_debt_credit_description'.tr(),
              fontSize: 13,
              colorName: 'textSecondary',
              height: 1.3,
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: getColor(context, 'primary'),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();
      final amount = double.parse(_amountController.text.trim());
      
      // Calculate period dates
      final (startDate, endDate) = _calculatePeriodDates(now, _selectedPeriod);

      final budget = Budget(
        name: _nameController.text.trim(),
        amount: amount,
        spent: 0.0,
        period: _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        syncId: _uuid.v4(),
        isIncomeBudget: _isIncomeBudget,
        excludeDebtCreditInstallments: _excludeDebtCredit,
        // Default values for other optional fields
        excludeObjectiveInstallments: false,
        includeTransferInOutWithSameCurrency: false,
        includeUpcomingTransactionFromBudget: false,
      );

      if (mounted) {
        context.read<BudgetsBloc>().add(CreateBudget(budget));
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              'budgets.form.created_successfully'.tr(
                namedArgs: {'name': budget.name}
              ),
              colorName: 'white',
            ),
            backgroundColor: getColor(context, 'success'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back to budgets page
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              'budgets.form.creation_failed'.tr(),
              colorName: 'white',
            ),
            backgroundColor: getColor(context, 'error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  (DateTime, DateTime) _calculatePeriodDates(DateTime now, BudgetPeriod period) {
    DateTime startDate;
    DateTime endDate;

    switch (period) {
      case BudgetPeriod.daily:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));
        break;
      case BudgetPeriod.weekly:
        // Start from Monday of current week
        final mondayOffset = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day - mondayOffset);
        endDate = startDate.add(const Duration(days: 7)).subtract(const Duration(microseconds: 1));
        break;
      case BudgetPeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1).subtract(const Duration(microseconds: 1));
        break;
      case BudgetPeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 1).subtract(const Duration(microseconds: 1));
        break;
    }

    return (startDate, endDate);
  }
}
