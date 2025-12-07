import 'dart:async';

import 'package:pasar_lokal_mvvm/core/models/demo_account.dart';
import 'package:pasar_lokal_mvvm/core/models/user.dart';

class AuthRepository {
  AuthRepository();

  final List<_UserCredential> _credentials = [
    _UserCredential(
      email: 'andi@example.com',
      password: 'rahasia123',
      user: User(
        id: 'user-andi',
        name: 'Andi Purba',
        email: 'andi@example.com',
        phone: '+62 812 3456 7890',
        address: 'Jl. Cendrawasih No. 10, Medan',
        memberSince: DateTime(2024, 2, 13),
        role: UserRole.buyer,
      ),
    ),
    _UserCredential(
      email: 'sari@example.com',
      password: 'belanja123',
      user: User(
        id: 'user-sari',
        name: 'Sari Hutabarat',
        email: 'sari@example.com',
        phone: '+62 813 9876 5432',
        address: 'Jl. Kenanga No. 3, Medan',
        memberSince: DateTime(2023, 8, 24),
        role: UserRole.buyer,
      ),
    ),
    _UserCredential(
      email: 'putri.seller@pasarlokal.id',
      password: 'spicehouse',
      user: User(
        id: 'seller-putri-account',
        name: 'Putri Siregar',
        email: 'putri.seller@pasarlokal.id',
        phone: '+62 811 2233 5566',
        address: 'Jl. Dahlia No. 8, Binjai',
        memberSince: DateTime(2022, 5, 4),
        role: UserRole.seller,
        sellerId: 'seller-putri',
      ),
    ),
  ];

  List<DemoAccount> get demoAccounts {
    return _credentials
        .map(
          (credential) => DemoAccount(
            name: credential.user.name,
            email: credential.email,
            password: credential.password,
            role: credential.user.role,
            sellerId: credential.user.sellerId,
          ),
        )
        .toList(growable: false);
  }

  Future<User?> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final normalizedEmail = email.trim().toLowerCase();
    for (final credential in _credentials) {
      if (credential.email == normalizedEmail &&
          credential.password == password) {
        return credential.user;
      }
    }
    return null;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

class _UserCredential {
  const _UserCredential({
    required this.email,
    required this.password,
    required this.user,
  });

  final String email;
  final String password;
  final User user;
}
