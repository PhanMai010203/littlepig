import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isFromUser,
    required this.timestamp,
    this.isVoiceMessage = false,
    this.isTyping = false,
  });

  final String message;
  final bool isFromUser;
  final DateTime timestamp;
  final bool isVoiceMessage;
  final bool isTyping;

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
                    : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isFromUser ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isFromUser ? const Radius.circular(4) : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                                  ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                                  : colorScheme.onSurfaceVariant.withOpacity(0.7),
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
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isFromUser 
                            ? colorScheme.onPrimaryContainer 
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
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