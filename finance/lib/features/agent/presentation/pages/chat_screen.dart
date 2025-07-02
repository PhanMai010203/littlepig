import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/speech_service.dart';
import '../../../../shared/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final _uuid = const Uuid();
  bool _isAITyping = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechService();
    _addWelcomeMessage();
  }

  Future<void> _initializeSpeechService() async {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    await speechService.initialize();
    
    // Listen for speech results
    speechService.addListener(_onSpeechResult);
  }

  void _onSpeechResult() {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    if (speechService.lastWords.isNotEmpty && !speechService.isListening) {
      _sendMessage(speechService.lastWords, isVoiceMessage: true);
      speechService.clearLastWords();
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      text: 'agent.welcome_message'.tr(),
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

    // Simulate AI response
    _simulateAIResponse(text.trim());
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

    // Generate AI response based on user message
    String aiResponse = _generateAIResponse(userMessage);

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

  String _generateAIResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();
    
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

  @override
  void dispose() {
    final speechService = Provider.of<SpeechService>(context, listen: false);
    speechService.removeListener(_onSpeechResult);
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
              Icons.smart_toy,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('agent.chat_assistant'.tr()),
          ],
        ),
        actions: [
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
          // Speech Status Bar
          Consumer<SpeechService>(
            builder: (context, speechService, child) {
              if (!speechService.isListening && speechService.lastWords.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colorScheme.primaryContainer.withOpacity(0.3),
                child: Row(
                  children: [
                    if (speechService.isListening) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'agent.listening'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (speechService.lastWords.isNotEmpty) ...[
                      Icon(
                        Icons.mic,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          speechService.lastWords,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      speechService.currentLocale == 'en_US' ? 'EN' : 'VI',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
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
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'agent.no_messages'.tr(),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                      hintText: 'agent.type_message'.tr(),
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
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<SpeechService>(
                  builder: (context, speechService, child) {
                    return IconButton.filled(
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
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 