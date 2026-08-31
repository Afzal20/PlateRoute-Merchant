import 'package:flutter_test/flutter_test.dart';
import 'package:merchant/features/orders/data/order_model.dart';
import 'package:merchant/features/orders/presentation/orders_board_provider.dart';

void main() {
  group('OrderBoardState Tests', () {
    test('Buckets correctly group orders by urgency and sort actNow by time', () {
      final now = DateTime.now();
      final orders = [
        Order(
          uuid: 'uuid-1',
          status: OrderStatus.placed,
          branch: 'b-1',
          currency: 'BDT',
          itemsTotalMinor: 1000,
          grandTotalMinor: 1000,
          placedAt: now,
          items: const [],
          acceptWindowSeconds: 120, // actNow, but not late
        ),
        Order(
          uuid: 'uuid-2',
          status: OrderStatus.preparing,
          branch: 'b-1',
          currency: 'BDT',
          itemsTotalMinor: 1000,
          grandTotalMinor: 1000,
          placedAt: now,
          items: const [],
        ), // inKitchen
        Order(
          uuid: 'uuid-4',
          status: OrderStatus.placed,
          branch: 'b-1',
          currency: 'BDT',
          itemsTotalMinor: 1000,
          grandTotalMinor: 1000,
          placedAt: now,
          items: const [],
          acceptWindowSeconds: 30, // actNow, late
        ),
        Order(
          uuid: 'uuid-5',
          status: OrderStatus.picked,
          branch: 'b-1',
          currency: 'BDT',
          itemsTotalMinor: 1000,
          grandTotalMinor: 1000,
          placedAt: now,
          items: const [],
        ), // scheduled
      ];

      final state = OrderBoardState(orders: orders);

      expect(state.actNow.length, 2);
      expect(state.inKitchen.length, 1);
      expect(state.scheduled.length, 1);

      // Sorting test: uuid-4 has 30s, uuid-1 has 120s, so uuid-4 should be first
      expect(state.actNow.first.uuid, 'uuid-4');
      expect(state.actNow.last.uuid, 'uuid-1');

      // Stats test
      expect(state.newCount, 2);
      expect(state.activeCount, 1);
      expect(state.lateCount, 1);
    });
  });
}
