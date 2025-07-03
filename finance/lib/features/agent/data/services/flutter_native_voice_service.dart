import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

import '../../domain/entities/voice_command.dart';
import '../../domain/services/native_voice_service.dart';

/// Flutter implementation of NativeVoiceService using flutter_tts and speech_to_text
class FlutterNativeVoiceService implements NativeVoiceService {
  static const String _logTag = '🎤 FlutterNativeVoiceService';
  
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  final StreamController<VoiceServiceEvent> _eventController = 
      StreamController<VoiceServiceEvent>.broadcast();
  final StreamController<VoiceCommand> _voiceCommandController = 
      StreamController<VoiceCommand>.broadcast();
  final Uuid _uuid = const Uuid();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  VoiceSettings _currentSettings = const VoiceSettings();
  String? _currentListeningSessionId;
  Timer? _listeningTimeoutTimer;
  String? _lastDetectedLocale;
  String? _activeSttLanguage;
  
  // ML Kit language identifier for auto language detection
  final LanguageIdentifier _languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  bool get isListening => _isListening;
  
  @override
  bool get isSpeaking => _isSpeaking;
  
  @override
  bool get isPaused => _isPaused;
  
  @override
  VoiceSettings get currentSettings => _currentSettings;
  
  @override
  Stream<VoiceServiceEvent> get events => _eventController.stream;

  @override
  Future<bool> initialize(VoiceSettings settings) async {
    try {
      debugPrint('$_logTag - Initializing voice service...');
      
      // Initialize TTS
      if (await isTextToSpeechAvailable) {
        await _initializeTts(settings);
        debugPrint('$_logTag - TTS initialized successfully');
      } else {
        debugPrint('$_logTag - TTS not available on this device');
      }
      
      // Initialize STT
      if (await isSpeechRecognitionAvailable) {
        await _initializeStt();
        debugPrint('$_logTag - STT initialized successfully');
      } else {
        debugPrint('$_logTag - STT not available on this device');
      }
      
      _currentSettings = settings;
      _isInitialized = true;
      
      _eventController.add(SettingsUpdatedEvent(
        oldSettings: const VoiceSettings(),
        newSettings: settings,
        timestamp: DateTime.now(),
        message: 'Voice service initialized',
      ));
      
      debugPrint('$_logTag - Voice service initialization completed');
      return true;
    } catch (e, stackTrace) {
      debugPrint('$_logTag - Initialization failed: $e');
      _eventController.add(VoiceServiceErrorEvent(
        error: 'Failed to initialize voice service: $e',
        stackTrace: stackTrace.toString(),
        timestamp: DateTime.now(),
      ));
      return false;
    }
  }

