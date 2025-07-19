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
          
          const _SectionHeader(title: 'Account'),
          _MenuItem(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your profile information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile tapped')),
              );
            },
          ),
          _MenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences and configurations',
            onTap: () {
              context.push('/settings');
            },
          ),
          _MenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications tapped')),
              );
            },
          ),
          const _SectionHeader(title: 'Data & Sync'),
          _SyncMenuItem(
            onTap: () {
              context.push('/sync');
            },
          ),
          const _SectionHeader(title: 'Analytics'),
          _MenuItem(
            icon: Icons.analytics,
            title: 'Reports',
            subtitle: 'View detailed financial reports',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reports tapped')),
              );
            },
          ),
          _MenuItem(
            icon: Icons.trending_up,
            title: 'Goals',
            subtitle: 'Track your financial goals',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goals tapped')),
              );
            },
          ),
          const _SectionHeader(title: 'Developer'),
          _MenuItem(
            icon: Icons.developer_mode,
            title: 'Framework Demo',
            subtitle: 'Explore all framework capabilities',
            onTap: () {
              context.push('/demo');
            },
          ),
          const _SectionHeader(title: 'Support'),
          _MenuItem(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help tapped')),
              );
            },
          ),
          _MenuItem(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About tapped')),
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
        title,
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
      title: Text(title),
      subtitle: Text(subtitle),
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
      title: const Text('Sync'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Manage data synchronization and backup'),
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
