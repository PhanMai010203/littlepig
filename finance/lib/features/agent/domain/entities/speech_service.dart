import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/settings/app_settings.dart';

class SpeechService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isInitialized = false;
  String _recognizedText = '';
  String _lastWords = '';
  String _currentLocale = 'en_US';
  List<LocaleName> _availableLocales = [];
  
  // Auto-stop timer
  Timer? _autoStopTimer;
  static const Duration _autoStopDuration = Duration(seconds: 3);

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  bool get isInitialized => _isInitialized;
  String get recognizedText => _recognizedText;
  String get lastWords => _lastWords;
  String get currentLocale => _currentLocale;
  List<LocaleName> get availableLocales => _availableLocales;

  Future<bool> initialize() async {
    try {
      // Check microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      _isAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: kDebugMode,
      );

      if (_isAvailable) {
        _availableLocales = await _speechToText.locales();
        
        // Set default locale - prefer English or Vietnamese if available
        final preferredLocales = ['en_US', 'en_GB', 'vi_VN'];
        for (final locale in preferredLocales) {
          if (_availableLocales.any((l) => l.localeId == locale)) {
            _currentLocale = locale;
            break;
          }
        }
      }

      _isInitialized = _isAvailable;
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      return false;
    }
  }

  Future<void> startListening({String? localeId}) async {
    if (!_isAvailable || _isListening) return;

    try {
      _recognizedText = '';
      
      // Use voice language from settings if not explicitly provided
      String selectedLocale;
      if (localeId != null) {
        selectedLocale = localeId;
      } else {
        final voiceLanguage = AppSettings.voiceLanguage;
        if (voiceLanguage == 'auto') {
          selectedLocale = _currentLocale; // Fall back to current locale for auto
        } else {
          selectedLocale = voiceLanguage;
          // Update current locale to match settings
          _currentLocale = voiceLanguage;
        }
      }
      
      debugPrint('🎤 SpeechService - Starting listening with locale: $selectedLocale');
      
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: selectedLocale,
        listenFor: const Duration(seconds: 30), // Maximum listening time
        pauseFor: _autoStopDuration, // Pause detection
        partialResults: true,
        onSoundLevelChange: _onSoundLevelChange,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );

      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Start listening error: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      _autoStopTimer?.cancel();
      notifyListeners();
    } catch (e) {
      debugPrint('Stop listening error: $e');
    }
  }

  void switchLocale([String? localeId]) {
    if (localeId != null) {
      if (_availableLocales.any((l) => l.localeId == localeId)) {
        _currentLocale = localeId;
        notifyListeners();
      }
    } else {
      // Toggle between English and Vietnamese
      if (_currentLocale == 'en_US') {
        if (_availableLocales.any((l) => l.localeId == 'vi_VN')) {
          _currentLocale = 'vi_VN';
        }
      } else {
        _currentLocale = 'en_US';
      }
      notifyListeners();
    }
  }

  void clearLastWords() {
    _lastWords = '';
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _recognizedText = result.recognizedWords;
    
    // Save last completed words when final result is received
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      _lastWords = result.recognizedWords;
    }
    
    // Reset auto-stop timer on new results
    _autoStopTimer?.cancel();
    if (result.hasConfidenceRating && result.confidence > 0) {
      _autoStopTimer = Timer(_autoStopDuration, () {
        if (_isListening) {
          stopListening();
        }
      });
    }
    
    notifyListeners();
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _autoStopTimer?.cancel();
      notifyListeners();
    }
  }

  void _onSpeechError(dynamic error) {
    debugPrint('Speech error: $error');
    _isListening = false;
    _autoStopTimer?.cancel();
    notifyListeners();
  }

  void _onSoundLevelChange(double level) {
    // Optional: Handle sound level changes for UI feedback
    // debugPrint('Sound level: $level');
  }

  @override
  void dispose() {
    _autoStopTimer?.cancel();
    super.dispose();
  }
} 