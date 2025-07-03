import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/speech_service.dart';
import '../../domain/services/ai_service.dart';
import '../../data/services/ai_service_factory.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _initializeSpeechService();
      await _initializeAIService();
      _addWelcomeMessage();
    } catch (e) {
      setState(() {
        _lastError = 'Failed to initialize services: $e';
      });
    }
  }

  Future<void> _initializeSpeechService() async {
    _speechService = Provider.of<SpeechService>(context, listen: false);
    await _speechService!.initialize();
    
    // Listen for speech results
    _speechService!.addListener(_onSpeechResult);
  }

  Future<void> _initializeAIService() async {
    try {
      _aiService = await AIServiceFactory.getInstance();
      setState(() {
        _isAIServiceReady = AIServiceFactory.isReady;
        _lastError = null;
      });
    } catch (e) {
      setState(() {
        _isAIServiceReady = false;
        _lastError = 'AI Service initialization failed: $e';
      });
    }
  }

  void _onSpeechResult() {
    if (_speechService == null) return;

    if (_speechService!.lastWords.isNotEmpty && !_speechService!.isListening) {
      _sendMessage(_speechService!.lastWords, isVoiceMessage: true);
      _speechService!.clearLastWords();
    }
  }

  void _addWelcomeMessage() {
    final toolCount = AIServiceFactory.toolCount;
    final welcomeText = _isAIServiceReady 
        ? 'Hello! I\'m your AI financial assistant powered by Gemini. I have access to $toolCount tools to help you manage your finances. Ask me about your transactions, budgets, accounts, or categories!'
        : 'agent.welcome_message'.tr();
    
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
  }

  void _sendMessage(String text, {bool isVoiceMessage = false}) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: text.trim(),
      isFromUser: true,
      timestamp: DateTime.now(),
      isTyping: false,
      isVoiceMessage: isVoiceMessage,
    );

    setState(() {
      _messages.add(userMessage);
      _isAITyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Use real AI service or fallback to simulation
    if (_isAIServiceReady && _aiService != null) {
      _handleAIResponse(text.trim());
    } else {
      _simulateAIResponse(text.trim());
    }
  }

  Future<void> _handleAIResponse(String userMessage) async {
    // Add typing indicator
    final typingMessage = ChatMessage(
      id: '${_uuid.v4()}_typing',
      text: '',
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
      isVoiceMessage: false,
    );

    setState(() {
      _messages.add(typingMessage);
    });

    _scrollToBottom();

    try {
      // Use streaming response for better UX
      final responseStream = _aiService!.sendMessageStream(
        userMessage,
        conversationHistory: _getConversationHistory(),
      );

      String accumulatedResponse = '';
      bool isFirstChunk = true;
      
      await for (final aiResponse in responseStream) {
        if (isFirstChunk) {
          // Remove typing indicator on first chunk
          setState(() {
            _messages.removeWhere((msg) => msg.id.endsWith('_typing'));
          });
          isFirstChunk = false;
        }

        accumulatedResponse = aiResponse.content;
        
        // Update or add the AI message
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
            _messages[existingIndex] = aiMessage;
          } else {
            _messages.add(aiMessage);
          }
        });

        _scrollToBottom();
      }

      setState(() {
        _isAITyping = false;
        _lastError = null;
      });

    } catch (e) {
      // Remove typing indicator
      setState(() {
        _messages.removeWhere((msg) => msg.id.endsWith('_typing'));
        _isAITyping = false;
        _lastError = 'AI response error: $e';
      });

      // Add error message
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'I apologize, but I encountered an error while processing your request. Please try again or check your network connection.',
        isFromUser: false,
        timestamp: DateTime.now(),
        isTyping: false,
        isVoiceMessage: false,
      );

      setState(() {
        _messages.add(errorMessage);
      });
    }

    _scrollToBottom();
  }

  Future<void> _simulateAIResponse(String userMessage) async {
    // Add typing indicator
    final typingMessage = ChatMessage(
      id: '${_uuid.v4()}_typing',
      text: '',
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: true,
      isVoiceMessage: false,
    );

    setState(() {
      _messages.add(typingMessage);
    });

    _scrollToBottom();

    // Simulate processing time
    await Future.delayed(const Duration(seconds: 2));

    // Remove typing indicator
    setState(() {
      _messages.removeWhere((msg) => msg.id.endsWith('_typing'));
      _isAITyping = false;
    });

    // Generate fallback response
    String aiResponse = _generateFallbackResponse(userMessage);

    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      text: aiResponse,
      isFromUser: false,
      timestamp: DateTime.now(),
      isTyping: false,
      isVoiceMessage: false,
    );

    setState(() {
      _messages.add(aiMessage);
    });

    _scrollToBottom();
  }

  String _generateFallbackResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();
    
    if (!_isAIServiceReady) {
      return 'I\'m sorry, but my AI capabilities are not available right now. ${_lastError ?? "Please check your internet connection and API configuration."}';
    }
    
    // Simple response logic for demonstration
    if (lowercaseMessage.contains('hello') || lowercaseMessage.contains('hi')) {
      return 'agent.greeting_response'.tr();
    } else if (lowercaseMessage.contains('balance') || lowercaseMessage.contains('money')) {
      return 'agent.balance_response'.tr();
    } else if (lowercaseMessage.contains('expense') || lowercaseMessage.contains('spending')) {
      return 'agent.expense_response'.tr();
    } else if (lowercaseMessage.contains('budget')) {
      return 'agent.budget_response'.tr();
    } else if (lowercaseMessage.contains('help')) {
      return 'agent.help_response'.tr();
    } else {
      return 'agent.default_response'.tr();
    }
  }

  List<ChatMessage> _getConversationHistory() {
    // Return last 10 messages for context (excluding typing indicators)
    return _messages
        .where((msg) => !msg.id.endsWith('_typing'))
        .toList()
        .reversed
        .take(10)
        .toList()
        .reversed
        .toList();
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
    setState(() {
      _lastError = null;
      _isAIServiceReady = false;
    });
    
    try {
      await AIServiceFactory.reset();
      await _initializeAIService();
    } catch (e) {
      setState(() {
        _lastError = 'Retry failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _speechService?.removeListener(_onSpeechResult);
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
          Consumer<SpeechService>(
            builder: (context, speechService, child) {
              return IconButton(
                onPressed: () {
                  speechService.switchLocale();
                },
                icon: Icon(
                  Icons.language,
                  color: colorScheme.primary,
                ),
                tooltip: 'agent.switch_language'.tr(),
              );
            },
          ),
          Consumer<SpeechService>(
            builder: (context, speechService, child) {
              return IconButton(
                onPressed: speechService.isAvailable
                    ? () {
                        if (speechService.isListening) {
                          speechService.stopListening();
                        } else {
                          speechService.startListening();
                        }
                      }
                    : null,
                icon: Icon(
                  speechService.isListening ? Icons.mic : Icons.mic_none,
                  color: speechService.isListening 
                      ? colorScheme.primary 
                      : colorScheme.onSurfaceVariant,
                ),
                tooltip: speechService.isListening 
                    ? 'agent.stop_listening'.tr() 
                    : 'agent.start_listening'.tr(),
              );
            },
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
                      speechService.currentLocale == 'en_US' ? 'EN' : 'VI',
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