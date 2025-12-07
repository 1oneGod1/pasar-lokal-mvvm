enum UserRole { buyer, seller }

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.memberSince,
    required this.role,
    this.sellerId,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime memberSince;
  final UserRole role;
  final String? sellerId;

  bool get isSeller => role == UserRole.seller;
}
