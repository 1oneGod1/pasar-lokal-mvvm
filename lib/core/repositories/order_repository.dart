import 'dart:collection';

import '../models/order.dart';

class OrderRepository {
  final List<Order> _orders = [];

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  void create(Order order) {
    _orders.add(order);
  }

  void updateStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((item) => item.id == orderId);
    if (index == -1) {
      throw ArgumentError('Order not found for id $orderId');
    }
    _orders[index] = _orders[index].copyWith(status: status);
  }

  void delete(String orderId) {
    _orders.removeWhere((item) => item.id == orderId);
  }
}
