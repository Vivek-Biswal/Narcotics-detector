import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/capture/screens/camera_capture_screen.dart';
import '../../features/capture/screens/reference_detection_screen.dart';
import '../../features/calibration/screens/calibration_screen.dart';
import '../../features/result/screens/result_screen.dart';
import '../../features/records/screens/digital_record_screen.dart';
import '../../features/verification/screens/qr_verification_screen.dart';
import '../../features/history/screens/test_history_screen.dart';
import '../../features/history/screens/test_details_screen.dart';
import '../../models/test_record.dart';

class AppRouter {
  final AuthController authController;

  AppRouter({required this.authController});

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    debugLogDiagnostics: true,
    redirect: _redirect,
    refreshListenable: authController,
    routes: [
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.cameraCapture,
        name: 'cameraCapture',
        builder: (context, state) => const CameraCaptureScreen(),
      ),
      GoRoute(
        path: RouteNames.referenceDetection,
        name: 'referenceDetection',
        builder: (context, state) => const ReferenceDetectionScreen(),
      ),
      GoRoute(
        path: RouteNames.calibration,
        name: 'calibration',
        builder: (context, state) => const CalibrationScreen(),
      ),
      GoRoute(
        path: RouteNames.result,
        name: 'result',
        builder: (context, state) => const ResultScreen(),
      ),
      GoRoute(
        path: RouteNames.digitalRecord,
        name: 'digitalRecord',
        builder: (context, state) => const DigitalRecordScreen(),
      ),
      GoRoute(
        path: RouteNames.qrVerification,
        name: 'qrVerification',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'] ?? 'generate';
          return QrVerificationScreen(mode: mode);
        },
      ),
      GoRoute(
        path: RouteNames.testHistory,
        name: 'testHistory',
        builder: (context, state) => const TestHistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.testDetails,
        name: 'testDetails',
        builder: (context, state) {
          final record = state.extra as TestRecord?;
          return TestDetailsScreen(record: record);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Route not found: ${state.uri}'),
            TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authController.isAuthenticated;
    final isLoginRoute = state.matchedLocation == RouteNames.login;

    if (!isAuthenticated && !isLoginRoute) return RouteNames.login;
    if (isAuthenticated && isLoginRoute) return RouteNames.dashboard;
    return null;
  }
}
