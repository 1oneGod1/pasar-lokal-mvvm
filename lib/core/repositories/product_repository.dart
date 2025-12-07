import 'dart:collection';

import '../models/product.dart';

class ProductRepository {
  final List<Product> _products = [
    const Product(
      id: 'prod-mango',
      name: 'Manis Medan Mango',
      categoryId: 'cat-produce',
      sellerId: 'seller-andi',
      price: 25000,
      stock: 40,
      description: 'Sweet mangoes harvested this morning.',
      imageUrl:
          'https://images.unsplash.com/photo-1562157873-818bc0726f5b?auto=format&fit=crop&w=800&q=80',
    ),
    const Product(
      id: 'prod-coffee',
      name: 'Lintong Coffee Beans',
      categoryId: 'cat-spices',
      sellerId: 'seller-putri',
      price: 78000,
      stock: 25,
      description: 'Medium roast coffee beans sourced from Lintong.',
      imageUrl:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=80',
    ),
    const Product(
      id: 'prod-ulos',
      name: 'Ulos Blanket',
      categoryId: 'cat-handicraft',
      sellerId: 'seller-rani',
      price: 180000,
      stock: 12,
      description: 'Traditional Ulos blanket woven by local artisans.',
      imageUrl:
          'https://images.unsplash.com/photo-1503342394128-c104d54dba01?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);

  Product? findById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> byCategory(String categoryId) {
    return _products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  void create(Product product) {
    _products.add(product);
  }

  void update(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) {
      throw ArgumentError('Product not found for id ${product.id}');
    }
    _products[index] = product;
  }

  void delete(String id) {
    _products.removeWhere((item) => item.id == id);
  }
}
