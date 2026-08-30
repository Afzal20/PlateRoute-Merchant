import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/api/token_storage.dart';
import '../../../core/providers/core_providers.dart';
import 'order_model.dart';

/// WebSocket event types from order-board deltas
enum WsEventType { orderNew, orderUpdate, countdownUpdate, unknown }

class WsOrderEvent {
  const WsOrderEvent({
    required this.type,
    required this.orderUuid,
    this.status,
    this.acceptWindowSeconds,
    this.payload,
  });

  final WsEventType type;
  final String orderUuid;
  final OrderStatus? status;
  final int? acceptWindowSeconds;
  final Map<String, dynamic>? payload;
}

enum WsConnectionState { connecting, connected, reconnecting, disconnected }

class OrderBoardWsService {
  OrderBoardWsService(this._tokenStorage, this._wsBaseUrl);

  final TokenStorage _tokenStorage;
  final String _wsBaseUrl;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _reconnectTimer;
  bool _disposed = false;

  final _connectionState = BehaviorSubject<WsConnectionState>.seeded(
    WsConnectionState.disconnected,
  );
  final _events = StreamController<WsOrderEvent>.broadcast();

  Stream<WsConnectionState> get connectionState => _connectionState.stream;
  Stream<WsOrderEvent> get events => _events.stream;

  Future<void> connect({required String branchUuid}) async {
    if (_disposed) return;
    _connectionState.add(WsConnectionState.connecting);

    try {
      final token = await _tokenStorage.getAccess();
      final url = '$_wsBaseUrl/orders/$branchUuid/?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(url));

      await _channel!.ready;
      _connectionState.add(WsConnectionState.connected);

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (_) => _scheduleReconnect(branchUuid: branchUuid),
        onDone: () => _scheduleReconnect(branchUuid: branchUuid),
      );
    } catch (_) {
      _scheduleReconnect(branchUuid: branchUuid);
    }
  }

  void _onMessage(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = json['type'] as String?;
      final uuid = json['order_uuid'] as String? ?? '';

      WsEventType eventType;
      switch (type) {
        case 'order.new':
          eventType = WsEventType.orderNew;
        case 'order.update':
          eventType = WsEventType.orderUpdate;
        case 'countdown.update':
          eventType = WsEventType.countdownUpdate;
        default:
          eventType = WsEventType.unknown;
      }

      _events.add(WsOrderEvent(
        type: eventType,
        orderUuid: uuid,
        status: json['status'] != null
            ? OrderStatus.fromString(json['status'] as String)
            : null,
        acceptWindowSeconds: json['accept_window_seconds'] as int?,
        payload: json,
      ));
    } catch (_) {
      // Malformed message — ignore
    }
  }

  void _scheduleReconnect({required String branchUuid}) {
    if (_disposed) return;
    _connectionState.add(WsConnectionState.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      connect(branchUuid: branchUuid);
    });
  }

  void disconnect() {
    _sub?.cancel();
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _connectionState.add(WsConnectionState.disconnected);
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _connectionState.close();
    _events.close();
  }
}

final orderBoardWsServiceProvider = Provider<OrderBoardWsService>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final wsUrl = dotenv.env['WS_BASE_URL'] ?? 'ws://10.0.2.2:8000/ws';
  final service = OrderBoardWsService(tokenStorage, wsUrl);
  ref.onDispose(service.dispose);
  return service;
});
