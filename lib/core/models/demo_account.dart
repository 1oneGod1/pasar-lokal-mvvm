import 'user.dart';

class DemoAccount {
  const DemoAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.sellerId,
  });

  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? sellerId;

  bool get isSeller => role == UserRole.seller;
}
