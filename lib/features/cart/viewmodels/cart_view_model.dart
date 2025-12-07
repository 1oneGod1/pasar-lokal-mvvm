import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/cart_item.dart';
import '../../../core/models/order.dart';
import '../../../core/models/product.dart';
import '../../../core/repositories/cart_repository.dart';

class CartViewModel extends ChangeNotifier {
  CartViewModel(this._repository);

  final CartRepository _repository;

  UnmodifiableListView<CartItem> get items => _repository.items;

  double get total => _repository.total;

  int get itemCount => items.fold(0, (value, item) => value + item.quantity);

  CartItem? _itemById(String cartItemId) {
    try {
      return items.firstWhere((element) => element.id == cartItemId);
    } catch (_) {
      return null;
    }
  }

  void addToCart(Product product) {
    _repository.addItem(product);
    notifyListeners();
  }

  void incrementQuantity(String cartItemId) {
    final item = _itemById(cartItemId);
    if (item == null) {
      return;
    }
    _repository.updateQuantity(cartItemId, item.quantity + 1);
    notifyListeners();
  }

  void decrementQuantity(String cartItemId) {
    final item = _itemById(cartItemId);
    if (item == null) {
      return;
    }
    _repository.updateQuantity(cartItemId, item.quantity - 1);
    notifyListeners();
  }

  void remove(String cartItemId) {
    _repository.removeItem(cartItemId);
    notifyListeners();
  }

  void clear() {
    _repository.clear();
    notifyListeners();
  }

  Order? checkout() {
    if (items.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final clonedItems =
        items
            .map(
              (item) => CartItem(
                id: item.id,
                product: item.product,
                quantity: item.quantity,
              ),
            )
            .toList();

    final order = Order(
      id: 'order-${now.millisecondsSinceEpoch}',
      items: clonedItems,
      total: total,
      createdAt: now,
    );

    _repository.clear();
    notifyListeners();
    return order;
  }
}
