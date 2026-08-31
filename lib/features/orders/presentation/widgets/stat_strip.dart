import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Exactly 3 tabular stat slots: new orders / active / late today.
/// Numbers Bold 20, overline captions 11 uppercase.
class StatStrip extends StatelessWidget {
  const StatStrip({
    super.key,
    required this.newOrders,
    required this.activeOrders,
    required this.lateToday,
  });

  final int newOrders;
  final int activeOrders;
  final int lateToday;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingM,
      ),
      child: Row(
        children: [
          _Slot(label: 'NEW', value: newOrders, color: AppColors.queuePulse),
          _Divider(),
          _Slot(label: 'ACTIVE', value: activeOrders, color: AppColors.primary),
          _Divider(),
          _Slot(label: 'LATE', value: lateToday, color: AppColors.lateAlarm),
        ],
      ),
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.statLabel.copyWith(color: textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: AppTextStyles.statNumber.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.divider.withOpacity(0.3),
    );
  }
}
