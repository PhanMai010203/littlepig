import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/dialogs/bottom_sheet_service.dart';
import '../../../../shared/widgets/text_input.dart';
import '../../../../shared/widgets/selector_widget.dart';
import '../../../../shared/widgets/multi_account_selector.dart';
import '../../../../shared/widgets/multi_category_selector.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_enums.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/tappable_text_entry.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budget_creation_bloc.dart';
import '../bloc/budgets_event.dart';
import '../bloc/budgets_state.dart';

/// Enum for budget types to make the selector more type-safe
enum BudgetType {
  expense,
  savings;

  bool get isExpense => this == BudgetType.expense;
  bool get isSavings => this == BudgetType.savings;
}

/// Full-screen page for creating a new budget
/// This page overlaps and hides the navbar for a focused creation experience
class BudgetCreatePage extends StatefulWidget {
  const BudgetCreatePage({super.key});

  @override
  State<BudgetCreatePage> createState() => _BudgetCreatePageState();
}

class _BudgetCreatePageState extends State<BudgetCreatePage>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _periodAmountController = TextEditingController();
  final _scrollController = ScrollController();

  final _nameFocusNode = FocusNode();
  final _periodAmountFocusNode = FocusNode();

  late AnimationController _nameAnimationController;
  late AnimationController _periodAmountAnimationController;
  late Animation<Color?> _nameBorderColorAnimation;
  late Animation<Color?> _periodAmountBorderColorAnimation;

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  int _periodAmount = 1;
  DateTime _startDate = DateTime.now();
  BudgetType _budgetType = BudgetType.expense;
  late Color _selectedColor;

  // New state variables for the enhanced selectors
  BudgetTrackingType _budgetTrackingType = BudgetTrackingType.automatic;

  final List<Color> _budgetColors = const [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF795548), // Brown
    Color(0xFF009688), // Teal
    Color(0xFFF44336), // Red
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = _budgetColors[0];
    _nameController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
    _periodAmountController.text = _periodAmount.toString();
    _periodAmountController.addListener(_onPeriodAmountChanged);

    // Initialize animation controllers
    _nameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _periodAmountAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Setup focus listeners
    _nameFocusNode.addListener(_onNameFocusChanged);
    _periodAmountFocusNode.addListener(_onPeriodAmountFocusChanged);

    // Initialize budget creation state and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<BudgetCreationBloc>()
          .add(BudgetTrackingTypeChanged(_budgetTrackingType));
      context.read<BudgetCreationBloc>().add(LoadAccountsForBudget());
      context.read<BudgetCreationBloc>().add(LoadCategoriesForBudget());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize color animations after context is available
    _nameBorderColorAnimation = ColorTween(
      begin: getColor(context, "border"),
      end: getColor(context, "primary"),
    ).animate(CurvedAnimation(
      parent: _nameAnimationController,
      curve: Curves.easeInOut,
    ));

    _periodAmountBorderColorAnimation = ColorTween(
      begin: getColor(context, "border"),
      end: getColor(context, "primary"),
    ).animate(CurvedAnimation(
      parent: _periodAmountAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _periodAmountController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    _periodAmountFocusNode.dispose();
    _nameAnimationController.dispose();
    _periodAmountAnimationController.dispose();
    super.dispose();
  }

  void _onNameFocusChanged() {
    if (_nameFocusNode.hasFocus) {
      _nameAnimationController.forward();
    } else {
      _nameAnimationController.reverse();
    }
  }

  void _onPeriodAmountFocusChanged() {
    if (_periodAmountFocusNode.hasFocus) {
      _periodAmountAnimationController.forward();
    } else {
      _periodAmountAnimationController.reverse();
    }
  }

  void _onPeriodAmountChanged() {
    final amount = int.tryParse(_periodAmountController.text);
    if (amount != null && amount > 0) {
      setState(() {
        _periodAmount = amount;
      });
    }
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
        const SizedBox(height: 0),
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

    BottomSheetService.showCustomBottomSheet(
      context,
      content,
      title: 'budgets.enter_budget_amount'.tr(),
      resizeForKeyboard: true,
      popupWithKeyboard: true, // Allow keyboard with this sheet
      isScrollControlled: true,
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
    debugPrint(
        '[_progressiveButtonAction] name: \\${_nameController.text}, amount: \\${_amountController.text}');
    if (_nameController.text.isEmpty) {
      return () => _nameFocusNode.requestFocus();
    }
    if (_amountController.text.isEmpty) {
      return _selectBudgetAmount;
    }
    return _submit;
  }

  void _submit() {
    debugPrint('[BudgetCreatePage] _submit called');
    final state = context.read<BudgetCreationBloc>().state;

    // Convert UI state to Budget entity
    final budget = _createBudgetFromUiState(state);
    debugPrint('[BudgetCreatePage] Created budget: \\${budget.toString()}');

    // Submit the budget via BLoC
    context.read<BudgetsBloc>().add(CreateBudget(budget));

    Navigator.pop(context);
  }

  Budget _createBudgetFromUiState(BudgetsState state) {
    // Extract current selection state
    List<String>? walletFks;
    int? categoryId;

    if (state is BudgetCreationState) {
      // Convert tracking type to walletFks
      if (_budgetTrackingType.isAutomatic) {
        if (state.isAllAccountsSelected) {
          // For "All" accounts, we leave walletFks as null or empty to include all
          // According to the Budget entity docs, null walletFks means manual mode
          // So for "All" automatic mode, we should include all available account IDs
          walletFks = state.availableAccounts
              .map((account) => account.id.toString())
              .toList();
        } else {
          walletFks = state.selectedAccounts
              .map((account) => account.id.toString())
              .toList();
        }
      } else {
        // Manual mode: walletFks should be null
        walletFks = null;
      }

      // Convert category selection
      if (!state.isAllCategoriesIncluded &&
          state.includedCategories.isNotEmpty) {
        // If specific categories are selected, use the first one as primary category
        // Note: The Budget entity currently only supports one categoryId
        // For multiple categories, this would need to be handled via budgetTransactionFilters
        categoryId = state.includedCategories.first.id;
      }
      // For "All" categories, we leave categoryId as null
    }

    // Generate unique sync ID
    final syncId = DateTime.now().millisecondsSinceEpoch.toString();

    return Budget(
      name: _nameController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      spent: 0.0,
      categoryId: categoryId,
      period: _selectedPeriod,
      periodAmount: _periodAmount,
      startDate: _startDate,
      endDate: _getEndDate(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncId: syncId,

      // Set wallet selection based on tracking type
      walletFks: walletFks,

      // Set budget purpose based on type
      isIncomeBudget: _budgetType.isSavings,

      // Set the user-selected color
      colour: _colorToHex(_selectedColor),

      // Default filtering options - can be enhanced later
      excludeDebtCreditInstallments: true,
      excludeObjectiveInstallments: false,
      includeTransferInOutWithSameCurrency: false,
      includeUpcomingTransactionFromBudget: false,

      // Additional filtering for exclude categories would go in budgetTransactionFilters
      // This is a more advanced feature that could be implemented later
      budgetTransactionFilters: _buildTransactionFilters(state),
    );
  }

  Map<String, dynamic>? _buildTransactionFilters(BudgetsState state) {
    if (state is! BudgetCreationState) return null;
    if (state.excludedCategories.isEmpty) return null;

    // Build filter to exclude specific categories
    // This is a simplified implementation - actual filter structure would depend on
    // the BudgetFilterService implementation
    return {
      'excludedCategoryIds':
          state.excludedCategories.map((cat) => cat.id).toList(),
    };
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

  String _formatPeriod(BudgetPeriod period, int amount) {
    final String basePeriod;
    switch (period) {
      case BudgetPeriod.daily:
        basePeriod = amount == 1 ? 'day' : 'days';
        break;
      case BudgetPeriod.weekly:
        basePeriod = amount == 1 ? 'week' : 'weeks';
        break;
      case BudgetPeriod.monthly:
        basePeriod = amount == 1 ? 'month' : 'months';
        break;
      case BudgetPeriod.yearly:
        basePeriod = amount == 1 ? 'year' : 'years';
        break;
    }
    return basePeriod;
  }

  /// Convert Color to hex string format expected by the Budget entity
  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  DateTime _getEndDate() {
    final now = _startDate;
    switch (_selectedPeriod) {
      case BudgetPeriod.daily:
        return now.add(Duration(days: _periodAmount - 1));
      case BudgetPeriod.weekly:
        return now.add(Duration(days: (_periodAmount * 7) - 1));
      case BudgetPeriod.monthly:
        // Calculate end date for multiple months
        DateTime endDate =
            DateTime(now.year, now.month + _periodAmount, now.day);
        // Adjust to last day of the final month if needed
        return DateTime(endDate.year, endDate.month, 0);
      case BudgetPeriod.yearly:
        return DateTime(now.year + _periodAmount - 1, 12, 31);
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
                // Budget Type Selector (Expense vs Savings)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: SelectorWidget<BudgetType>(
                    selectedValue: _budgetType,
                    options: [
                      SelectorOption<BudgetType>(
                        value: BudgetType.expense,
                        label: "budgets.expense_budget".tr(),
                        iconPath: 'assets/icons/arrow_down.svg',
                        activeIconColor: getColor(context, "error"),
                        activeTextColor: getColor(context, "textSecondary"),
                        activeBackgroundColor: getColor(context, "primary"),
                      ),
                      SelectorOption<BudgetType>(
                        value: BudgetType.savings,
                        label: "budgets.savings_budget".tr(),
                        iconPath: 'assets/icons/arrow_up.svg',
                        activeIconColor: getColor(context, "success"),
                        activeTextColor: getColor(context, "textSecondary"),
                        activeBackgroundColor: getColor(context, "success"),
                      ),
                    ],
                    onSelectionChanged: (budgetType) {
                      setState(() {
                        _budgetType = budgetType;
                      });
                    },
                  ),
                ),

                // Name Input - Direct editing with animated border
                Center(
                  child: AnimatedBuilder(
                    animation: _nameBorderColorAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: _nameBorderColorAnimation.value ??
                                  getColor(context, "border"),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: getColor(context, "textPrimary"),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Name',
                              hintStyle: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                color: getColor(context, "textLight"),
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsetsDirectional.fromSTEB(
                                      10, 10, 10, 10),
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 0),

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
                    // Period Amount - Direct editing with animated border
                    AnimatedBuilder(
                      animation: _periodAmountBorderColorAnimation,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    _periodAmountBorderColorAnimation.value ??
                                        getColor(context, "border"),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: IntrinsicWidth(
                            child: TextField(
                              controller: _periodAmountController,
                              focusNode: _periodAmountFocusNode,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 24,
                                color: getColor(context, "textLight"),
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 4),
                                fillColor: Colors.transparent,
                                filled: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: AppText(
                        ' ',
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
                            _formatPeriod(_selectedPeriod, _periodAmount),
                            fontSize: 24,
                            textColor: getColor(context, "textLight"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Beginning Date
                TappableWidget(
                  onTap: _selectStartDate,
                  animationType: TapAnimationType.scale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'beginning ',
                        fontSize: 18,
                        textColor: getColor(context, "textLight"),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: getColor(context, "border"),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: AppText(
                          DateFormat('MMMM d').format(_startDate),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: _budgetColors.length,
                      itemBuilder: (context, index) {
                        final color = _budgetColors[index];
                        final isSelected = color == _selectedColor;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: TappableWidget(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            animationType: TapAnimationType.scale,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 24)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Budget Tracking Type Selector (Manual vs Automatic)
                BlocBuilder<BudgetCreationBloc, BudgetsState>(
                  builder: (context, state) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: SelectorWidget<BudgetTrackingType>(
                        selectedValue: _budgetTrackingType,
                        options: [
                          SelectorOption<BudgetTrackingType>(
                            value: BudgetTrackingType.manual,
                            label: "budgets.manual_budget".tr(),
                            activeTextColor: getColor(context, "textSecondary"),
                            activeBackgroundColor: getColor(context, "primary"),
                          ),
                          SelectorOption<BudgetTrackingType>(
                            value: BudgetTrackingType.automatic,
                            label: "budgets.automatic_budget".tr(),
                            activeTextColor: getColor(context, "textSecondary"),
                            activeBackgroundColor: getColor(context, "primary"),
                          ),
                        ],
                        onSelectionChanged: (trackingType) {
                          setState(() {
                            _budgetTrackingType = trackingType;
                          });
                          context
                              .read<BudgetCreationBloc>()
                              .add(BudgetTrackingTypeChanged(trackingType));
                        },
                      ),
                    );
                  },
                ),

                // Conditional Account Selector (only for automatic budgets)
                BlocBuilder<BudgetCreationBloc, BudgetsState>(
                  builder: (context, state) {
                    if (_budgetTrackingType.isManual) {
                      return const SizedBox.shrink();
                    }

                    if (state is BudgetCreationState) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: MultiAccountSelector(
                          title: "budgets.select_accounts".tr(),
                          availableAccounts: state.availableAccounts,
                          selectedAccounts: state.selectedAccounts,
                          isAllSelected: state.isAllAccountsSelected,
                          isLoading: state.isAccountsLoading,
                          onAllSelected: () {
                            context.read<BudgetCreationBloc>().add(
                                  const BudgetAccountsSelected([], true),
                                );
                          },
                          onSelectionChanged: (selectedAccounts) {
                            context.read<BudgetCreationBloc>().add(
                                  BudgetAccountsSelected(
                                      selectedAccounts, false),
                                );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Include Categories Selector
                BlocBuilder<BudgetCreationBloc, BudgetsState>(
                  builder: (context, state) {
                    if (state is BudgetCreationState) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: MultiCategorySelector(
                          title: "budgets.include_categories".tr(),
                          availableCategories: state.availableCategories,
                          selectedCategories: state.includedCategories,
                          isAllSelected: state.isAllCategoriesIncluded,
                          isLoading: state.isCategoriesLoading,
                          isOpacityReduced:
                              state.shouldReduceIncludeCategoriesOpacity,
                          onAllSelected: () {
                            context.read<BudgetCreationBloc>().add(
                                  const BudgetIncludeCategoriesSelected(
                                      [], true),
                                );
                          },
                          onSelectionChanged: (selectedCategories) {
                            context.read<BudgetCreationBloc>().add(
                                  BudgetIncludeCategoriesSelected(
                                      selectedCategories, false),
                                );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Exclude Categories Selector
                BlocBuilder<BudgetCreationBloc, BudgetsState>(
                  builder: (context, state) {
                    if (state is BudgetCreationState) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        child: MultiCategorySelector(
                          title: "budgets.exclude_categories".tr(),
                          availableCategories: state.availableCategories,
                          selectedCategories: state.excludedCategories,
                          isAllSelected: false,
                          isLoading: state.isCategoriesLoading,
                          isExcludeMode: true,
                          onAllSelected: () {},
                          onSelectionChanged: (selectedCategories) {
                            context.read<BudgetCreationBloc>().add(
                                  BudgetExcludeCategoriesSelected(
                                      selectedCategories),
                                );
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
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
