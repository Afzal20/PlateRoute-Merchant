import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class MoneyScreen extends ConsumerWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppBar(title: const Text('Payouts')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current period card
            _PeriodCard(
              title: 'Current period',
              grossMinor: 124500,
              commissionBps: 1200,
              netMinor: 109560,
              isDark: isDark,
            ),
            const SizedBox(height: AppSizes.spacingM),
            // Today vs yesterday delta
            _DeltaRow(
              todayMinor: 28400,
              yesterdayMinor: 22000,
              isDark: isDark,
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'Past periods',
              style: AppTextStyles.titleS.copyWith(color: textPrimary),
            ),
            const SizedBox(height: AppSizes.spacingS),
            // Historical periods list
            ...List.generate(4, (i) {
              final months = ['July 2026', 'June 2026', 'May 2026', 'April 2026'];
              return _HistoricalPeriodTile(
                period: months[i],
                netMinor: (90000 + i * 15000),
                isDark: isDark,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({
    required this.title,
    required this.grossMinor,
    required this.commissionBps,
    required this.netMinor,
    required this.isDark,
  });

  final String title;
  final int grossMinor;
  final int commissionBps;
  final int netMinor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final pct = (commissionBps / 100).toStringAsFixed(0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption.copyWith(color: textSecondary)),
            const SizedBox(height: AppSizes.spacingS),
            _MoneyLine(
              label: 'Gross sales',
              minor: grossMinor,
              textSecondary: textSecondary,
              textPrimary: textPrimary,
            ),
            const SizedBox(height: 6),
            _MoneyLine(
              label: 'Platform fee $pct%',
              minor: -(grossMinor * commissionBps ~/ 10000),
              textSecondary: textSecondary,
              textPrimary: AppColors.lateAlarm,
              isDeduction: true,
            ),
            const Divider(height: AppSizes.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your cut after platform fee',
                  style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
                ),
                Text(
                  '৳${(netMinor / 100).toStringAsFixed(0)}',
                  style: AppTextStyles.titleS.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.label,
    required this.minor,
    required this.textSecondary,
    required this.textPrimary,
    this.isDeduction = false,
  });

  final String label;
  final int minor;
  final Color textSecondary;
  final Color textPrimary;
  final bool isDeduction;

  @override
  Widget build(BuildContext context) {
    final amount = minor.abs() / 100;
    final formatted = '${isDeduction ? '-' : ''}৳${amount.toStringAsFixed(0)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: textSecondary)),
        Text(formatted, style: AppTextStyles.price.copyWith(color: textPrimary)),
      ],
    );
  }
}

class _DeltaRow extends StatelessWidget {
  const _DeltaRow({
    required this.todayMinor,
    required this.yesterdayMinor,
    required this.isDark,
  });

  final int todayMinor;
  final int yesterdayMinor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final diff = todayMinor - yesterdayMinor;
    final isUp = diff >= 0;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: (isUp ? AppColors.success : AppColors.lateAlarm).withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          color: (isUp ? AppColors.success : AppColors.lateAlarm).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            color: isUp ? AppColors.success : AppColors.lateAlarm,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Today vs yesterday same weekday: ${isUp ? '+' : ''}৳${(diff / 100).toStringAsFixed(0)}',
              style: AppTextStyles.body.copyWith(color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoricalPeriodTile extends StatelessWidget {
  const _HistoricalPeriodTile({
    required this.period,
    required this.netMinor,
    required this.isDark,
  });

  final String period;
  final int netMinor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return _PayoutPeriodCard(
      period: period,
      netMinor: netMinor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );
  }
}

class _PayoutPeriodCard extends StatelessWidget {
  const _PayoutPeriodCard({
    required this.period,
    required this.netMinor,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String period;
  final int netMinor;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
      child: ListTile(
        minVerticalPadding: AppSizes.spacingM,
        title: Text(period, style: AppTextStyles.body.copyWith(color: textPrimary)),
        subtitle: Text(
          'Net ৳${(netMinor / 100).toStringAsFixed(0)}',
          style: AppTextStyles.dense.copyWith(color: textSecondary),
        ),
        trailing: TextButton.icon(
          onPressed: () {
            // Open invoice PDF (FR-PAY-07)
          },
          icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: Text(
            'Invoice',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
