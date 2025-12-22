import 'package:flutter_test/flutter_test.dart';

import 'package:pasar_lokal_mvvm/core/models/product.dart';
import 'package:pasar_lokal_mvvm/core/repositories/cart_repository.dart';

void main() {
  group('CartRepository (unit test)', () {
    test('calculates total and merges duplicate items', () {
      // Arrange
      final repo = CartRepository();
      const product = Product(
        id: 'prod-a',
        name: 'Product A',
        categoryId: 'cat-a',
        sellerId: 'seller-a',
        price: 10000,
        stock: 99,
        description: 'Test product',
        imageUrl: 'https://example.com/a.jpg',
      );

      // Act
      repo.addItem(product);
      repo.addItem(product); // same product id should increment quantity

      // Assert
      expect(repo.items, hasLength(1));
      expect(repo.items.first.quantity, equals(2));
      expect(repo.total, equals(20000));
    });

    test('removes item when quantity set to zero', () {
      // Arrange
      final repo = CartRepository();
      const product = Product(
        id: 'prod-b',
        name: 'Product B',
        categoryId: 'cat-b',
        sellerId: 'seller-b',
        price: 5000,
        stock: 99,
        description: 'Test product',
        imageUrl: 'https://example.com/b.jpg',
      );

      repo.addItem(product);
      expect(repo.items, hasLength(1));

      // Act
      repo.updateQuantity('cart-prod-b', 0);

      // Assert
      expect(repo.items, isEmpty);
      expect(repo.total, equals(0));
    });

    test('sums totals across multiple products', () {
      // Arrange
      final repo = CartRepository();
      const productA = Product(
        id: 'prod-a',
        name: 'Product A',
        categoryId: 'cat-a',
        sellerId: 'seller-a',
        price: 10000,
        stock: 99,
        description: 'Test product',
        imageUrl: 'https://example.com/a.jpg',
      );
      const productB = Product(
        id: 'prod-b',
        name: 'Product B',
        categoryId: 'cat-b',
        sellerId: 'seller-b',
        price: 7500,
        stock: 99,
        description: 'Test product',
        imageUrl: 'https://example.com/b.jpg',
      );

      // Act
      repo.addItem(productA); // 1 x 10000
      repo.addItem(productB); // 1 x 7500
      repo.addItem(productB); // 2 x 7500

      // Assert
      expect(repo.total, equals(25000));
    });
  });
}
