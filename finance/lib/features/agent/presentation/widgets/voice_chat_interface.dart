import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../domain/entities/voice_command.dart';
import '../../domain/services/native_voice_service.dart';
import '../../data/services/flutter_native_voice_service.dart';

/// Voice chat interface widget that provides speech-to-text and text-to-speech capabilities
class VoiceChatInterface extends StatefulWidget {
  final Function(String message, {bool isVoiceMessage}) onMessageSent;
  final Function(String text)? onSpeakResponse;
  final VoiceSettings? initialSettings;
  final bool enableVisualFeedback;
  final bool enableHapticFeedback;

  const VoiceChatInterface({
    super.key,
    required this.onMessageSent,
    this.onSpeakResponse,
    this.initialSettings,
    this.enableVisualFeedback = true,
    this.enableHapticFeedback = true,
  });

  @override
  State<VoiceChatInterface> createState() => _VoiceChatInterfaceState();
}

class _VoiceChatInterfaceState extends State<VoiceChatInterface>
    with TickerProviderStateMixin {
  static const String _logTag = '🎤 VoiceChatInterface';
  
  late NativeVoiceService _voiceService;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _hasPermissions = false;
  String _lastRecognizedText = '';
  double _soundLevel = 0.0;
  VoiceSettings _currentSettings = const VoiceSettings();
  
  StreamSubscription<VoiceCommand>? _voiceCommandSubscription;
  StreamSubscription<VoiceServiceEvent>? _voiceEventSubscription;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
  }

  Future<void> _initializeVoiceService() async {
    try {
      debugPrint('$_logTag - Initializing voice service...');
      
      _voiceService = FlutterNativeVoiceService();
      _currentSettings = widget.initialSettings ?? await _voiceService.getSystemDefaultSettings();
      
      final initialized = await _voiceService.initialize(_currentSettings);
      final hasPermissions = await _voiceService.hasSpeechPermissions;
      
      setState(() {
        _isInitialized = initialized;
        _hasPermissions = hasPermissions;
      });
      
      if (initialized) {
        _setupVoiceEventListeners();
        debugPrint('$_logTag - Voice service initialized successfully');
      } else {
        debugPrint('$_logTag - Voice service initialization failed');
      }
    } catch (e) {
      debugPrint('$_logTag - Error initializing voice service: $e');
      setState(() {
        _isInitialized = false;
        _hasPermissions = false;
      });
    }
  }

  void _setupVoiceEventListeners() {
    _voiceEventSubscription = _voiceService.events.listen((event) {
      debugPrint('$_logTag - Voice event: ${event.runtimeType}');
      
      if (event is SpeechRecognitionStartedEvent) {
        setState(() {
          _isListening = true;
        });
        _pulseController.repeat();
        _waveController.repeat();
        
        if (_currentSettings.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      } else if (event is SpeechRecognitionStoppedEvent) {
        setState(() {
          _isListening = false;
        });
        _pulseController.stop();
        _waveController.stop();
      } else if (event is TextToSpeechStartedEvent) {
        setState(() {
          _isSpeaking = true;
        });
      } else if (event is TextToSpeechCompletedEvent) {
        setState(() {
          _isSpeaking = false;
        });
      } else if (event is VoiceServiceErrorEvent) {
        _showErrorSnackBar(event.error);
        setState(() {
          _isListening = false;
          _isSpeaking = false;
        });
        _pulseController.stop();
        _waveController.stop();
      }
    });
  }

  void _showErrorSnackBar(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voice Error: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final granted = await _voiceService.requestSpeechPermissions();
      setState(() {
        _hasPermissions = granted;
      });
      
      if (!granted) {
        _showErrorSnackBar('Microphone permission is required for voice chat');
      }
    } catch (e) {
      debugPrint('$_logTag - Error requesting permissions: $e');
      _showErrorSnackBar('Failed to request microphone permission');
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      _showErrorSnackBar('Voice service not initialized');
      return;
    }
    
    if (!_hasPermissions) {
      await _requestPermissions();
      if (!_hasPermissions) return;
    }
    
    try {
      debugPrint('$_logTag - Starting voice listening...');
      
      _voiceCommandSubscription?.cancel();
      _voiceCommandSubscription = _voiceService.startListening(
        settings: _currentSettings,
        partialResults: true,
      ).listen((command) {
        debugPrint('$_logTag - Voice command received: ${command.text} (${command.confidence})');
        
        setState(() {
          _lastRecognizedText = command.text;
        });
        
        // Send final recognized text as message
        if (command.status == VoiceCommandStatus.recognized && command.text.isNotEmpty) {
          _lastRecognizedText = command.text;
          widget.onMessageSent(command.text, isVoiceMessage: true);
          
          if (_currentSettings.enableHapticFeedback) {
            HapticFeedback.mediumImpact();
          }
        }
      });
      
    } catch (e) {
      debugPrint('$_logTag - Error starting listening: $e');
      _showErrorSnackBar('Failed to start voice recognition');
    }
  }

  Future<void> _stopListening() async {
    try {
      debugPrint('$_logTag - Stopping voice listening...');
      
      await _voiceService.stopListening();
      _voiceCommandSubscription?.cancel();
      
      setState(() {
        _isListening = false;
      });
      
      _pulseController.stop();
      _waveController.stop();
    } catch (e) {
      debugPrint('$_logTag - Error stopping listening: $e');
    }
  }

  Future<void> _speakText(String text) async {
    if (!_isInitialized) {
      _showErrorSnackBar('Voice service not initialized');
      return;
    }
    
    try {
      debugPrint('$_logTag - Speaking text: "$text"');
      
      // Stop any current speech
      if (_isSpeaking) {
        await _voiceService.stopSpeaking();
      }
      
      // Speak the text
      await _voiceService.speak(text, settings: _currentSettings);
      
      if (widget.onSpeakResponse != null) {
        widget.onSpeakResponse!(text);
      }
    } catch (e) {
      debugPrint('$_logTag - Error speaking text: $e');
      _showErrorSnackBar('Failed to speak text');
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  @override
  void dispose() {
    _voiceCommandSubscription?.cancel();
    _voiceEventSubscription?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice status and recognized text display
          if (_isListening || _lastRecognizedText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isListening 
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isListening ? Icons.mic : Icons.mic_off,
                        size: 16,
                        color: _isListening 
                            ? colorScheme.primary 
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isListening ? 'Listening...' : 'Voice Recognition',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isListening 
                              ? colorScheme.primary 
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isListening) ...[
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3 + (0.7 * _pulseAnimation.value),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  if (_lastRecognizedText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _lastRecognizedText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // Voice control buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              // Listen button
              _VoiceButton(
                onPressed: _isInitialized ? _toggleListening : null,
                icon: _isListening ? Icons.mic_off : Icons.mic,
                label: _isListening ? 'Stop' : 'Listen',
                isActive: _isListening,
                animation: _isListening ? _pulseAnimation : null,
                color: colorScheme.primary,
              ),
              
              // Voice settings button
              _VoiceButton(
                onPressed: _isInitialized ? () => _showVoiceSettings(context) : null,
                icon: Icons.settings_voice,
                label: 'Settings',
                isActive: false,
                color: colorScheme.secondary,
              ),
              
              // Test voice button
              _VoiceButton(
                onPressed: _isInitialized ? () => _testVoice() : null,
                icon: _isSpeaking ? Icons.volume_off : Icons.volume_up,
                label: _isSpeaking ? 'Stop' : 'Test',
                isActive: _isSpeaking,
                color: colorScheme.tertiary,
              ),
            ],
          ),
          
          // Status text
          if (!_isInitialized)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Initializing voice service...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            )
          else if (!_hasPermissions)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.mic_external_on),
                label: const Text('Grant Microphone Permission'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _testVoice() async {
    if (_isSpeaking) {
      await _voiceService.stopSpeaking();
    } else {
      await _speakText('Voice service test. Speech recognition and text to speech are working correctly.');
    }
  }

  void _showVoiceSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _VoiceSettingsSheet(
        currentSettings: _currentSettings,
        voiceService: _voiceService,
        onSettingsChanged: (settings) {
          setState(() {
            _currentSettings = settings;
          });
          // Apply settings immediately
          _voiceService.updateSettings(settings);
        },
      ),
    );
  }

  // Public method to speak AI responses
  Future<void> speakResponse(String text) async {
    await _speakText(text);
  }
}

