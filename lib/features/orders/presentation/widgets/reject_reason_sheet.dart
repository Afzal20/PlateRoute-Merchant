import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/orders_repository.dart';

/// FR-ORD-03 reject reason sheet.
/// Single-select chips; confirm button inside sheet bottom.
/// Two deliberate steps separate regret from rashness.
class RejectReasonSheet extends StatefulWidget {
  const RejectReasonSheet({super.key, required this.onConfirm});

  final Future<void> Function(RejectReason reason, String? note) onConfirm;

  @override
  State<RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<RejectReasonSheet> {
  RejectReason? _selected;
  final _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  static const _reasons = [
    (RejectReason.outOfStock, 'Out of stock'),
    (RejectReason.tooBusy, 'Too busy'),
    (RejectReason.closingSoon, 'Closing soon'),
    (RejectReason.cannotDeliverArea, 'Cannot deliver to area'),
    (RejectReason.other, 'Other reason'),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
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
          // Drag handle
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
          // Header in reject surface tint
          Container(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            decoration: BoxDecoration(
              color: AppColors.rejectSurface,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: AppColors.rejectOutline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.rejectOutline, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tell us why to inform the customer',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.rejectOutline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          // Reason chips — single select
          Wrap(
            spacing: AppSizes.spacingS,
            runSpacing: AppSizes.spacingS,
            children: _reasons.map((entry) {
              final (reason, label) = entry;
              final isSelected = _selected == reason;
              return FilterChip(
                label: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => setState(() => _selected = reason),
                selectedColor: AppColors.rejectOutline,
                checkmarkColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingS,
                  vertical: AppSizes.spacingXS,
                ),
              );
            }).toList(),
          ),
          if (_selected == RejectReason.other) ...[
            const SizedBox(height: AppSizes.spacingM),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Optional note for customer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingL),
          // Confirm button — disabled until reason selected
          SizedBox(
            height: AppSizes.touchPrimary,
            child: FilledButton(
              onPressed: _selected == null || _isSubmitting
                  ? null
                  : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lateAlarm,
                disabledBackgroundColor: AppColors.lateAlarm.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm reject',
                      style: AppTextStyles.button.copyWith(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_selected == null) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onConfirm(
        _selected!,
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
