import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/countdown_ring.dart';
import '../../../core/widgets/idempotent_submit_button.dart';
import '../data/order_model.dart';
import 'orders_board_provider.dart';
import 'widgets/reject_reason_sheet.dart';

/// S3a — Full-screen alarm overlay.
/// Wakes over any screen state via FCM high-priority.
/// Accept is the ONLY enabled control until fully opened.
/// Layout shifts prohibited during active alarms.
class AlarmOverlayScreen extends ConsumerStatefulWidget {
  const AlarmOverlayScreen({super.key, required this.orderUuid});

  final String orderUuid;

  @override
  ConsumerState<AlarmOverlayScreen> createState() => _AlarmOverlayScreenState();
}

class _AlarmOverlayScreenState extends ConsumerState<AlarmOverlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _isAccepting = false;
  bool _fullyOpened = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the accept button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // After 1.5s, allow reject option (prevent pocket taps)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _fullyOpened = true);
    });

    // Keep screen on
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(orderBoardProvider);
    final order = board.orders.where((o) => o.uuid == widget.orderUuid).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand header
            _AlarmHeader(),
            Expanded(
              child: order == null
                  ? const Center(child: CircularProgressIndicator())
                  : _AlarmContent(
                      order: order,
                      isReconnecting: board.isWsReconnecting,
                      isAccepting: _isAccepting,
                      fullyOpened: _fullyOpened,
                      pulseAnim: _pulseAnim,
                      onAccept: () => _accept(order),
                      onReject: _fullyOpened
                          ? () => _showRejectSheet(order)
                          : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(Order order) async {
    // Haptic heavy thump through kitchen noise
    HapticFeedback.heavyImpact();

    // Instrumentation: track accept start time
    final acceptStartMs = DateTime.now().millisecondsSinceEpoch;

    setState(() => _isAccepting = true);

    try {
      await ref.read(orderBoardProvider.notifier).acceptOrder(order.uuid);

      // Instrumentation: alarm_sound_start -> accepted_post p50 <= 7s
      final acceptEndMs = DateTime.now().millisecondsSinceEpoch;
      debugPrint(
        '[METRIC] accept_latency_ms=${acceptEndMs - acceptStartMs} order=${order.uuid}',
      );

      if (mounted) context.go('/orders');
    } catch (e) {
      setState(() => _isAccepting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept. Tap again to retry.')),
        );
      }
    }
  }

  void _showRejectSheet(Order order) {
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
          if (mounted) context.go('/orders');
        },
      ),
    );
  }
}

class _AlarmHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingM,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'PlateRoute',
            style: AppTextStyles.titleS.copyWith(color: Colors.white),
          ),
          const Spacer(),
          // Pulsing alarm indicator
          const _AlarmPulse(),
        ],
      ),
    );
  }
}

class _AlarmPulse extends StatefulWidget {
  const _AlarmPulse();

  @override
  State<_AlarmPulse> createState() => _AlarmPulseState();
}

class _AlarmPulseState extends State<_AlarmPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.queuePulse,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'New Order!',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlarmContent extends StatelessWidget {
  const _AlarmContent({
    required this.order,
    required this.isReconnecting,
    required this.isAccepting,
    required this.fullyOpened,
    required this.pulseAnim,
    required this.onAccept,
    this.onReject,
  });

  final Order order;
  final bool isReconnecting;
  final bool isAccepting;
  final bool fullyOpened;
  final Animation<double> pulseAnim;
  final VoidCallback onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final secs = order.acceptWindowSeconds ?? 0;
    final totalSecs = 300;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSizes.spacingL),
          // Order card clone with countdown ring
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border(
                left: BorderSide(
                  color: AppColors.queuePulse,
                  width: AppSizes.urgencyBorderWidth,
                ),
              ),
            ),
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.displayNumber}',
                        style: AppTextStyles.orderNumber.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                    // CountdownRing — top-right, server-truth
                    CountdownRing(
                      remainingSeconds: secs,
                      totalSeconds: totalSecs,
                      isReconnecting: isReconnecting,
                      size: 64,
                      strokeWidth: 6,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  order.itemSummary,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.titleS.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                if (!isReconnecting && secs > 0) ...[
                  const SizedBox(height: AppSizes.spacingS),
                  Text(
                    'Auto-cancels in ${secs}s',
                    style: AppTextStyles.caption.copyWith(
                      color: secs < 60
                          ? AppColors.lateAlarm
                          : AppColors.textSecondaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          // Accept button — pulsing, always visible
          Semantics(
            label:
                'Accept order ${order.displayNumber}, ${order.items.length} items, '
                '${order.formattedTotal}, auto cancel in ${secs} seconds',
            child: ScaleTransition(
              scale: pulseAnim,
              child: SizedBox(
                height: 72,
                child: IdempotentSubmitButton(
                  onPressed: () async => onAccept(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.actionAcceptDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                  ),
                  child: Text(
                          'Accept order now',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          // Reject — only visible after 1.5s (pocket-tap guard)
          if (fullyOpened && onReject != null)
            SizedBox(
              height: AppSizes.touchSecondary,
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
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.rejectOutline,
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: AppSizes.touchSecondary),
          const SizedBox(height: AppSizes.spacingL),
        ],
      ),
    );
  }
}