/// Custom voice button widget
class _VoiceButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isActive;
  final Animation<double>? animation;
  final Color color;

  const _VoiceButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.isActive,
    this.animation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget buttonContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
                ? color 
                : color.withValues(alpha: 0.1),
            border: Border.all(
              color: isActive 
                  ? color 
                  : color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isActive 
                ? Colors.white 
                : color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive 
                ? color 
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (animation != null) {
      buttonContent = AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (0.1 * animation!.value),
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: buttonContent,
    );
  }
}

/// Voice settings bottom sheet
class _VoiceSettingsSheet extends StatefulWidget {
  final VoiceSettings currentSettings;
  final NativeVoiceService voiceService;
  final Function(VoiceSettings) onSettingsChanged;

  const _VoiceSettingsSheet({
    required this.currentSettings,
    required this.voiceService,
    required this.onSettingsChanged,
  });

  @override
  State<_VoiceSettingsSheet> createState() => _VoiceSettingsSheetState();
}

class _VoiceSettingsSheetState extends State<_VoiceSettingsSheet> {
  late VoiceSettings _settings;
  List<String> _availableLanguages = ['auto'];
  bool _isLoadingLanguages = true;

  @override
  void initState() {
    super.initState();
    _settings = widget.currentSettings;
    _loadAvailableLanguages();
  }

