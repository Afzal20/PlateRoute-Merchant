import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_state_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final status = authState.vendorStatus ?? 'pending';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account status'),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(authStateProvider.notifier).signOut(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            _StatusPipelineCard(status: status),
            const SizedBox(height: AppSizes.spacingL),
            _statusBody(status, textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _statusBody(String status, Color textSecondary) {
    String message;
    switch (status) {
      case 'pending':
        message = 'Our team is reviewing your application. We\'ll notify you when approved.';
      case 'paused':
        message = 'Your account has been paused. Please contact support.';
      default:
        message = 'Your account is active.';
    }
    return Text(
      message,
      style: AppTextStyles.body.copyWith(color: textSecondary),
      textAlign: TextAlign.center,
    );
  }
}

class _StatusPipelineCard extends StatelessWidget {
  const _StatusPipelineCard({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final steps = ['Draft', 'Pending review', 'Approved'];
    final currentStep = status == 'pending' ? 1 : status == 'approved' ? 2 : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(
          color: _borderColor(status).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          children: [
            _statusIcon(status),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              _statusLabel(status),
              style: AppTextStyles.titleS.copyWith(color: _borderColor(status)),
            ),
            const SizedBox(height: AppSizes.spacingL),
            // Pipeline indicator
            Row(
              children: List.generate(steps.length, (i) {
                final isActive = i <= currentStep;
                final isDone = i < currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      if (i > 0)
                        Expanded(
                          child: Container(
                            height: 2,
                            color: isDone ? AppColors.success : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.success
                                  : i == currentStep
                                      ? AppColors.primary
                                      : Colors.grey.withOpacity(0.3),
                            ),
                            child: Icon(
                              isDone ? Icons.check : Icons.circle,
                              size: 14,
                              color: isActive ? Colors.white : Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            steps[i],
                            style: AppTextStyles.caption.copyWith(
                              color: isActive
                                  ? (Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight)
                                  : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'paused':
        return AppColors.lateAlarm;
      default:
        return AppColors.queuePulse;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Account Active';
      case 'paused':
        return 'Account Paused';
      default:
        return 'Pending Review';
    }
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return const Icon(Icons.check_circle, color: AppColors.success, size: 64);
      case 'paused':
        return const Icon(Icons.pause_circle, color: AppColors.lateAlarm, size: 64);
      default:
        return const Icon(Icons.hourglass_top, color: AppColors.queuePulse, size: 64);
    }
  }
}
