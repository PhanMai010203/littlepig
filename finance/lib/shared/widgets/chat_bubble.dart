import 'dart:convert';
import 'package:flutter/material.dart';
import 'transaction_chat_card.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFromUser,
    required this.timestamp,
    this.isVoiceMessage = false,
    this.isTyping = false,
    this.onTransactionTap,
  });

  final String message;
  final bool isFromUser;
  final DateTime timestamp;
  final bool isVoiceMessage;
  final bool isTyping;
  final Function(Map<String, dynamic>)? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isFromUser ? 64.0 : 16.0,
        4,
        isFromUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isFromUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isFromUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isVoiceMessage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            size: 14,
                            color: isFromUser 
                                ? colorScheme.onPrimaryContainer 
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Voice message',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isFromUser 
                                  ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isTyping)
                    _TypingIndicator(
                      color: isFromUser 
                          ? colorScheme.onPrimaryContainer 
                          : colorScheme.onSurfaceVariant,
                    )
                  else
                    _buildMessageContent(theme, colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme, ColorScheme colorScheme) {
    // Check if message contains structured transaction data
    if (!isFromUser && message.contains('[TRANSACTIONS_DATA]')) {
      return _buildRichTransactionContent(theme, colorScheme);
    }
    
    // Default text message
    return Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isFromUser 
            ? colorScheme.onPrimaryContainer 
            : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildRichTransactionContent(ThemeData theme, ColorScheme colorScheme) {
    try {
      // Extract transaction data from message
      const startTag = '[TRANSACTIONS_DATA]';
      const endTag = '[/TRANSACTIONS_DATA]';
      
      final startIndex = message.indexOf(startTag);
      final endIndex = message.indexOf(endTag);
      
      // Validate that both tags exist and appear in the expected order.
      // We also ensure that there is at least one character between the tags
      // (startTag.length is added to startIndex to represent the first
      // character after the start tag). If any of these conditions fail we
      // fall back to rendering plain text to avoid a RangeError.
      if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex + startTag.length) {
        return _buildFallbackText(theme, colorScheme);
      }
      
      final dataJson = message.substring(
        startIndex + startTag.length,
        endIndex,
      ).trim();
      
      final transactionList = jsonDecode(dataJson) as List;
      final transactions = transactionList.cast<Map<String, dynamic>>();
      
      // Extract readable text (everything after the data block)
      final textPart = message.substring(endIndex + endTag.length).trim();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rich transaction display
          if (transactions.isNotEmpty)
            TransactionListChatWidget(
              transactions: transactions,
              title: 'Transactions Found',
              onTransactionTap: onTransactionTap,
            ),
          
          // Readable text part
          if (textPart.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              textPart,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      );
    } catch (e) {
      // Fallback to regular text if parsing fails
      return _buildFallbackText(theme, colorScheme);
    }
  }

  Widget _buildFallbackText(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isFromUser 
            ? colorScheme.onPrimaryContainer 
            : colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.color});

  final Color color;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_animation.value + delay) % 1.0;
            final opacity = (animationValue < 0.5) 
                ? animationValue * 2 
                : (1.0 - animationValue) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
} 