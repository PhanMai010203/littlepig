import 'dart:io';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import '../settings/app_settings.dart';
import '../../features/transactions/domain/entities/transaction.dart';
import '../../features/accounts/domain/entities/account.dart';
import '../../features/categories/domain/entities/category.dart';
import '../../features/budgets/domain/entities/budget.dart';

@lazySingleton
class CsvExportService {
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Export app settings to CSV
  Future<void> exportSettingsToCSV() async {
    final settings = AppSettings.getAll();
    final exportData = _prepareSettingsForExport(settings);
    
    final csvData = [
      // Header row
      [
        'Category',
        'Setting Key',
        'Setting Value',
        'Data Type',
        'Export Date',
        'App Version',
      ],
      // Data rows
      ...exportData.map((setting) => [
        setting['category'],
        setting['key'],
        setting['value'],
        setting['type'],
        _dateFormatter.format(DateTime.now()),
        AppSettings.getWithDefault('lastVersion', '1.0.0'),
      ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    await _saveAndShareFile(csvString, 'app_settings.csv', 'App Settings Export');
  }

  /// Export all app data to CSV (comprehensive export)
  Future<void> exportAllDataToCSV({
    List<Transaction>? transactions,
    List<Account>? accounts,
    List<Category>? categories,
    List<Budget>? budgets,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final exportDir = Directory('${directory.path}/finance_export_$timestamp');
    await exportDir.create();

    final files = <XFile>[];

    // Export settings
    final settings = AppSettings.getAll();
    final settingsData = _prepareSettingsForExport(settings);
    final settingsCsv = _generateCsvFromData([
      ['Category', 'Setting Key', 'Setting Value', 'Data Type', 'Export Date', 'App Version'],
      ...settingsData.map((s) => [
        s['category'], s['key'], s['value'], s['type'],
        _dateFormatter.format(DateTime.now()),
        AppSettings.getWithDefault('lastVersion', '1.0.0'),
      ]),
    ]);
    final settingsFile = File('${exportDir.path}/settings.csv');
    await settingsFile.writeAsString(settingsCsv);
    files.add(XFile(settingsFile.path));

    // Export transactions if provided
    if (transactions != null && transactions.isNotEmpty) {
      final transactionsCsv = _generateTransactionsCsv(transactions);
      final transactionsFile = File('${exportDir.path}/transactions.csv');
      await transactionsFile.writeAsString(transactionsCsv);
      files.add(XFile(transactionsFile.path));
    }

    // Export accounts if provided
    if (accounts != null && accounts.isNotEmpty) {
      final accountsCsv = _generateAccountsCsv(accounts);
      final accountsFile = File('${exportDir.path}/accounts.csv');
      await accountsFile.writeAsString(accountsCsv);
      files.add(XFile(accountsFile.path));
    }

    // Export categories if provided
    if (categories != null && categories.isNotEmpty) {
      final categoriesCsv = _generateCategoriesCsv(categories);
      final categoriesFile = File('${exportDir.path}/categories.csv');
      await categoriesFile.writeAsString(categoriesCsv);
      files.add(XFile(categoriesFile.path));
    }

    // Export budgets if provided
    if (budgets != null && budgets.isNotEmpty) {
      final budgetsCsv = _generateBudgetsCsv(budgets);
      final budgetsFile = File('${exportDir.path}/budgets.csv');
      await budgetsFile.writeAsString(budgetsCsv);
      files.add(XFile(budgetsFile.path));
    }

    // Share all files
    await Share.shareXFiles(files, text: 'Finance App Data Export');
  }

  /// Export transactions to CSV
  Future<void> exportTransactionsToCSV(List<Transaction> transactions) async {
    final csvString = _generateTransactionsCsv(transactions);
    await _saveAndShareFile(csvString, 'transactions.csv', 'Transactions Export');
  }

  /// Export accounts to CSV
  Future<void> exportAccountsToCSV(List<Account> accounts) async {
    final csvString = _generateAccountsCsv(accounts);
    await _saveAndShareFile(csvString, 'accounts.csv', 'Accounts Export');
  }

  /// Export categories to CSV
  Future<void> exportCategoriesToCSV(List<Category> categories) async {
    final csvString = _generateCategoriesCsv(categories);
    await _saveAndShareFile(csvString, 'categories.csv', 'Categories Export');
  }

  /// Export budgets to CSV
  Future<void> exportBudgetsToCSV(List<Budget> budgets) async {
    final csvString = _generateBudgetsCsv(budgets);
    await _saveAndShareFile(csvString, 'budgets.csv', 'Budgets Export');
  }

  /// Prepare settings for export, filtering sensitive data
  List<Map<String, dynamic>> _prepareSettingsForExport(Map<String, dynamic> settings) {
    final exportData = <Map<String, dynamic>>[];
    
    // Define sensitive keys that should not be exported
    const sensitiveKeys = {
      'geminiApiKey',
      'firstLaunch',
      'lastVersion', // Device-specific
    };

    // Define categories for better organization
    const categories = {
      'themeMode': 'Theme',
      'materialYou': 'Theme',
      'useSystemAccent': 'Theme',
      'accentColor': 'Theme',
      'font': 'Text',
      'fontSize': 'Text',
      'increaseTextContrast': 'Text',
      'locale': 'Language',
      'reduceAnimations': 'Animation',
      'animationLevel': 'Animation',
      'batterySaver': 'Performance',
      'outlinedIcons': 'Display',
      'appAnimations': 'Animation',
      'hapticFeedback': 'Feedback',
      'highContrast': 'Accessibility',
      'aiEnabled': 'AI',
      'aiModel': 'AI',
      'aiTemperature': 'AI',
      'aiMaxTokens': 'AI',
      'voiceLanguage': 'Voice',
      'voiceSpeechRate': 'Voice',
      'voicePitch': 'Voice',
      'voiceVolume': 'Voice',
      'voiceEnableHapticFeedback': 'Voice',
      'voiceEnablePartialResults': 'Voice',
    };

    for (final entry in settings.entries) {
      if (sensitiveKeys.contains(entry.key)) continue;

      exportData.add({
        'category': categories[entry.key] ?? 'General',
        'key': entry.key,
        'value': entry.value.toString(),
        'type': entry.value.runtimeType.toString(),
      });
    }

    return exportData;
  }

  /// Generate CSV string from data
  String _generateCsvFromData(List<List<dynamic>> data) {
    return const ListToCsvConverter().convert(data);
  }

  /// Generate transactions CSV
  String _generateTransactionsCsv(List<Transaction> transactions) {
    final csvData = [
      [
        'ID',
        'Title',
        'Note',
        'Amount',
        'Date',
        'Category ID',
        'Account ID',
        'Transaction Type',
        'Special Type',
        'Recurrence',
        'Period Length',
        'End Date',
        'Transaction State',
        'Paid',
        'Skip Paid',
        'Created At',
        'Updated At',
        'Sync ID',
      ],
      ...transactions.map((t) => [
        t.id?.toString() ?? '',
        t.title,
        t.note ?? '',
        t.amount.toString(),
        _dateFormatter.format(t.date),
        t.categoryId.toString(),
        t.accountId.toString(),
        t.transactionType.toString(),
        t.specialType?.toString() ?? '',
        t.recurrence.toString(),
        t.periodLength?.toString() ?? '',
        t.endDate != null ? _dateFormatter.format(t.endDate!) : '',
        t.transactionState.toString(),
        t.paid.toString(),
        t.skipPaid.toString(),
        _dateFormatter.format(t.createdAt),
        _dateFormatter.format(t.updatedAt),
        t.syncId,
      ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  /// Generate accounts CSV
  String _generateAccountsCsv(List<Account> accounts) {
    final csvData = [
      [
        'ID',
        'Name',
        'Balance',
        'Currency',
        'Is Default',
        'Color',
        'Created At',
        'Updated At',
        'Sync ID',
      ],
      ...accounts.map((a) => [
        a.id?.toString() ?? '',
        a.name,
        a.balance.toString(),
        a.currency,
        a.isDefault.toString(),
        '0x${a.color.toARGB32().toRadixString(16)}',
        _dateFormatter.format(a.createdAt),
        _dateFormatter.format(a.updatedAt),
        a.syncId,
      ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  /// Generate categories CSV
  String _generateCategoriesCsv(List<Category> categories) {
    final csvData = [
      [
        'ID',
        'Name',
        'Icon',
        'Color',
        'Is Expense',
        'Is Default',
        'Created At',
        'Updated At',
        'Sync ID',
      ],
      ...categories.map((c) => [
        c.id?.toString() ?? '',
        c.name,
        c.icon,
        '0x${c.color.toARGB32().toRadixString(16)}',
        c.isExpense.toString(),
        c.isDefault.toString(),
        _dateFormatter.format(c.createdAt),
        _dateFormatter.format(c.updatedAt),
        c.syncId,
      ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  /// Generate budgets CSV
  String _generateBudgetsCsv(List<Budget> budgets) {
    final csvData = [
      [
        'ID',
        'Name',
        'Amount',
        'Spent',
        'Remaining',
        'Period',
        'Start Date',
        'End Date',
        'Category ID',
        'Exclude Debt/Credit',
        'Exclude Objectives',
        'Currency Normalization',
        'Is Income Budget',
        'Is Active',
        'Created At',
        'Updated At',
        'Sync ID',
      ],
      ...budgets.map((b) => [
        b.id?.toString() ?? '',
        b.name,
        b.amount.toString(),
        b.spent.toString(),
        (b.amount - b.spent).toString(),
        b.period.toString(),
        _dateFormatter.format(b.startDate),
        _dateFormatter.format(b.endDate),
        b.categoryId?.toString() ?? '',
        b.excludeDebtCreditInstallments.toString(),
        b.excludeObjectiveInstallments.toString(),
        b.normalizeToCurrency ?? '',
        b.isIncomeBudget.toString(),
        b.isActive.toString(),
        _dateFormatter.format(b.createdAt),
        _dateFormatter.format(b.updatedAt),
        b.syncId,
      ]),
    ];

    return const ListToCsvConverter().convert(csvData);
  }

  /// Save file and share it
  Future<void> _saveAndShareFile(String content, String fileName, String shareText) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);

    await Share.shareXFiles([XFile(file.path)], text: shareText);
  }
}