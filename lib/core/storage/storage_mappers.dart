import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';

Map<String, Object?> userToMap(User user) {
  return {
    'id': user.id,
    'name': user.name,
    'email': user.email,
    'phone': user.phone,
    'address': user.address,
    'memberSince': user.memberSince.millisecondsSinceEpoch,
    'role': user.role.name,
    'sellerId': user.sellerId,
  };
}

User userFromMap(Map<dynamic, dynamic> map) {
  final memberSinceMillis =
      (map['memberSince'] is num) ? (map['memberSince'] as num).toInt() : 0;
  final roleRaw = (map['role'] ?? UserRole.buyer.name).toString();
  final role = UserRole.values.firstWhere(
    (value) => value.name == roleRaw,
    orElse: () => UserRole.buyer,
  );

  return User(
    id: (map['id'] ?? '').toString(),
    name: (map['name'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    phone: (map['phone'] ?? '').toString(),
    address: (map['address'] ?? '').toString(),
    memberSince: DateTime.fromMillisecondsSinceEpoch(memberSinceMillis),
    role: role,
    sellerId:
        (map['sellerId'] as String?)?.isEmpty == true
            ? null
            : map['sellerId'] as String?,
  );
}

Map<String, Object?> productToMap(Product product) {
  return {
    'id': product.id,
    'name': product.name,
    'categoryId': product.categoryId,
    'sellerId': product.sellerId,
    'price': product.price,
    'stock': product.stock,
    'description': product.description,
    'imageUrl': product.imageUrl,
  };
}

Product productFromMap(Map<dynamic, dynamic> map) {
  return Product(
    id: (map['id'] ?? '').toString(),
    name: (map['name'] ?? '').toString(),
    categoryId: (map['categoryId'] ?? '').toString(),
    sellerId: (map['sellerId'] ?? '').toString(),
    price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
    stock: (map['stock'] is num) ? (map['stock'] as num).toInt() : 0,
    description: (map['description'] ?? '').toString(),
    imageUrl: (map['imageUrl'] ?? '').toString(),
  );
}

Map<String, Object?> cartItemToMap(CartItem item) {
  return {
    'id': item.id,
    'quantity': item.quantity,
    'product': productToMap(item.product),
  };
}

CartItem cartItemFromMap(Map<dynamic, dynamic> map) {
  final productMap = map['product'];
  return CartItem(
    id: (map['id'] ?? '').toString(),
    product:
        productMap is Map
            ? productFromMap(productMap)
            : const Product(
              id: 'unknown',
              name: 'Unknown',
              categoryId: 'unknown',
              sellerId: 'unknown',
              price: 0,
              stock: 0,
            ),
    quantity: (map['quantity'] is num) ? (map['quantity'] as num).toInt() : 0,
  );
}

Map<String, Object?> orderToMap(Order order) {
  return {
    'id': order.id,
    'total': order.total,
    'createdAt': order.createdAt.millisecondsSinceEpoch,
    'status': order.status.name,
    'items': order.items.map(cartItemToMap).toList(growable: false),
  };
}

Order orderFromMap(Map<dynamic, dynamic> map) {
  final createdAtMillis =
      (map['createdAt'] is num) ? (map['createdAt'] as num).toInt() : 0;

  final statusRaw = (map['status'] ?? OrderStatus.pending.name).toString();
  final status = OrderStatus.values.firstWhere(
    (value) => value.name == statusRaw,
    orElse: () => OrderStatus.pending,
  );

  final itemsRaw = map['items'];
  final items =
      itemsRaw is List
          ? itemsRaw
              .whereType<Map<dynamic, dynamic>>()
              .map(cartItemFromMap)
              .toList()
          : <CartItem>[];

  return Order(
    id: (map['id'] ?? '').toString(),
    items: items,
    total: (map['total'] is num) ? (map['total'] as num).toDouble() : 0.0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    status: status,
  );
}
