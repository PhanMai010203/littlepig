import 'package:flutter/material.dart';
import 'package:finance/shared/widgets/page_template.dart';
import 'package:finance/core/di/injection.dart';
import 'package:finance/features/accounts/domain/repositories/account_repository.dart';
import 'package:finance/features/accounts/domain/entities/account.dart';
import 'package:finance/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance/features/currencies/domain/repositories/currency_repository.dart';
import 'package:finance/shared/extensions/account_currency_extension.dart';
import '../../widgets/account_card.dart';

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
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  int _selectedAccountIndex = 0;
  
  List<AccountTileData> _accountTiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads accounts and assembles AccountTileData
  Future<void> _loadAccounts() async {
    try {
      final accountRepository = getIt<AccountRepository>();
      final transactionRepository = getIt<TransactionRepository>();
      final currencyRepository = getIt<CurrencyRepository>();

      // 1. Retrieve all accounts
      final accounts = await accountRepository.getAllAccounts();
      
      // 2. For each account, get transaction count and formatted balance
      final List<AccountTileData> tiles = [];
      
      for (final account in accounts) {
        // Get transaction count for this account
        final transactions = await transactionRepository.getTransactionsByAccount(account.id!);
        final transactionCount = transactions.length;
        
        // Format balance using AccountCurrencyExtension
        final formattedBalance = await account.formatBalance(
          currencyRepository,
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
    return PageTemplate(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 100),
                  child: Container(
                    alignment: AlignmentDirectional.bottomStart,
                    padding:
                        const EdgeInsetsDirectional.only(start: 9, bottom: 17, end: 9),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 125,
                  child: _buildAccountsSection(),
                ),
              ],
            ),
          ),
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
              color: Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load accounts',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
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
    
    if (_accountTiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AddAccountCard(
              onTap: () {
                // TODO: Navigate to add account page
              },
            ),
            const SizedBox(height: 8),
            Text(
              'No accounts yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
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
              padding: EdgeInsets.only(right: index < _accountTiles.length - 1 ? 16 : 0),
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
          // Add spacing and AddAccountCard at the end
          if (_accountTiles.isNotEmpty) ...[
            const SizedBox(width: 16),
            AddAccountCard(
              onTap: () {
                // TODO: Navigate to add account page
              },
            ),
          ],
        ],
      ),
    );
  }
}