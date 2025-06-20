# Settings State Consistency Fix

## 🚨 Problem
Theme and settings changes don't persist after app restart because `SettingsBloc` and `AppSettings` are disconnected:
- **UI uses**: `SettingsBloc.state.themeMode` (in-memory, non-persistent)
- **Settings Page saves to**: `AppSettings.setThemeMode()` (persists to SharedPreferences)
- **Result**: App always starts with hardcoded defaults instead of saved preferences

## 🔍 Root Cause
In `lib/features/settings/presentation/bloc/settings_bloc.dart`:

```dart
// ❌ Current: Hardcoded defaults, no persistence
void _onLoadSettings(_LoadSettings event, Emitter<SettingsState> emit) {
  emit(SettingsState(
    themeMode: ThemeMode.system,        // Hardcoded!
    analyticsEnabled: true,             // Hardcoded!
    autoBackupEnabled: false,           // Hardcoded!
    notificationsEnabled: true,         // Hardcoded!
  ));
}

void _onThemeModeChanged(_ThemeModeChanged event, Emitter<SettingsState> emit) {
  emit(state.copyWith(themeMode: event.themeMode));
  // ❌ No persistence - only updates BLoC state
}
```

## ✅ Solution
Connect `SettingsBloc` to `AppSettings` for bidirectional sync:

### 1. Update `_onLoadSettings` method:
```dart
void _onLoadSettings(_LoadSettings event, Emitter<SettingsState> emit) {
  emit(SettingsState(
    themeMode: AppSettings.themeMode,
    analyticsEnabled: AppSettings.getWithDefault<bool>('analyticsEnabled', true),
    autoBackupEnabled: AppSettings.getWithDefault<bool>('autoBackupEnabled', false),
    notificationsEnabled: AppSettings.getWithDefault<bool>('notificationsEnabled', true),
  ));
}
```

### 2. Update all event handlers to persist:
```dart
void _onThemeModeChanged(_ThemeModeChanged event, Emitter<SettingsState> emit) {
  emit(state.copyWith(themeMode: event.themeMode));
  AppSettings.setThemeMode(event.themeMode);  // ✅ Persist to SharedPreferences
}

void _onAnalyticsToggled(_AnalyticsToggled event, Emitter<SettingsState> emit) {
  emit(state.copyWith(analyticsEnabled: event.enabled));
  AppSettings.set('analyticsEnabled', event.enabled);  // ✅ Persist
}

void _onAutoBackupToggled(_AutoBackupToggled event, Emitter<SettingsState> emit) {
  emit(state.copyWith(autoBackupEnabled: event.enabled));
  AppSettings.set('autoBackupEnabled', event.enabled);  // ✅ Persist
}

void _onNotificationsToggled(_NotificationsToggled event, Emitter<SettingsState> emit) {
  emit(state.copyWith(notificationsEnabled: event.enabled));
  AppSettings.set('notificationsEnabled', event.enabled);  // ✅ Persist
}
```

### 3. Add required import:
```dart
import '../../../../core/settings/app_settings.dart';
```

## 🧪 Testing
Verify fix works:
1. Change theme mode in settings
2. Close and restart app
3. **Expected**: App starts with previously selected theme
4. **Current**: App always starts with system theme

## 📁 Files to Modify
- `lib/features/settings/presentation/bloc/settings_bloc.dart`

## ⏱️ Estimated Time
**30 minutes** - Simple implementation with existing infrastructure

## 🎯 Expected Outcome
- ✅ All settings persist across app restarts
- ✅ Single source of truth for settings
- ✅ Eliminates state inconsistency bugs
- ✅ Improves user experience and trust 