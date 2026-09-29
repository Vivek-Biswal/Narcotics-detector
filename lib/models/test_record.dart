import 'package:equatable/equatable.dart';
import '../core/enums/app_enums.dart';

class TestRecord extends Equatable {
  final String testId;
  final TestResult result;
  final String operatorId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String imagePath;       // Will be a real path / URI later
  final String imageHash;       // TODO: Real SHA-256 of image bytes
  final String digitalSignature; // TODO: Real ECDSA / RSA signature
  final VerificationStatus verificationStatus;
  final double? confidenceScore; // 0.0 – 1.0 from ML model
  final String? substanceName;   // e.g. "Heroin Class A"
  final String? notes;
  final String? verificationId;

  const TestRecord({
    required this.testId,
    required this.result,
    required this.operatorId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.imageHash,
    required this.digitalSignature,
    required this.verificationStatus,
    this.confidenceScore,
    this.substanceName,
    this.notes,
    this.verificationId,
  });

  String get locationString =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  TestRecord copyWith({
    String? testId,
    TestResult? result,
    String? operatorId,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? imagePath,
    String? imageHash,
    String? digitalSignature,
    VerificationStatus? verificationStatus,
    double? confidenceScore,
    String? substanceName,
    String? notes,
    String? verificationId,
  }) {
    return TestRecord(
      testId: testId ?? this.testId,
      result: result ?? this.result,
      operatorId: operatorId ?? this.operatorId,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      imageHash: imageHash ?? this.imageHash,
      digitalSignature: digitalSignature ?? this.digitalSignature,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      substanceName: substanceName ?? this.substanceName,
      notes: notes ?? this.notes,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  Map<String, dynamic> toJson() => {
        'testId': testId,
        'result': result.name,
        'operatorId': operatorId,
        'timestamp': timestamp.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'imagePath': imagePath,
        'imageHash': imageHash,
        'digitalSignature': digitalSignature,
        'verificationStatus': verificationStatus.name,
        'confidenceScore': confidenceScore,
        'substanceName': substanceName,
        'notes': notes,
        'verificationId': verificationId,
      };

  @override
  List<Object?> get props => [testId, result, operatorId, timestamp];
}
