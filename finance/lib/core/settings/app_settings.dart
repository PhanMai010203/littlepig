import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/animation_performance_service.dart';
import '../../features/agent/domain/entities/voice_command.dart';

/// Global app settings manager based on the budget app's system
class AppSettings {
  static Map<String, dynamic> _settings = {};
  static SharedPreferences? _prefs;

  /// Initialize the settings system - call this in main()
  static Future<bool> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");
    
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    return true;
  }

  /// Get a setting value with type safety
  static T? get<T>(String key) {
    return _settings[key] as T?;
  }

  /// Get a setting value with a default fallback
  static T getWithDefault<T>(String key, T defaultValue) {
    try {
      final value = _settings[key];
      if (value is T) {
        return value;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Update a setting and persist it
  static Future<bool> set(
    String key,
    dynamic value, {
    bool notifyListeners = true,
  }) async {
    bool isChanged = _settings[key] != value;
    _settings[key] = value;

    await _saveSettings();

    if (isChanged && notifyListeners) {
      // Trigger app rebuild for theme changes
      _notifyAppStateChange();
    }

    return true;
  }

  /// Get all settings
  static Map<String, dynamic> getAll() {
    return Map<String, dynamic>.from(_settings);
  }

  /// Reset to default settings
  static Future<void> resetToDefaults() async {
    _settings = _getDefaultSettings();
    await _saveSettings();
    _notifyAppStateChange();
  }

  /// Load settings from persistent storage
  static Future<void> _loadSettings() async {
    try {
      final settingsJson = _prefs?.getString('app_settings');
      if (settingsJson != null) {
        final loadedSettings =
            json.decode(settingsJson) as Map<String, dynamic>;
        _settings = _mergeWithDefaults(loadedSettings);
      } else {
        _settings = _getDefaultSettings();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _settings = _getDefaultSettings();
    }
  }

  /// Save settings to persistent storage
  static Future<void> _saveSettings() async {
    try {
      final settingsJson = json.encode(_settings);
      await _prefs?.setString('app_settings', settingsJson);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Merge loaded settings with defaults to handle new settings
  static Map<String, dynamic> _mergeWithDefaults(Map<String, dynamic> loaded) {
    final defaults = _getDefaultSettings();
    final merged = Map<String, dynamic>.from(defaults);

    loaded.forEach((key, value) {
      // Special handling for AI model to clean up invalid model names
      if (key == 'aiModel' && value is String) {
        final cleanedModel = _cleanupAiModel(value);
        merged[key] = cleanedModel;
      } else {
        merged[key] = value;
      }
    });

    return merged;
  }

  /// Clean up invalid AI model names (remove API prefixes and fix deprecated models)
  static String _cleanupAiModel(String modelName) {
    // Remove 'models/' prefix if present
    if (modelName.startsWith('models/')) {
      modelName = modelName.substring('models/'.length);
    }
    
    // Fix deprecated model names
    const modelMappings = {
      'gemini-2.5-flash-preview-04-17': 'gemini-2.5-flash',
      'gemini-2.0-flash-thinking-exp-01-21': 'gemini-2.0-flash-thinking-exp',
      'gemini-1.5-pro-preview': 'gemini-1.5-pro',
      'gemini-1.5-flash-preview': 'gemini-1.5-flash',
    };
    
    // Check if the model name needs to be mapped to a valid one
    final cleanedModel = modelMappings[modelName] ?? modelName;
    
    debugPrint('[AppSettings] Cleaned AI model: "$modelName" -> "$cleanedModel"');
    return cleanedModel;
  }

  /// Default settings - customize these for your app
  static Map<String, dynamic> _getDefaultSettings() {
    return {
      // Theme settings
      'themeMode': 'system', // 'light', 'dark', 'system'
      'materialYou': false, // User can enable if supported
      'useSystemAccent': false, // User can enable if supported
      'accentColor': '0xFF2196F3', // Default blue fallback

      // Text settings
      'font': 'Avenir', // 'system', 'Avenir', 'Inter', 'DMSans', etc.
      'fontSize': 16.0,
      'increaseTextContrast': false,

      // Localization
      'locale': 'system', // 'system' or locale code like 'en', 'es'

      // Enhanced animation settings (Phase 1)
      'reduceAnimations': false,
      'animationLevel': 'normal', // 'none', 'reduced', 'normal', 'enhanced'
      'batterySaver': false,
      'outlinedIcons': false,
      'appAnimations': true,

      // Haptic feedback settings
      'hapticFeedback': true, // Independent haptic feedback control

      // Accessibility
      'highContrast': false,

      // App behavior
      'firstLaunch': true,
      'lastVersion': '1.0.0',

      // AI Agent settings
      'geminiApiKey': dotenv.env['GEMINI_API_KEY'] ?? '', // Load from environment
      'aiEnabled': dotenv.env['AI_ENABLED']?.toLowerCase() == 'true', // Load from environment
      'aiModel': 'gemini-2.5-flash', 
      'aiTemperature': double.tryParse(dotenv.env['AI_TEMPERATURE'] ?? '0.3') ?? 0.3, // Load from environment
      'aiMaxTokens': int.tryParse(dotenv.env['AI_MAX_TOKENS'] ?? '4000') ?? 4000, // Load from environment

      // Voice settings
      'voiceLanguage': 'auto',
      'voiceSpeechRate': 0.8,
      'voicePitch': 1.0,
      'voiceVolume': 1.0,
      'voiceEnableHapticFeedback': true,
      'voiceEnablePartialResults': true,

      // Biometric authentication settings
      'biometricEnabled': false,
      'biometricAppLock': false,
    };
  }

  /// Callback for app state changes - override this in your main app
  static VoidCallback? _onAppStateChanged;

  /// Set the callback for when settings change
  static void setAppStateChangeCallback(VoidCallback callback) {
    _onAppStateChanged = callback;
  }

  /// Notify app of state changes
  static void _notifyAppStateChange() {
    _onAppStateChanged?.call();
    // Notify performance service to update listeners for immediate UI refresh
    AnimationPerformanceService.notifyListeners();
  }

  /// Convenience methods for common settings
  static ThemeMode get themeMode {
    final mode = get<String>('themeMode') ?? 'system';
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Color get accentColor {
    final colorString = get<String>('accentColor') ?? '0xFF2196F3';
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return Colors.blue; // Fallback
    }
  }

  static Future<void> setAccentColor(Color color) async {
    await set('accentColor',
        '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}');
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await set('themeMode', modeString);
  }

  /// Animation-related convenience methods (Phase 1)
  static String get animationLevel {
    return get<String>('animationLevel') ?? 'normal';
  }

  static Future<void> setAnimationLevel(String level) async {
    await set('animationLevel', level);
  }

  static bool get batterySaver {
    return get<bool>('batterySaver') ?? false;
  }

  static Future<void> setBatterySaver(bool enabled) async {
    await set('batterySaver', enabled);
  }

  static bool get outlinedIcons {
    return get<bool>('outlinedIcons') ?? false;
  }

  static Future<void> setOutlinedIcons(bool enabled) async {
    await set('outlinedIcons', enabled);
  }

  static bool get appAnimations {
    return get<bool>('appAnimations') ?? true;
  }

  static Future<void> setAppAnimations(bool enabled) async {
    await set('appAnimations', enabled);
  }

  static bool get reduceAnimations {
    return get<bool>('reduceAnimations') ?? false;
  }

  static Future<void> setReduceAnimations(bool enabled) async {
    await set('reduceAnimations', enabled);
  }

  static bool get hapticFeedback {
    return get<bool>('hapticFeedback') ?? true;
  }

  static Future<void> setHapticFeedback(bool enabled) async {
    await set('hapticFeedback', enabled);
  }

  /// AI-related convenience methods
  static String get geminiApiKey {
    return get<String>('geminiApiKey') ?? '';
  }

  static Future<void> setGeminiApiKey(String apiKey) async {
    await set('geminiApiKey', apiKey);
  }

  static bool get aiEnabled {
    return get<bool>('aiEnabled') ?? false;
  }

  static Future<void> setAiEnabled(bool enabled) async {
    await set('aiEnabled', enabled);
  }

  static String get aiModel {
    final rawModel = get<String>('aiModel') ?? 'gemini-1.5-pro';
    return _cleanupAiModel(rawModel);
  }

  static Future<void> setAiModel(String model) async {
    await set('aiModel', model);
  }

  static double get aiTemperature {
    return get<double>('aiTemperature') ?? 0.3;
  }

  static Future<void> setAiTemperature(double temperature) async {
    await set('aiTemperature', temperature);
  }

  static int get aiMaxTokens {
    return get<int>('aiMaxTokens') ?? 4000;
  }

  static Future<void> setAiMaxTokens(int maxTokens) async {
    await set('aiMaxTokens', maxTokens);
  }

  /// Voice settings convenience methods
  static String get voiceLanguage {
    return get<String>('voiceLanguage') ?? 'auto';
  }

  static Future<void> setVoiceLanguage(String language) async {
    await set('voiceLanguage', language);
  }

  static double get voiceSpeechRate {
    return get<double>('voiceSpeechRate') ?? 0.8;
  }

  static Future<void> setVoiceSpeechRate(double rate) async {
    await set('voiceSpeechRate', rate);
  }

  static double get voicePitch {
    return get<double>('voicePitch') ?? 1.0;
  }

  static Future<void> setVoicePitch(double pitch) async {
    await set('voicePitch', pitch);
  }

  static double get voiceVolume {
    return get<double>('voiceVolume') ?? 1.0;
  }

  static Future<void> setVoiceVolume(double volume) async {
    await set('voiceVolume', volume);
  }

  static bool get voiceEnableHapticFeedback {
    return get<bool>('voiceEnableHapticFeedback') ?? true;
  }

  static Future<void> setVoiceEnableHapticFeedback(bool enabled) async {
    await set('voiceEnableHapticFeedback', enabled);
  }

  static bool get voiceEnablePartialResults {
    return get<bool>('voiceEnablePartialResults') ?? true;
  }

  static Future<void> setVoiceEnablePartialResults(bool enabled) async {
    await set('voiceEnablePartialResults', enabled);
  }

  /// Helper method to get VoiceSettings from AppSettings
  static VoiceSettings getVoiceSettings() {
    return VoiceSettings(
      language: voiceLanguage,
      speechRate: voiceSpeechRate,
      pitch: voicePitch,
      volume: voiceVolume,
      enableHapticFeedback: voiceEnableHapticFeedback,
      enablePartialResults: voiceEnablePartialResults,
    );
  }

  /// Helper method to save VoiceSettings to AppSettings
  static Future<void> setVoiceSettings(VoiceSettings settings) async {
    await Future.wait([
      setVoiceLanguage(settings.language),
      setVoiceSpeechRate(settings.speechRate),
      setVoicePitch(settings.pitch),
      setVoiceVolume(settings.volume),
      setVoiceEnableHapticFeedback(settings.enableHapticFeedback),
      setVoiceEnablePartialResults(settings.enablePartialResults),
    ]);
  }

  /// Biometric authentication settings
  static bool get biometricEnabled {
    return get<bool>('biometricEnabled') ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await set('biometricEnabled', enabled);
  }

  static bool get biometricAppLock {
    return get<bool>('biometricAppLock') ?? false;
  }

  static Future<void> setBiometricAppLock(bool enabled) async {
    await set('biometricAppLock', enabled);
  }

  /// Debug method to print all settings
  static void debugPrintSettings() {
    debugPrint('=== App Settings ===');
    _settings.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('==================');
  }
}
