import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/sync_status_compact_widget.dart';
import '../widgets/sheep_premium_banner.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('navigation.more'.tr()),
      ),
      body: ListView(
        children: [
          // Premium Banner at top
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: SheepPremiumBanner(),
          ),
          
          const _SectionHeader(title: 'more.sections.account'),
          _MenuItem(
            icon: Icons.person,
            title: 'more.items.profile',
            subtitle: 'more.items.profile_subtitle',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('more.actions.profile_tapped'.tr())),
              );
            },
          ),
          _MenuItem(
            icon: Icons.settings,
            title: 'more.items.settings',
            subtitle: 'more.items.settings_subtitle',
            onTap: () {
              context.push('/settings');
            },
          ),
          _MenuItem(
            icon: Icons.notifications,
            title: 'more.items.notifications',
            subtitle: 'more.items.notifications_subtitle',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('more.actions.notifications_tapped'.tr())),
              );
            },
          ),
          const _SectionHeader(title: 'more.sections.data_sync'),
          _SyncMenuItem(
            onTap: () {
              context.push('/sync');
            },
          ),
          const _SectionHeader(title: 'more.sections.analytics'),
          _MenuItem(
            icon: Icons.analytics,
            title: 'more.items.reports',
            subtitle: 'more.items.reports_subtitle',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('more.actions.reports_tapped'.tr())),
              );
            },
          ),
          _MenuItem(
            icon: Icons.trending_up,
            title: 'more.items.goals',
            subtitle: 'more.items.goals_subtitle',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('more.actions.goals_tapped'.tr())),
              );
            },
          ),
          const _SectionHeader(title: 'more.sections.developer'),
          _MenuItem(
            icon: Icons.developer_mode,
            title: 'more.items.framework_demo',
            subtitle: 'more.items.framework_demo_subtitle',
            onTap: () {
              context.push('/demo');
            },
          ),
          const _SectionHeader(title: 'more.sections.support'),
          _MenuItem(
            icon: Icons.help,
            title: 'more.items.help_support',
            subtitle: 'more.items.help_support_subtitle',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('more.actions.help_tapped'.tr())),
              );
            },
          ),
          _MenuItem(
            icon: Icons.info,
            title: 'more.items.about',
            subtitle: 'more.items.about_subtitle',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('more.actions.about_tapped'.tr())),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.tr(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(title.tr()),
      subtitle: Text(subtitle.tr()),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SyncMenuItem extends StatelessWidget {
  const _SyncMenuItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.sync,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text('more.items.sync'.tr()),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('more.items.sync_subtitle'.tr()),
          const SizedBox(height: 4),
          const SyncStatusCompactWidget(),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
