import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';
import '../../../../shared/widgets/page_template.dart';

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
    return PageTemplate(
      title: 'budgets.create_budget'.tr(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
              ],
            ),
          ),
        ),
      ],
    );
  }
}
