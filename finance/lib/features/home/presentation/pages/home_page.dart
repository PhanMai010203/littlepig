import 'package:flutter/material.dart';
import 'package:finance/shared/widgets/page_template.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/shared/extensions/account_currency_extension.dart';
import '../../widgets/account_card.dart';
// Phase 5 imports
import '../../../../shared/utils/responsive_layout_builder.dart';
import '../../../../shared/utils/performance_optimization.dart';
import '../../../../core/services/platform_service.dart';

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

  const HomePage({
    super.key,
    required this.accountRepository,
    required this.transactionRepository,
    required this.currencyRepository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  
  // Phase 5: Cache theme data and platform info for performance (Phase 1 pattern)
  late ColorScheme _colorScheme;
  late TextTheme _textTheme;
  late bool _isIOS;
  
  int _selectedAccountIndex = 0;
  List<AccountTileData> _accountTiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Phase 5: Cache platform detection (Phase 3 pattern)
    final platform = PlatformService.getPlatform();
    _isIOS = platform == PlatformOS.isIOS;
    
    // Phase 5: Platform-optimized animation controller (Phase 3 pattern)
    _animationController = AnimationController(
      vsync: this,
      duration: _isIOS 
        ? const Duration(milliseconds: 2000)
        : const Duration(milliseconds: 1800),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      double percent = _scrollController.offset / 200;
      if (percent <= 1) {
        double offset = _scrollController.offset;
        if (percent >= 1) offset = 0;
        _animationController.value = 1 - offset / 200;
      }
    });

    _loadAccounts();
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
    _animationController.dispose();
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
        final transactions =
            await widget.transactionRepository.getTransactionsByAccount(account.id!);
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

      setState(() {
        _accountTiles = tiles;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load accounts: ${e.toString()}';
      });

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

  /// Single handler for account selection
  void _onSelectAccount(int index) {
    setState(() {
      _selectedAccountIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Phase 5: Track component optimization
    PerformanceOptimizations.trackRenderingOptimization(
      'HomePage', 
      'ResponsiveLayoutBuilder+ThemeCaching+PlatformOptimization'
    );

    // Phase 5: Use ResponsiveLayoutBuilder for size-dependent layout (Phase 2 pattern)
    return ResponsiveLayoutBuilder(
      debugLabel: 'HomePage',
      builder: (context, constraints, layoutData) {
        return PageTemplate(
          slivers: _buildOptimizedSlivers(layoutData),
        );
      },
    );
  }

  /// Phase 5: Build optimized slivers with layout data
  List<Widget> _buildOptimizedSlivers(ResponsiveLayoutData layoutData) {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: layoutData.isCompact ? 16 : 26),
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
              const SizedBox(height: 24),
              SizedBox(
                height: layoutData.isCompact ? 110 : 125,
                child: _buildAccountsSection(),
              ),
            ],
          ),
        ),
      ),
    ];
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          // Account cards from data
          ..._accountTiles.asMap().entries.map((entry) {
            final index = entry.key;
            final tileData = entry.value;

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: AccountCard(
                title: tileData.account.name,
                amount: tileData.formattedBalance,
                transactions: '${tileData.transactionCount} transactions',
                color: tileData.account.color,
                isSelected: _selectedAccountIndex == index,
                index: index,
                onSelected: _onSelectAccount,
              ),
            );
          }),
          // AddAccountCard at the end
          AddAccountCard(
            onTap: () {
              // TODO: Navigate to add account page
            },
          ),
        ],
      ),
    );
  }
}


