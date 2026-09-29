import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:narcotics_detector/main.dart';
import 'package:narcotics_detector/features/auth/controllers/auth_controller.dart';
import 'package:narcotics_detector/services/mock/mock_auth_service.dart';

void main() {
  testWidgets('NarcTrace app smoke test — renders without crashing',
      (WidgetTester tester) async {
    // Build the full app (NarcoticsDetectorApp) and trigger a frame.
    await tester.pumpWidget(const NarcoticsDetectorApp());
    await tester.pump(const Duration(milliseconds: 300));

    // The app should render the login screen root.
    // We just verify the app starts up without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('AuthController starts unauthenticated',
      (WidgetTester tester) async {
    final auth = AuthController(authService: MockAuthService());
    expect(auth.isAuthenticated, isFalse);
    expect(auth.operator, isNull);
  });
}
