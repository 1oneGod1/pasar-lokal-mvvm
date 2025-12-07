import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}
