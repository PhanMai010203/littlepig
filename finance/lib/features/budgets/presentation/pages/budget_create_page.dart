import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/dialogs/bottom_sheet_service.dart';
import '../../../../shared/widgets/text_input.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/animations/animation_utils.dart';
import '../../domain/entities/budget.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/tappable_text_entry.dart';

/// Smooth toggle switch widget following project's animation framework
class SmoothToggleSwitch extends StatefulWidget {
  final bool isExpenseBudget;
  final ValueChanged<bool> onToggle;
  final String leftLabel;
  final String rightLabel;

  const SmoothToggleSwitch({
    super.key,
    required this.isExpenseBudget,
    required this.onToggle,
    required this.leftLabel,
    required this.rightLabel,
  });

  @override
  State<SmoothToggleSwitch> createState() => _SmoothToggleSwitchState();
}

class _SmoothToggleSwitchState extends State<SmoothToggleSwitch>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isExpenseBudget ? 0 : 1,
      animationDuration:
          AnimationUtils.getDuration(const Duration(milliseconds: 300)),
    );
  }

  @override
  void didUpdateWidget(SmoothToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isExpenseBudget != widget.isExpenseBudget) {
      _controller.animateTo(widget.isExpenseBudget ? 0 : 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = widget.isExpenseBudget;
    final Color indicatorColor = isExpense 
        ? getColor(context, "primary") 
        : getColor(context, "success");

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: getColor(context, "surfaceContainer"),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getColor(context, "border"),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: TabBar(
          controller: _controller,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: indicatorColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.zero,
          onTap: (index) {
            final isExpense = index == 0;
            if (widget.isExpenseBudget != isExpense) {
              widget.onToggle(isExpense);

              // Add haptic feedback using project's patterns
              if (AnimationUtils.shouldAnimate()) {
                HapticFeedback.lightImpact();
              }
            }
          },
          tabs: [
            _buildTab(
              label: widget.leftLabel,
              isSelected: isExpense,
              iconPath: 'assets/icons/arrow_down.svg',
              activeTextColor: getColor(context, "textSecondary"),
              activeIconColor: getColor(context, "error"),
            ),
            _buildTab(
              label: widget.rightLabel,
              isSelected: !isExpense,
              iconPath: 'assets/icons/arrow_up.svg',
              activeTextColor: getColor(context, "textSecondary"),
              activeIconColor: getColor(context, "success"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required String iconPath,
    required Color activeTextColor,
    required Color activeIconColor,
  }) {
    final Color textColor = isSelected 
        ? activeTextColor
        : getColor(context, "textLight");
    
    final Color iconColor = isSelected
        ? activeIconColor
        : getColor(context, "textLight");

    return TappableWidget(
      animationType: TapAnimationType.scale,
      scaleFactor: 0.98,
      duration: AnimationUtils.getDuration(const Duration(milliseconds: 150)),
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationUtils.animatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: AnimationUtils.getCurve(Curves.easeOut),
              child: SvgPicture.asset(
                iconPath,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: AnimationUtils.animatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: AnimationUtils.getCurve(Curves.easeOut),
                child: AppText(
                  label,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  textColor: textColor,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  bool _isExpenseBudget =
      true; // true for Expense Budget, false for Savings Budget
  bool _excludeDebtCredit = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: getColor(context, "primary"),
                  onPrimary: getColor(context, "white"),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _selectBudgetName() {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInput(
          controller: _nameController,
          hintText: 'budgets.name_placeholder'.tr(),
          autofocus: true,
          style: TextInputStyle.underline,
          handleOnTapOutside: true,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: getColor(context, "primary"),
            foregroundColor: getColor(context, "white"),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text('actions.save'.tr()),
        )
      ],
    );

    BottomSheetService.showSimpleBottomSheet(
      context,
      content,
      title: 'budgets.enter_budget_name'.tr(),
    );
  }

  void _selectBudgetAmount() {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInput(
          controller: _amountController,
          hintText: '0.00',
          autofocus: true,
          textInputAction: TextInputAction.done,
          style: TextInputStyle.underline,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          handleOnTapOutside: true,
          textCapitalization: TextCapitalization.none,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: getColor(context, "primary"),
            foregroundColor: getColor(context, "white"),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text('actions.save'.tr()),
        )
      ],
    );

    BottomSheetService.showSimpleBottomSheet(
      context,
      content,
      title: 'budgets.enter_budget_amount'.tr(),
    );
  }

  void _selectBudgetPeriod() async {
    final selectedValue =
        await BottomSheetService.showOptionsBottomSheet<BudgetPeriod>(
      context,
      title: 'budgets.select_period'.tr(),
      options: BudgetPeriod.values.map((period) {
        return BottomSheetOption(
          title: "budgets.period_${period.name}".tr(),
          value: period,
        );
      }).toList(),
    );

    if (selectedValue != null) {
      setState(() {
        _selectedPeriod = selectedValue;
      });
    }
  }

  String get _progressiveButtonLabel {
    if (_nameController.text.isEmpty) {
      return 'budgets.set_name_action'.tr();
    }
    if (_amountController.text.isEmpty) {
      return 'budgets.set_amount_action'.tr();
    }
    return 'budgets.create_budget_action'.tr();
  }

  VoidCallback? get _progressiveButtonAction {
    if (_nameController.text.isEmpty) {
      return _selectBudgetName;
    }
    if (_amountController.text.isEmpty) {
      return _selectBudgetAmount;
    }
    return _submit;
  }

  void _submit() {
    // TODO: Implement submission logic
    Navigator.pop(context);
  }

  String _formatCurrency(String amountStr) {
    final number = double.tryParse(amountStr) ?? 0.0;
    // This is a simplified formatter. For a real app, use the project's currency service.
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    ).format(number);
  }

  String _formatPeriod(BudgetPeriod period) {
    // In a real app, this would use translations.
    switch (period) {
      case BudgetPeriod.daily:
        return 'day';
      case BudgetPeriod.weekly:
        return 'week';
      case BudgetPeriod.monthly:
        return 'month';
      case BudgetPeriod.yearly:
        return 'year';
    }
  }

  DateTime _getEndDate() {
    final now = _startDate;
    switch (_selectedPeriod) {
      case BudgetPeriod.daily:
        return now;
      case BudgetPeriod.weekly:
        return now.add(const Duration(days: 6));
      case BudgetPeriod.monthly:
        // Last day of the month
        return (now.month < 12)
            ? DateTime(now.year, now.month + 1, 0)
            : DateTime(now.year + 1, 1, 0);
      case BudgetPeriod.yearly:
        return DateTime(now.year, 12, 31);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'budgets.create_budget'.tr(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: FloatingActionButton.extended(
          key: ValueKey<String>(_progressiveButtonLabel),
          onPressed: _progressiveButtonAction,
          label: AppText(
            _progressiveButtonLabel,
            textColor: getColor(context, "white"),
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(Icons.arrow_forward, color: getColor(context, "white")),
          backgroundColor: getColor(context, "primary"),
        ),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                // Budget Type Toggle Switch
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: SmoothToggleSwitch(
                    isExpenseBudget: _isExpenseBudget,
                    leftLabel: "budgets.expense_budget".tr(),
                    rightLabel: "budgets.savings_budget".tr(),
                    onToggle: (isExpense) {
                      setState(() {
                        _isExpenseBudget = isExpense;
                      });
                    },
                  ),
                ),

                // Name Input
                TappableTextEntry(
                  title: _nameController.text,
                  placeholder: 'Name',
                  onTap: _selectBudgetName,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  addTappableBackground: false,
                  internalPadding:
                      const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
                ),

                const SizedBox(height: 24),

                // Amount & Period
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    TappableWidget(
                      onTap: _selectBudgetAmount,
                      animationType: TapAnimationType.scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: getColor(context, "border"),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: AppText(
                          _formatCurrency(_amountController.text),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: AppText(
                        '/',
                        fontSize: 24,
                        textColor: getColor(context, "textLight"),
                      ),
                    ),
                    TappableWidget(
                      onTap: _selectBudgetPeriod,
                      animationType: TapAnimationType.scale,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: getColor(context, "border"),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: AppText(
                            '1 ${_formatPeriod(_selectedPeriod)}',
                            fontSize: 24,
                            textColor: getColor(context, "textLight"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Beginning Date
                TappableWidget(
                  onTap: _selectStartDate,
                  animationType: TapAnimationType.scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: getColor(context, "border"),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          'beginning ',
                          fontSize: 18,
                          textColor: getColor(context, "textLight"),
                        ),
                        AppText(
                          DateFormat('MMMM d').format(_startDate),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Current Period Hint
                Center(
                  child: AppText(
                    'Current Period: ${DateFormat.MMMd().format(_startDate)} - ${DateFormat.MMMd().format(_getEndDate())}',
                    fontSize: 14,
                    textColor: getColor(context, "textLight"),
                  ),
                ),

                // Spacer
                const SizedBox(height: 150),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
