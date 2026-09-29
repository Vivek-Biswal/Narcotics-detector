import '../service_interfaces.dart';
import '../../models/verification.dart';

/// Mock verification service.
/// TODO: Replace with real cryptographic verification:
/// - SHA-256 hash comparison of stored vs computed image hash
/// - ECDSA/RSA signature validation
/// - Timestamp and location integrity check
class MockVerificationService implements VerificationService {
  // Known tampered IDs for demo
  static const _tamperedIds = {'TEST-2026-TAMPERED'};

  @override
  Future<VerificationResult> verifyRecord(String testId) async {
    await Future.delayed(const Duration(seconds: 2));

    if (_tamperedIds.contains(testId)) {
      return const VerificationResult(
        isValid: false,
        imageHashMatches: false,
        signatureValid: false,
        timestampValid: true,
        locationValid: true,
        operatorValid: true,
        testId: 'TEST-2026-TAMPERED',
        message: 'RECORD INTEGRITY FAILED',
      );
    }

    // Mock: all checks pass for known records
    return VerificationResult(
      isValid: true,
      imageHashMatches: true,
      signatureValid: true,
      timestampValid: true,
      locationValid: true,
      operatorValid: true,
      testId: testId,
      message: 'Record integrity verified.',
    );
  }

  @override
  Future<VerificationResult> verifyFromQr(String qrData) async {
    // TODO: Parse real QR data and call verifyRecord
    final testId = qrData.split('|').first;
    return verifyRecord(testId);
  }
}

/// Mock QR service.
/// TODO: Replace with qr_flutter for generation and mobile_scanner for scanning.
class MockQrService implements QrService {
  @override
  String generateQrData(String testId, String verificationId) {
    // TODO: Replace with real signed QR payload (JWT or JSON with signature)
    return '$testId|$verificationId|${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String?> scanQr() async {
    // TODO: Launch mobile_scanner and return scanned QR string
    await Future.delayed(const Duration(seconds: 1));
    return 'TEST-2026-001|VER-2026-001|1727594400000';
  }
}
