import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/countdown_ring.dart';
import '../data/order_model.dart';

/// Card representing a single order on the board.
/// Left urgency border color determined by bucket.
/// Semantics label: "Accept order {num}, {N} items, {total}, auto cancel in {s} seconds"
class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.isReconnecting,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onStageChange,
  });

  final Order order;
  final bool isReconnecting;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final void Function(OrderStatus newStatus)? onStageChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucket = order.status.bucket;
    final borderColor = _bucketBorderColor(bucket, order.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final secs = order.acceptWindowSeconds ?? 0;
    final totalSecs = 300; // default 5-minute accept window

    return Semantics(
      label: 'Order ${order.displayNumber}, '
          '${order.items.length} items, '
          '${order.formattedTotal}, '
          '${bucket == OrderBucket.actNow ? 'auto cancel in $secs seconds' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingS,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: AppSizes.urgencyBorderWidth,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: order number + countdown ring
                Row(
                  children: [
                    // Order number stamp — monospaced Bold
                    Expanded(
                      child: Text(
                        '#${order.displayNumber}',
                        style: AppTextStyles.orderNumber.copyWith(color: textPrimary),
                      ),
                    ),
                    if (bucket == OrderBucket.actNow)
                      CountdownRing(
                        remainingSeconds: secs,
                        totalSeconds: totalSecs,
                        isReconnecting: isReconnecting,
                      ),
                    if (bucket == OrderBucket.inKitchen)
                      _StatusChip(status: order.status),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingS),
                // Item summary
                Text(
                  order.itemSummary,
                  style: AppTextStyles.body.copyWith(color: textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSizes.spacingXS),
                // Total
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.titleS.copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSizes.spacingM),
                // Action buttons
                if (bucket == OrderBucket.actNow && onAccept != null)
                  _ActNowButtons(
                    onAccept: onAccept!,
                    onReject: onReject,
                  ),
                if (bucket == OrderBucket.inKitchen && onStageChange != null)
                  _StageButtons(
                    status: order.status,
                    onStageChange: onStageChange!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _bucketBorderColor(OrderBucket bucket, OrderStatus status) {
    switch (bucket) {
      case OrderBucket.actNow:
        return AppColors.queuePulse;
      case OrderBucket.inKitchen:
        return status == OrderStatus.preparing
            ? AppColors.borderInKitchen
            : AppColors.success;
      case OrderBucket.scheduled:
        return AppColors.info;
      case OrderBucket.history:
        return Colors.grey;
    }
  }
}

class _ActNowButtons extends StatelessWidget {
  const _ActNowButtons({required this.onAccept, this.onReject});
  final VoidCallback onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: AppSizes.touchPrimary,
            child: FilledButton(
              onPressed: onAccept,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.actionAcceptDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Text(
                'Accept',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        if (onReject != null) ...[
          const SizedBox(width: AppSizes.spacingS),
          SizedBox(
            height: AppSizes.touchPrimary,
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.rejectOutline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Text(
                'Reject',
                style: AppTextStyles.button.copyWith(color: AppColors.rejectOutline),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Stage progression buttons — PREPARING -> READY (guarded)
class _StageButtons extends StatelessWidget {
  const _StageButtons({required this.status, required this.onStageChange});
  final OrderStatus status;
  final void Function(OrderStatus) onStageChange;

  @override
  Widget build(BuildContext context) {
    final allowed = status.allowedTransitions;
    if (allowed.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: AppSizes.touchSecondary,
      child: FilledButton.icon(
        onPressed: () => onStageChange(allowed.first),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSizes.touchSecondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        icon: Icon(_stageIcon(allowed.first), size: 18),
        label: Text(
          _stageLabel(status),
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  String _stageLabel(OrderStatus current) => switch (current) {
    OrderStatus.accepted => 'Start Preparing',
    OrderStatus.preparing => 'Mark Ready',
    OrderStatus.ready => 'Picked Up',
    _ => 'Advance',
  };

  IconData _stageIcon(OrderStatus next) => switch (next) {
    OrderStatus.preparing => Icons.restaurant,
    OrderStatus.ready => Icons.check_circle_outline,
    OrderStatus.picked => Icons.delivery_dining,
    _ => Icons.arrow_forward,
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color => switch (status) {
    OrderStatus.accepted => AppColors.info,
    OrderStatus.preparing => AppColors.queuePulse,
    OrderStatus.ready => AppColors.success,
    _ => Colors.grey,
  };

  String get _label => switch (status) {
    OrderStatus.accepted => 'Accepted',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.ready => 'Ready',
    _ => status.name,
  };
}
