import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/api/router.dart';

/// More tab — entry point to hours, staff, settings, history, reviews.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          _SectionHeader(title: 'Restaurant'),
          _MoreTile(
            icon: Icons.schedule,
            title: 'Opening hours',
            subtitle: 'Set weekly schedule and closures',
            onTap: () => context.push('/more/hours'),
          ),
          _MoreTile(
            icon: Icons.people_outline,
            title: 'Staff',
            subtitle: 'Manage team members',
            onTap: () => context.push('/more/staff'),
          ),
          const SizedBox(height: AppSizes.spacingM),
          _SectionHeader(title: 'Activity'),
          _MoreTile(
            icon: Icons.history,
            title: 'Order history',
            subtitle: 'Search and export past orders',
            onTap: () => context.push('/more/history'),
          ),
          _MoreTile(
            icon: Icons.star_outline,
            title: 'Reviews',
            subtitle: 'Read and reply to customer feedback',
            onTap: () => context.push('/more/reviews'),
          ),
          const SizedBox(height: AppSizes.spacingM),
          _SectionHeader(title: 'Preferences'),
          _MoreTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Dark mode, alert sounds, shift toggle',
            onTap: () => context.push('/more/settings'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSizes.spacingXS,
        top: AppSizes.spacingS,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.statLabel.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingXS),
      child: ListTile(
        minVerticalPadding: AppSizes.spacingM,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTextStyles.body.copyWith(color: textPrimary)),
        subtitle: Text(subtitle,
            style: AppTextStyles.dense.copyWith(color: textSecondary)),
        trailing: Icon(Icons.chevron_right,
            color: textSecondary.withOpacity(0.5)),
        onTap: onTap,
      ),
    );
  }
}
