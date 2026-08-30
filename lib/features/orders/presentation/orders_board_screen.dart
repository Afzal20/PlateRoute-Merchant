import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/order_model.dart';
import '../data/orders_repository.dart';
import 'orders_board_provider.dart';
import 'widgets/order_card.dart';
import 'widgets/stat_strip.dart';
import 'widgets/reject_reason_sheet.dart';

/// S3 — Orders board with 4 buckets and stat strip.
class OrdersBoardScreen extends ConsumerWidget {
  const OrdersBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(orderBoardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Orders'),
            if (board.isWsReconnecting) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reconnecting',
                      style: AppTextStyles.caption.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else if (board.isWsConnected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.wifi, size: 14, color: AppColors.success),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.read(orderBoardProvider.notifier).refresh(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderBoardProvider.notifier).refresh(),
        child: board.isLoading
            ? const Center(child: CircularProgressIndicator())
            : board.error != null && board.orders.isEmpty
                ? _ErrorView(
                    message: board.error!,
                    onRetry: () =>
                        ref.read(orderBoardProvider.notifier).refresh(),
                  )
                : _BoardBody(
                    board: board,
                    isReconnecting: board.isWsReconnecting,
                  ),
      ),
    );
  }
}

class _BoardBody extends ConsumerWidget {
  const _BoardBody({
    required this.board,
    required this.isReconnecting,
  });

  final OrderBoardState board;
  final bool isReconnecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Stat strip — pinned at top
        SliverToBoxAdapter(
          child: StatStrip(
            newOrders: board.newCount,
            activeOrders: board.activeCount,
            lateToday: board.lateCount,
          ),
        ),

        // ACT NOW bucket
        _BucketHeader(
          title: 'ACT NOW',
          count: board.actNow.length,
          color: AppColors.queuePulse,
        ),
        if (board.actNow.isEmpty)
          const SliverToBoxAdapter(child: _EmptyBucket(message: 'No pending orders'))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => OrderCard(
                order: board.actNow[i],
                isReconnecting: isReconnecting,
                onTap: () => context.push('/orders/${board.actNow[i].uuid}'),
                onAccept: () => _acceptOrder(ref, context, board.actNow[i]),
                onReject: () => _showRejectSheet(ref, context, board.actNow[i]),
              ),
              childCount: board.actNow.length,
            ),
          ),

        // IN KITCHEN bucket — capped 6 visible + counter
        _BucketHeader(
          title: 'IN KITCHEN',
          count: board.inKitchen.length,
          color: AppColors.borderInKitchen,
        ),
        if (board.inKitchen.isEmpty)
          const SliverToBoxAdapter(child: _EmptyBucket(message: 'Kitchen is clear'))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                if (i == 6 && board.inKitchen.length > 6) {
                  return _MoreCounter(count: board.inKitchen.length - 6);
                }
                final order = board.inKitchen[i];
                return OrderCard(
                  order: order,
                  isReconnecting: isReconnecting,
                  onTap: () => context.push('/orders/${order.uuid}'),
                  onStageChange: (newStatus) => ref
                      .read(orderBoardProvider.notifier)
                      .transitionOrder(order.uuid, newStatus),
                );
              },
              childCount: board.inKitchen.length > 6 ? 7 : board.inKitchen.length,
            ),
          ),

        // SCHEDULED bucket
        if (board.scheduled.isNotEmpty) ...[
          _BucketHeader(
            title: 'SCHEDULED',
            count: board.scheduled.length,
            color: AppColors.info,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => OrderCard(
                order: board.scheduled[i],
                isReconnecting: isReconnecting,
                onTap: () =>
                    context.push('/orders/${board.scheduled[i].uuid}'),
              ),
              childCount: board.scheduled.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Future<void> _acceptOrder(
    WidgetRef ref,
    BuildContext context,
    Order order,
  ) async {
    try {
      await ref.read(orderBoardProvider.notifier).acceptOrder(order.uuid);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept order. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRejectSheet(
    WidgetRef ref,
    BuildContext context,
    Order order,
  ) {
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
        },
      ),
    );
  }
}

class _BucketHeader extends StatelessWidget {
  const _BucketHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingM,
          AppSizes.spacingL,
          AppSizes.spacingM,
          AppSizes.spacingXS,
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.statLabel.copyWith(
                color: color,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBucket extends StatelessWidget {
  const _EmptyBucket({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.spacingL,
        horizontal: AppSizes.spacingM,
      ),
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: Colors.grey),
      ),
    );
  }
}

class _MoreCounter extends StatelessWidget {
  const _MoreCounter({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Text(
          '+$count more orders in kitchen',
          style: AppTextStyles.body.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: AppSizes.spacingM),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSizes.spacingL),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
