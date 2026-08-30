import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String role;
  final String email;
  final bool isActive;
}

/// S12 — Staff management list.
class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  static const _staff = [
    StaffMember(id: 1, name: 'Kamal Hossain', role: 'Manager', email: 'kamal@resto.bd'),
    StaffMember(id: 2, name: 'Rina Begum', role: 'Kitchen staff', email: 'rina@resto.bd'),
    StaffMember(id: 3, name: 'Sohel Rana', role: 'Delivery rider', email: 'sohel@resto.bd',
        isActive: false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Invite staff',
            onPressed: () => _showInviteSheet(context),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        itemCount: _staff.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.spacingXS),
        itemBuilder: (ctx, i) => _StaffTile(member: _staff[i]),
      ),
    );
  }

  void _showInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InviteSheet(),
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.member});
  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Card(
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              member.isActive ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.2),
          child: Text(
            member.name.substring(0, 1),
            style: AppTextStyles.bodyMedium.copyWith(
              color: member.isActive ? AppColors.primary : Colors.grey,
            ),
          ),
        ),
        title: Text(member.name,
            style: AppTextStyles.body.copyWith(color: textPrimary)),
        subtitle: Text('${member.role} · ${member.email}',
            style: AppTextStyles.dense.copyWith(color: textSecondary)),
        trailing: member.isActive
            ? null
            : Text('Inactive',
                style: AppTextStyles.caption.copyWith(color: Colors.grey)),
      ),
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.spacingL,
        left: AppSizes.spacingM,
        right: AppSizes.spacingM,
        top: AppSizes.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            'Invite staff member',
            style: AppTextStyles.titleS.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSizes.touchPrimary),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
            ),
            child: Text(
              'Send invite',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
