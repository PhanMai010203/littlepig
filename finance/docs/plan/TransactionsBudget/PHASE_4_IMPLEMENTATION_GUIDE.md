# Phase 4 Implementation Guide: UI Integration & Enhanced Features

## Overview

Phase 4 focuses on creating intuitive user interfaces for the advanced budget features and implementing enhanced capabilities like shared budgets and multi-currency support. This phase brings all the backend functionality from Phases 2 and 3 to the user through polished, responsive UI components.

**Duration**: 4-5 days  
**Priority**: MEDIUM-HIGH  
**Dependencies**: Phase 3 (Real-Time Budget Updates) must be completed  

---

## 🔥 Quick Start - UI Enhancement Packages

### Additional Flutter Packages for Phase 4

Add these to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  # Enhanced charts and visualizations
  fl_chart: ^0.68.0
  
  # Better animations and transitions
  animations: ^2.0.11
  
  # Advanced UI components
  flutter_staggered_grid_view: ^0.7.0
  
  # Icon enhancements
  phosphor_flutter: ^2.1.0
  
  # Better form handling
  reactive_forms: ^17.0.1
```

---

## Phase 4.1: Advanced Budget Configuration Widgets (2 days)

### 4.1.1 Budget Filter Configuration Widget

**File**: `lib/features/budgets/presentation/widgets/budget_filter_config_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_enums.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';

class BudgetFilterConfigWidget extends StatefulWidget {
  final Budget budget;
  final Function(Budget) onBudgetUpdated;
  
  const BudgetFilterConfigWidget({
    Key? key,
    required this.budget,
    required this.onBudgetUpdated,
  }) : super(key: key);

  @override
  State<BudgetFilterConfigWidget> createState() => _BudgetFilterConfigWidgetState();
}

