class Product {
  final String id;
  final String name;
  final String categoryId;
  final String sellerId;
  final double price;
  final int stock;
  final String description;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.sellerId,
    required this.price,
    required this.stock,
    this.description = '',
    this.imageUrl = '',
  });

  Product copyWith({
    String? name,
    String? categoryId,
    String? sellerId,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
