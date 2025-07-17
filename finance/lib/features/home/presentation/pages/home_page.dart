import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:finance/shared/widgets/page_template.dart';
import 'package:finance/shared/widgets/selector_widget.dart';
import 'package:finance/shared/widgets/app_text.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/features/budgets/domain/repositories/budget_repository.dart';
import 'package:finance/features/budgets/domain/entities/budget.dart';
import 'package:finance/features/budgets/domain/services/budget_display_service.dart';
import 'package:finance/features/transactions/domain/entities/transaction_card_data.dart';
import 'package:finance/features/transactions/domain/services/transaction_display_service.dart';
import 'package:finance/features/categories/domain/repositories/category_repository.dart';
import 'package:finance/features/categories/domain/entities/category.dart';
import 'package:finance/shared/extensions/account_currency_extension.dart';
import '../../widgets/home_page_username.dart';
import '../../widgets/account_card.dart';
import '../../../budgets/presentation/widgets/budget_tile.dart';
import '../../../budgets/presentation/widgets/budget_summary_card.dart'
    show AddBudgetCard;
import '../../../transactions/presentation/widgets/transaction_summary_card.dart';
// Phase 5 imports
import '../../../../shared/utils/responsive_layout_builder.dart';
import '../../../../shared/utils/performance_optimization.dart';
import '../../../../core/services/platform_service.dart';
import '../../../../shared/widgets/animations/tappable_widget.dart';
import 'package:finance/features/transactions/presentation/widgets/transaction_list.dart';
import 'package:finance/features/transactions/domain/entities/transaction.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../navigation/presentation/bloc/navigation_bloc.dart';
import '../../../accounts/presentation/bloc/account_selection_bloc.dart';

// TransactionFilter enum is now imported from transaction_display_service.dart

/// Lightweight view-model object for account display data
class AccountTileData {
  final Account account;
  final String formattedBalance;
  final int transactionCount;

  const AccountTileData({
    required this.account,
    required this.formattedBalance,
    required this.transactionCount,
  });
}

class HomePage extends StatefulWidget {
  final AccountRepository accountRepository;
  final TransactionRepository transactionRepository;
  final CurrencyRepository currencyRepository;
  final BudgetRepository budgetRepository;
  final BudgetDisplayService budgetDisplayService;
  final TransactionDisplayService transactionDisplayService;
  final CategoryRepository categoryRepository;

