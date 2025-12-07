import 'dart:collection';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartRepository {
  final List<CartItem> _items = [];

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items);

  double get total => _items.fold(0, (value, item) => value + item.subtotal);

  void addItem(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _items.add(
        CartItem(id: 'cart-${product.id}', product: product, quantity: 1),
      );
    } else {
      final existing = _items[index];
      _items[index] = existing.copyWith(quantity: existing.quantity + 1);
    }
  }

  void updateQuantity(String cartItemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      return;
    }

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
  }

  void clear() {
    _items.clear();
  }
}
