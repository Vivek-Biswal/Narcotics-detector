import '../auth_service.dart';
import '../../models/operator.dart';

/// Mock implementation of AuthService for frontend prototype.
/// TODO: Replace with real Firebase Auth / JWT service.
class MockAuthService implements AuthService {
  Operator? _currentOperator;

  static const _mockUsers = {
    'op1042@cnb.gov.in': {
      'password': 'pass1234',
      'id': 'OP-1042',
      'name': 'Arjun Sharma',
      'badge': 'CNB-1042',
      'unit': 'North Zone Unit',
    },
    'op1044@cnb.gov.in': {
      'password': 'pass1234',
      'id': 'OP-1044',
      'name': 'Priya Nair',
      'badge': 'CNB-1044',
      'unit': 'South Zone Unit',
    },
    'admin@cnb.gov.in': {
      'password': 'admin123',
      'id': 'OP-ADMIN',
      'name': 'Admin User',
      'badge': 'CNB-ADMIN',
      'unit': 'HQ Operations',
    },
  };

  @override
  Future<Operator?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final userData = _mockUsers[email.toLowerCase().trim()];
    if (userData == null || userData['password'] != password) {
      throw Exception('Invalid credentials. Please check your Operator ID and password.');
    }

    _currentOperator = Operator(
      id: userData['id']!,
      name: userData['name']!,
      email: email.toLowerCase().trim(),
      badge: userData['badge']!,
      unit: userData['unit']!,
      avatarInitials: userData['name']!
          .split(' ')
          .take(2)
          .map((e) => e[0])
          .join(),
    );
    return _currentOperator;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentOperator = null;
  }

  @override
  bool get isLoggedIn => _currentOperator != null;

  @override
  Operator? get currentOperator => _currentOperator;
}
