import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/speech_service.dart';
import '../../domain/entities/voice_command.dart';
import '../../../../core/settings/app_settings.dart';

import '../../domain/services/ai_service.dart';
import '../../domain/services/native_voice_service.dart';
import '../../data/services/ai_service_factory.dart';
import '../../data/services/flutter_native_voice_service.dart';
import '../../../../shared/widgets/chat_bubble.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final _uuid = const Uuid();
  // Cached reference to SpeechService to avoid context lookups in dispose
  SpeechService? _speechService;
  
  bool _isAITyping = false;
  bool _isAIServiceReady = false;
  String? _lastError;
  AIService? _aiService;
  NativeVoiceService? _nativeVoiceService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _initializeSpeechService();
      await _initializeNativeVoiceService();
      await _initializeAIService();
      _addWelcomeMessage();
    } catch (e) {
      setState(() {
        _lastError = 'Failed to initialize services: $e';
      });
    }
  }

  Future<void> _initializeNativeVoiceService() async {
    try {
      _nativeVoiceService = FlutterNativeVoiceService();
      // Load voice settings from AppSettings
      final settings = AppSettings.getVoiceSettings();
      await _nativeVoiceService!.initialize(settings);
      debugPrint('✅ AI Chat - Native voice service initialized with saved settings');
    } catch (e) {
      debugPrint('❌ AI Chat - Native voice service initialization failed: $e');
    }
  }

  Future<void> _initializeSpeechService() async {
    _speechService = Provider.of<SpeechService>(context, listen: false);
    await _speechService!.initialize();
    
    // Listen for speech results
    _speechService!.addListener(_onSpeechResult);
  }

  Future<void> _initializeAIService() async {
    debugPrint('🔧 AI Chat - Initializing AI service...');
    try {
      debugPrint('🔧 AI Chat - Calling AIServiceFactory.getInstance()');
      _aiService = await AIServiceFactory.getInstance();
      debugPrint('✅ AI Chat - AI service instance obtained');
      
      final isReady = AIServiceFactory.isReady;
      final toolCount = AIServiceFactory.toolCount;
      
      debugPrint('✅ AI Chat - Service ready: $isReady, Tools available: $toolCount');
      
      setState(() {
        _isAIServiceReady = isReady;
        _lastError = null;
      });
      
      if (isReady) {
        debugPrint('✅ AI Chat - AI service initialization completed successfully');
        // Print debug info
        AIServiceFactory.printDebugInfo();
      } else {
        debugPrint('⚠️ AI Chat - AI service not ready after initialization');
      }
    } catch (e) {
      debugPrint('❌ AI Chat - AI service initialization failed: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      setState(() {
        _isAIServiceReady = false;
        _lastError = 'AI Service initialization failed: $e';
      });
    }
  }

  void _onSpeechResult() {
    debugPrint('🎤 AI Chat - Speech result received');
    if (_speechService == null) {
      debugPrint('⚠️ AI Chat - Speech service is null');
      return;
    }

    if (_speechService!.lastWords.isNotEmpty && !_speechService!.isListening) {
      final spokenText = _speechService!.lastWords;
      debugPrint('🎤 AI Chat - Spoken text: "$spokenText"');
      _sendMessage(spokenText, isVoiceMessage: true);
      _speechService!.clearLastWords();
      debugPrint('🎤 AI Chat - Speech text cleared');
    }
  }

  void _addWelcomeMessage() {
    debugPrint('👋 AI Chat - Adding welcome message');
    final toolCount = AIServiceFactory.toolCount;
    final welcomeText = 'agent.welcome_message'.tr();
    
    debugPrint('👋 Welcome message: "$welcomeText"');
    
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      text: welcomeText,
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: false,
      isVoiceMessage: false,
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
    
    debugPrint('✅ AI Chat - Welcome message added');
  }

  void _sendMessage(String text, {bool isVoiceMessage = false}) {
    debugPrint('📤 AI Chat - Sending message');
    debugPrint('📤 Message text: "$text"');
    debugPrint('📤 Is voice message: $isVoiceMessage');
    debugPrint('📤 AI service ready: $_isAIServiceReady');
    
    if (text.trim().isEmpty) {
      debugPrint('⚠️ AI Chat - Empty message, skipping');
      return;
    }

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
      isTyping: false,
      isVoiceMessage: isVoiceMessage,
    );

    debugPrint('📝 AI Chat - User message created with ID: ${userMessage.id}');

    setState(() {
      _messages.add(userMessage);
      _isAITyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Use real AI service or fallback to simulation
    if (_isAIServiceReady && _aiService != null) {
      debugPrint('🤖 AI Chat - Using real AI service');
      _handleAIResponse(text.trim());
    } else {
      debugPrint('🔄 AI Chat - Using simulation fallback');
      _simulateAIResponse(text.trim());
    }
  }

  Future<void> _handleAIResponse(String userMessage) async {
    debugPrint('🤖 AI Chat - Handling AI response for: "$userMessage"');
    
    // Add typing indicator
    final typingMessage = ChatMessage(
      id: '${_uuid.v4()}_typing',
      text: '',
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
      isVoiceMessage: false,
    );

    debugPrint('⏳ AI Chat - Adding typing indicator');
    setState(() {
      _messages.add(typingMessage);
    });

    _scrollToBottom();

    try {
      debugPrint('📡 AI Chat - Calling sendMessageStream');
      
      // Use streaming response for better UX
      final responseStream = _aiService!.sendMessageStream(
        userMessage,
        conversationHistory: _getConversationHistory(),
      );

      debugPrint('📡 AI Chat - Stream created, waiting for responses...');

      String accumulatedResponse = '';
      bool isFirstChunk = true;
      String? currentResponseId;
      
      await for (final aiResponse in responseStream) {
        debugPrint('📦 AI Chat - Received AI response chunk');
        debugPrint('📦 Response ID: ${aiResponse.id}');
        debugPrint('📦 Content length: ${aiResponse.content.length}');
        debugPrint('📦 Is streaming: ${aiResponse.isStreaming}');
        debugPrint('📦 Is complete: ${aiResponse.isComplete}');
        debugPrint('📦 Tool calls: ${aiResponse.toolCalls.length}');
        
        if (isFirstChunk) {
          // Remove typing indicator on first chunk
          debugPrint('🗑️ AI Chat - Removing typing indicator');
          if (mounted) {
            setState(() {
              _messages.removeWhere((msg) => msg.id.endsWith('_typing'));
            });
          }
          isFirstChunk = false;
          currentResponseId = aiResponse.id;
        }

        accumulatedResponse = aiResponse.content;
        final previewLength = accumulatedResponse.length > 100 ? 100 : accumulatedResponse.length;
        debugPrint('📝 AI Chat - Accumulated response: ${accumulatedResponse.substring(0, previewLength)}${accumulatedResponse.length > 100 ? '...' : ''}');
        
        // Update or add the AI message
        if (mounted) {
          setState(() {
            final existingIndex = _messages.indexWhere(
              (msg) => msg.id == aiResponse.id && !msg.isFromUser,
            );
            
            final aiMessage = ChatMessage(
              id: aiResponse.id,
              text: accumulatedResponse,
              isFromUser: false,
            timestamp: aiResponse.timestamp ?? DateTime.now(),
            isTyping: !aiResponse.isComplete,
            isVoiceMessage: false,
          );

            if (existingIndex >= 0) {
              debugPrint('🔄 AI Chat - Updating existing message at index $existingIndex');
              _messages[existingIndex] = aiMessage;
            } else {
              debugPrint('➕ AI Chat - Adding new AI message');
              _messages.add(aiMessage);
            }
          });
        }

        _scrollToBottom();
      }

      debugPrint('✅ AI Chat - AI response stream completed');
      debugPrint('✅ Final response length: ${accumulatedResponse.length}');

      if (mounted) {
        setState(() {
          _isAITyping = false;
          _lastError = null;
        });
        
        // Automatically speak the completed AI response
        if (accumulatedResponse.isNotEmpty) {
          debugPrint('🔊 AI Chat - Auto-speaking completed AI response');
          _speakMessage(accumulatedResponse);
        }
      }

    } catch (e) {
      debugPrint('❌ AI Chat - AI response error: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      
      // Remove typing indicator
      if (mounted) {
        setState(() {
          _messages.removeWhere((msg) => msg.id.endsWith('_typing'));
          _isAITyping = false;
          _lastError = 'AI response error: $e';
        });
      }

      // Add error message
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'I apologize, but I encountered an error while processing your request. Please try again or check your network connection.',
        isFromUser: false,
        timestamp: DateTime.now(),
        isTyping: false,
        isVoiceMessage: false,
      );

      debugPrint('📝 AI Chat - Adding error message');
      if (mounted) {
        setState(() {
          _messages.add(errorMessage);
        });
      }
    }

    _scrollToBottom();
  }

  Future<void> _simulateAIResponse(String userMessage) async {
    debugPrint('🔄 AI Chat - Simulating AI response for: "$userMessage"');
    
    // Add typing indicator
    final typingMessage = ChatMessage(
      id: '${_uuid.v4()}_typing',
      text: '',
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
      isVoiceMessage: false,
    );

    debugPrint('⏳ AI Chat - Adding typing indicator (simulation)');
    setState(() {
      _messages.add(typingMessage);
    });

    _scrollToBottom();

    // Simulate processing time
    debugPrint('⏱️ AI Chat - Simulating 2 second delay');
    await Future.delayed(const Duration(seconds: 2));

    // Remove typing indicator
    debugPrint('🗑️ AI Chat - Removing typing indicator (simulation)');
    if (mounted) {
      setState(() {
        _messages.removeWhere((msg) => msg.id.endsWith('_typing'));
        _isAITyping = false;
      });
    }

    // Generate fallback response
    String aiResponse = _generateFallbackResponse(userMessage);
    debugPrint('📝 AI Chat - Generated fallback response: "$aiResponse"');

    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      text: aiResponse,
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: false,
      isVoiceMessage: false,
    );

    if (mounted) {
      setState(() {
        _messages.add(aiMessage);
      });
      
      // Automatically speak the simulated AI response
      debugPrint('🔊 AI Chat - Auto-speaking simulated AI response');
      _speakMessage(aiResponse);
    }

    _scrollToBottom();
    debugPrint('✅ AI Chat - Simulation completed');
  }

  String _generateFallbackResponse(String userMessage) {
    debugPrint('💭 AI Chat - Generating fallback response for: "$userMessage"');
    final lowercaseMessage = userMessage.toLowerCase();
    
    if (!_isAIServiceReady) {
      final fallback = 'I\'m sorry, but my AI capabilities are not available right now. ${_lastError ?? "Please check your internet connection and API configuration."}';
      debugPrint('💭 Fallback (not ready): "$fallback"');
      return fallback;
    }
    
    // Simple response logic for demonstration
    String response;
    if (lowercaseMessage.contains('hello') || lowercaseMessage.contains('hi')) {
      response = 'agent.greeting_response'.tr();
    } else if (lowercaseMessage.contains('balance') || lowercaseMessage.contains('money')) {
      response = 'agent.balance_response'.tr();
    } else if (lowercaseMessage.contains('expense') || lowercaseMessage.contains('spending')) {
      response = 'agent.expense_response'.tr();
    } else if (lowercaseMessage.contains('budget')) {
      response = 'agent.budget_response'.tr();
    } else if (lowercaseMessage.contains('help')) {
      response = 'agent.help_response'.tr();
    } else {
      response = 'agent.default_response'.tr();
    }
    
    debugPrint('💭 Generated response: "$response"');
    return response;
  }

  List<ChatMessage> _getConversationHistory() {
    // Return last 10 messages for context (excluding typing indicators)
    final history = _messages
        .where((msg) => !msg.id.endsWith('_typing'))
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed
        .toList();
    
    debugPrint('📜 AI Chat - Conversation history: ${history.length} messages');
    return history;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _retryAIInitialization() async {
    debugPrint('🔄 AI Chat - Retrying AI initialization');
    setState(() {
      _lastError = null;
      _isAIServiceReady = false;
    });
    await _initializeAIService();
  }

  void _handleTransactionTap(Map<String, dynamic> transaction) {
    debugPrint('💳 AI Chat - Transaction tapped: ${transaction['id']}');
    
    // Show transaction details dialog
    showDialog(
      context: context,
      builder: (context) => _TransactionDetailsDialog(transaction: transaction),
    );
  }


  Future<void> _speakMessage(String message) async {
    debugPrint('🔊 AI Chat - _speakMessage called with: "${message.substring(0, message.length.clamp(0, 50))}${message.length > 50 ? "..." : ""}"');
    
    if (_nativeVoiceService == null) {
      debugPrint('❌ AI Chat - Native voice service not available (null)');
      return;
    }

    debugPrint('🔊 AI Chat - Voice service is available, checking initialization...');
    debugPrint('🔊 AI Chat - Voice service initialized: ${_nativeVoiceService!.isInitialized}');

    try {
      // Clean the message text for TTS (remove special formatting)
      String cleanMessage = message
          .replaceAll(RegExp(r'\[TRANSACTIONS_DATA\].*?\[/TRANSACTIONS_DATA\]', dotAll: true), '')
          .replaceAll(RegExp(r'[•\-\+]'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      debugPrint('🔊 AI Chat - Cleaned message: "${cleanMessage.substring(0, cleanMessage.length.clamp(0, 100))}${cleanMessage.length > 100 ? "..." : ""}"');
      
      if (cleanMessage.isNotEmpty) {
        debugPrint('🔊 AI Chat - Calling voice service speak method...');
        final voiceSettings = AppSettings.getVoiceSettings();
        debugPrint('🔊 AI Chat - Voice settings: language=${voiceSettings.language}, rate=${voiceSettings.speechRate}, volume=${voiceSettings.volume}');
        
        final response = await _nativeVoiceService!.speak(cleanMessage, settings: voiceSettings);
        debugPrint('🔊 AI Chat - Voice service speak completed with status: ${response.status}');
        
        if (response.status == VoiceResponseStatus.error) {
          debugPrint('❌ AI Chat - TTS failed with error: ${response.metadata?['error']}');
        }
      } else {
        debugPrint('⚠️ AI Chat - Cleaned message is empty, skipping TTS');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ AI Chat - Error speaking message: $e');
      debugPrint('❌ AI Chat - Stack trace: $stackTrace');
    }
  }

  Future<void> _testTTS() async {
    debugPrint('🔊 AI Chat - Test TTS button pressed');
    
    if (_nativeVoiceService == null) {
      debugPrint('❌ AI Chat - Voice service not available for test');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice service not available')),
        );
      }
      return;
    }

    try {
      debugPrint('🔊 AI Chat - Running TTS test...');
      final voiceSettings = AppSettings.getVoiceSettings();
      
      // Test with different languages based on current setting
      String testMessage;
      if (voiceSettings.language.startsWith('vi')) {
        testMessage = "Xin chào! Đây là thử nghiệm giọng nói tiếng Việt.";
      } else if (voiceSettings.language.startsWith('es')) {
        testMessage = "¡Hola! Esta es una prueba de voz en español.";
      } else if (voiceSettings.language.startsWith('fr')) {
        testMessage = "Bonjour! Ceci est un test de voix en français.";
      } else {
        testMessage = "Hello! This is a voice test message. TTS is working correctly.";
      }
      
      debugPrint('🔊 AI Chat - Test message: "$testMessage"');
      debugPrint('🔊 AI Chat - Language setting: ${voiceSettings.language}');
      
      final response = await _nativeVoiceService!.speak(testMessage, settings: voiceSettings);
      
      if (response.status == VoiceResponseStatus.completed) {
        debugPrint('✅ AI Chat - TTS test completed successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('TTS test completed successfully!')),
          );
        }
      } else {
        debugPrint('❌ AI Chat - TTS test failed with status: ${response.status}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('TTS test failed: ${response.metadata?['error'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ AI Chat - TTS test error: $e');
      debugPrint('❌ AI Chat - Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('TTS test error: $e')),
        );
      }
    }
  }

  void _showVoiceSettings(BuildContext context) {
    if (_nativeVoiceService == null) return;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _VoiceSettingsSheet(
        currentSettings: AppSettings.getVoiceSettings(),
        voiceService: _nativeVoiceService!,
        onSettingsChanged: (settings) async {
          // Save settings to AppSettings
          await AppSettings.setVoiceSettings(settings);
          // Apply settings to the voice service
          _nativeVoiceService!.updateSettings(settings);
        },
      ),
    );
  }

  String _getLocaleDisplayText(String locale) {
    debugPrint('🎤 AI Chat - Current locale for display: $locale, Voice setting: ${AppSettings.voiceLanguage}');
    
    if (locale.startsWith('vi')) {
      return 'VI';
    } else if (locale.startsWith('en')) {
      return 'EN';
    } else if (locale.startsWith('es')) {
      return 'ES';
    } else if (locale.startsWith('fr')) {
      return 'FR';
    } else if (locale.startsWith('de')) {
      return 'DE';
    } else if (locale.startsWith('zh')) {
      return 'ZH';
    } else if (locale.startsWith('ja')) {
      return 'JA';
    } else if (locale.startsWith('ko')) {
      return 'KO';
    } else {
      return locale.length > 2 ? locale.substring(0, 2).toUpperCase() : locale.toUpperCase();
    }
  }

  @override
  void dispose() {
    _speechService?.removeListener(_onSpeechResult);
    _nativeVoiceService?.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _isAIServiceReady ? Icons.smart_toy : Icons.warning,
              color: _isAIServiceReady ? colorScheme.primary : colorScheme.error,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Financial Assistant'),
                if (!_isAIServiceReady)
                  Text(
                    'Service Unavailable',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          if (_lastError != null)
            IconButton(
              onPressed: _retryAIInitialization,
              icon: Icon(Icons.refresh),
              tooltip: 'Retry AI Service',
            ),
          IconButton(
            onPressed: _nativeVoiceService != null ? () => _testTTS() : null,
            icon: Icon(
              Icons.volume_up,
              color: colorScheme.secondary,
            ),
            tooltip: 'Test TTS',
          ),
          IconButton(
            onPressed: _nativeVoiceService != null ? () => _showVoiceSettings(context) : null,
            icon: Icon(
              Icons.language,
              color: colorScheme.primary,
            ),
            tooltip: 'agent.switch_language'.tr(),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Service Status Bar
          if (_lastError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.errorContainer,
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _retryAIInitialization,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          
          // AI Service Info Bar
          if (_isAIServiceReady)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Powered by Gemini AI • ${AIServiceFactory.toolCount} tools available',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Speech Status Bar
          Consumer<SpeechService>(
            builder: (context, speechService, child) {
              if (!speechService.isListening && speechService.lastWords.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colorScheme.secondaryContainer.withOpacity(0.3),
                child: Row(
                  children: [
                    if (speechService.isListening) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'agent.listening'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (speechService.lastWords.isNotEmpty) ...[
                      Icon(
                        Icons.mic,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          speechService.lastWords,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      _getLocaleDisplayText(speechService.currentLocale),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isAIServiceReady ? Icons.chat_bubble_outline : Icons.error_outline,
                          size: 64,
                          color: (_isAIServiceReady ? colorScheme.onSurfaceVariant : colorScheme.error).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isAIServiceReady ? 'agent.no_messages'.tr() : 'AI service is not available',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _isAIServiceReady ? colorScheme.onSurfaceVariant : colorScheme.error,
                          ),
                        ),
                        if (!_isAIServiceReady) ...[
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _retryAIInitialization,
                            child: Text('Retry Connection'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ChatBubble(
                          message: message.text,
                          isFromUser: message.isFromUser,
                          timestamp: message.timestamp,
                          isVoiceMessage: message.isVoiceMessage,
                          isTyping: message.isTyping,
                          onTransactionTap: _handleTransactionTap,
                          onSpeakMessage: !message.isFromUser ? _speakMessage : null,
                        ),
                      );
                    },
                  ),
          ),
          
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: _isAIServiceReady 
                                ? 'Ask me about your finances...' 
                                : 'agent.type_message'.tr(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (text) => _sendMessage(text),
                          enabled: !_isAITyping,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer<SpeechService>(
                        builder: (context, speechService, child) {
                          return IconButton.filled(
                            onPressed: speechService.isAvailable && !_isAITyping
                                ? () {
                                    if (speechService.isListening) {
                                      speechService.stopListening();
                                    } else {
                                      speechService.startListening();
                                    }
                                  }
                                : null,
                            icon: Icon(
                              speechService.isListening ? Icons.mic_off : Icons.mic,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: speechService.isListening 
                                  ? colorScheme.primary 
                                  : colorScheme.primaryContainer,
                              foregroundColor: speechService.isListening 
                                  ? colorScheme.onPrimary 
                                  : colorScheme.onPrimaryContainer,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _isAITyping ? null : () => _sendMessage(_textController.text),
                        icon: _isAITyping 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Dialog for displaying transaction details with navigation options
class _TransactionDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionDetailsDialog({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final description = transaction['description'] as String? ?? 'Unknown Transaction';
    final date = transaction['date'] as String? ?? 'Unknown Date';
    final category = transaction['category'] as String? ?? 'General';
    final accountName = transaction['account'] as String? ?? 'Unknown Account';
    final transactionId = transaction['id'] as String?;
    
    final isIncome = amount > 0;
    final amountColor = isIncome ? Colors.green : Colors.red;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isIncome ? Icons.trending_up : Icons.trending_down,
                  color: amountColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Transaction Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Amount
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: amountColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isIncome ? '+' : ''}${amount.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Details
            _DetailRow(
              icon: Icons.description,
              label: 'Description',
              value: description,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.category,
              label: 'Category',
              value: category,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.account_balance_wallet,
              label: 'Account',
              value: accountName,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Date',
              value: _formatDate(date),
              theme: theme,
            ),
            
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to transaction edit page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit transaction feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to full transaction page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('View in Transactions page feature coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View Full'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

/// Helper widget for displaying detail rows in transaction dialog
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
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
      // Load SPEECH RECOGNITION languages (STT) from device
      final deviceLanguages = await widget.voiceService.getAvailableSpeechLanguages();
      debugPrint('🎤 Voice Settings - Device speech languages: $deviceLanguages');
      debugPrint('🎤 Voice Settings - Current setting language: ${_settings.language}');
      
      // Create comprehensive language list with common languages (both dash and underscore formats)
      final commonLanguages = [
        'auto',
        // English
        'en-US', 'en-GB', 'en', 'en_US', 'en_GB',
        // Vietnamese - THE MOST IMPORTANT!
        'vi-VN', 'vi', 'vi_VN', 'vietnamese',
        // Spanish
        'es-ES', 'es-MX', 'es', 'es_ES', 'es_MX',
        // French
        'fr-FR', 'fr', 'fr_FR',
        // German  
        'de-DE', 'de', 'de_DE',
        // Italian
        'it-IT', 'it', 'it_IT',
        // Portuguese
        'pt-BR', 'pt', 'pt_BR',
        // Russian
        'ru-RU', 'ru', 'ru_RU',
        // Japanese
        'ja-JP', 'ja', 'ja_JP',
        // Korean
        'ko-KR', 'ko', 'ko_KR',
        // Chinese
        'zh-CN', 'zh-TW', 'zh', 'zh_CN', 'zh_TW',
        // Other languages
        'ar', 'hi', 'th', 'id', 'ms', 'tl', 'tr', 'nl',
        'sv', 'no', 'da', 'fi', 'pl', 'cs', 'sk', 'hu',
        'ro', 'bg', 'hr', 'sl'
      ];
      
      // Create a Set to avoid duplicates
      final languageSet = <String>{};
      
      // Add 'auto' first
      languageSet.add('auto');
      
      // Add device languages (normalize and check against common languages)
      for (final deviceLang in deviceLanguages) {
        if (deviceLang == 'auto') continue;
        
        // Normalize language code (convert underscores to dashes)
        final normalizedLang = _normalizeLanguageCode(deviceLang);
        
        // Check if normalized version is in our common languages or if device lang is
        if (commonLanguages.contains(normalizedLang) || commonLanguages.contains(deviceLang)) {
          languageSet.add(normalizedLang);
        }
        
        debugPrint('🎤 Voice Settings - Device language: $deviceLang -> normalized: $normalizedLang');
      }
      
      // If no Vietnamese variant found in device languages, add vi-VN anyway
      final hasVietnamese = languageSet.any((lang) => lang.startsWith('vi'));
      if (!hasVietnamese) {
        debugPrint('🎤 Voice Settings - Vietnamese not found in device languages, adding vi-VN');
        languageSet.add('vi-VN');
      }
      
      // Ensure current language is in the list
      if (_settings.language != 'auto' && !languageSet.contains(_settings.language)) {
        debugPrint('🎤 Voice Settings - Adding current language ${_settings.language} to available list');
        languageSet.add(_settings.language);
      }
      
      // Convert to sorted list (keeping 'auto' first)
      final sortedLanguages = languageSet.toList();
      sortedLanguages.remove('auto');
      sortedLanguages.sort();
      sortedLanguages.insert(0, 'auto');
      
      setState(() {
        _availableLanguages = sortedLanguages;
        _isLoadingLanguages = false;
      });
      debugPrint('🎤 Voice Settings - Final available languages: $_availableLanguages');
    } catch (e) {
      debugPrint('❌ Voice Settings - Error loading languages: $e');
      setState(() {
        // Fallback to essential languages if loading fails
        _availableLanguages = ['auto', 'en-US', 'vi-VN', 'es-ES', 'fr-FR', 'de-DE', 'zh-CN', 'ja-JP'];
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
              value: _availableLanguages.contains(_settings.language) ? _settings.language : 'auto',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              items: _availableLanguages.map((language) {
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
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply settings and close
                    widget.onSettingsChanged(_settings);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
          
          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String _normalizeLanguageCode(String languageCode) {
    // Convert underscores to dashes (Android often uses en_US instead of en-US)
    String normalized = languageCode.replaceAll('_', '-');
    
    // Handle common variations
    final languageMap = {
      'en': 'en-US',
      'vi': 'vi-VN', 
      'es': 'es-ES',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-BR',
      'ru': 'ru-RU',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
    };
    
    // If it's a simple language code, map it to a region-specific one
    if (languageMap.containsKey(normalized)) {
      normalized = languageMap[normalized]!;
    }
    
    return normalized;
  }

  String _getLanguageDisplayName(String languageCode) {
    if (languageCode == 'auto') {
      return 'Automatic Detection';
    }
    final Map<String, String> languageNames = {
      // English variants
      'en-US': 'English (US) 🇺🇸',
      'en-GB': 'English (UK) 🇬🇧',
      'en': 'English',
      'en_US': 'English (US) 🇺🇸', // Android format
      'en_GB': 'English (UK) 🇬🇧', // Android format
      
      // Spanish variants
      'es-ES': 'Spanish (Spain) 🇪🇸',
      'es-MX': 'Spanish (Mexico) 🇲🇽',
      'es': 'Spanish',
      'es_ES': 'Spanish (Spain) 🇪🇸',
      'es_MX': 'Spanish (Mexico) 🇲🇽',
      
      // French variants
      'fr-FR': 'French (France) 🇫🇷',
      'fr': 'French',
      'fr_FR': 'French (France) 🇫🇷',
      
      // German variants
      'de-DE': 'German (Germany) 🇩🇪',
      'de': 'German',
      'de_DE': 'German (Germany) 🇩🇪',
      
      // Italian variants
      'it-IT': 'Italian (Italy) 🇮🇹',
      'it': 'Italian',
      'it_IT': 'Italian (Italy) 🇮🇹',
      
      // Portuguese variants
      'pt-BR': 'Portuguese (Brazil) 🇧🇷',
      'pt': 'Portuguese',
      'pt_BR': 'Portuguese (Brazil) 🇧🇷',
      
      // Russian variants
      'ru-RU': 'Russian (Russia) 🇷🇺',
      'ru': 'Russian',
      'ru_RU': 'Russian (Russia) 🇷🇺',
      
      // Japanese variants
      'ja-JP': 'Japanese (Japan) 🇯🇵',
      'ja': 'Japanese',
      'ja_JP': 'Japanese (Japan) 🇯🇵',
      
      // Korean variants
      'ko-KR': 'Korean (Korea) 🇰🇷',
      'ko': 'Korean',
      'ko_KR': 'Korean (Korea) 🇰🇷',
      
      // Chinese variants
      'zh-CN': 'Chinese (Simplified) 🇨🇳',
      'zh-TW': 'Chinese (Traditional) 🇹🇼',
      'zh': 'Chinese',
      'zh_CN': 'Chinese (Simplified) 🇨🇳',
      'zh_TW': 'Chinese (Traditional) 🇹🇼',
      
      // Vietnamese variants - THE IMPORTANT ONES!
      'vi-VN': 'Vietnamese (Vietnam) 🇻🇳',
      'vi': 'Vietnamese 🇻🇳',
      'vi_VN': 'Vietnamese (Vietnam) 🇻🇳', // Android format
      'vietnamese': 'Vietnamese 🇻🇳',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'th': 'Thai',
      'id': 'Indonesian',
      'ms': 'Malay',
      'tl': 'Tagalog',
      'tr': 'Turkish',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'no': 'Norwegian',
      'da': 'Danish',
      'fi': 'Finnish',
      'pl': 'Polish',
      'cs': 'Czech',
      'sk': 'Slovak',
      'hu': 'Hungarian',
      'ro': 'Romanian',
      'bg': 'Bulgarian',
      'hr': 'Croatian',
      'sl': 'Slovenian',
      'et': 'Estonian',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'uk': 'Ukrainian',
      'he': 'Hebrew',
      'fa': 'Persian',
      'ur': 'Urdu',
      'bn': 'Bengali',
      'ta': 'Tamil',
      'te': 'Telugu',
      'mr': 'Marathi',
      'gu': 'Gujarati',
      'kn': 'Kannada',
    };
    
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }
}