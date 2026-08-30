import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../orders/data/order_model.dart';
import '../../orders/data/orders_repository.dart';
import '../../../core/providers/core_providers.dart';
import 'package:dio/dio.dart';

/// S6 — Order history: searchable, dense 14sp, CSV export trigger.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory({String? search}) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      final orders = await repo.fetchHistory(search: search);
      setState(() {
        _orders = orders;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load history.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order history'),
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            tooltip: 'Export CSV',
            onPressed: _isExporting ? null : _exportCsv,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              0,
              AppSizes.spacingM,
              AppSizes.spacingS,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => _fetchHistory(search: v.isEmpty ? null : v),
              decoration: InputDecoration(
                hintText: 'Search orders…',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: AppTextStyles.dense,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _orders.isEmpty
              ? Center(child: Text(_error!))
              : ListView.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                  itemBuilder: (ctx, i) => _HistoryRow(order: _orders[i]),
                ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(ordersRepositoryProvider);
      await repo.exportCsv(branchUuid: 'default');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV export triggered — check your email.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return SizedBox(
      height: AppSizes.listRow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
        child: Row(
          children: [
            // Order number — dense monospaced
            SizedBox(
              width: 70,
              child: Text(
                '#${order.displayNumber}',
                style: AppTextStyles.dense.copyWith(
                  fontFamily: 'RobotoMono',
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Item summary
            Expanded(
              child: Text(
                order.itemSummary,
                style: AppTextStyles.dense.copyWith(color: textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Total + status
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.formattedTotal,
                  style: AppTextStyles.dense.copyWith(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                _StatusLabel(status: order.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Text(
      _label,
      style: AppTextStyles.caption.copyWith(color: _color),
    );
  }

  Color get _color => switch (status) {
    OrderStatus.delivered => AppColors.success,
    OrderStatus.rejected ||
    OrderStatus.cancelledRestaurant ||
    OrderStatus.cancelledCustomer => AppColors.lateAlarm,
    _ => Colors.grey,
  };

  String get _label => switch (status) {
    OrderStatus.delivered => 'Delivered',
    OrderStatus.rejected => 'Rejected',
    OrderStatus.cancelledRestaurant => 'Cancelled',
    OrderStatus.cancelledCustomer => 'Cust. cancelled',
    _ => status.name,
  };
}
