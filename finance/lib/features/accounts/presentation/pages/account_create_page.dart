import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/dialogs/bottom_sheet_service.dart';
import '../../../../shared/widgets/text_input.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import '../../../../shared/widgets/page_template.dart';
import '../../../currencies/domain/entities/currency.dart';
import '../bloc/account_create_bloc.dart';
import '../bloc/account_create_event.dart';
import '../bloc/account_create_state.dart';
import '../../../../core/di/injection.dart';

/// Full-screen page for creating a new account
/// This page follows the same design patterns as budget and transaction create pages
class AccountCreatePage extends StatefulWidget {
  const AccountCreatePage({super.key});

  @override
  State<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends State<AccountCreatePage>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _scrollController = ScrollController();

  final _nameFocusNode = FocusNode();

  late AnimationController _nameAnimationController;
  late Animation<Color?> _nameBorderColorAnimation;

  late AccountCreateBloc _bloc;

  // Account colors (same as budget create page)
  final List<Color> _accountColors = const [
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
    
    // Initialize bloc
    _bloc = getIt<AccountCreateBloc>();
    
    // Initialize controllers and listeners
    _nameController.addListener(() {
      _bloc.add(UpdateAccountName(_nameController.text));
    });
    _balanceController.addListener(() {
      final balance = double.tryParse(_balanceController.text);
      if (balance != null) {
        _bloc.add(UpdateAccountBalance(balance));
      }
    });

    // Initialize animation controllers
    _nameAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Setup focus listeners
    _nameFocusNode.addListener(_onNameFocusChanged);
    
    // Load initial data
    _bloc.add(const LoadInitialAccountData());
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _scrollController.dispose();
    _nameFocusNode.dispose();
    _nameAnimationController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onNameFocusChanged() {
    if (_nameFocusNode.hasFocus) {
      _nameAnimationController.forward();
    } else {
      _nameAnimationController.reverse();
    }
  }

  void _selectBalance() {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInput(
          controller: _balanceController,
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
      title: 'accounts.enter_beginning_balance'.tr(),
      resizeForKeyboard: true,
      popupWithKeyboard: true,
      isScrollControlled: true,
    );
  }

  void _selectCurrency(AccountCreateLoaded state) async {
    final selectedCurrency = await BottomSheetService.showOptionsBottomSheet<Currency>(
      context,
      title: 'accounts.select_currency'.tr(),
      options: state.availableCurrencies.map((currency) {
        return BottomSheetOption(
          title: '${currency.symbol} ${currency.code} - ${currency.name}',
          value: currency,
        );
      }).toList(),
    );

    if (selectedCurrency != null) {
      _bloc.add(UpdateAccountCurrency(selectedCurrency));
    }
  }

  String _formatCurrency(double amount, String? currencyCode) {
    if (currencyCode == null) return amount.toStringAsFixed(2);
    
    // Simplified formatter - in real app, use CurrencyService
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: currencyCode == 'USD' ? '\$' : currencyCode,
      decimalDigits: 2,
    ).format(amount);
  }

  String _getProgressiveButtonLabel(AccountCreateLoaded state) {
    if (state.nextRequiredField != null) {
      switch (state.nextRequiredField!) {
        case 'name':
          return 'accounts.set_name_action'.tr();
        case 'currency':
          return 'accounts.select_currency_action'.tr();
        default:
          return 'accounts.create_account_action'.tr();
      }
    }
    return 'accounts.create_account_action'.tr();
  }

  VoidCallback? _getProgressiveButtonAction(AccountCreateLoaded state) {
    if (state.nextRequiredField != null) {
      switch (state.nextRequiredField!) {
        case 'name':
          return () => _nameFocusNode.requestFocus();
        case 'currency':
          return () => _selectCurrency(state);
        default:
          return state.isValid ? _submit : null;
      }
    }
    return state.isValid ? _submit : null;
  }

  void _submit() {
    _bloc.add(const CreateAccount());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountCreateBloc>(
      create: (context) => _bloc,
      child: BlocListener<AccountCreateBloc, AccountCreateState>(
        listener: (context, state) {
          if (state is AccountCreateSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AccountCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: getColor(context, "error"),
              ),
            );
          }
        },
        child: BlocBuilder<AccountCreateBloc, AccountCreateState>(
          builder: (context, state) {
            if (state is AccountCreateLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (state is AccountCreateError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      ElevatedButton(
                        onPressed: () => _bloc.add(const LoadInitialAccountData()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            if (state is! AccountCreateLoaded) {
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

  Widget _buildLoadedState(BuildContext context, AccountCreateLoaded state) {
    return PageTemplate(
      title: 'accounts.create_account'.tr(),
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
                            hintText: 'accounts.account_name_hint'.tr(),
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
              ),

              const SizedBox(height: 32),

              // Beginning Balance
              Center(
                child: TappableWidget(
                  onTap: _selectBalance,
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
                      _formatCurrency(state.balance, state.selectedCurrency?.code),
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Beginning Balance Label
              Center(
                child: AppText(
                  'accounts.beginning_balance'.tr(),
                  fontSize: 16,
                  textColor: getColor(context, "textLight"),
                ),
              ),

              const SizedBox(height: 32),

              // Currency Selector
              TappableWidget(
                onTap: () => _selectCurrency(state),
                animationType: TapAnimationType.scale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      '${'accounts.currency_label'.tr()} ',
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
                        state.selectedCurrency != null 
                            ? '${state.selectedCurrency!.symbol} ${state.selectedCurrency!.code}'
                            : 'accounts.select_currency'.tr(),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Color Selector
              Center(
                child: AppText(
                  'accounts.select_color'.tr(),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    itemCount: _accountColors.length,
                    itemBuilder: (context, index) {
                      final color = _accountColors[index];
                      final isSelected = color == state.selectedColor;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TappableWidget(
                          onTap: () {
                            _bloc.add(UpdateAccountColor(color));
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

              // Spacer
              const SizedBox(height: 150),
            ]),
          ),
        ),
      ],
    );
  }
}