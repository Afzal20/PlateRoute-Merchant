import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/order_model.dart';
import '../data/orders_repository.dart';
import 'orders_board_provider.dart';
import 'widgets/order_card.dart';
import 'widgets/reject_reason_sheet.dart';

/// S4 — Order detail screen with inline modifier expansion.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(orderBoardProvider);
    final order = board.orders.where((o) => o.uuid == uuid).firstOrNull;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('#${order.displayNumber}',
            style: AppTextStyles.orderNumber.copyWith(color: textPrimary)),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status chip
            _StatusBanner(status: order.status),
            const SizedBox(height: AppSizes.spacingM),
            // Items — inline modifier expansion (never a new screen)
            ...order.items.map((item) => _ItemRow(item: item)),
            const Divider(height: AppSizes.spacingL),
            // Totals
            _PriceLine(label: 'Subtotal', minor: order.itemsTotalMinor),
            if (order.discountMinor > 0)
              _PriceLine(
                label: 'Discount',
                minor: -order.discountMinor,
                color: AppColors.success,
              ),
            _PriceLine(label: 'Delivery fee', minor: order.deliveryFeeMinor),
            if (order.vatMinor > 0)
              _PriceLine(label: 'VAT', minor: order.vatMinor),
            const Divider(),
            _PriceLine(
              label: 'Total',
              minor: order.grandTotalMinor,
              bold: true,
            ),
            const SizedBox(height: AppSizes.spacingL),
            // Action buttons based on current status
            if (order.status == OrderStatus.placed) ...[
              _AcceptButton(
                onPressed: () => _acceptOrder(ref, context, order),
              ),
              const SizedBox(height: AppSizes.spacingS),
              _RejectButton(
                onPressed: () => _showRejectSheet(ref, context, order),
              ),
            ],
            if (order.status.bucket == OrderBucket.inKitchen) ...[
              _StageButton(
                status: order.status,
                onPressed: () {
                  final next = order.status.allowedTransitions.firstOrNull;
                  if (next != null) {
                    ref
                        .read(orderBoardProvider.notifier)
                        .transitionOrder(order.uuid, next);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _acceptOrder(
    WidgetRef ref,
    BuildContext context,
    Order order,
  ) async {
    try {
      await ref.read(orderBoardProvider.notifier).acceptOrder(order.uuid);
      if (context.mounted) context.pop();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept. Please try again.')),
        );
      }
    }
  }

  void _showRejectSheet(WidgetRef ref, BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RejectReasonSheet(
        onConfirm: (reason, note) async {
          Navigator.pop(context);
          await ref
              .read(orderBoardProvider.notifier)
              .rejectOrder(order.uuid, reason: reason, note: note);
          if (context.mounted) context.pop();
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        _label,
        style: AppTextStyles.bodyMedium.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color get _color => switch (status) {
    OrderStatus.placed => AppColors.queuePulse,
    OrderStatus.accepted => AppColors.info,
    OrderStatus.preparing => AppColors.queuePulse,
    OrderStatus.ready => AppColors.success,
    OrderStatus.rejected || OrderStatus.cancelledRestaurant => AppColors.lateAlarm,
    OrderStatus.delivered => AppColors.success,
    _ => Colors.grey,
  };

  String get _label => switch (status) {
    OrderStatus.placed => 'Awaiting your response',
    OrderStatus.accepted => 'Accepted - start when ready',
    OrderStatus.preparing => 'Preparing',
    OrderStatus.ready => 'Ready for pickup',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.rejected => 'Rejected',
    _ => status.name,
  };
}

class _ItemRow extends StatefulWidget {
  const _ItemRow({required this.item});
  final OrderItem item;

  @override
  State<_ItemRow> createState() => _ItemRowState();
}

class _ItemRowState extends State<_ItemRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.item.options != null
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
            child: Row(
              children: [
                Text(
                  '${widget.item.qty}x',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.titleSnapshot,
                    style: AppTextStyles.body.copyWith(color: textPrimary),
                  ),
                ),
                Text(
                  _formatPrice(widget.item.lineTotalMinor),
                  style: AppTextStyles.price.copyWith(color: textPrimary),
                ),
                if (widget.item.options != null)
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
        // Inline modifier expansion — never a new screen
        if (_expanded && widget.item.options != null)
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: AppSizes.spacingS),
            child: Text(
              widget.item.options.toString(),
              style: AppTextStyles.dense.copyWith(color: Colors.grey),
            ),
          ),
        Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
      ],
    );
  }

  String _formatPrice(int minor) => '৳${(minor / 100).toStringAsFixed(0)}';
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.minor,
    this.bold = false,
    this.color,
  });

  final String label;
  final int minor;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final style = bold
        ? AppTextStyles.bodyMedium.copyWith(
            color: color ?? textPrimary,
            fontWeight: FontWeight.w700,
          )
        : AppTextStyles.body.copyWith(color: color ?? textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('৳${(minor / 100).toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.touchPrimary,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.actionAcceptDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        child: Text(
          'Accept order now',
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _RejectButton extends StatelessWidget {
  const _RejectButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.touchSecondary,
      child: OutlinedButton(
        onPressed: onPressed,
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
    );
  }
}

class _StageButton extends StatelessWidget {
  const _StageButton({required this.status, required this.onPressed});
  final OrderStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.touchPrimary,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
        ),
        child: Text(
          _label,
          style: AppTextStyles.button.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  String get _label => switch (status) {
    OrderStatus.accepted => 'Start preparing',
    OrderStatus.preparing => 'Food is ready',
    OrderStatus.ready => 'Mark as picked up',
    _ => 'Advance',
  };
}
