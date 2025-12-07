import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/order.dart';
import '../../../core/repositories/order_repository.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel(this._repository);

  final OrderRepository _repository;

  UnmodifiableListView<Order> get orders => _repository.orders;

  void addOrder(Order order) {
    _repository.create(order);
    notifyListeners();
  }

  void updateStatus(String orderId, OrderStatus status) {
    _repository.updateStatus(orderId, status);
    notifyListeners();
  }

  void deleteOrder(String orderId) {
    _repository.delete(orderId);
    notifyListeners();
  }
}
