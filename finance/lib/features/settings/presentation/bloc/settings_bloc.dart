import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/settings/app_settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState(
    themeMode: ThemeMode.system,
    analyticsEnabled: true,
    autoBackupEnabled: false,
    notificationsEnabled: true,
  )) {
    on<_LoadSettings>(_onLoadSettings);
    on<_ThemeModeChanged>(_onThemeModeChanged);
    on<_AnalyticsToggled>(_onAnalyticsToggled);
    on<_AutoBackupToggled>(_onAutoBackupToggled);
    on<_NotificationsToggled>(_onNotificationsToggled);
  }

  void _onLoadSettings(
    _LoadSettings event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsState(
      themeMode: AppSettings.themeMode,
      analyticsEnabled: AppSettings.getWithDefault<bool>('analyticsEnabled', true),
      autoBackupEnabled: AppSettings.getWithDefault<bool>('autoBackupEnabled', false),
      notificationsEnabled: AppSettings.getWithDefault<bool>('notificationsEnabled', true),
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
} 