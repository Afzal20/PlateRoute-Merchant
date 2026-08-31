import 'dart:async';
import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../data/order_model.dart';
import '../data/orders_repository.dart';
import '../data/order_board_ws.dart';

import '../../../core/providers/branch_provider.dart';

class OrderBoardState {
  const OrderBoardState({
    this.orders = const [],
    this.isLoading = true,
    this.error,
    this.isWsConnected = false,
    this.isWsReconnecting = false,
  });

  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final bool isWsConnected;
  final bool isWsReconnecting;

  // Board buckets (sorted by urgency)
  List<Order> get actNow => orders
      .where((o) => o.status.bucket == OrderBucket.actNow)
      .toList()
    ..sort((a, b) => (a.acceptWindowSeconds ?? 999).compareTo(
        b.acceptWindowSeconds ?? 999));

  List<Order> get inKitchen =>
      orders.where((o) => o.status.bucket == OrderBucket.inKitchen).toList();

  List<Order> get scheduled =>
      orders.where((o) => o.status.bucket == OrderBucket.scheduled).toList();

  // Stats
  int get newCount => actNow.length;
  int get activeCount => inKitchen.length;
  int get lateCount => actNow
      .where((o) => (o.acceptWindowSeconds ?? 999) < 60)
      .length;

  OrderBoardState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    bool? isWsConnected,
    bool? isWsReconnecting,
  }) {
    return OrderBoardState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      isWsReconnecting: isWsReconnecting ?? this.isWsReconnecting,
    );
  }
}

/// 30-second coalescing window for identical order events
class _CoalescingBuffer {
  final _buffer = <String, DateTime>{};

  bool shouldDeliver(String orderUuid) {
    final now = DateTime.now();
    final last = _buffer[orderUuid];
    if (last == null || now.difference(last).inSeconds > 30) {
      _buffer[orderUuid] = now;
      return true;
    }
    return false;
  }
}

class OrderBoardNotifier extends Notifier<OrderBoardState> {
  final _coalescing = _CoalescingBuffer();
  StreamSubscription? _wsSub;
  StreamSubscription? _wsStateSub;
  Timer? _pollingTimer;

  @override
  OrderBoardState build() {
    ref.onDispose(() {
      _wsSub?.cancel();
      _wsStateSub?.cancel();
      _pollingTimer?.cancel();
    });

    Future.microtask(_initialize);
    return const OrderBoardState();
  }

  Future<void> _initialize() async {
    await _fetchOrders();
    _connectWs();
    // Fallback polling every 30s
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!state.isWsConnected) _fetchOrders();
    });
  }

  Future<void> _fetchOrders() async {
    try {
      final repo = ref.read(ordersRepositoryProvider);
      final orders = await repo.fetchBoard();
      state = state.copyWith(orders: orders, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load orders. Pull to refresh.',
      );
    }
  }

  void _connectWs() {
    final ws = ref.read(orderBoardWsServiceProvider);

    _wsStateSub = ws.connectionState.listen((wsState) {
      state = state.copyWith(
        isWsConnected: wsState == WsConnectionState.connected,
        isWsReconnecting: wsState == WsConnectionState.reconnecting,
      );
    });

    _wsSub = ws.events.listen((event) {
      _handleWsEvent(event);
    });

    final branch = ref.read(branchProvider);
    final uuid = branch.branchUuid ?? 'default';
    ws.connect(branchUuid: uuid);
  }

  void _handleWsEvent(WsOrderEvent event) {
    switch (event.type) {
      case WsEventType.orderNew:
        if (_coalescing.shouldDeliver(event.orderUuid)) {
          _fetchOrders(); // Refresh to get full order data
        }
      case WsEventType.orderUpdate:
        _updateOrderStatus(event);
      case WsEventType.countdownUpdate:
        _updateCountdown(event);
      case WsEventType.unknown:
        break;
    }
  }

  void _updateOrderStatus(WsOrderEvent event) {
    if (event.status == null) return;
    final updated = state.orders.map((o) {
      if (o.uuid == event.orderUuid) {
        return o.copyWith(status: event.status);
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updated);
  }

  void _updateCountdown(WsOrderEvent event) {
    if (event.acceptWindowSeconds == null) return;
    final updated = state.orders.map((o) {
      if (o.uuid == event.orderUuid) {
        return o.copyWith(acceptWindowSeconds: event.acceptWindowSeconds);
      }
      return o;
    }).toList();
    state = state.copyWith(orders: updated);
  }

  /// Optimistic accept — instant card re-tint, rollback on failure
  Future<void> acceptOrder(String uuid) async {
    // 1. Optimistic update
    final original = state.orders.firstWhere((o) => o.uuid == uuid);
    final optimistic = original.copyWith(status: OrderStatus.accepted);
    _replaceOrder(optimistic);

    // 2. Send with idempotency key
    final key = OrdersRepository.generateIdempotencyKey();
    try {
      final repo = ref.read(ordersRepositoryProvider);
      final confirmed = await repo.acceptOrder(uuid, idempotencyKey: key);
      _replaceOrder(confirmed);
    } catch (_) {
      // Rollback on server error
      _replaceOrder(original);
      rethrow;
    }
  }

  Future<void> rejectOrder(
    String uuid, {
    required RejectReason reason,
    String? note,
  }) async {
    final key = OrdersRepository.generateIdempotencyKey();
    final repo = ref.read(ordersRepositoryProvider);
    final confirmed = await repo.rejectOrder(
      uuid,
      reason: reason,
      note: note,
      idempotencyKey: key,
    );
    _replaceOrder(confirmed);
  }

  Future<void> transitionOrder(String uuid, OrderStatus newStatus) async {
    final original = state.orders.firstWhere((o) => o.uuid == uuid);
    // Optimistic
    _replaceOrder(original.copyWith(status: newStatus));
    try {
      final key = OrdersRepository.generateIdempotencyKey();
      final repo = ref.read(ordersRepositoryProvider);
      final confirmed = await repo.transitionOrder(
        uuid,
        newStatus,
        idempotencyKey: key,
      );
      _replaceOrder(confirmed);
    } catch (_) {
      _replaceOrder(original);
      rethrow;
    }
  }

  void _replaceOrder(Order order) {
    final list = state.orders.map((o) => o.uuid == order.uuid ? order : o).toList();
    // If not present (new order), append
    if (!list.any((o) => o.uuid == order.uuid)) {
      list.add(order);
    }
    state = state.copyWith(orders: list);
  }

  Future<void> refresh() => _fetchOrders();
}

final orderBoardProvider =
    NotifierProvider<OrderBoardNotifier, OrderBoardState>(OrderBoardNotifier.new);
