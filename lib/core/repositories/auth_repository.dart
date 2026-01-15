import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pasar_lokal_mvvm/core/models/demo_account.dart';
import 'package:pasar_lokal_mvvm/core/models/auth_session.dart';
import 'package:pasar_lokal_mvvm/core/models/user.dart';
import 'package:pasar_lokal_mvvm/core/storage/local_store.dart';
import 'package:pasar_lokal_mvvm/core/storage/storage_mappers.dart';

class AuthRepository {
  AuthRepository({LocalStore? store, GoogleSignIn? googleSignIn})
    : _store = store,
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const ['email', 'profile'],
            clientId:
                kIsWeb
                    ? const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID')
                    : null,
          );

  static const _sessionKey = 'auth.session.v1';

  final LocalStore? _store;
  final GoogleSignIn _googleSignIn;

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

  AuthSession? get cachedSession {
    final store = _store;
    if (store == null) {
      return null;
    }

    final raw = store.read<dynamic>(_sessionKey);
    if (raw is! Map) {
      return null;
    }

    final providerRaw = (raw['provider'] ?? '').toString();
    final provider = switch (providerRaw) {
      'google' => AuthProviderType.google,
      _ => AuthProviderType.password,
    };

    final userRaw = raw['user'];
    if (userRaw is! Map<dynamic, dynamic>) {
      return null;
    }

    final user = userFromMap(userRaw);
    final token = raw['token']?.toString();
    return AuthSession(user: user, provider: provider, sessionToken: token);
  }

  Future<void> _writeSession(AuthSession session) async {
    final store = _store;
    if (store == null) {
      return;
    }

    await store.write(_sessionKey, {
      'provider':
          session.provider == AuthProviderType.google ? 'google' : 'password',
      'token': session.sessionToken,
      'user': userToMap(session.user),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _clearSession() async {
    final store = _store;
    if (store == null) {
      return;
    }
    await store.remove(_sessionKey);
  }

  /// Attempts to restore & refresh a persisted session.
  ///
  /// - For password sessions, returns the cached session.
  /// - For Google sessions, performs `signInSilently()` to refresh tokens.
  Future<AuthSession?> restoreSession() async {
    final cached = cachedSession;
    if (cached == null) {
      return null;
    }

    if (cached.provider != AuthProviderType.google) {
      return cached;
    }

    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      await _clearSession();
      return null;
    }

    final auth = await account.authentication;
    final token = auth.idToken ?? auth.accessToken;

    final user = User(
      id: 'google-${account.id}',
      name: account.displayName ?? 'Google User',
      email: _normalizeEmail(account.email),
      phone: '-',
      address: '-',
      memberSince: cached.user.memberSince,
      role: cached.user.role,
      sellerId: cached.user.sellerId,
    );

    final refreshed = AuthSession(
      user: user,
      provider: AuthProviderType.google,
      sessionToken: token,
    );
    await _writeSession(refreshed);
    return refreshed;
  }

  Future<AuthSession?> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final normalizedEmail = _normalizeEmail(email);
    for (final credential in _credentials) {
      if (credential.email == normalizedEmail &&
          credential.password == password) {
        final session = AuthSession(
          user: credential.user,
          provider: AuthProviderType.password,
          sessionToken:
              'demo-${credential.user.id}-${DateTime.now().millisecondsSinceEpoch}',
        );
        await _writeSession(session);
        return session;
      }
    }
    return null;
  }

  Future<AuthSession> loginWithGoogle() async {
    if (kIsWeb &&
        const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID').trim().isEmpty) {
      throw StateError(
        'GOOGLE_WEB_CLIENT_ID belum di-set. Jalankan dengan --dart-define=GOOGLE_WEB_CLIENT_ID=...',
      );
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw StateError('AUTH_CANCELLED');
    }

    final auth = await account.authentication;
    final token = auth.idToken ?? auth.accessToken;

    final normalizedEmail = _normalizeEmail(account.email);
    final now = DateTime.now();
    final user = User(
      id: 'google-${account.id}',
      name: account.displayName ?? 'Google User',
      email: normalizedEmail,
      phone: '-',
      address: '-',
      memberSince: now,
      role: UserRole.buyer,
    );

    final session = AuthSession(
      user: user,
      provider: AuthProviderType.google,
      sessionToken: token,
    );
    await _writeSession(session);
    return session;
  }

  Future<AuthSession?> registerBuyer({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = _normalizeEmail(email);
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Nama tidak boleh kosong.');
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('Email tidak valid.');
    }
    if (password.length < 6) {
      throw ArgumentError('Kata sandi minimal 6 karakter.');
    }

    final exists = _credentials.any((c) => c.email == normalizedEmail);
    if (exists) {
      return null;
    }

    final now = DateTime.now();
    final user = User(
      id: 'user-${now.microsecondsSinceEpoch}',
      name: trimmedName,
      email: normalizedEmail,
      phone: '-',
      address: '-',
      memberSince: now,
      role: UserRole.buyer,
    );

    _credentials.add(
      _UserCredential(email: normalizedEmail, password: password, user: user),
    );

    final session = AuthSession(
      user: user,
      provider: AuthProviderType.password,
      sessionToken: 'demo-${user.id}-${now.millisecondsSinceEpoch}',
    );
    await _writeSession(session);
    return session;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final cached = cachedSession;
    if (cached?.provider == AuthProviderType.google) {
      await _googleSignIn.signOut();
    }

    await _clearSession();
  }

  Future<User> updateProfile(User updatedUser) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final index = _credentials.indexWhere((c) => c.user.id == updatedUser.id);
    if (index != -1) {
      final existing = _credentials[index];
      _credentials[index] = _UserCredential(
        email: updatedUser.email,
        password: existing.password,
        user: updatedUser,
      );
    }

    final cached = cachedSession;
    if (cached != null) {
      final session = AuthSession(
        user: updatedUser,
        provider: cached.provider,
        sessionToken: cached.sessionToken,
      );
      await _writeSession(session);
    }

    return updatedUser;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
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