class _BudgetFilterConfigWidgetState extends State<BudgetFilterConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(PhosphorIcons.sliders()),
        title: Text('Advanced Budget Settings'),
        subtitle: Text('Configure filtering and security options'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildFilterSection(),
                const Divider(height: 32),
                _buildWalletSection(),
                const Divider(height: 32),
                _buildCurrencySection(),
                const Divider(height: 32),
                _buildSecuritySection(),
                const Divider(height: 32),
                _buildExportSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Filters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        // Debt/Credit exclusion toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(PhosphorIcons.prohibit()),
          title: Text('Exclude Debt/Credit Transactions'),
          subtitle: Text('Don\'t count borrowed/lent money towards budget'),
          value: widget.budget.excludeDebtCreditInstallments,
          onChanged: (value) => _updateBudgetFilter(
            widget.budget.copyWith(excludeDebtCreditInstallments: value)
          ),
        ),
        
        // Objective exclusion toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(PhosphorIcons.target()),
          title: Text('Exclude Objective Installments'),
          subtitle: Text('Don\'t count objective payments towards budget'),
          value: widget.budget.excludeObjectiveInstallments,
          onChanged: (value) => _updateBudgetFilter(
            widget.budget.copyWith(excludeObjectiveInstallments: value)
          ),
        ),
        
        // Transfer inclusion toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(PhosphorIcons.arrowsLeftRight()),
          title: Text('Include Same-Currency Transfers'),
          subtitle: Text('Include transfers between accounts with same currency'),
          value: widget.budget.includeTransferInOutWithSameCurrency,
          onChanged: (value) => _updateBudgetFilter(
            widget.budget.copyWith(includeTransferInOutWithSameCurrency: value)
          ),
        ),
      ],
    );
  }

  Widget _buildWalletSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet Selection',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(PhosphorIcons.wallet()),
          title: Text('Include Specific Wallets'),
          subtitle: Text(
            widget.budget.walletFks?.isEmpty ?? true 
              ? 'All wallets included' 
              : '${widget.budget.walletFks!.length} wallets selected'
          ),
          trailing: Icon(PhosphorIcons.caretRight()),
          onTap: () => _showWalletSelectionDialog(),
        ),
      ],
    );
  }

  Widget _buildCurrencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency Settings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(PhosphorIcons.currencyDollar()),
          title: Text('Currency Normalization'),
          subtitle: Text(
            widget.budget.normalizeToCurrency ?? 'No normalization'
          ),
          trailing: Icon(PhosphorIcons.caretRight()),
          onTap: () => _showCurrencySelectionDialog(),
        ),
        
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(PhosphorIcons.trendUp()),
          title: Text('Income Budget'),
          subtitle: Text('Track income instead of expenses'),
          value: widget.budget.isIncomeBudget,
          onChanged: (value) => _updateBudgetFilter(
            widget.budget.copyWith(isIncomeBudget: value)
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security & Privacy',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(PhosphorIcons.fingerprint()),
          title: Text('Biometric Protection'),
          subtitle: Text('Require fingerprint/face ID to view budget details'),
          value: widget.budget.budgetTransactionFilters?['requireAuth'] ?? false,
          onChanged: (value) => _updateAuthRequirement(value),
        ),
      ],
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Export',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportBudgetData(),
                icon: Icon(PhosphorIcons.export()),
                label: Text('Export CSV'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareBudgetData(),
                icon: Icon(PhosphorIcons.shareNetwork()),
                label: Text('Share Data'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateBudgetFilter(Budget updatedBudget) {
    widget.onBudgetUpdated(updatedBudget);
  }

  void _updateAuthRequirement(bool requireAuth) {
    final filters = Map<String, dynamic>.from(widget.budget.budgetTransactionFilters ?? {});
    filters['requireAuth'] = requireAuth;
    final updatedBudget = widget.budget.copyWith(budgetTransactionFilters: filters);
    widget.onBudgetUpdated(updatedBudget);
  }

  Future<void> _showWalletSelectionDialog() async {
    // Implementation for wallet selection dialog
    showDialog(
      context: context,
      builder: (context) => WalletSelectionDialog(
        selectedWallets: widget.budget.walletFks ?? [],
        onWalletsSelected: (selectedWallets) {
          final updatedBudget = widget.budget.copyWith(walletFks: selectedWallets);
          widget.onBudgetUpdated(updatedBudget);
        },
      ),
    );
  }

  Future<void> _showCurrencySelectionDialog() async {
    // Implementation for currency selection dialog
    showDialog(
      context: context,
      builder: (context) => CurrencySelectionDialog(
        selectedCurrency: widget.budget.normalizeToCurrency,
        onCurrencySelected: (currency) {
          final updatedBudget = widget.budget.copyWith(normalizeToCurrency: currency);
          widget.onBudgetUpdated(updatedBudget);
        },
      ),
    );
  }

  Future<void> _exportBudgetData() async {
    context.read<BudgetsBloc>().add(ExportBudgetData(widget.budget));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(PhosphorIcons.export(), color: Colors.white),
            SizedBox(width: 8),
            Text('Exporting budget data...'),
          ],
        ),
      ),
    );
  }

  Future<void> _shareBudgetData() async {
    // Implementation for sharing budget data
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(PhosphorIcons.shareNetwork(), color: Colors.white),
            SizedBox(width: 8),
            Text('Preparing data for sharing...'),
          ],
        ),
      ),
    );
  }
}
```

### 4.1.2 Wallet Selection Dialog

**File**: `lib/features/budgets/presentation/widgets/wallet_selection_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WalletSelectionDialog extends StatefulWidget {
  final List<String> selectedWallets;
  final Function(List<String>) onWalletsSelected;

  const WalletSelectionDialog({
    Key? key,
    required this.selectedWallets,
    required this.onWalletsSelected,
  }) : super(key: key);

  @override
  State<WalletSelectionDialog> createState() => _WalletSelectionDialogState();
}

class _WalletSelectionDialogState extends State<WalletSelectionDialog> {
  late List<String> _selectedWallets;
  
