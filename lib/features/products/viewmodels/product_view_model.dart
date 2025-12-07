import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/models/product.dart';
import '../../../core/repositories/product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  ProductViewModel(this._repository);

  final ProductRepository _repository;

  UnmodifiableListView<Product> get products => _repository.products;

  Product? findById(String id) => _repository.findById(id);

  List<Product> byCategory(String? categoryId) {
    if (categoryId == null || categoryId.isEmpty) {
      return products.toList();
    }
    return _repository.byCategory(categoryId);
  }

  void addProduct(Product product) {
    _repository.create(product);
    notifyListeners();
  }

  void updateProduct(Product product) {
    _repository.update(product);
    notifyListeners();
  }

  void deleteProduct(String id) {
    _repository.delete(id);
    notifyListeners();
  }
}
