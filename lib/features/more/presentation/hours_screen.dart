import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/idempotent_submit_button.dart';

/// S11 — Opening hours editor with weekly schedule grid.
class HoursScreen extends ConsumerWidget {
  const HoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opening hours'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IdempotentSubmitButton(
            onPressed: () async {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        children: [
          ...days.map((day) => _DayRow(day: day)),
          const SizedBox(height: AppSizes.spacingL),
          // Closure dates section
          Text(
            'CLOSURES',
            style: AppTextStyles.statLabel.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text('Add closure date'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSizes.touchSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatefulWidget {
  const _DayRow({required this.day});
  final String day;

  @override
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  bool _isOpen = true;
  TimeOfDay _open = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _close = const TimeOfDay(hour: 22, minute: 0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSizes.spacingXS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingS,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                widget.day,
                style: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
              ),
            ),
            Switch(
              value: _isOpen,
              activeColor: AppColors.actionAcceptDark,
              onChanged: (v) => setState(() => _isOpen = v),
            ),
            if (_isOpen) ...[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _TimeButton(
                      time: _open,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _open,
                        );
                        if (t != null) setState(() => _open = t);
                      },
                    ),
                    Text(' – ',
                        style: AppTextStyles.body.copyWith(color: textPrimary)),
                    _TimeButton(
                      time: _close,
                      onTap: () async {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: _close,
                        );
                        if (t != null) setState(() => _close = t);
                      },
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'Closed',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.body.copyWith(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.time, required this.onTap});
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          time.format(context),
          style: AppTextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
