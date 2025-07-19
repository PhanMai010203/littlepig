import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../../shared/widgets/dialogs/bottom_sheet_service.dart';
import '../../../../shared/widgets/text_input.dart';
import '../../../../shared/widgets/selector_widget.dart';
import '../../../../shared/widgets/single_account_selector.dart';
import '../../../../shared/widgets/single_category_selector.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/page_template.dart';

import '../bloc/transaction_create_bloc.dart';
import '../bloc/transaction_create_event.dart';
import '../bloc/transaction_create_state.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../currencies/presentation/bloc/currency_display_bloc.dart';
import '../../../accounts/presentation/bloc/account_selection_bloc.dart';
import '../../../../core/di/injection.dart';


/// Full-screen page for creating a new transaction
/// This page uses BLoC for state management and supports all advanced transaction features
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

  late TransactionCreateBloc _bloc;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    // Initialize bloc
    _bloc = getIt<TransactionCreateBloc>();
    
    // Initialize controllers and listeners
    _titleController.addListener(() {
      _bloc.add(UpdateTitle(_titleController.text));
    });
    _amountController.addListener(() {
      final amount = double.tryParse(_amountController.text);
      if (amount != null) {
        _bloc.add(UpdateAmount(amount));
      }
    });
    _noteController.addListener(() {
      _bloc.add(UpdateNote(_noteController.text));
    });

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
    
    // Load initial data
    _bloc.add(LoadInitialData());
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
    debugPrint('🧹 TransactionCreatePage disposing...');
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    _titleFocusNode.dispose();
    _noteFocusNode.dispose();
    _titleAnimationController.dispose();
    _noteAnimationController.dispose();
    _bloc.close();
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

  void _selectDate(DateTime currentDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
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
    if (picked != null && picked != currentDate) {
      _bloc.add(UpdateDate(picked));
    }
  }

  void _selectAmount() {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInput(
          controller: _amountController,
          hintText: 'transactions.amount_hint'.tr(),
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


  String _formatCurrency(double amount, {String? currency}) {
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: currency ?? '\$',
      decimalDigits: 2,
    ).format(amount);
  }

  String _getProgressiveButtonLabel(TransactionCreateLoaded state) {
    if (state.nextRequiredField != null) {
      switch (state.nextRequiredField!) {
        case 'title':
          return 'transactions.set_title_action'.tr();
        case 'amount':
          return 'transactions.set_amount_action'.tr();
        case 'category':
          return 'transactions.select_category_action'.tr();
        default:
          return 'transactions.create_transaction_action'.tr();
      }
    }
    return 'transactions.create_transaction_action'.tr();
  }

  VoidCallback? _getProgressiveButtonAction(TransactionCreateLoaded state) {
    if (state.nextRequiredField != null) {
      switch (state.nextRequiredField!) {
        case 'title':
          return () => _titleFocusNode.requestFocus();
        case 'amount':
          return _selectAmount;
        case 'category':
          return () => _showCategorySelector(state);
        default:
          return state.isValid ? _submit : null;
      }
    }
    return state.isValid ? _submit : null;
  }

  void _showCategorySelector(TransactionCreateLoaded state) {
    _showCategorySelectionModal(state);
  }


  void _showCategorySelectionModal(TransactionCreateLoaded state) {
    Category? tempSelectedCategory = state.selectedCategory;

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
                        // Category Options
                        ...state.currentCategories.map((category) {
                          return RadioListTile<Category>(
                            title: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppText(
                                    category.name,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: category.isDefault
                                ? AppText(
                                    'categories.default'.tr(),
                                    fontSize: 12,
                                    textColor: getColor(context, "textSecondary"),
                                  )
                                : null,
                            value: category,
                            groupValue: tempSelectedCategory,
                            onChanged: (Category? value) {
                              setState(() {
                                tempSelectedCategory = value;
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
                        onPressed: tempSelectedCategory != null 
                            ? () {
                                _bloc.add(UpdateCategory(tempSelectedCategory!));
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
      title: 'transactions.select_category'.tr(),
      isScrollControlled: true,
      resizeForKeyboard: false,
    );
  }


  void _submit() {
    debugPrint('🚀 Submitting transaction creation...');
    _bloc.add(CreateTransaction());
  }

  Widget _buildAttachmentPreview(AttachmentData attachment) {
    final file = File(attachment.filePath);
    final extension = path.extension(attachment.fileName).toLowerCase();
    
    // Check if file is an image
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension)) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: getColor(context, "border")),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported,
                color: getColor(context, "textSecondary"),
                size: 20,
              );
            },
          ),
        ),
      );
    }
    
    // For non-image files, show appropriate icon
    IconData iconData;
    Color iconColor = getColor(context, "textSecondary");
    
    switch (extension) {
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case '.xls':
      case '.xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case '.txt':
        iconData = Icons.text_snippet;
        break;
      default:
        iconData = Icons.attach_file;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: getColor(context, "border")),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionCreateBloc>(
          create: (context) => _bloc,
        ),
        BlocProvider<CurrencyDisplayBloc>.value(
          value: context.read<CurrencyDisplayBloc>(),
        ),
      ],
      child: BlocListener<TransactionCreateBloc, TransactionCreateState>(
        listener: (context, state) {
          if (state is TransactionCreateSuccess) {
            debugPrint('🎉 Transaction created successfully: ${state.message}');
            debugPrint('🔙 Navigating back to transactions page...');
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TransactionCreateError) {
            debugPrint('❌ Transaction creation failed: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: getColor(context, "error"),
              ),
            );
          }
        },
        child: BlocBuilder<TransactionCreateBloc, TransactionCreateState>(
          builder: (context, state) {
            if (state is TransactionCreateLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (state is TransactionCreateError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () => _bloc.add(LoadInitialData()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (state is! TransactionCreateLoaded) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            return _buildLoadedState(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, TransactionCreateLoaded state) {
    return PageTemplate(
      title: 'transactions.create_transaction'.tr(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: FloatingActionButton.extended(
          key: ValueKey<String>(_getProgressiveButtonLabel(state)),
          onPressed: state.isCreating ? null : _getProgressiveButtonAction(state),
          label: state.isCreating 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : AppText(
                  _getProgressiveButtonLabel(state),
                  textColor: getColor(context, "white"),
                  fontWeight: FontWeight.w600,
                ),
          icon: state.isCreating 
              ? null 
              : Icon(Icons.arrow_forward, color: getColor(context, "white")),
          backgroundColor: getColor(context, "primary"),
        ),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Transaction Type Selector
              _buildTransactionTypeSelector(state),
              const SizedBox(height: 24),

              // Title Input
              _buildTitleInput(state),
              const SizedBox(height: 24),

              // Amount Display
              _buildAmountInput(state),
              const SizedBox(height: 24),

              // Date Selector
              _buildDateSelector(state),
              const SizedBox(height: 24),

              // Category Selector
              _buildCategorySelector(state),
              const SizedBox(height: 16),

              // Account Selector
              _buildAccountSelector(state),
              const SizedBox(height: 24),

              // Note Input
              _buildNoteInput(state),
              const SizedBox(height: 24),

              // Advanced Features Section
              _buildAdvancedFeatures(state),

              // Spacer
              const SizedBox(height: 150),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSelector(TransactionCreateLoaded state) {
    return SelectorWidget<TransactionType>(
      selectedValue: state.transactionType,
      options: [
        SelectorOption<TransactionType>(
          value: TransactionType.expense,
          label: "transactions.expense".tr(),
          iconPath: 'assets/icons/arrow_down.svg',
          activeIconColor: getColor(context, "error"),
          activeTextColor: getColor(context, "textSecondary"),
          activeBackgroundColor: getColor(context, "primary"),
        ),
        SelectorOption<TransactionType>(
          value: TransactionType.income,
          label: "transactions.income".tr(),
          iconPath: 'assets/icons/arrow_up.svg',
          activeIconColor: getColor(context, "success"),
          activeTextColor: getColor(context, "textSecondary"),
          activeBackgroundColor: getColor(context, "success"),
        ),
      ],
      onSelectionChanged: (transactionType) {
        _bloc.add(UpdateTransactionType(transactionType));
      },
    );
  }

  Widget _buildTitleInput(TransactionCreateLoaded state) {
    return Center(
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
                  color: getColor(context, "text"),
                ),
                decoration: InputDecoration(
                  hintText: 'transactions.title_hint'.tr(),
                  hintStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: getColor(context, "textLight"),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      10, 10, 10, 10),
                  fillColor: Colors.transparent,
                  filled: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountInput(TransactionCreateLoaded state) {
    return Center(
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
            _formatCurrency(state.amount ?? 0.0, currency: state.selectedAccount?.currency),
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector(TransactionCreateLoaded state) {
    return TappableWidget(
      onTap: () => _selectDate(state.date),
      animationType: TapAnimationType.scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            '${'transactions.date_label'.tr()} ',
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
              DateFormat('MMMM d, yyyy').format(state.date),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(TransactionCreateLoaded state) {
    return SingleCategorySelector(
      availableCategories: state.currentCategories,
      selectedCategory: state.selectedCategory,
      onSelectionChanged: (category) {
        _bloc.add(UpdateCategory(category));
      },
      title: 'transactions.select_category'.tr(),
      isRequired: true,
      errorText: state.validationErrors['category'],
    );
  }

  Widget _buildAccountSelector(TransactionCreateLoaded state) {
    return SingleAccountSelector(
      availableAccounts: state.accounts,
      selectedAccount: state.selectedAccount,
      onSelectionChanged: (account) {
        _bloc.add(UpdateAccount(account));
      },
      title: 'transactions.select_account'.tr(),
      isRequired: true,
      errorText: state.validationErrors['account'],
    );
  }

  Widget _buildNoteInput(TransactionCreateLoaded state) {
    return AnimatedBuilder(
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
              color: getColor(context, "text"),
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
    );
  }

  Widget _buildAdvancedFeatures(TransactionCreateLoaded state) {
    return ExpansionTile(
      title: AppText(
        'transactions.advanced_features'.tr(),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      children: [
        // Transaction State Selector
        _buildTransactionStateSelector(state),
        const SizedBox(height: 16),
        
        // Special Type Selector (Credit/Debt)
        _buildSpecialTypeSelector(state),
        const SizedBox(height: 16),
        
        // Recurrence Settings
        _buildRecurrenceSettings(state),
        const SizedBox(height: 16),
        
        // Budget Linking
        if (state.manualBudgets.isNotEmpty) ...[
          _buildBudgetLinking(state),
          const SizedBox(height: 16),
        ],
        
        // Attachments Section
        _buildAttachmentsSection(state),
      ],
    );
  }

  Widget _buildTransactionStateSelector(TransactionCreateLoaded state) {
    return SelectorWidget<TransactionState>(
      selectedValue: state.transactionState,
      options: [
        SelectorOption<TransactionState>(
          value: TransactionState.completed,
          label: "transactions.state.completed".tr(),
          iconPath: 'assets/icons/check.svg',
        ),
        SelectorOption<TransactionState>(
          value: TransactionState.pending,
          label: "transactions.state.pending".tr(),
          iconPath: 'assets/icons/clock.svg',
        ),
        SelectorOption<TransactionState>(
          value: TransactionState.scheduled,
          label: "transactions.state.scheduled".tr(),
          iconPath: 'assets/icons/calendar.svg',
        ),
      ],
      onSelectionChanged: (transactionState) {
        _bloc.add(UpdateTransactionState(transactionState));
      },
    );
  }

  Widget _buildSpecialTypeSelector(TransactionCreateLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'transactions.special_type'.tr(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<TransactionSpecialType?>(
                title: AppText('transactions.credit'.tr()),
                value: TransactionSpecialType.credit,
                groupValue: state.specialType,
                onChanged: (value) {
                  _bloc.add(UpdateSpecialType(value));
                },
              ),
            ),
            Expanded(
              child: RadioListTile<TransactionSpecialType?>(
                title: AppText('transactions.debt'.tr()),
                value: TransactionSpecialType.debt,
                groupValue: state.specialType,
                onChanged: (value) {
                  _bloc.add(UpdateSpecialType(value));
                },
              ),
            ),
          ],
        ),
        RadioListTile<TransactionSpecialType?>(
          title: AppText('transactions.none'.tr()),
          value: null,
          groupValue: state.specialType,
          onChanged: (value) {
            _bloc.add(UpdateSpecialType(value));
          },
        ),
      ],
    );
  }

  Widget _buildRecurrenceSettings(TransactionCreateLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'transactions.recurrence'.tr(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TransactionRecurrence>(
          value: state.recurrence,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: TransactionRecurrence.values.map((recurrence) {
            return DropdownMenuItem(
              value: recurrence,
              child: AppText('transactions.recurrence_${recurrence.name}'.tr()),
            );
          }).toList(),
          onChanged: (recurrence) {
            if (recurrence != null) {
              _bloc.add(UpdateRecurrence(recurrence));
            }
          },
        ),
      ],
    );
  }

  Widget _buildBudgetLinking(TransactionCreateLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'transactions.link_to_budgets'.tr(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        if (state.budgetLinks.isNotEmpty) ...[
          ...state.budgetLinks.map((link) => ListTile(
                title: AppText(link.budget.name),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    _bloc.add(RemoveBudgetLink(link.budget));
                  },
                ),
              )),
        ],
        ElevatedButton(
          onPressed: () => _showBudgetLinkingDialog(state),
          child: AppText('transactions.add_budget_link'.tr()),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(TransactionCreateLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'transactions.attachments'.tr(),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        if (state.attachments.isNotEmpty) ...[
          ...state.attachments.map((attachment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: getColor(context, "border")),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: AppText(attachment.fileName),
                  subtitle: attachment.isCapturedFromCamera
                      ? AppText(
                          'transactions.captured_from_camera'.tr(),
                          fontSize: 12,
                          textColor: getColor(context, "textSecondary"),
                        )
                      : null,
                  leading: _buildAttachmentPreview(attachment),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: getColor(context, "error")),
                    onPressed: () {
                      _bloc.add(RemoveAttachment(attachment.filePath));
                    },
                  ),
                ),
              )),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImageFromCamera(),
              icon: const Icon(Icons.camera_alt),
              label: AppText('transactions.camera'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: getColor(context, "primary"),
                foregroundColor: getColor(context, "white"),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickImageFromGallery(),
              icon: const Icon(Icons.photo_library),
              label: AppText('transactions.gallery'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: getColor(context, "primary"),
                foregroundColor: getColor(context, "white"),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => _pickMultipleImages(),
              icon: const Icon(Icons.photo_library_outlined),
              label: AppText('transactions.multiple_photos'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: getColor(context, "secondary"),
                foregroundColor: getColor(context, "white"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showBudgetLinkingDialog(TransactionCreateLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText('transactions.select_budget'.tr()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: state.manualBudgets.length,
            itemBuilder: (context, index) {
              final budget = state.manualBudgets[index];
              final isAlreadyLinked = state.budgetLinks
                  .any((link) => link.budget.id == budget.id);
              
              return ListTile(
                title: AppText(budget.name),
                subtitle: AppText(_formatCurrency(budget.amount, currency: state.selectedAccount?.currency)),
                enabled: !isAlreadyLinked,
                onTap: isAlreadyLinked
                    ? null
                    : () {
                        _bloc.add(LinkToBudget(budget));
                        Navigator.pop(context);
                      },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('actions.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        final fileName = path.basename(image.path);
        _bloc.add(AddAttachment(
          image.path,
          fileName,
          isCapturedFromCamera: true,
        ));
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transactions.photo_captured'.tr(namedArgs: {'fileName': fileName})),
            backgroundColor: getColor(context, "success"),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transactions.failed_to_capture_photo'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: getColor(context, "error"),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        final fileName = path.basename(image.path);
        _bloc.add(AddAttachment(
          image.path,
          fileName,
          isCapturedFromCamera: false,
        ));
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transactions.photo_selected'.tr(namedArgs: {'fileName': fileName})),
            backgroundColor: getColor(context, "success"),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transactions.failed_to_select_photo'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: getColor(context, "error"),
          ),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (images.isNotEmpty && mounted) {
        for (final image in images) {
          final fileName = path.basename(image.path);
          _bloc.add(AddAttachment(
            image.path,
            fileName,
            isCapturedFromCamera: false,
          ));
        }
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transactions.photos_selected'.tr(namedArgs: {'count': images.length.toString()})),
            backgroundColor: getColor(context, "success"),
          ),
        );
      }
    } catch (e) {
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transactions.failed_to_select_photos'.tr(namedArgs: {'error': e.toString()})),
            backgroundColor: getColor(context, "error"),
          ),
        );
      }
    }
  }
}
