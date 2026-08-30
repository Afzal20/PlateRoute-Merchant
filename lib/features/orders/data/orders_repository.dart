import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/core_providers.dart';
import 'order_model.dart';

/// FR-ORD-03 reject reason codes
enum RejectReason {
  outOfStock,
  tooBusy,
  closingSoon,
  cannotDeliverArea,
  other;

  String get code => switch (this) {
    RejectReason.outOfStock => 'out_of_stock',
    RejectReason.tooBusy => 'too_busy',
    RejectReason.closingSoon => 'closing_soon',
    RejectReason.cannotDeliverArea => 'cannot_deliver_area',
    RejectReason.other => 'other',
  };
}

class OrdersRepository {
  OrdersRepository(this._dio);

  final Dio _dio;

  Future<List<Order>> fetchBoard() async {
    final resp = await _dio.get('/orders/', queryParameters: {
      'limit': 100,
      'status__in': 'placed,accepted,preparing,ready,picked,out',
    });
    final results = resp.data['results'] as List<dynamic>;
    return results
        .map((j) => Order.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Order>> fetchHistory({
    String? search,
    int limit = 30,
    int offset = 0,
  }) async {
    final resp = await _dio.get('/orders/', queryParameters: {
      'limit': limit,
      'offset': offset,
      if (search != null) 'search': search,
      'status__in': 'delivered,cancelled_customer,cancelled_restaurant,rejected',
    });
    final results = resp.data['results'] as List<dynamic>;
    return results
        .map((j) => Order.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Order> fetchOrder(String uuid) async {
    final resp = await _dio.get('/orders/$uuid/');
    return Order.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Optimistic accept — POST with idempotency key (MOB-C-04)
  Future<Order> acceptOrder(String uuid, {required String idempotencyKey}) async {
    final resp = await _dio.post(
      '/orders/$uuid/transition/',
      data: {'status': 'accepted'},
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return Order.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Transition order to next status in state machine
  Future<Order> transitionOrder(
    String uuid,
    OrderStatus newStatus, {
    required String idempotencyKey,
  }) async {
    final resp = await _dio.post(
      '/orders/$uuid/transition/',
      data: {'status': newStatus.name},
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return Order.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Order> rejectOrder(
    String uuid, {
    required RejectReason reason,
    String? note,
    required String idempotencyKey,
  }) async {
    final resp = await _dio.post(
      '/orders/$uuid/transition/',
      data: {
        'status': 'rejected',
        'cancel_reason': reason.code,
        if (note != null) 'reject_note': note,
      },
      options: Options(extra: {'idempotencyKey': idempotencyKey}),
    );
    return Order.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Trigger CSV export (async job)
  Future<void> exportCsv({
    required String branchUuid,
    DateTime? from,
    DateTime? to,
  }) async {
    await _dio.get(
      '/orders/',
      queryParameters: {
        'format': 'csv',
        'branch': branchUuid,
        if (from != null) 'placed_at__gte': from.toIso8601String(),
        if (to != null) 'placed_at__lte': to.toIso8601String(),
      },
    );
  }

  static String generateIdempotencyKey() => const Uuid().v4();
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final apiClientAsync = ref.watch(apiClientProvider);
  final dio = apiClientAsync.when(
    data: (c) => c.dio,
    loading: () => Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1/')),
    error: (_, __) => Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1/')),
  );
  return OrdersRepository(dio);
});