  Future<void> _initializeTts(VoiceSettings settings) async {
    // Configure TTS settings
    if (settings.language != 'auto') {
    await _tts.setLanguage(settings.language);
    }
    await _tts.setSpeechRate(settings.speechRate);
    await _tts.setPitch(settings.pitch);
    await _tts.setVolume(settings.volume);
    
    // Set platform-specific settings
    if (Platform.isAndroid) {
      await _tts.isLanguageInstalled(settings.language);
    }
    
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.allowBluetooth],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }
    
    // Setup event handlers
    _tts.setStartHandler(() {
      _isSpeaking = true;
      _eventController.add(TextToSpeechStartedEvent(
        text: 'TTS Started',
        timestamp: DateTime.now(),
      ));
    });
    
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      _eventController.add(TextToSpeechCompletedEvent(
        text: 'TTS Completed',
        timestamp: DateTime.now(),
      ));
    });
    
    _tts.setErrorHandler((msg) {
      _isSpeaking = false;
      _isPaused = false;
      _eventController.add(VoiceServiceErrorEvent(
        error: 'TTS Error: $msg',
        timestamp: DateTime.now(),
      ));
    });
    
    _tts.setPauseHandler(() {
      _isPaused = true;
    });
    
    _tts.setContinueHandler(() {
      _isPaused = false;
    });
  }

  Future<void> _initializeStt() async {
    final available = await _stt.initialize(
      onStatus: (status) {
        debugPrint('$_logTag - STT Status: $status');
        if (status == 'listening') {
          _isListening = true;
          _eventController.add(SpeechRecognitionStartedEvent(
            timestamp: DateTime.now(),
            message: 'Speech recognition started',
          ));
        } else if (status == 'notListening' || status == 'done') {
          if (_isListening) {
          _isListening = false;
          _eventController.add(SpeechRecognitionStoppedEvent(
            timestamp: DateTime.now(),
            message: 'Speech recognition stopped',
          ));
          }
        }
      },
      onError: (error) {
        debugPrint('$_logTag - STT Error: ${error.errorMsg}');
        _isListening = false;
        _eventController.add(VoiceServiceErrorEvent(
          error: 'Speech recognition error: ${error.errorMsg}',
          timestamp: DateTime.now(),
        ));
      },
    );
    
    if (!available) {
      throw VoiceServiceException(
        'Speech recognition not available on this device',
        code: 'STT_NOT_AVAILABLE',
      );
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('$_logTag - Disposing voice service...');
    
    try {
      // Stop any ongoing operations
      if (_isListening) {
        await stopListening();
      }
      if (_isSpeaking) {
        await stopSpeaking();
      }
      
      // Cancel timers
      _listeningTimeoutTimer?.cancel();
      
      // Close stream controllers
      await _eventController.close();
      await _voiceCommandController.close();
      
      _isInitialized = false;
      _languageIdentifier.close();
      debugPrint('$_logTag - Voice service disposed');
    } catch (e) {
      debugPrint('$_logTag - Error during disposal: $e');
    }
  }

  @override
  Future<bool> get isSpeechRecognitionAvailable async {
    try {
      return await _stt.initialize();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> get isTextToSpeechAvailable async {
    try {
      // Try to get available languages - if this works, TTS is available
      final languages = await _tts.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableSpeechLanguages() async {
    try {
      final locales = await _stt.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      debugPrint('$_logTag - Error getting speech languages: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getAvailableTtsLanguages() async {
    try {
      final languages = await _tts.getLanguages;
      return languages?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('$_logTag - Error getting TTS languages: $e');
      return [];
    }
  }

  @override
  Future<List<String>> getAvailableTtsEngines() async {
    try {
      final engines = await _tts.getEngines;
      return engines?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('$_logTag - Error getting TTS engines: $e');
      return [];
    }
  }

  @override
  Future<bool> requestSpeechPermissions() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('$_logTag - Error requesting speech permissions: $e');
      return false;
    }
  }

  @override
  Future<bool> get hasSpeechPermissions async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      debugPrint('$_logTag - Error checking speech permissions: $e');
      return false;
    }
  }

  @override
  Stream<VoiceCommand> startListening({
    VoiceSettings? settings,
    bool partialResults = true,
  }) {
    final effectiveSettings = settings ?? _currentSettings;
    _currentListeningSessionId = _uuid.v4();
    
    var languageForSession = effectiveSettings.language;
    if (languageForSession == 'auto' && _lastDetectedLocale != null) {
      languageForSession = _lastDetectedLocale!;
    }
    
    debugPrint(
        '$_logTag - Starting listening session: $_currentListeningSessionId with language: $languageForSession');
    
    _startListeningInternal(
        effectiveSettings.copyWith(language: languageForSession), partialResults);
    
    return _voiceCommandController.stream;
  }

  Future<void> _startListeningInternal(
    VoiceSettings settings,
    bool partialResults,
  ) async {
    try {
      if (!await hasSpeechPermissions) {
        final granted = await requestSpeechPermissions();
        if (!granted) {
          throw VoiceServiceException(
            'Microphone permission not granted',
            code: 'PERMISSION_DENIED',
          );
        }
      }
      
      // Setup timeout timer
      _listeningTimeoutTimer?.cancel();
      _listeningTimeoutTimer = Timer(settings.listeningTimeout, () {
        debugPrint('$_logTag - Listening timeout reached');
        stopListening();
      });
      
      await _stt.listen(
        onResult: (SpeechRecognitionResult result) async {
          final command = VoiceCommand(
            id: _uuid.v4(),
            text: result.recognizedWords,
            confidence: result.confidence,
            language: settings.language,
            timestamp: DateTime.now(),
            status: result.finalResult 
                ? VoiceCommandStatus.recognized 
                : VoiceCommandStatus.listening,
            metadata: {
              'sessionId': _currentListeningSessionId,
              'partialResult': !result.finalResult,
              'hasConfidenceRating': result.hasConfidenceRating,
            },
          );
          
          _voiceCommandController.add(command);

          if (result.finalResult &&
              result.recognizedWords.isNotEmpty &&
              _currentSettings.language == 'auto') {
            final detectedLang =
                await _languageIdentifier.identifyLanguage(result.recognizedWords);
            if (detectedLang != 'und' && detectedLang.isNotEmpty) {
              final availableLocales = await getAvailableSpeechLanguages();
              String? matchedLocale;
              for (final locale in availableLocales) {
                if (locale.startsWith(detectedLang)) {
                  matchedLocale = locale;
                  break;
                }
              }

              if (matchedLocale != null && matchedLocale != _lastDetectedLocale) {
                debugPrint(
                    '$_logTag - Language for next session detected: $matchedLocale');
                _lastDetectedLocale = matchedLocale;
              }
            }
          }
          
          // Auto-stop on final result if not in continuous mode
          if (result.finalResult && !settings.enableContinuousListening) {
            Timer(settings.pauseThreshold, () {
              if (_isListening) stopListening();
            });
          }
        },
        listenFor: settings.listeningTimeout,
        pauseFor: settings.pauseThreshold,
        partialResults: partialResults && settings.enablePartialResults,
        localeId: settings.language == 'auto' ? null : settings.language,
        onSoundLevelChange: settings.enableVisualFeedback ? (level) {
          // You can emit sound level events here if needed
        } : null,
      );
      
    } catch (e) {
      debugPrint('$_logTag - Error starting listening: $e');
      _eventController.add(VoiceServiceErrorEvent(
        error: 'Failed to start listening: $e',
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      debugPrint('$_logTag - Stopping listening...');
      _listeningTimeoutTimer?.cancel();
      await _stt.stop();
      // This is managed by the status listener now
      // _isListening = false; 
    } catch (e) {
      debugPrint('$_logTag - Error stopping listening: $e');
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      debugPrint('$_logTag - Cancelling listening...');
      _listeningTimeoutTimer?.cancel();
      await _stt.cancel();
      // This is managed by the status listener now
      // _isListening = false;
    } catch (e) {
      debugPrint('$_logTag - Error cancelling listening: $e');
    }
  }

  @override
  Future<VoiceResponse> speak(
    String text, {
    VoiceSettings? settings,
    String? voiceEngine,
  }) async {
    final effectiveSettings = settings ?? _currentSettings;
    final responseId = _uuid.v4();
    
    try {
      debugPrint('$_logTag - Speaking: "$text"');
      
      // Update TTS settings if provided, handling auto language detection
      if (settings != null) {
        if (settings.language == 'auto') {
          // Detect language from text before speaking
          final langCode = await _languageIdentifier.identifyLanguage(text);
          if (langCode != 'und' && langCode.isNotEmpty) {
            await _tts.setLanguage(langCode);
          }
          // else, use the last known or default language
        } else {
        await _tts.setLanguage(settings.language);
        }
        await _tts.setSpeechRate(settings.speechRate);
        await _tts.setPitch(settings.pitch);
        await _tts.setVolume(settings.volume);
      }
      
      // Set voice engine if specified
      if (voiceEngine != null && Platform.isAndroid) {
        await _tts.setEngine(voiceEngine);
      }
      
      // Trigger haptic feedback if enabled
      if (effectiveSettings.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
      
      // Speak the text
      final result = await _tts.speak(text);
      
      return VoiceResponse(
        id: responseId,
        text: text,
        speechRate: effectiveSettings.speechRate,
        pitch: effectiveSettings.pitch,
        volume: effectiveSettings.volume,
        language: effectiveSettings.language,
        timestamp: DateTime.now(),
        status: result == 1 
            ? VoiceResponseStatus.completed 
            : VoiceResponseStatus.error,
        metadata: {
          'engine': voiceEngine,
          'result': result,
        },
      );
      
    } catch (e) {
      debugPrint('$_logTag - Error speaking: $e');
      _eventController.add(VoiceServiceErrorEvent(
        error: 'Failed to speak text: $e',
        timestamp: DateTime.now(),
      ));
      
      return VoiceResponse(
        id: responseId,
        text: text,
        language: effectiveSettings.language,
        timestamp: DateTime.now(),
        status: VoiceResponseStatus.error,
        metadata: {'error': e.toString()},
      );
    }
  }

  @override
  Future<void> stopSpeaking() async {
    try {
      debugPrint('$_logTag - Stopping speech...');
      await _tts.stop();
      _isSpeaking = false;
      _isPaused = false;
    } catch (e) {
      debugPrint('$_logTag - Error stopping speech: $e');
    }
  }

  @override
  Future<void> pauseSpeaking() async {
    try {
      debugPrint('$_logTag - Pausing speech...');
      await _tts.pause();
      _isPaused = true;
    } catch (e) {
      debugPrint('$_logTag - Error pausing speech: $e');
    }
  }

  @override
  Future<void> resumeSpeaking() async {
    try {
      debugPrint('$_logTag - Resuming speech...');
      await _tts.pause(); // This resumes on some platforms
      _isPaused = false;
    } catch (e) {
      debugPrint('$_logTag - Error resuming speech: $e');
    }
  }

  @override
  Future<void> updateSettings(VoiceSettings settings) async {
    final oldSettings = _currentSettings;
    
    try {
      // If the user manually selects a language, reset our auto-detection.
      if (settings.language != 'auto') {
        _lastDetectedLocale = null;
      }

      // Update TTS settings
      if (await isTextToSpeechAvailable) {
        if (settings.language != 'auto') {
        await _tts.setLanguage(settings.language);
        }
        await _tts.setSpeechRate(settings.speechRate);
        await _tts.setPitch(settings.pitch);
        await _tts.setVolume(settings.volume);
      }
      
      _currentSettings = settings;
      
      _eventController.add(SettingsUpdatedEvent(
        oldSettings: oldSettings,
        newSettings: settings,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('$_logTag - Settings updated');
    } catch (e) {
      debugPrint('$_logTag - Error updating settings: $e');
      _eventController.add(VoiceServiceErrorEvent(
        error: 'Failed to update settings: $e',
        timestamp: DateTime.now(),
      ));
    }
  }

  // Helper methods for individual setting updates
  @override
  Future<void> setSpeechRate(double rate) async {
    final clampedRate = rate.clamp(0.1, 2.0);
    try {
      await _tts.setSpeechRate(clampedRate);
      _currentSettings = _currentSettings.copyWith(speechRate: clampedRate);
      debugPrint('$_logTag - Speech rate set to: $clampedRate');
    } catch (e) {
      debugPrint('$_logTag - Error setting speech rate: $e');
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    final clampedPitch = pitch.clamp(0.5, 2.0);
    try {
      await _tts.setPitch(clampedPitch);
      _currentSettings = _currentSettings.copyWith(pitch: clampedPitch);
      debugPrint('$_logTag - Pitch set to: $clampedPitch');
    } catch (e) {
      debugPrint('$_logTag - Error setting pitch: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    try {
      await _tts.setVolume(clampedVolume);
      _currentSettings = _currentSettings.copyWith(volume: clampedVolume);
      debugPrint('$_logTag - Volume set to: $clampedVolume');
    } catch (e) {
      debugPrint('$_logTag - Error setting volume: $e');
    }
  }

  @override
  Future<void> setLanguage(String language) async {
    final oldLanguage = _currentSettings.language;
    try {
      if (language != 'auto') {
      await _tts.setLanguage(language);
      }
      _currentSettings = _currentSettings.copyWith(language: language);
      _lastDetectedLocale = null; // Reset on manual language change
      
      _eventController.add(LanguageChangedEvent(
        oldLanguage: oldLanguage,
        newLanguage: language,
        timestamp: DateTime.now(),
      ));
      
      debugPrint('$_logTag - Language changed from $oldLanguage to $language');
    } catch (e) {
      debugPrint('$_logTag - Error setting language: $e');
    }
  }

  @override
  Future<void> setContinuousListening(bool enabled) async {
    _currentSettings = _currentSettings.copyWith(enableContinuousListening: enabled);
    debugPrint('$_logTag - Continuous listening: $enabled');
  }

  @override
  Future<void> testTextToSpeech({String? text, String? language}) async {
    final testText = text ?? 'Voice service test. Can you hear this message clearly?';
    final testLanguage = language ?? _currentSettings.language;
    
    final originalLanguage = _currentSettings.language;
    
    try {
      if (testLanguage != originalLanguage) {
        if (testLanguage != 'auto') {
        await setLanguage(testLanguage);
        }
      }
      
      await speak(testText);
      debugPrint('$_logTag - TTS test completed');
    } finally {
      if (testLanguage != originalLanguage) {
        await setLanguage(originalLanguage);
      }
    }
  }

  @override
  Future<VoiceCommand?> testSpeechRecognition({Duration? timeout}) async {
    final testTimeout = timeout ?? const Duration(seconds: 5);
    final completer = Completer<VoiceCommand?>();
    
    late StreamSubscription<VoiceCommand> subscription;
    late Timer timeoutTimer;
    
    subscription = startListening(
      settings: _currentSettings.copyWith(
        listeningTimeout: testTimeout,
        enablePartialResults: false,
      ),
      partialResults: false,
    ).listen((command) {
      if (command.status == VoiceCommandStatus.recognized) {
        timeoutTimer.cancel();
        subscription.cancel();
        completer.complete(command);
      }
    });
    
    timeoutTimer = Timer(testTimeout, () {
      subscription.cancel();
      stopListening();
      completer.complete(null);
    });
    
    return completer.future;
  }

  @override
  Future<VoiceSettings> getSystemDefaultSettings() async {
    try {
      // Get system language
      String systemLanguage = Platform.localeName.replaceAll('_', '-');
      
      // Validate if the language is available
      final availableLanguages = await getAvailableTtsLanguages();
      if (!availableLanguages.contains(systemLanguage)) {
        systemLanguage = 'en-US'; // Fallback to English
      }
      
      return const VoiceSettings(
        language: 'auto', // Default to automatic detection
        speechRate: 0.8,
        pitch: 1.0,
        volume: 1.0,
        enableContinuousListening: false,
        listeningTimeout: const Duration(seconds: 30),
        pauseThreshold: const Duration(seconds: 2),
        enablePartialResults: true,
        enableHapticFeedback: true,
        enableVisualFeedback: true,
      );
    } catch (e) {
      debugPrint('$_logTag - Error getting system defaults: $e');
      return const VoiceSettings(); // Return default settings
    }
  }

  @override
  Future<bool> isFeatureSupported(VoiceFeature feature) async {
    try {
      switch (feature) {
        case VoiceFeature.speechRecognition:
          return await isSpeechRecognitionAvailable;
        
        case VoiceFeature.textToSpeech:
          return await isTextToSpeechAvailable;
        
        case VoiceFeature.continuousListening:
          return true; // Supported by speech_to_text
        
        case VoiceFeature.partialResults:
          return true; // Supported by speech_to_text
        
        case VoiceFeature.pauseResume:
          return Platform.isIOS; // Better support on iOS
        
        case VoiceFeature.voiceEngineSelection:
          return Platform.isAndroid; // Better support on Android
        
        case VoiceFeature.customSpeechRate:
        case VoiceFeature.customPitch:
        case VoiceFeature.customVolume:
          return true; // Supported by flutter_tts
        
        case VoiceFeature.multipleLanguages:
          final languages = await getAvailableTtsLanguages();
          return languages.length > 1;
        
        case VoiceFeature.offlineRecognition:
          return Platform.isAndroid; // Better offline support on Android
        
        case VoiceFeature.onDeviceProcessing:
          return true; // Both packages process on-device
      }
    } catch (e) {
      debugPrint('$_logTag - Error checking feature support for $feature: $e');
      return false;
    }
  }
} 