  const HomePage({
    super.key,
    required this.accountRepository,
    required this.transactionRepository,
    required this.currencyRepository,
    required this.budgetRepository,
    required this.budgetDisplayService,
    required this.transactionDisplayService,
    required this.categoryRepository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;

  // Phase 5: Cache theme data and platform info for performance (Phase 1 pattern)
  late ColorScheme _colorScheme;
  late TextTheme _textTheme;
  late bool _isIOS;

  List<AccountTileData> _accountTiles = [];
  List<Budget> _budgets = [];
  List<TransactionCardData> _transactionCards = [];
  bool _isLoading = true;
  bool _isBudgetsLoading = true;
  bool _isTransactionsLoading = true;
  String? _errorMessage;
  String? _budgetsErrorMessage;
  String? _transactionsErrorMessage;
  TransactionFilter _selectedTransactionFilter = TransactionFilter.all;

  // Cache for current month transactions to avoid re-filtering on filter changes
  List<Transaction>? _cachedCurrentMonthTransactions;
  Map<int, Category>? _cachedCategoryMap;

  @override
  void initState() {
    super.initState();

    // Phase 5: Cache platform detection (Phase 3 pattern)
    final platform = PlatformService.getPlatform();
    _isIOS = platform == PlatformOS.isIOS;

    // Phase 5: Platform-optimized animation controller (Phase 3 pattern)
    _scrollController = ScrollController();

    // Initialize AccountSelectionBloc
    final accountSelectionBloc = getIt<AccountSelectionBloc>();
    accountSelectionBloc.initialize();

    _loadAccounts();
    _loadBudgets();
    _loadTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Phase 5: Cache theme data once (Phase 1 pattern)
    final theme = Theme.of(context);
    _colorScheme = theme.colorScheme;
    _textTheme = theme.textTheme;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads accounts and assembles AccountTileData
  Future<void> _loadAccounts() async {
    try {
      // 1. Retrieve all accounts
      final accounts = await widget.accountRepository.getAllAccounts();

      // 2. For each account, get transaction count and formatted balance
      final List<AccountTileData> tiles = [];

      for (final account in accounts) {
        // Get transaction count for this account
        final transactions = await widget.transactionRepository
            .getTransactionsByAccount(account.id!);
        final transactionCount = transactions.length;

        // Format balance using AccountCurrencyExtension
        final formattedBalance = await account.formatBalance(
          widget.currencyRepository,
          showSymbol: true,
          useCodeWithSymbol: true,
        );

        tiles.add(AccountTileData(
          account: account,
          formattedBalance: formattedBalance,
          transactionCount: transactionCount,
        ));
      }

      if (mounted) {
        setState(() {
          _accountTiles = tiles;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load accounts: ${e.toString()}';
        });
      }

      // Show error feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading accounts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Loads budgets as Budget entities for use with original BudgetTile
  Future<void> _loadBudgets() async {
    try {
      // Retrieve active budgets as Budget entities
      final budgets = await widget.budgetRepository.getActiveBudgets();

      if (mounted) {
        setState(() {
          _budgets = budgets;
          _isBudgetsLoading = false;
          _budgetsErrorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBudgetsLoading = false;
          _budgetsErrorMessage = 'Failed to load budgets: ${e.toString()}';
        });
      }

      // Show error feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading budgets: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Loads transactions and prepares them for display
  Future<void> _loadTransactions() async {
    if (mounted) {
      setState(() {
        _isTransactionsLoading = true;
        _transactionsErrorMessage = null;
      });
    }
    
    // Clear cache for fresh data load
    _cachedCurrentMonthTransactions = null;
    _cachedCategoryMap = null;
    
    await _loadAndFilterTransactions();
  }

  /// Applies the current transaction filter without reloading from repository
  Future<void> _applyTransactionFilter() async {
    if (_isTransactionsLoading) return;
    
    await _loadAndFilterTransactions();
  }

  /// Shared method to load and filter transactions with current filter settings
  Future<void> _loadAndFilterTransactions() async {
    try {
      List<Transaction> currentMonthTransactions;
      Map<int, Category> categoryMap;

      // Use cached data if available, otherwise load fresh data
      if (_cachedCurrentMonthTransactions != null && _cachedCategoryMap != null) {
        currentMonthTransactions = _cachedCurrentMonthTransactions!;
        categoryMap = _cachedCategoryMap!;
      } else {
        // 1. Load all transactions
        final transactions = await widget.transactionRepository.getAllTransactions();
        
        // 2. Load all categories
        final categories = await widget.categoryRepository.getAllCategories();
        categoryMap = <int, Category>{};
        for (final category in categories) {
          if (category.id != null) {
            categoryMap[category.id!] = category;
          }
        }
        
        // 3. Filter to current month
        currentMonthTransactions = widget.transactionDisplayService
            .filterCurrentMonthTransactions(transactions);
        
        // Cache the results
        _cachedCurrentMonthTransactions = currentMonthTransactions;
        _cachedCategoryMap = categoryMap;
      }
      
      // 4. Apply type filter
      final filteredTransactions = widget.transactionDisplayService
          .filterTransactionsByType(currentMonthTransactions, _selectedTransactionFilter);
      
      // 5. Prepare display data
      final transactionCards = await widget.transactionDisplayService
          .prepareTransactionCardsData(filteredTransactions, categoryMap, 
              context: mounted ? context : null);
      
      if (mounted) {
        setState(() {
          _transactionCards = transactionCards;
          _isTransactionsLoading = false;
          _transactionsErrorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTransactionsLoading = false;
          _transactionsErrorMessage = 'Failed to load transactions: ${e.toString()}';
        });

        // Show error feedback to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading transactions: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Single handler for account selection
  void _onSelectAccount(int index) {
    print('DEBUG: _onSelectAccount called with index: $index');
    if (mounted) {
      final accountSelectionBloc = getIt<AccountSelectionBloc>();
      
      // Get the account from our local data to find its ID
      if (index < _accountTiles.length) {
        final account = _accountTiles[index].account;
        print('DEBUG: Selecting account: ${account.name} (ID: ${account.id})');
        
        // Use selectAccount with the account ID instead of index
        accountSelectionBloc.add(AccountSelectionEvent.selectAccount(accountId: account.id.toString()));
      } else {
        print('DEBUG: Index $index out of bounds for _accountTiles (length: ${_accountTiles.length})');
      }
    } else {
      print('DEBUG: Widget not mounted, skipping account selection');
    }
  }

  /// Handler for transaction filter selection
  void _onTransactionFilterChanged(TransactionFilter filter) {
    if (mounted) {
      setState(() {
        _selectedTransactionFilter = filter;
      });
      _applyTransactionFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization('HomePage',
        'ResponsiveLayoutBuilder+ThemeCaching+PlatformOptimization');

    // Phase 5: Use ResponsiveLayoutBuilder for size-dependent layout (Phase 2 pattern)
    return ResponsiveLayoutBuilder(
      debugLabel: 'HomePage',
      builder: (context, constraints, layoutData) {
        return PageTemplate(
          slivers: _buildSlivers(layoutData),
          scrollController: _scrollController,
        );
      },
    );
  }

  List<Widget> _buildSlivers(ResponsiveLayoutData layoutData) {
    final horizontalPadding =
        EdgeInsets.symmetric(horizontal: layoutData.isCompact ? 16 : 26);

    return [
      SliverPadding(
        padding: horizontalPadding,
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 100),
                child: Container(
                  alignment: AlignmentDirectional.bottomStart,
                  padding: const EdgeInsetsDirectional.only(
                      start: 9, bottom: 17, end: 9),
                ),
              ),
              HomePageUsername(scrollController: _scrollController),
              const SizedBox(height: 24),
              SizedBox(
                height: layoutData.isCompact ? 110 : 125,
                child: _buildAccountsSection(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160, // Match the height of BudgetTile
                child: _buildBudgetsSection(),
              ),
              const SizedBox(height: 12),
              _buildTransactionFilterSection(),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
      _buildTransactionsSection(EdgeInsets.symmetric(horizontal: layoutData.isCompact ? 16 : 26)),
    ];
  }

  Widget _buildTransactionFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectorWidget<TransactionFilter>(
          selectedValue: _selectedTransactionFilter,
          options: TransactionFilter.values.toSelectorOptions(
            labelBuilder: (filter) {
              switch (filter) {
                case TransactionFilter.all:
                  return 'transactions.filter_all'.tr();
                case TransactionFilter.expense:
                  return 'transactions.filter_expense'.tr();
                case TransactionFilter.income:
                  return 'transactions.filter_income'.tr();
              }
            },
          ),
          onSelectionChanged: _onTransactionFilterChanged,
          height: 44,
          borderRadius: BorderRadius.circular(12),
          animationDuration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildAccountsSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: _colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load accounts',
              style: _textTheme.bodyMedium?.copyWith(
                color: _colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadAccounts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<AccountSelectionBloc, AccountSelectionState>(
      bloc: getIt<AccountSelectionBloc>(),
      builder: (context, accountSelectionState) {
        print('DEBUG: BlocBuilder rebuild - selectedIndex: ${accountSelectionState.selectedIndex}, accounts: ${accountSelectionState.availableAccounts.length}');
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              // Account cards from data - use the same data source for both display and selection
              ..._accountTiles.asMap().entries.map((entry) {
                final index = entry.key;
                final tileData = entry.value;

                // Check if this account matches the selected account from the bloc
                final isSelected = accountSelectionState.selectedAccount?.id == tileData.account.id;
                
                print('DEBUG: Account ${tileData.account.name} (index: $index, id: ${tileData.account.id}) - isSelected: $isSelected');

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: AccountCard(
                    title: tileData.account.name,
                    amount: tileData.formattedBalance,
                    transactions: '${tileData.transactionCount} transactions',
                    color: tileData.account.color,
                    isSelected: isSelected,
                    index: index,
                    onSelected: _onSelectAccount,
                  ),
                );
              }),
              // AddAccountCard at the end
              AddAccountCard(
                onTap: () {
                  context.go(AppRoutes.accountCreate);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetsSection() {
    if (_isBudgetsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_budgetsErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: _colorScheme.error,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load budgets',
              style: _textTheme.bodyMedium?.copyWith(
                color: _colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadBudgets,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_budgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              color: _colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No budgets yet',
              style: _textTheme.bodyMedium?.copyWith(
                color: _colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // TODO: Navigate to add budget page
              },
              child: const Text('Create Budget'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          // Original BudgetTile widgets with fixed width for horizontal scrolling
          ..._budgets.map((budget) {
            return SizedBox(
              width: 280, // Fixed width for horizontal scrolling
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: BudgetTile(budget: budget),
              ),
            );
          }),
          // AddBudgetCard at the end
          AddBudgetCard(
            onTap: () {
              // TODO: Navigate to add budget page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(EdgeInsetsGeometry horizontalPadding) {
    if (_isTransactionsLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_transactionsErrorMessage != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: _colorScheme.error,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load transactions',
                style: _textTheme.bodyMedium?.copyWith(
                  color: _colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadTransactions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_transactionCards.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: _colorScheme.onSurfaceVariant,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'home.no_transactions_this_month'.tr(),
                style: _textTheme.bodyMedium?.copyWith(
                  color: _colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to add transaction page
                },
                child: Text('transactions.add_transaction'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    // Extract transactions and categories from TransactionCardData
    final List<Transaction> transactions =
        _transactionCards.map((e) => e.transaction).toList();
    final Map<int, Category> categories = {
      for (final card in _transactionCards)
        if (card.category != null) card.category!.id!: card.category!
    };

    return SliverMainAxisGroup(
      slivers: [
        TransactionList(
          transactions: transactions,
          categories: categories,
          selectedMonth: DateTime.now(),
          contentPadding: horizontalPadding,
        ),
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                final navBloc = context.read<NavigationBloc>();
                final navState = navBloc.state;
                final index = navState.navigationItems.indexWhere(
                  (item) => item.routePath == AppRoutes.transactions,
                );

                if (index != -1) {
                  navBloc.add(NavigationEvent.navigationIndexChanged(index));
                  context.go(AppRoutes.transactions);
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text('home.view_all_transactions'.tr()),
            ),
          ),
        ),
      ],
    );
  }
}
