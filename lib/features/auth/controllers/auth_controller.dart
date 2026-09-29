import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../models/operator.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthController extends ChangeNotifier {
  final AuthService authService;

  AuthController({required this.authService});

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  Operator? _operator;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Operator? get operator => _operator;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final operator = await authService.login(email, password);
      if (operator != null) {
        _operator = operator;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.error;
        _errorMessage = 'Login failed. Please try again.';
      }
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await authService.logout();
    _operator = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) _status = AuthStatus.idle;
    notifyListeners();
  }
}
