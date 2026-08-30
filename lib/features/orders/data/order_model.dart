import 'package:equatable/equatable.dart';

/// Maps to API OrderStatusEnum
enum OrderStatus {
  placed,
  accepted,
  preparing,
  ready,
  picked,
  out,
  delivered,
  rejected,
  cancelledCustomer,
  cancelledRestaurant,
  cancelledPlatform,
  failedPayment,
  refundPending,
  refunded;

  static OrderStatus fromString(String s) {
    switch (s) {
      case 'placed': return OrderStatus.placed;
      case 'accepted': return OrderStatus.accepted;
      case 'preparing': return OrderStatus.preparing;
      case 'ready': return OrderStatus.ready;
      case 'picked': return OrderStatus.picked;
      case 'out': return OrderStatus.out;
      case 'delivered': return OrderStatus.delivered;
      case 'rejected': return OrderStatus.rejected;
      case 'cancelled_customer': return OrderStatus.cancelledCustomer;
      case 'cancelled_restaurant': return OrderStatus.cancelledRestaurant;
      case 'cancelled_platform': return OrderStatus.cancelledPlatform;
      case 'failed_payment': return OrderStatus.failedPayment;
      case 'refund_pending': return OrderStatus.refundPending;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.placed;
    }
  }

  /// FR-ORD-03: allowed outbound transitions for merchant
  List<OrderStatus> get allowedTransitions {
    switch (this) {
      case OrderStatus.placed:
        return [OrderStatus.accepted, OrderStatus.rejected];
      case OrderStatus.accepted:
        return [OrderStatus.preparing, OrderStatus.rejected];
      case OrderStatus.preparing:
        return [OrderStatus.ready];
      case OrderStatus.ready:
        return [OrderStatus.picked];
      default:
        return [];
    }
  }

  bool get isActive => switch (this) {
    OrderStatus.placed || OrderStatus.accepted ||
    OrderStatus.preparing || OrderStatus.ready => true,
    _ => false,
  };

  bool get isTerminal => switch (this) {
    OrderStatus.delivered || OrderStatus.rejected ||
    OrderStatus.cancelledCustomer || OrderStatus.cancelledRestaurant ||
    OrderStatus.cancelledPlatform || OrderStatus.failedPayment ||
    OrderStatus.refunded => true,
    _ => false,
  };

  /// Board bucket classification
  OrderBucket get bucket {
    switch (this) {
      case OrderStatus.placed:
        return OrderBucket.actNow;
      case OrderStatus.accepted:
      case OrderStatus.preparing:
      case OrderStatus.ready:
        return OrderBucket.inKitchen;
      case OrderStatus.picked:
      case OrderStatus.out:
        return OrderBucket.scheduled;
      default:
        return OrderBucket.history;
    }
  }
}

enum OrderBucket { actNow, inKitchen, scheduled, history }

class OrderItem extends Equatable {
  const OrderItem({
    required this.id,
    required this.menuItemRef,
    required this.titleSnapshot,
    required this.qty,
    required this.unitPriceMinor,
    required this.lineTotalMinor,
    this.options,
  });

  final int id;
  final int menuItemRef;
  final String titleSnapshot;
  final int qty;
  final int unitPriceMinor;
  final int lineTotalMinor;
  final dynamic options;

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
    id: j['id'] as int,
    menuItemRef: j['menu_item_ref'] as int,
    titleSnapshot: j['title_snapshot'] as String,
    qty: j['qty'] as int,
    unitPriceMinor: j['unit_price_minor'] as int,
    lineTotalMinor: j['line_total_minor'] as int,
    options: j['options'],
  );

  @override
  List<Object?> get props => [id];
}

class Order extends Equatable {
  const Order({
    required this.uuid,
    required this.status,
    required this.branch,
    required this.currency,
    required this.itemsTotalMinor,
    required this.grandTotalMinor,
    required this.placedAt,
    required this.items,
    this.discountMinor = 0,
    this.deliveryFeeMinor = 0,
    this.vatMinor = 0,
    this.tipMinor = 0,
    this.address,
    this.eta,
    this.acceptedAt,
    this.deliveredAt,
    this.cancelReason,
    this.acceptWindowSeconds,
  });

  final String uuid;
  final OrderStatus status;
  final String branch;
  final String currency;
  final int itemsTotalMinor;
  final int grandTotalMinor;
  final int discountMinor;
  final int deliveryFeeMinor;
  final int vatMinor;
  final int tipMinor;
  final dynamic address;
  final dynamic eta;
  final DateTime placedAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;
  final String? cancelReason;
  final List<OrderItem> items;

  /// Seconds remaining in accept window (from WebSocket delta or FCM payload)
  final int? acceptWindowSeconds;

  String get displayNumber => uuid.substring(0, 6).toUpperCase();

  /// Summary like "3x Kacchi, 2x Borhani"
  String get itemSummary {
    if (items.isEmpty) return '';
    final parts = items.take(3).map((i) => '${i.qty}x ${i.titleSnapshot}').toList();
    if (items.length > 3) parts.add('+${items.length - 3} more');
    return parts.join(', ');
  }

  String get formattedTotal {
    final amount = (grandTotalMinor / 100).toStringAsFixed(0);
    return '৳$amount';
  }

  factory Order.fromJson(Map<String, dynamic> j) => Order(
    uuid: j['uuid'] as String,
    status: OrderStatus.fromString(j['status'] as String? ?? 'placed'),
    branch: j['branch'] as String,
    currency: j['currency'] as String? ?? 'BDT',
    itemsTotalMinor: (j['items_total_minor'] as num?)?.toInt() ?? 0,
    grandTotalMinor: (j['grand_total_minor'] as num?)?.toInt() ?? 0,
    discountMinor: (j['discount_minor'] as num?)?.toInt() ?? 0,
    deliveryFeeMinor: (j['delivery_fee_minor'] as num?)?.toInt() ?? 0,
    vatMinor: (j['vat_minor'] as num?)?.toInt() ?? 0,
    tipMinor: (j['tip_minor'] as num?)?.toInt() ?? 0,
    address: j['address'],
    eta: j['eta'],
    placedAt: DateTime.parse(j['placed_at'] as String),
    acceptedAt: j['accepted_at'] != null
        ? DateTime.tryParse(j['accepted_at'] as String)
        : null,
    deliveredAt: j['delivered_at'] != null
        ? DateTime.tryParse(j['delivered_at'] as String)
        : null,
    cancelReason: j['cancel_reason'] as String?,
    items: (j['items'] as List<dynamic>?)
            ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Order copyWith({
    OrderStatus? status,
    int? acceptWindowSeconds,
  }) {
    return Order(
      uuid: uuid,
      status: status ?? this.status,
      branch: branch,
      currency: currency,
      itemsTotalMinor: itemsTotalMinor,
      grandTotalMinor: grandTotalMinor,
      discountMinor: discountMinor,
      deliveryFeeMinor: deliveryFeeMinor,
      vatMinor: vatMinor,
      tipMinor: tipMinor,
      address: address,
      eta: eta,
      placedAt: placedAt,
      acceptedAt: acceptedAt,
      deliveredAt: deliveredAt,
      cancelReason: cancelReason,
      items: items,
      acceptWindowSeconds: acceptWindowSeconds ?? this.acceptWindowSeconds,
    );
  }

  @override
  List<Object?> get props => [uuid, status, acceptWindowSeconds];
}
