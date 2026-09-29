/// Abstract camera service interface.
/// TODO: Replace with real camera_plus / camera plugin integration.
abstract class CameraService {
  Future<void> initialize();
  Future<String?> captureImage();
  Future<void> dispose();
  bool get isInitialized;
}

/// Abstract image analysis service.
/// TODO: Replace with real OpenCV / ML model inference calls to FastAPI.
abstract class ImageAnalysisService {
  /// Detect reference colour card bounding box in image.
  /// Returns a map with 'detected' bool and optional 'bounds' data.
  Future<Map<String, dynamic>> detectReferenceCard(String imagePath);

  /// Run full calibration pipeline.
  /// Returns step-by-step status updates via a Stream.
  Stream<Map<String, dynamic>> runCalibration(String imagePath);

  /// Classify test result from calibrated image.
  Future<Map<String, dynamic>> classifyResult(String imagePath);
}

/// Abstract location service.
/// TODO: Replace with geolocator plugin.
abstract class LocationService {
  Future<Map<String, double>> getCurrentLocation();
}

/// Abstract record service.
/// TODO: Replace with FastAPI / Firebase calls.
abstract class RecordService {
  Future<List<dynamic>> getAllRecords();
  Future<dynamic> getRecord(String testId);
  Future<dynamic> saveRecord(dynamic record);
  Future<void> deleteRecord(String testId);
}

/// Abstract verification service.
/// TODO: Replace with real cryptographic verification (SHA-256 + digital signature check).
abstract class VerificationService {
  Future<dynamic> verifyRecord(String testId);
  Future<dynamic> verifyFromQr(String qrData);
}

/// Abstract QR service.
/// TODO: Replace with real QR generation using qr_flutter and QR scanning with mobile_scanner.
abstract class QrService {
  String generateQrData(String testId, String verificationId);
  Future<String?> scanQr();
}
