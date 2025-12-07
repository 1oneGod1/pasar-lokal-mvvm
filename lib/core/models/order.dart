import 'cart_item.dart';

enum OrderStatus { pending, processing, completed }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.completed:
        return 'Completed';
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = OrderStatus.pending,
  });

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      items: items,
      total: total,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  String get createdAtLabel {
    final local = createdAt.toLocal();
    final buffer =
        StringBuffer()
          ..write(local.year.toString().padLeft(4, '0'))
          ..write('-')
          ..write(local.month.toString().padLeft(2, '0'))
          ..write('-')
          ..write(local.day.toString().padLeft(2, '0'))
          ..write(' ')
          ..write(local.hour.toString().padLeft(2, '0'))
          ..write(':')
          ..write(local.minute.toString().padLeft(2, '0'));
    return buffer.toString();
  }
}
