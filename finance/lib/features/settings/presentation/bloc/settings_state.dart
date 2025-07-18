part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required ThemeMode themeMode,
    required bool analyticsEnabled,
    required bool autoBackupEnabled,
    required bool notificationsEnabled,
    required bool hapticFeedbackEnabled,
    required bool biometricEnabled,
    required bool biometricAppLockEnabled,
    @Default(false) bool isExporting,
    @Default(null) String? exportStatus,
    @Default(null) String? exportError,
  }) = _SettingsState;
}
