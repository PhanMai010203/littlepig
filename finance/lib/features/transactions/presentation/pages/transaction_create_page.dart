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
import '../../../../shared/widgets/page_template.dart';
import '../../../../shared/widgets/tappable_text_entry.dart';

import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_enums.dart';

/// Enum for transaction types to make the selector more type-safe
enum TransactionTypeSelector {
  expense,
  income;

  bool get isExpense => this == TransactionTypeSelector.expense;
  bool get isIncome => this == TransactionTypeSelector.income;
}

/// Full-screen page for creating a new transaction
/// This page overlaps and hides the navbar for a focused creation experience
class TransactionCreatePage extends StatefulWidget {
  const TransactionCreatePage({super.key});

  @override
  State<TransactionCreatePage> createState() => _TransactionCreatePageState();
}

class _TransactionCreatePageState extends State<TransactionCreatePage>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _scrollController = ScrollController();

  final _titleFocusNode = FocusNode();
  final _noteFocusNode = FocusNode();

  late AnimationController _titleAnimationController;
  late AnimationController _noteAnimationController;
  late Animation<Color?> _titleBorderColorAnimation;
  late Animation<Color?> _noteBorderColorAnimation;

  DateTime _selectedDate = DateTime.now();
  TransactionTypeSelector _transactionType = TransactionTypeSelector.expense;
  int? _selectedCategoryId;
  int? _selectedAccountId;
  late Color _selectedColor;

  final List<Color> _transactionColors = const [
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
    _selectedColor = _transactionColors[0];
    _titleController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
    _noteController.addListener(() => setState(() {}));

    // Initialize animation controllers
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _noteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Setup focus listeners
    _titleFocusNode.addListener(_onTitleFocusChanged);
    _noteFocusNode.addListener(_onNoteFocusChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize color animations after context is available
    _titleBorderColorAnimation = ColorTween(
      begin: getColor(context, "border"),
      end: getColor(context, "primary"),
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.easeInOut,
    ));

    _noteBorderColorAnimation = ColorTween(
      begin: getColor(context, "border"),
      end: getColor(context, "primary"),
    ).animate(CurvedAnimation(
      parent: _noteAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    _titleFocusNode.dispose();
    _noteFocusNode.dispose();
    _titleAnimationController.dispose();
    _noteAnimationController.dispose();
    super.dispose();
  }

  void _onTitleFocusChanged() {
    if (_titleFocusNode.hasFocus) {
      _titleAnimationController.forward();
    } else {
      _titleAnimationController.reverse();
    }
  }

  void _onNoteFocusChanged() {
    if (_noteFocusNode.hasFocus) {
      _noteAnimationController.forward();
    } else {
      _noteAnimationController.reverse();
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectAmount() {
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
      title: 'transactions.enter_amount'.tr(),
      resizeForKeyboard: true,
      popupWithKeyboard: true,
      isScrollControlled: true,
    );
  }

  String get _progressiveButtonLabel {
    if (_titleController.text.isEmpty) {
      return 'transactions.set_title_action'.tr();
    }
    if (_amountController.text.isEmpty) {
      return 'transactions.set_amount_action'.tr();
    }
    if (_selectedCategoryId == null) {
      return 'transactions.select_category_action'.tr();
    }
    if (_selectedAccountId == null) {
      return 'transactions.select_account_action'.tr();
    }
    return 'transactions.create_transaction_action'.tr();
  }

  VoidCallback? get _progressiveButtonAction {
    if (_titleController.text.isEmpty) {
      return () => _titleFocusNode.requestFocus();
    }
    if (_amountController.text.isEmpty) {
      return _selectAmount;
    }
    if (_selectedCategoryId == null) {
      return null; // Category selector will handle this
    }
    if (_selectedAccountId == null) {
      return null; // Account selector will handle this
    }
    return _submit;
  }

  void _submit() {
    debugPrint('[TransactionCreatePage] _submit called');

    // Create the transaction entity
    final transaction = _createTransactionFromUiState();
    debugPrint('[TransactionCreatePage] Created transaction: ${transaction.toString()}');

    // Submit the transaction via BLoC
    context.read<TransactionsBloc>().add(CreateTransactionEvent(transaction));

    Navigator.pop(context);
  }

  Transaction _createTransactionFromUiState() {
    // Generate unique sync ID
    final syncId = DateTime.now().millisecondsSinceEpoch.toString();

    // Convert amount based on transaction type
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final finalAmount = _transactionType.isExpense ? -amount.abs() : amount.abs();

    return Transaction(
      title: _titleController.text,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      amount: finalAmount,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      date: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncId: syncId,
      transactionType: _transactionType.isExpense 
          ? TransactionType.expense 
          : TransactionType.income,
      transactionState: TransactionState.completed,
    );
  }

  String _formatCurrency(String amountStr) {
    final number = double.tryParse(amountStr) ?? 0.0;
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'transactions.create_transaction'.tr(),
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
                // Transaction Type Selector (Expense vs Income)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: SelectorWidget<TransactionTypeSelector>(
                    selectedValue: _transactionType,
                    options: [
                      SelectorOption<TransactionTypeSelector>(
                        value: TransactionTypeSelector.expense,
                        label: "transactions.expense".tr(),
                        iconPath: 'assets/icons/arrow_down.svg',
                        activeIconColor: getColor(context, "error"),
                        activeTextColor: getColor(context, "textSecondary"),
                        activeBackgroundColor: getColor(context, "primary"),
                      ),
                      SelectorOption<TransactionTypeSelector>(
                        value: TransactionTypeSelector.income,
                        label: "transactions.income".tr(),
                        iconPath: 'assets/icons/arrow_up.svg',
                        activeIconColor: getColor(context, "success"),
                        activeTextColor: getColor(context, "textSecondary"),
                        activeBackgroundColor: getColor(context, "success"),
                      ),
                    ],
                    onSelectionChanged: (transactionType) {
                      setState(() {
                        _transactionType = transactionType;
                      });
                    },
                  ),
                ),

                // Title Input - Direct editing with animated border
                Center(
                  child: AnimatedBuilder(
                    animation: _titleBorderColorAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(
                            bottom: BorderSide(
                              color: _titleBorderColorAnimation.value ??
                                  getColor(context, "border"),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: _titleController,
                            focusNode: _titleFocusNode,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w500,
                              color: getColor(context, "textPrimary"),
                            ),
                            decoration: InputDecoration(
                              hintText: 'transactions.title_hint'.tr(),
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

                const SizedBox(height: 24),

                // Amount Display
                Center(
                  child: TappableWidget(
                    onTap: _selectAmount,
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
                ),

                const SizedBox(height: 24),

                // Date Selector
                TappableWidget(
                  onTap: _selectDate,
                  animationType: TapAnimationType.scale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        'transactions.date_label'.tr() + ' ',
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
                          DateFormat('MMMM d, yyyy').format(_selectedDate),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Color Selector
                SizedBox(
                  height: 48,
                  child: Center(
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemCount: _transactionColors.length,
                      itemBuilder: (context, index) {
                        final color = _transactionColors[index];
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

                const SizedBox(height: 24),

                // Note Input
                AnimatedBuilder(
                  animation: _noteBorderColorAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: _noteBorderColorAnimation.value ??
                              getColor(context, "border"),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 16,
                          color: getColor(context, "textPrimary"),
                        ),
                        decoration: InputDecoration(
                          hintText: 'transactions.note_hint'.tr(),
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: getColor(context, "textLight"),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          fillColor: Colors.transparent,
                          filled: true,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Category Selector Placeholder
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getColor(context, "surface"),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: getColor(context, "border"),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'transactions.select_category'.tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        _selectedCategoryId != null 
                            ? 'Category ID: $_selectedCategoryId'
                            : 'transactions.no_category_selected'.tr(),
                        fontSize: 14,
                        textColor: getColor(context, "textLight"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Account Selector Placeholder
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: getColor(context, "surface"),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: getColor(context, "border"),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'transactions.select_account'.tr(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        _selectedAccountId != null 
                            ? 'Account ID: $_selectedAccountId'
                            : 'transactions.no_account_selected'.tr(),
                        fontSize: 14,
                        textColor: getColor(context, "textLight"),
                      ),
                    ],
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