  Future<void> _loadAvailableLanguages() async {
    try {
      final languages = await widget.voiceService.getAvailableTtsLanguages();
      // Ensure no duplicates if 'auto' is somehow returned by service
      final uniqueLanguages = languages.where((l) => l != 'auto').toList();
      setState(() {
        _availableLanguages.addAll(uniqueLanguages);
        _isLoadingLanguages = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLanguages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.settings_voice,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Voice Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Language selection
          Text(
            'Language',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoadingLanguages)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<String>(
              value: _settings.language,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _availableLanguages.toSet().map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(_getLanguageDisplayName(language)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _settings = _settings.copyWith(language: value);
                  });
                  widget.onSettingsChanged(_settings);
                }
              },
            ),
          
          const SizedBox(height: 16),
          
          // Speech rate
          Text(
            'Speech Rate: ${_settings.speechRate.toStringAsFixed(1)}x',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _settings.speechRate,
            min: 0.1,
            max: 2.0,
            divisions: 19,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(speechRate: value);
              });
              widget.onSettingsChanged(_settings);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Pitch
          Text(
            'Pitch: ${_settings.pitch.toStringAsFixed(1)}x',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _settings.pitch,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(pitch: value);
              });
              widget.onSettingsChanged(_settings);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Volume
          Text(
            'Volume: ${(_settings.volume * 100).round()}%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: _settings.volume,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(volume: value);
              });
              widget.onSettingsChanged(_settings);
            },
          ),
          
          const SizedBox(height: 16),
          
          // Switches
          SwitchListTile(
            title: const Text('Enable Haptic Feedback'),
            value: _settings.enableHapticFeedback,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(enableHapticFeedback: value);
              });
              widget.onSettingsChanged(_settings);
            },
          ),
          
          SwitchListTile(
            title: const Text('Enable Partial Results'),
            subtitle: const Text('Show speech recognition results as you speak'),
            value: _settings.enablePartialResults,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(enablePartialResults: value);
              });
              widget.onSettingsChanged(_settings);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Close'),
            ),
          ),
          
          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    if (languageCode == 'auto') {
      return 'Automatic';
    }
    final Map<String, String> languageNames = {
      'en-US': 'English (US)',
      'en-GB': 'English (UK)',
      'es-ES': 'Spanish (Spain)',
      'es-MX': 'Spanish (Mexico)',
      'fr-FR': 'French',
      'de-DE': 'German',
      'it-IT': 'Italian',
      'pt-BR': 'Portuguese (Brazil)',
      'ru-RU': 'Russian',
      'ja-JP': 'Japanese',
      'ko-KR': 'Korean',
      'zh-CN': 'Chinese (Simplified)',
      'zh-TW': 'Chinese (Traditional)',
      'vi-VN': 'Vietnamese',
    };
    
    return languageNames[languageCode] ?? languageCode;
  }
} 