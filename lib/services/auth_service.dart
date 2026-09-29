import '../models/operator.dart';

/// Abstract auth service interface.
/// TODO: Replace MockAuthService with real Firebase Auth or JWT backend.
abstract class AuthService {
  Future<Operator?> login(String email, String password);
  Future<void> logout();
  bool get isLoggedIn;
  Operator? get currentOperator;
}
