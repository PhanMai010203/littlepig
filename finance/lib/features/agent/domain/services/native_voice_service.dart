import '../entities/voice_command.dart';

/// Abstract interface for native voice services
/// Provides speech-to-text and text-to-speech capabilities using platform-native engines
abstract class NativeVoiceService {
  /// Initialize the voice service with the given settings
  Future<bool> initialize(VoiceSettings settings);
  
  /// Dispose of resources and clean up
  Future<void> dispose();
  
  /// Check if the service is initialized and ready
  bool get isInitialized;
  
  /// Check if the device supports speech recognition
  Future<bool> get isSpeechRecognitionAvailable;
  
  /// Check if the device supports text-to-speech
  Future<bool> get isTextToSpeechAvailable;
  
  /// Get available speech recognition languages
  Future<List<String>> getAvailableSpeechLanguages();
  
  /// Get available text-to-speech languages  
  Future<List<String>> getAvailableTtsLanguages();
  
  /// Get available text-to-speech engines/voices
  Future<List<String>> getAvailableTtsEngines();
  
  /// Request necessary permissions for speech recognition
  Future<bool> requestSpeechPermissions();
  
  /// Check if speech permissions are granted
  Future<bool> get hasSpeechPermissions;
  
  /// Start listening for speech input
  /// Returns a stream of partial and final recognition results
  Stream<VoiceCommand> startListening({
    VoiceSettings? settings,
    bool partialResults = true,
  });
  
  /// Stop listening for speech input
  Future<void> stopListening();
  
  /// Cancel current listening session
  Future<void> cancelListening();
  
  /// Check if currently listening
  bool get isListening;
  
  /// Speak the given text using text-to-speech
  /// Returns a future that completes when speech finishes
  Future<VoiceResponse> speak(
    String text, {
    VoiceSettings? settings,
    String? voiceEngine,
  });
  
  /// Stop current text-to-speech playback
  Future<void> stopSpeaking();
  
  /// Pause current text-to-speech playback (if supported)
  Future<void> pauseSpeaking();
  
  /// Resume paused text-to-speech playback (if supported)  
  Future<void> resumeSpeaking();
  
  /// Check if currently speaking
  bool get isSpeaking;
  
  /// Check if speech is currently paused
  bool get isPaused;
  
  /// Get current voice settings
  VoiceSettings get currentSettings;
  
  /// Update voice settings
  Future<void> updateSettings(VoiceSettings settings);
  
  /// Stream of voice service events (errors, state changes, etc.)
  Stream<VoiceServiceEvent> get events;
  
  /// Set speech rate (0.1 to 2.0, where 1.0 is normal speed)
  Future<void> setSpeechRate(double rate);
  
  /// Set speech pitch (0.5 to 2.0, where 1.0 is normal pitch)
  Future<void> setPitch(double pitch);
  
  /// Set speech volume (0.0 to 1.0)
  Future<void> setVolume(double volume);
  
  /// Set the language for speech recognition and text-to-speech
  Future<void> setLanguage(String language);
  
  /// Enable or disable continuous listening mode
  Future<void> setContinuousListening(bool enabled);
  
  /// Test text-to-speech with a sample phrase
  Future<void> testTextToSpeech({String? text, String? language});
  
  /// Test speech recognition with a short recording
  Future<VoiceCommand?> testSpeechRecognition({Duration? timeout});
  
  /// Get system's default voice settings
  Future<VoiceSettings> getSystemDefaultSettings();
  
  /// Check if a specific feature is supported on this platform
  Future<bool> isFeatureSupported(VoiceFeature feature);
}

/// Events that can be emitted by the voice service
abstract class VoiceServiceEvent {
  final DateTime timestamp;
  final String? message;
  
  const VoiceServiceEvent({
    required this.timestamp,
    this.message,
  });
}

/// Speech recognition started
class SpeechRecognitionStartedEvent extends VoiceServiceEvent {
  const SpeechRecognitionStartedEvent({
    required super.timestamp,
    super.message,
  });
}

/// Speech recognition stopped
class SpeechRecognitionStoppedEvent extends VoiceServiceEvent {
  const SpeechRecognitionStoppedEvent({
    required super.timestamp,
    super.message,
  });
}

/// Text-to-speech started
class TextToSpeechStartedEvent extends VoiceServiceEvent {
  final String text;
  
  const TextToSpeechStartedEvent({
    required this.text,
    required super.timestamp,
    super.message,
  });
}

/// Text-to-speech completed
class TextToSpeechCompletedEvent extends VoiceServiceEvent {
  final String text;
  
  const TextToSpeechCompletedEvent({
    required this.text,
    required super.timestamp,
    super.message,
  });
}

/// Voice service error
class VoiceServiceErrorEvent extends VoiceServiceEvent {
  final String error;
  final String? stackTrace;
  
  const VoiceServiceErrorEvent({
    required this.error,
    this.stackTrace,
    required super.timestamp,
    super.message,
  });
}

/// Language changed event
class LanguageChangedEvent extends VoiceServiceEvent {
  final String oldLanguage;
  final String newLanguage;
  
  const LanguageChangedEvent({
    required this.oldLanguage,
    required this.newLanguage,
    required super.timestamp,
    super.message,
  });
}

/// Settings updated event
class SettingsUpdatedEvent extends VoiceServiceEvent {
  final VoiceSettings oldSettings;
  final VoiceSettings newSettings;
  
  const SettingsUpdatedEvent({
    required this.oldSettings,
    required this.newSettings,
    required super.timestamp,
    super.message,
  });
}

/// Voice service features that can be checked for support
enum VoiceFeature {
  speechRecognition,
  textToSpeech,
  continuousListening,
  partialResults,
  pauseResume,
  voiceEngineSelection,
  customSpeechRate,
  customPitch,
  customVolume,
  multipleLanguages,
  offlineRecognition,
  onDeviceProcessing,
}

/// Exception thrown by voice service operations
class VoiceServiceException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  
  const VoiceServiceException(
    this.message, {
    this.code,
    this.originalException,
  });
  
  @override
  String toString() {
    if (code != null) {
      return 'VoiceServiceException[$code]: $message';
    }
    return 'VoiceServiceException: $message';
  }
} 