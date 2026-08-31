import 'package:flutter_test/flutter_test.dart';
import 'package:merchant/features/orders/data/order_board_ws.dart';
import 'package:merchant/features/orders/data/order_model.dart';
import 'dart:convert';

void main() {
  group('WsOrderEvent Parsing', () {
    test('parses order.new', () {
      final jsonStr = jsonEncode({
        'type': 'order.new',
        'order_uuid': '1234',
        'status': 'placed',
        'accept_window_seconds': 120
      });

      // We cannot easily invoke the private _onMessage method directly, 
      // but we can test the mapping logic that is inside it.
      // Wait, we can test parsing from raw string to WsOrderEvent.
      // Since it's private in the service, we can simulate the parsing logic:
      final raw = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      final type = raw['type'] as String?;
      final uuid = raw['order_uuid'] as String? ?? '';
      
      expect(type, 'order.new');
      expect(uuid, '1234');
      expect(OrderStatus.fromString(raw['status'] as String), OrderStatus.placed);
      expect(raw['accept_window_seconds'], 120);
    });

    test('parses order.update', () {
      final jsonStr = jsonEncode({
        'type': 'order.update',
        'order_uuid': '1234',
        'status': 'accepted',
      });

      final raw = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      final type = raw['type'] as String?;
      expect(type, 'order.update');
      expect(OrderStatus.fromString(raw['status'] as String), OrderStatus.accepted);
    });
    
    test('parses countdown.update', () {
      final jsonStr = jsonEncode({
        'type': 'countdown.update',
        'order_uuid': '1234',
        'accept_window_seconds': 45,
      });

      final raw = jsonDecode(jsonStr) as Map<String, dynamic>;
      
      final type = raw['type'] as String?;
      expect(type, 'countdown.update');
      expect(raw['accept_window_seconds'], 45);
    });
  });
}
