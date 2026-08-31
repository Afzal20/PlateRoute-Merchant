import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:merchant/core/widgets/countdown_ring.dart';
import 'package:merchant/features/orders/data/order_model.dart';
import 'package:merchant/features/orders/presentation/alarm_overlay_screen.dart';
import 'package:merchant/features/orders/presentation/orders_board_provider.dart';

void main() {
  testWidgets('AlarmOverlay shows accept button and countdown ring', (WidgetTester tester) async {
    final now = DateTime.now();
    final dummyOrder = Order(
      uuid: 'uuid-1234',
      status: OrderStatus.placed,
      branch: 'branch',
      currency: 'BDT',
      itemsTotalMinor: 500,
      grandTotalMinor: 500,
      placedAt: now,
      items: const [],
      acceptWindowSeconds: 60,
    );

    final mockState = OrderBoardState(orders: [dummyOrder], isWsReconnecting: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          orderBoardProvider.overrideWith(() {
            return _MockOrderBoardNotifier(mockState);
          }),
        ],
        child: const MaterialApp(
          home: AlarmOverlayScreen(orderUuid: 'uuid-1234'),
        ),
      ),
    );

    // Give it time to run pulse animation
    await tester.pump();

    expect(find.text('Accept order now'), findsOneWidget);
    expect(find.byType(CountdownRing), findsOneWidget);

    // Reject button is not shown immediately (1.5s delay)
    expect(find.text('Reject'), findsNothing);

    // Fast forward 1.5s
    await tester.pump(const Duration(milliseconds: 1500));
    
    // Now Reject should be visible
    expect(find.text('Reject'), findsOneWidget);
  });
}

class _MockOrderBoardNotifier extends Notifier<OrderBoardState> implements OrderBoardNotifier {
  _MockOrderBoardNotifier(this._state);
  
  final OrderBoardState _state;

  @override
  OrderBoardState build() => _state;

  @override
  Future<void> acceptOrder(String uuid) async {}

  @override
  Future<void> rejectOrder(String uuid, {required reason, String? note}) async {}
  
  @override
  Future<void> refresh() async {}

  @override
  Future<void> transitionOrder(String uuid, OrderStatus newStatus) async {}
}
