import 'dart:collection';

import '../models/order.dart';
import '../storage/local_store.dart';
import '../storage/storage_mappers.dart';

class OrderRepository {
  OrderRepository({LocalStore? store}) : _store = store {
    _restore();
  }

  static const _storageKey = 'orders.v1';

  final LocalStore? _store;
  final List<Order> _orders = [];

  UnmodifiableListView<Order> get orders => UnmodifiableListView(_orders);

  void _restore() {
    final store = _store;
    if (store == null) {
      return;
    }

    final raw = store.read<dynamic>(_storageKey);
    if (raw is! List) {
      return;
    }

    _orders
      ..clear()
      ..addAll(raw.whereType<Map<dynamic, dynamic>>().map(orderFromMap));
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) {
      return;
    }

    final payload = _orders.map(orderToMap).toList(growable: false);
    await store.write(_storageKey, payload);
  }

  void create(Order order) {
    _orders.add(order);
    _persist();
  }

  void updateStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((item) => item.id == orderId);
    if (index == -1) {
      throw ArgumentError('Order not found for id $orderId');
    }
    _orders[index] = _orders[index].copyWith(status: status);
    _persist();
  }

  void delete(String orderId) {
    _orders.removeWhere((item) => item.id == orderId);
    _persist();
  }
}
