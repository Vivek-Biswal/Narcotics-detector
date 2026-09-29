import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/capture/controllers/capture_controller.dart';
import 'features/calibration/controllers/calibration_controller.dart';
import 'features/result/controllers/result_controller.dart';
import 'features/records/controllers/record_controller.dart';
import 'features/verification/controllers/verification_controller.dart';
import 'features/history/controllers/history_controller.dart';
import 'services/mock/mock_auth_service.dart';
import 'services/mock/mock_camera_service.dart';
import 'services/mock/mock_image_analysis_service.dart';
import 'services/mock/mock_location_service.dart';
import 'services/mock/mock_record_service.dart';
import 'services/mock/mock_verification_service.dart';
import 'services/mock/mock_qr_service.dart';
import 'repositories/test_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NarcoticsDetectorApp());
}

class NarcoticsDetectorApp extends StatelessWidget {
  const NarcoticsDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate mock services
    final authService = MockAuthService();
    final cameraService = MockCameraService();
    final imageAnalysisService = MockImageAnalysisService();
    final locationService = MockLocationService();
    final recordService = MockRecordService();
    final verificationService = MockVerificationService();
    final qrService = MockQrService();
    final testRepository = TestRepository(recordService: recordService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => CaptureController(
            cameraService: cameraService,
            locationService: locationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CalibrationController(
            imageAnalysisService: imageAnalysisService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ResultController(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecordController(
            recordService: recordService,
            testRepository: testRepository,
            qrService: qrService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VerificationController(
            verificationService: verificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryController(testRepository: testRepository),
        ),
      ],
      child: const AppRoot(),
    );
  }
}
