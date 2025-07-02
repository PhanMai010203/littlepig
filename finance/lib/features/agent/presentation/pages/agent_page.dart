import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/page_template.dart';
import '../../../agent/domain/entities/speech_service.dart';
import 'ai_chat_screen.dart';

class AgentPage extends StatelessWidget {
  const AgentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'navigation.agent'.tr(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _WelcomeSection(),
              const SizedBox(height: 24),
              const _AIFeaturesSection(),
              const SizedBox(height: 24),
              const _ChatSection(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.psychology,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'agent.welcome_title'.tr(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'agent.welcome_subtitle'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AIFeaturesSection extends StatelessWidget {
  const _AIFeaturesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final features = [
      {
        'icon': Icons.analytics,
        'title': 'agent.feature_analysis_title'.tr(),
        'subtitle': 'agent.feature_analysis_subtitle'.tr(),
      },
      {
        'icon': Icons.lightbulb_outline,
        'title': 'agent.feature_insights_title'.tr(),
        'subtitle': 'agent.feature_insights_subtitle'.tr(),
      },
      {
        'icon': Icons.trending_up,
        'title': 'agent.feature_predictions_title'.tr(),
        'subtitle': 'agent.feature_predictions_subtitle'.tr(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'agent.features_title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FeatureCard(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            subtitle: feature['subtitle'] as String,
          ),
        )),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatSection extends StatelessWidget {
  const _ChatSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 350,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.smart_toy,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'agent.chat_assistant'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Consumer<SpeechService>(
                builder: (context, speechService, child) {
                  return Icon(
                    speechService.isListening 
                        ? Icons.mic 
                        : Icons.mic_none,
                    color: speechService.isListening 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Preview Chat Area
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  // Sample message bubbles for preview
                  _PreviewChatBubble(
                    text: 'agent.sample_user_message'.tr(),
                    isFromUser: true,
                    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
                  ),
                  const SizedBox(height: 12),
                  _PreviewChatBubble(
                    text: 'agent.sample_ai_message'.tr(),
                    isFromUser: false,
                    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
                  ),
                  const Spacer(),
                  
                  // Features highlight
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'agent.voice_support'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.language,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'agent.bilingual_support'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (context) => SpeechService(),
                          child: const AIChatScreen(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat),
                  label: Text('agent.start_chat'.tr()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Consumer<SpeechService>(
                builder: (context, speechService, child) {
                  return IconButton.filled(
                    onPressed: () async {
                      if (!speechService.isInitialized) {
                        await speechService.initialize();
                      }
                      
                      if (speechService.isListening) {
                        speechService.stopListening();
                      } else {
                        speechService.startListening();
                      }
                    },
                    icon: Icon(
                      speechService.isListening ? Icons.mic_off : Icons.mic,
                    ),
                    tooltip: speechService.isListening 
                        ? 'agent.stop_listening'.tr() 
                        : 'agent.start_listening'.tr(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewChatBubble extends StatelessWidget {
  const _PreviewChatBubble({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
  });

  final String text;
  final bool isFromUser;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFromUser 
              ? colorScheme.primary 
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isFromUser ? const Radius.circular(4) : null,
            bottomLeft: !isFromUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isFromUser 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat.Hm().format(timestamp),
              style: theme.textTheme.bodySmall?.copyWith(
                color: (isFromUser 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurfaceVariant).withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 