import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/settings_provider.dart';

/// S13 — Settings: dark mode, sound families, shift-online toggle.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          _SettingsSection(
            title: 'Display',
            children: [
              SwitchListTile(
                title: Text('Dark mode', style: AppTextStyles.body.copyWith(color: textPrimary)),
                subtitle: Text('Default ON for kitchen use',
                    style: AppTextStyles.dense.copyWith(color: textSecondary)),
                value: themeMode == ThemeMode.dark,
                activeColor: AppColors.primary,
                onChanged: (v) {
                  ref.read(themeModeProvider.notifier).setMode(
                        v ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          _SettingsSection(
            title: 'Alert sounds',
            children: [
              _SoundFamilyTile(
                family: 'Family A',
                description: 'Two-note rising chime — new orders',
                isSelected: true,
                onTap: () {},
              ),
              _SoundFamilyTile(
                family: 'Family B',
                description: 'Soft double-tick — order reminders',
                isSelected: false,
                onTap: () {},
              ),
              _SoundFamilyTile(
                family: 'Family C',
                description: 'Descending pair — late deadline',
                isSelected: false,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          _SettingsSection(
            title: 'Shift',
            children: [
              SwitchListTile(
                title: Text('Shift online',
                    style: AppTextStyles.body.copyWith(color: textPrimary)),
                subtitle: Text(
                  'Override: keeps alarm volume above media stream while online',
                  style: AppTextStyles.dense.copyWith(color: textSecondary),
                ),
                value: true,
                activeColor: AppColors.actionAcceptDark,
                onChanged: (v) {
                  // TODO: POST to branch is_accepting toggle
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.spacingXS),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.statLabel.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SoundFamilyTile extends StatelessWidget {
  const _SoundFamilyTile({
    required this.family,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String family;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      title: Text(family, style: AppTextStyles.body.copyWith(color: textPrimary)),
      subtitle: Text(description,
          style: AppTextStyles.dense.copyWith(color: textSecondary)),
      trailing: isSelected
          ? const Icon(Icons.radio_button_checked, color: AppColors.primary)
          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      onTap: onTap,
    );
  }
}
