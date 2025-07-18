part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.loadSettings() = _LoadSettings;
  const factory SettingsEvent.themeModeChanged(ThemeMode themeMode) =
      _ThemeModeChanged;
  const factory SettingsEvent.analyticsToggled(bool enabled) =
      _AnalyticsToggled;
  const factory SettingsEvent.autoBackupToggled(bool enabled) =
      _AutoBackupToggled;
  const factory SettingsEvent.notificationsToggled(bool enabled) =
      _NotificationsToggled;
  const factory SettingsEvent.hapticFeedbackToggled(bool enabled) =
      _HapticFeedbackToggled;
  const factory SettingsEvent.exportSettings() = _ExportSettings;
  const factory SettingsEvent.exportAllData() = _ExportAllData;
  const factory SettingsEvent.exportTransactions() = _ExportTransactions;
  const factory SettingsEvent.exportAccounts() = _ExportAccounts;
  const factory SettingsEvent.exportCategories() = _ExportCategories;
  const factory SettingsEvent.exportBudgets() = _ExportBudgets;
}
