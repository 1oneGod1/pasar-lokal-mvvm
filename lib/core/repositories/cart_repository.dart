import 'dart:collection';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../storage/local_store.dart';
import '../storage/storage_mappers.dart';

class CartRepository {
  CartRepository({LocalStore? store}) : _store = store {
    _restore();
  }

  static const _storageKey = 'cart.items.v1';

  final LocalStore? _store;
  final List<CartItem> _items = [];

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items);

  double get total => _items.fold(0, (value, item) => value + item.subtotal);

  void _restore() {
    final store = _store;
    if (store == null) {
      return;
    }

    final raw = store.read<dynamic>(_storageKey);
    if (raw is! List) {
      return;
    }

    _items
      ..clear()
      ..addAll(raw.whereType<Map<dynamic, dynamic>>().map(cartItemFromMap));
  }

  Future<void> _persist() async {
    final store = _store;
    if (store == null) {
      return;
    }

    final payload = _items.map(cartItemToMap).toList(growable: false);
    await store.write(_storageKey, payload);
  }

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

    _persist();
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

    _persist();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    _persist();
  }

  void clear() {
    _items.clear();
    _persist();
  }
}
