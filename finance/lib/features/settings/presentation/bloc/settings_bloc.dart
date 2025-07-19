import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../budgets/domain/repositories/budget_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final CsvExportService _csvExportService;
  final BiometricAuthService _biometricAuthService;
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;

  SettingsBloc(
    this._csvExportService,
    this._biometricAuthService,
    this._transactionRepository,
    this._accountRepository,
    this._categoryRepository,
    this._budgetRepository,
  )
      : super(const SettingsState(
          themeMode: ThemeMode.system,
          analyticsEnabled: true,
          autoBackupEnabled: false,
          notificationsEnabled: true,
          hapticFeedbackEnabled: true,
          biometricEnabled: false,
          biometricAppLockEnabled: false,
        )) {
    on<_LoadSettings>(_onLoadSettings);
    on<_ThemeModeChanged>(_onThemeModeChanged);
    on<_AnalyticsToggled>(_onAnalyticsToggled);
    on<_AutoBackupToggled>(_onAutoBackupToggled);
    on<_NotificationsToggled>(_onNotificationsToggled);
    on<_HapticFeedbackToggled>(_onHapticFeedbackToggled);
    on<_BiometricToggled>(_onBiometricToggled);
    on<_BiometricAppLockToggled>(_onBiometricAppLockToggled);
    on<_ExportSettings>(_onExportSettings);
    on<_ExportAllData>(_onExportAllData);
    on<_ExportTransactions>(_onExportTransactions);
    on<_ExportAccounts>(_onExportAccounts);
    on<_ExportCategories>(_onExportCategories);
    on<_ExportBudgets>(_onExportBudgets);
  }

  void _onLoadSettings(
    _LoadSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsState(
      themeMode: AppSettings.themeMode,
      analyticsEnabled:
          AppSettings.getWithDefault<bool>('analyticsEnabled', true),
      autoBackupEnabled:
          AppSettings.getWithDefault<bool>('autoBackupEnabled', false),
      notificationsEnabled:
          AppSettings.getWithDefault<bool>('notificationsEnabled', true),
      hapticFeedbackEnabled: AppSettings.hapticFeedback,
      biometricEnabled: AppSettings.biometricEnabled,
      biometricAppLockEnabled: AppSettings.biometricAppLock,
    ));
  }

  void _onThemeModeChanged(
    _ThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
    AppSettings.setThemeMode(event.themeMode);
  }

  void _onAnalyticsToggled(
    _AnalyticsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(analyticsEnabled: event.enabled));
    AppSettings.set('analyticsEnabled', event.enabled);
  }

  void _onAutoBackupToggled(
    _AutoBackupToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(autoBackupEnabled: event.enabled));
    AppSettings.set('autoBackupEnabled', event.enabled);
  }

  void _onNotificationsToggled(
    _NotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(notificationsEnabled: event.enabled));
    AppSettings.set('notificationsEnabled', event.enabled);
  }

  void _onHapticFeedbackToggled(
    _HapticFeedbackToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(hapticFeedbackEnabled: event.enabled));
    AppSettings.setHapticFeedback(event.enabled);
  }

  Future<void> _onExportSettings(
    _ExportSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isExporting: true,
      exportStatus: 'Exporting settings...',
      exportError: null,
    ));

    try {
      await _csvExportService.exportSettingsToCSV();
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Settings exported successfully!',
        exportError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportStatus: null,
        exportError: 'Failed to export settings: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportAllData(
    _ExportAllData event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isExporting: true,
      exportStatus: 'Fetching all data...',
      exportError: null,
    ));

    try {
      // Fetch all data from repositories
      emit(state.copyWith(exportStatus: 'Fetching transactions...'));
      final transactions = await _transactionRepository.getAllTransactions();
      
      emit(state.copyWith(exportStatus: 'Fetching accounts...'));
      final accounts = await _accountRepository.getAllAccounts();
      
      emit(state.copyWith(exportStatus: 'Fetching categories...'));
      final categories = await _categoryRepository.getAllCategories();
      
      emit(state.copyWith(exportStatus: 'Fetching budgets...'));
      final budgets = await _budgetRepository.getAllBudgets();
      
      final totalRecords = transactions.length + accounts.length + categories.length + budgets.length;
      
      emit(state.copyWith(
        exportStatus: 'Exporting $totalRecords records...',
      ));
      
      await _csvExportService.exportAllDataToCSV(
        transactions: transactions,
        accounts: accounts,
        categories: categories,
        budgets: budgets,
      );
      
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Successfully exported all data! (${transactions.length} transactions, ${accounts.length} accounts, ${categories.length} categories, ${budgets.length} budgets)',
        exportError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportStatus: null,
        exportError: 'Failed to export all data: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportTransactions(
    _ExportTransactions event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isExporting: true,
      exportStatus: 'Fetching transactions...',
      exportError: null,
    ));

    try {
      final transactions = await _transactionRepository.getAllTransactions();
      
      emit(state.copyWith(
        exportStatus: 'Exporting ${transactions.length} transactions...',
      ));
      
      await _csvExportService.exportTransactionsToCSV(transactions);
      
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Successfully exported ${transactions.length} transactions!',
        exportError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportStatus: null,
        exportError: 'Failed to export transactions: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportAccounts(
    _ExportAccounts event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isExporting: true,
      exportStatus: 'Fetching accounts...',
      exportError: null,
    ));

    try {
      final accounts = await _accountRepository.getAllAccounts();
      
      emit(state.copyWith(
        exportStatus: 'Exporting ${accounts.length} accounts...',
      ));
      
      await _csvExportService.exportAccountsToCSV(accounts);
      
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Successfully exported ${accounts.length} accounts!',
        exportError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportStatus: null,
        exportError: 'Failed to export accounts: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportCategories(
    _ExportCategories event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isExporting: true,
      exportStatus: 'Fetching categories...',
      exportError: null,
    ));

    try {
      final categories = await _categoryRepository.getAllCategories();
      
      emit(state.copyWith(
        exportStatus: 'Exporting ${categories.length} categories...',
      ));
      
      await _csvExportService.exportCategoriesToCSV(categories);
      
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Successfully exported ${categories.length} categories!',
        exportError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportStatus: null,
        exportError: 'Failed to export categories: ${e.toString()}',
      ));
    }
  }

  Future<void> _onExportBudgets(
    _ExportBudgets event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      isExporting: true,
      exportStatus: 'Fetching budgets...',
      exportError: null,
    ));

    try {
      final budgets = await _budgetRepository.getAllBudgets();
      
      emit(state.copyWith(
        exportStatus: 'Exporting ${budgets.length} budgets...',
      ));
      
      await _csvExportService.exportBudgetsToCSV(budgets);
      
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Successfully exported ${budgets.length} budgets!',
        exportError: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isExporting: false,
        exportStatus: null,
        exportError: 'Failed to export budgets: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBiometricToggled(
    _BiometricToggled event,
    Emitter<SettingsState> emit,
  ) async {
    if (event.enabled) {
      // User wants to enable biometrics - require authentication first
      emit(state.copyWith(
        isBiometricAuthenticating: true,
        biometricAuthError: null,
      ));

      try {
        // Check if biometric is available
        final isAvailable = await _biometricAuthService.isBiometricAvailable();
        if (!isAvailable) {
          emit(state.copyWith(
            isBiometricAuthenticating: false,
            biometricAuthError: 'Biometric authentication is not available on this device',
            biometricEnabled: false,
          ));
          return;
        }

        // Trigger native biometric authentication for setup
        final authenticated = await _biometricAuthService.authenticateForSetup(
          reason: 'Authenticate to enable biometric lock for this app',
          biometricOnly: true,
        );

        if (authenticated) {
          // Authentication successful - enable the setting
          emit(state.copyWith(
            isBiometricAuthenticating: false,
            biometricEnabled: true,
            biometricAuthError: null,
          ));
          await AppSettings.setBiometricEnabled(true);
        } else {
          // Authentication failed - keep disabled
          emit(state.copyWith(
            isBiometricAuthenticating: false,
            biometricEnabled: false,
            biometricAuthError: 'Authentication failed. Biometric lock remains disabled to prevent lockout.',
          ));
        }
      } catch (e) {
        // Handle any errors during authentication
        emit(state.copyWith(
          isBiometricAuthenticating: false,
          biometricEnabled: false,
          biometricAuthError: 'Failed to authenticate: ${e.toString()}',
        ));
      }
    } else {
      // User wants to disable biometrics - no authentication required
      emit(state.copyWith(
        biometricEnabled: false,
        biometricAuthError: null,
      ));
      await AppSettings.setBiometricEnabled(false);
    }
  }

  void _onBiometricAppLockToggled(
    _BiometricAppLockToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(biometricAppLockEnabled: event.enabled));
    AppSettings.setBiometricAppLock(event.enabled);
  }
}
