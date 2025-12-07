import 'package:flutter/foundation.dart';
import 'package:pasar_lokal_mvvm/core/models/demo_account.dart';
import 'package:pasar_lokal_mvvm/core/models/user.dart';
import 'package:pasar_lokal_mvvm/core/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;
  bool get isSeller => _currentUser?.isSeller ?? false;
  String? get sellerId => _currentUser?.sellerId;
  List<DemoAccount> get demoAccounts => _repository.demoAccounts;

  Future<bool> login(String email, String password) async {
    if (_isLoading) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _repository.login(email, password);
      if (user == null) {
        _errorMessage = 'Email atau kata sandi salah. Coba lagi ya!';
        _setLoading(false);
        notifyListeners();
        return false;
      }
      _currentUser = user;
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

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
