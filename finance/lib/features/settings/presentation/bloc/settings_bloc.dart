import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

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
    // In a real app, load settings from shared preferences
    emit(SettingsState(
      themeMode: ThemeMode.system,
      analyticsEnabled: true,
      autoBackupEnabled: false,
      notificationsEnabled: true,
    ));
  }

  void _onThemeModeChanged(
    _ThemeModeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
    // In a real app, save to shared preferences
  }

  void _onAnalyticsToggled(
    _AnalyticsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(analyticsEnabled: event.enabled));
    // In a real app, save to shared preferences
  }

  void _onAutoBackupToggled(
    _AutoBackupToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(autoBackupEnabled: event.enabled));
    // In a real app, save to shared preferences
  }

  void _onNotificationsToggled(
    _NotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(notificationsEnabled: event.enabled));
    // In a real app, save to shared preferences
  }
} 