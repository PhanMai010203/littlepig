import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/services/csv_export_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final CsvExportService _csvExportService;

  SettingsBloc(this._csvExportService)
      : super(const SettingsState(
          themeMode: ThemeMode.system,
          analyticsEnabled: true,
          autoBackupEnabled: false,
          notificationsEnabled: true,
          hapticFeedbackEnabled: true,
        )) {
    on<_LoadSettings>(_onLoadSettings);
    on<_ThemeModeChanged>(_onThemeModeChanged);
    on<_AnalyticsToggled>(_onAnalyticsToggled);
    on<_AutoBackupToggled>(_onAutoBackupToggled);
    on<_NotificationsToggled>(_onNotificationsToggled);
    on<_HapticFeedbackToggled>(_onHapticFeedbackToggled);
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
      exportStatus: 'Exporting all data...',
      exportError: null,
    ));

    try {
      await _csvExportService.exportAllDataToCSV();
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'All data exported successfully!',
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
      exportStatus: 'Exporting transactions...',
      exportError: null,
    ));

    try {
      // Note: This would need to be connected to transaction repository
      // For now, we'll just show a placeholder message
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Transaction export feature coming soon!',
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
      exportStatus: 'Exporting accounts...',
      exportError: null,
    ));

    try {
      // Note: This would need to be connected to account repository
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Account export feature coming soon!',
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
      exportStatus: 'Exporting categories...',
      exportError: null,
    ));

    try {
      // Note: This would need to be connected to category repository
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Category export feature coming soon!',
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
      exportStatus: 'Exporting budgets...',
      exportError: null,
    ));

    try {
      // Note: This would need to be connected to budget repository
      emit(state.copyWith(
        isExporting: false,
        exportStatus: 'Budget export feature coming soon!',
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
}
