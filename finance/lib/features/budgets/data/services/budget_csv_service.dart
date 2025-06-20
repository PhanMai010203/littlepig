import 'dart:io';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/budget.dart';

class BudgetCsvService {
  Future<void> exportBudgetToCSV(Budget budget, String fileName) async {
    final csvData = [
      // Header row
      [
        'Budget Name',
        'Amount',
        'Spent',
        'Remaining',
        'Start Date',
        'End Date',
        'Category ID',
        'Exclude Debt/Credit',
        'Exclude Objectives',
        'Currency Normalization',
        'Is Income Budget',
        'Sync ID',
      ],
      // Data row
      [
        budget.name,
        budget.amount.toString(),
        budget.spent.toString(),
        (budget.amount - budget.spent).toString(),
        budget.startDate.toIso8601String(),
        budget.endDate.toIso8601String(),
        budget.categoryId?.toString() ?? '',
        budget.excludeDebtCreditInstallments.toString(),
        budget.excludeObjectiveInstallments.toString(),
        budget.normalizeToCurrency ?? '',
        budget.isIncomeBudget.toString(),
        budget.syncId,
      ],
    ];

    final csvString = const ListToCsvConverter().convert(csvData);

    // Get temporary directory for file storage
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/${fileName.isEmpty ? 'budget_export.csv' : fileName}');
    await file.writeAsString(csvString);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Budget Export');
  }

  Future<void> exportBudgetsToCSV(List<Budget> budgets) async {
    final csvData = [
      // Header row
      [
        'Budget Name',
        'Amount',
        'Spent',
        'Remaining',
        'Start Date',
        'End Date',
        'Category ID',
        'Exclude Debt/Credit',
        'Exclude Objectives',
        'Currency Normalization',
        'Is Income Budget',
        'Sync ID',
      ],
    ];

    // Add data rows
    for (final budget in budgets) {
      csvData.add([
        budget.name,
        budget.amount.toString(),
        budget.spent.toString(),
        (budget.amount - budget.spent).toString(),
        budget.startDate.toIso8601String(),
        budget.endDate.toIso8601String(),
        budget.categoryId?.toString() ?? '',
        budget.excludeDebtCreditInstallments.toString(),
        budget.excludeObjectiveInstallments.toString(),
        budget.normalizeToCurrency ?? '',
        budget.isIncomeBudget.toString(),
        budget.syncId,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(csvData);

    // Get temporary directory for file storage
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/budgets_export.csv');
    await file.writeAsString(csvString);

    // Share the file
    await Share.shareXFiles([XFile(file.path)], text: 'Budgets Export');
  }

  Future<List<Budget>> importBudgetsFromCSV(String filePath) async {
    try {
      // Read file with UTF-8 encoding
      final file = File(filePath);
      final csvString = await file.readAsString();

      // Parse CSV
      final csvData = const CsvToListConverter().convert(csvString);

      // Skip header row and convert to budgets
      final budgets = <Budget>[];
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length >= 11) {
          budgets.add(_convertRowToBudget(row));
        }
      }

      return budgets;
    } catch (e) {
      throw Exception('Failed to import budgets from CSV: $e');
    }
  }

  Budget _convertRowToBudget(List<dynamic> row) {
    return Budget(
      name: row[0].toString(),
      amount: double.tryParse(row[1].toString()) ?? 0.0,
      spent: double.tryParse(row[2].toString()) ?? 0.0,
      startDate: DateTime.tryParse(row[4].toString()) ?? DateTime.now(),
      endDate: DateTime.tryParse(row[5].toString()) ??
          DateTime.now().add(const Duration(days: 30)),
      categoryId: int.tryParse(row[6].toString()),
      excludeDebtCreditInstallments: row[7].toString().toLowerCase() == 'true',
      excludeObjectiveInstallments: row[8].toString().toLowerCase() == 'true',
      normalizeToCurrency: row[9].toString().isEmpty ? null : row[9].toString(),
      isIncomeBudget: row[10].toString().toLowerCase() == 'true',

      // Required fields with defaults for import
      period: BudgetPeriod.monthly,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),

      // ✅ PHASE 4.4: Enhanced syncId handling for imports
      syncId: row.length > 11 && row[11].toString().isNotEmpty
          ? row[11].toString()
          : 'imported-budget-${DateTime.now().millisecondsSinceEpoch}-${row[0].toString().hashCode}',
    );
  }

  /// ✅ PHASE 4.4: Create budget with proper syncId for exports
  static Budget createBudgetForExport(Budget source) {
    return Budget(
      name: source.name,
      amount: source.amount,
      spent: source.spent,
      period: source.period,
      startDate: source.startDate,
      endDate: source.endDate,
      categoryId: source.categoryId,
      excludeDebtCreditInstallments: source.excludeDebtCreditInstallments,
      excludeObjectiveInstallments: source.excludeObjectiveInstallments,
      normalizeToCurrency: source.normalizeToCurrency,
      isIncomeBudget: source.isIncomeBudget,
      isActive: source.isActive,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,

      // ✅ PHASE 4.4: Ensure syncId is present for export tracking
      syncId: source.syncId.isNotEmpty
          ? source.syncId
          : 'export-budget-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
