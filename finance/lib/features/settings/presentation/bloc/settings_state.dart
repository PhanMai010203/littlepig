part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    required ThemeMode themeMode,
    required bool analyticsEnabled,
    required bool autoBackupEnabled,
    required bool notificationsEnabled,
  }) = _SettingsState;
}
