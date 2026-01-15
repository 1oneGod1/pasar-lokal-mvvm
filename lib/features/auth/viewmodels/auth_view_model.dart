import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pasar_lokal_mvvm/core/models/demo_account.dart';
import 'package:pasar_lokal_mvvm/core/models/user.dart';
import 'package:pasar_lokal_mvvm/core/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository) {
    _currentUser = _repository.cachedSession?.user;
    _sessionToken = _repository.cachedSession?.sessionToken;
    unawaited(restoreSession());
  }

  final AuthRepository _repository;

  User? _currentUser;
  String? _sessionToken;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get sessionToken => _sessionToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isSeller => _currentUser?.isSeller ?? false;
  String? get sellerId => _currentUser?.sellerId;
  List<DemoAccount> get demoAccounts => _repository.demoAccounts;

  Future<void> restoreSession() async {
    if (_isLoading) return;

    _setLoading(true);
    try {
      final session = await _repository.restoreSession();
      _currentUser = session?.user;
      _sessionToken = session?.sessionToken;
      _errorMessage = null;
    } catch (_) {
      _currentUser = null;
      _sessionToken = null;
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final session = await _repository.login(email, password);
      if (session == null) {
        _errorMessage = 'Email atau kata sandi salah. Coba lagi ya!';
        _setLoading(false);
        notifyListeners();
        return false;
      }
      _currentUser = session.user;
      _sessionToken = session.sessionToken;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Terjadi masalah. Silakan coba lagi.';
      _setLoading(false);
      notifyListeners();
      if (kDebugMode) {
        print('Login error: $error');
      }
      return false;
    }
  }

  Future<void> logout() async {
    if (_isLoading) return;

    _setLoading(true);
    await _repository.logout();
    _currentUser = null;
    _sessionToken = null;
    _errorMessage = null;
    _setLoading(false);
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> registerBuyer({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_isLoading) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final session = await _repository.registerBuyer(
        name: name,
        email: email,
        password: password,
      );

      if (session == null) {
        _errorMessage = 'Email sudah terdaftar. Gunakan email lain ya.';
        _setLoading(false);
        notifyListeners();
        return false;
      }

      _currentUser = session.user;
      _sessionToken = session.sessionToken;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Gagal daftar. Pastikan data sudah benar.';
      _setLoading(false);
      notifyListeners();
      if (kDebugMode) {
        print('Register error: $error');
      }
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    if (_isLoading) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final session = await _repository.loginWithGoogle();
      _currentUser = session.user;
      _sessionToken = session.sessionToken;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (error) {
      final message = error.toString();
      if (message.contains('GOOGLE_WEB_CLIENT_ID')) {
        _errorMessage =
            'Google Sign-In belum dikonfigurasi. Hubungkan Client ID (web) dulu.';
      } else if (message.contains('AUTH_CANCELLED')) {
        _errorMessage = 'Login dibatalkan.';
      } else {
        _errorMessage = 'Gagal masuk dengan Google. Coba lagi ya.';
      }
      _setLoading(false);
      notifyListeners();
      if (kDebugMode) {
        print('Google login error: $error');
      }
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    if (_isLoading) return false;
    final current = _currentUser;
    if (current == null) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final updated = User(
        id: current.id,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        address: address.trim(),
        memberSince: current.memberSince,
        role: current.role,
        sellerId: current.sellerId,
      );

      final saved = await _repository.updateProfile(updated);
      _currentUser = saved;
      _errorMessage = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = 'Gagal memperbarui profil.';
      _setLoading(false);
      notifyListeners();
      if (kDebugMode) {
        print('Update profile error: $error');
      }
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
