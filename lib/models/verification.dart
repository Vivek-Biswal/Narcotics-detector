import '../core/enums/app_enums.dart';

class VerificationResult {
  final bool isValid;
  final bool imageHashMatches;
  final bool signatureValid;
  final bool timestampValid;
  final bool locationValid;
  final bool operatorValid;
  final String? testId;
  final String? message;

  const VerificationResult({
    required this.isValid,
    required this.imageHashMatches,
    required this.signatureValid,
    required this.timestampValid,
    required this.locationValid,
    required this.operatorValid,
    this.testId,
    this.message,
  });

  VerificationStatus get status =>
      isValid ? VerificationStatus.verified : VerificationStatus.failed;
}