  // Mock wallet data - replace with actual wallet repository
  final List<Map<String, dynamic>> _availableWallets = [
    {'id': '1', 'name': 'Main Checking', 'currency': 'USD', 'icon': PhosphorIcons.bank()},
    {'id': '2', 'name': 'Savings Account', 'currency': 'USD', 'icon': PhosphorIcons.piggyBank()},
    {'id': '3', 'name': 'Credit Card', 'currency': 'USD', 'icon': PhosphorIcons.creditCard()},
    {'id': '4', 'name': 'Cash Wallet', 'currency': 'USD', 'icon': PhosphorIcons.wallet()},
    {'id': '5', 'name': 'Investment Account', 'currency': 'USD', 'icon': PhosphorIcons.trendUp()},
  ];

  @override
  void initState() {
    super.initState();
    _selectedWallets = List.from(widget.selectedWallets);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(PhosphorIcons.wallet()),
          SizedBox(width: 8),
          Text('Select Wallets'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Select All / Deselect All buttons
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedWallets = _availableWallets.map((w) => w['id'] as String).toList();
                    });
                  },
                  icon: Icon(PhosphorIcons.checkCircle()),
                  label: Text('Select All'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedWallets.clear();
                    });
                  },
                  icon: Icon(PhosphorIcons.circle()),
                  label: Text('Clear All'),
                ),
              ],
            ),
            Divider(),
            
            // Wallet list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableWallets.length,
                itemBuilder: (context, index) {
                  final wallet = _availableWallets[index];
                  final isSelected = _selectedWallets.contains(wallet['id']);
                  
                  return CheckboxListTile(
                    secondary: Icon(wallet['icon']),
                    title: Text(wallet['name']),
                    subtitle: Text('Currency: ${wallet['currency']}'),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedWallets.add(wallet['id']);
                        } else {
                          _selectedWallets.remove(wallet['id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onWalletsSelected(_selectedWallets);
            Navigator.of(context).pop();
          },
          child: Text('Apply (${_selectedWallets.length})'),
        ),
      ],
    );
  }
}
```

### 4.1.3 Currency Selection Dialog

**File**: `lib/features/budgets/presentation/widgets/currency_selection_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CurrencySelectionDialog extends StatefulWidget {
  final String? selectedCurrency;
  final Function(String?) onCurrencySelected;

  const CurrencySelectionDialog({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  }) : super(key: key);

  @override
  State<CurrencySelectionDialog> createState() => _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState extends State<CurrencySelectionDialog> {
  String? _selectedCurrency;
  String _searchText = '';
  
  // Mock currency data - replace with actual currency service
  final List<Map<String, String>> _availableCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'CAD', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'CHF', 'name': 'Swiss Franc', 'symbol': 'CHF'},
    {'code': 'CNY', 'name': 'Chinese Yuan', 'symbol': '¥'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.selectedCurrency;
  }

  List<Map<String, String>> get _filteredCurrencies {
    if (_searchText.isEmpty) {
      return _availableCurrencies;
    }
    return _availableCurrencies.where((currency) {
      return currency['code']!.toLowerCase().contains(_searchText.toLowerCase()) ||
             currency['name']!.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(PhosphorIcons.currencyDollar()),
          SizedBox(width: 8),
          Text('Select Currency'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                hintText: 'Search currencies...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            SizedBox(height: 16),
            
            // None option
            RadioListTile<String?>(
              title: Text('No Normalization'),
              subtitle: Text('Use original transaction currencies'),
              value: null,
              groupValue: _selectedCurrency,
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value;
                });
              },
            ),
            Divider(),
            
            // Currency list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = _filteredCurrencies[index];
                  
                  return RadioListTile<String>(
                    title: Text('${currency['code']} - ${currency['name']}'),
                    subtitle: Text('Symbol: ${currency['symbol']}'),
                    value: currency['code']!,
                    groupValue: _selectedCurrency,
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onCurrencySelected(_selectedCurrency);
            Navigator.of(context).pop();
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}
```

---

## Phase 4.2: Real-Time Budget Progress Widgets (2 days)

### 4.2.1 Enhanced Budget Card Widget

**File**: `lib/features/budgets/presentation/widgets/real_time_budget_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../domain/entities/budget.dart';
import '../bloc/budgets_bloc.dart';
import '../bloc/budgets_event.dart';
import '../bloc/budgets_state.dart';

class RealTimeBudgetCard extends StatelessWidget {
  final Budget budget;
  final bool isRealTimeActive;

  const RealTimeBudgetCard({
    Key? key,
    required this.budget,
    this.isRealTimeActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetsBloc, BudgetsState>(
      builder: (context, state) {
        double currentSpent = budget.spent;
        bool isAuthenticated = false;
        
        if (state is BudgetsLoaded) {
          // Use real-time spent amount if available
          currentSpent = state.realTimeSpentAmounts[budget.id] ?? budget.spent;
          isAuthenticated = state.authenticatedBudgets[budget.id] ?? false;
        }
        
        final progress = currentSpent / budget.amount;
        final isOverBudget = progress > 1.0;
        final remaining = budget.amount - currentSpent;
        
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () => _showBudgetDetails(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isAuthenticated),
                  SizedBox(height: 12),
                  _buildProgressSection(context, progress, isOverBudget),
                  SizedBox(height: 12),
                  _buildAmountDetails(context, currentSpent, remaining, isOverBudget),
                  SizedBox(height: 8),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isAuthenticated) {
    final requiresAuth = budget.budgetTransactionFilters?['requireAuth'] ?? false;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                budget.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (budget.categoryId != null)
                Text(
                  'Category Budget',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        
        // Real-time indicator
        if (isRealTimeActive)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Live',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        SizedBox(width: 8),
        
        // Security indicator
        if (requiresAuth)
          GestureDetector(
            onTap: () => _authenticateAndShowDetails(context),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isAuthenticated ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAuthenticated ? PhosphorIcons.shieldCheck() : PhosphorIcons.fingerprint(),
                size: 16,
                color: isAuthenticated ? Colors.green : Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress, bool isOverBudget) {
    return Column(
      children: [
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : _getProgressColor(progress),
              ),
            ),
          ),
        ),
        
        SizedBox(height: 8),
        
        // Progress percentage
        Row(
          children: [
            Text(
              '${(progress * 100).toStringAsFixed(1)}% used',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isOverBudget ? Colors.red : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            if (isOverBudget)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OVER BUDGET',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountDetails(BuildContext context, double currentSpent, double remaining, bool isOverBudget) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spent',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${currentSpent.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Budget',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${budget.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isOverBudget ? 'Over by' : 'Remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '\$${remaining.abs().toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _exportBudgetData(context),
            icon: Icon(PhosphorIcons.export(), size: 16),
            label: Text('Export', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showBudgetChart(context),
            icon: Icon(PhosphorIcons.chartLine(), size: 16),
            label: Text('Chart', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _showBudgetDetails(context),
            icon: Icon(PhosphorIcons.gear(), size: 16),
            label: Text('Settings', style: TextStyle(fontSize: 12)),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return Colors.green;
    if (progress < 0.8) return Colors.orange;
    return Colors.red;
  }

  void _showBudgetDetails(BuildContext context) {
    showModal(
      context: context,
      builder: (context) => BudgetDetailsModal(budget: budget),
    );
  }

  void _authenticateAndShowDetails(BuildContext context) {
    context.read<BudgetsBloc>().add(AuthenticateForBudgetAccess(budget.id!));
  }

  void _exportBudgetData(BuildContext context) {
    context.read<BudgetsBloc>().add(ExportBudgetData(budget));
  }

  void _showBudgetChart(BuildContext context) {
    showModal(
      context: context,
      builder: (context) => BudgetChartModal(budget: budget),
    );
  }
}
```

### 4.2.2 Budget Chart Modal

**File**: `lib/features/budgets/presentation/widgets/budget_chart_modal.dart`

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../domain/entities/budget.dart';

class BudgetChartModal extends StatelessWidget {
  final Budget budget;

  const BudgetChartModal({
    Key? key,
    required this.budget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(PhosphorIcons.chartPie()),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${budget.name} Analysis',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(PhosphorIcons.x()),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Pie Chart
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(),
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Legend
            _buildLegend(context),
            
            SizedBox(height: 24),
            
            // Stats
            _buildStats(context),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final spent = budget.spent;
    final remaining = budget.amount - spent;
    final isOverBudget = spent > budget.amount;
    
    if (isOverBudget) {
      // Show over-budget scenario
      return [
        PieChartSectionData(
          value: budget.amount,
          color: Colors.red,
          title: 'Budget',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          value: spent - budget.amount,
          color: Colors.red[300]!,
          title: 'Over',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    } else {
      // Normal scenario
      return [
        PieChartSectionData(
          value: spent,
          color: Colors.blue,
          title: 'Spent',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          value: remaining,
          color: Colors.green,
          title: 'Remaining',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }
  }

  Widget _buildLegend(BuildContext context) {
    final spent = budget.spent;
    final remaining = budget.amount - spent;
    final isOverBudget = spent > budget.amount;
    
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isOverBudget ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 8),
            Text(isOverBudget ? 'Budget Amount' : 'Spent'),
            Spacer(),
            Text('\$${isOverBudget ? budget.amount.toStringAsFixed(2) : spent.toStringAsFixed(2)}'),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isOverBudget ? Colors.red[300] : Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(width: 8),
            Text(isOverBudget ? 'Over Budget' : 'Remaining'),
            Spacer(),
            Text('\$${isOverBudget ? (spent - budget.amount).toStringAsFixed(2) : remaining.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
    final progress = budget.spent / budget.amount;
    final isOverBudget = progress > 1.0;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress:'),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOverBudget ? Colors.red : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Period:'),
              Text('${budget.startDate.day}/${budget.startDate.month} - ${budget.endDate.day}/${budget.endDate.month}'),
            ],
          ),
          if (budget.normalizeToCurrency != null) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Currency:'),
                Text(budget.normalizeToCurrency!),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## Testing Phase 4

### 4.1 Widget Tests

**File**: `test/features/budgets/widgets/budget_card_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Real-Time Budget Card Tests', () {
    testWidgets('displays budget information correctly', (tester) async {
      // Test budget card display logic
    });
    
    testWidgets('shows real-time indicator when active', (tester) async {
      // Test real-time indicator
    });
    
    testWidgets('handles authentication flow', (tester) async {
      // Test authentication features
    });
    
    testWidgets('exports budget data on button press', (tester) async {
      // Test export functionality
    });
  });
}
```

### 4.2 Integration Tests

**File**: `test/integration/budget_ui_integration_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Budget UI Integration Tests', () {
    testWidgets('complete budget configuration flow', (tester) async {
      // Test complete UI workflow:
      // 1. Create budget
      // 2. Configure filters
      // 3. Enable authentication
      // 4. Export data
      // 5. View charts
    });
  });
}
```

---

## Success Criteria for Phase 4

### Phase 4.1 Complete When:
- [ ] Budget filter configuration widget functional
- [ ] Wallet and currency selection dialogs working
- [ ] Security features implemented
- [ ] Export functionality operational

### Phase 4.2 Complete When:
- [ ] Real-time budget cards display correctly
- [ ] Chart visualization working
- [ ] Authentication UI flows complete
- [ ] All widget tests passing

---

## Next Steps

Upon completion of Phase 4, proceed to:
- **Phase 5**: Testing & Documentation

This phase brings all the advanced budget features to life through intuitive, responsive user interfaces that provide real-time feedback and powerful configuration options.
