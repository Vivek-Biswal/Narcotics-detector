import '../service_interfaces.dart';
import '../../models/test_record.dart';
import '../../core/enums/app_enums.dart';

/// Mock record service with pre-seeded test data.
/// TODO: Replace with FastAPI / Firebase / PostgreSQL calls.
class MockRecordService implements RecordService {
  final List<TestRecord> _records = [
    TestRecord(
      testId: 'TEST-2026-001',
      result: TestResult.positive,
      operatorId: 'OP-1042',
      timestamp: DateTime(2026, 9, 29, 12, 30),
      latitude: 28.4595,
      longitude: 77.0266,
      imagePath: 'mock://image_001.jpg',
      imageHash: 'a3f4b2c1d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2',
      digitalSignature: 'VALID',
      verificationStatus: VerificationStatus.verified,
      confidenceScore: 0.92,
      substanceName: 'Heroin Class A (presumptive)',
      verificationId: 'VER-2026-001',
    ),
    TestRecord(
      testId: 'TEST-2026-002',
      result: TestResult.negative,
      operatorId: 'OP-1044',
      timestamp: DateTime(2026, 9, 29, 13, 5),
      latitude: 28.4700,
      longitude: 77.0300,
      imagePath: 'mock://image_002.jpg',
      imageHash: 'b4e5c3d2f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3',
      digitalSignature: 'VALID',
      verificationStatus: VerificationStatus.verified,
      confidenceScore: 0.97,
      substanceName: null,
      verificationId: 'VER-2026-002',
    ),
    TestRecord(
      testId: 'TEST-2026-003',
      result: TestResult.inconclusive,
      operatorId: 'OP-1042',
      timestamp: DateTime(2026, 9, 29, 13, 25),
      latitude: 28.4600,
      longitude: 77.0200,
      imagePath: 'mock://image_003.jpg',
      imageHash: 'c5f6d4e3a7b8c9d0e1f2a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5',
      digitalSignature: 'PENDING',
      verificationStatus: VerificationStatus.pending,
      confidenceScore: 0.51,
      substanceName: null,
      verificationId: 'VER-2026-003',
    ),
    TestRecord(
      testId: 'TEST-2026-004',
      result: TestResult.positive,
      operatorId: 'OP-1044',
      timestamp: DateTime(2026, 9, 28, 9, 15),
      latitude: 28.4650,
      longitude: 77.0150,
      imagePath: 'mock://image_004.jpg',
      imageHash: 'd6a7e5f4b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5',
      digitalSignature: 'VALID',
      verificationStatus: VerificationStatus.verified,
      confidenceScore: 0.88,
      substanceName: 'Methamphetamine (presumptive)',
      verificationId: 'VER-2026-004',
    ),
    TestRecord(
      testId: 'TEST-2026-005',
      result: TestResult.negative,
      operatorId: 'OP-1042',
      timestamp: DateTime(2026, 9, 28, 11, 45),
      latitude: 28.4580,
      longitude: 77.0280,
      imagePath: 'mock://image_005.jpg',
      imageHash: 'e7b8f6a5c9d0e1f2a3b4c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7',
      digitalSignature: 'VALID',
      verificationStatus: VerificationStatus.verified,
      confidenceScore: 0.95,
      substanceName: null,
      verificationId: 'VER-2026-005',
    ),
  ];

  @override
  Future<List<TestRecord>> getAllRecords() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.from(_records.reversed);
  }

  @override
  Future<TestRecord?> getRecord(String testId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _records.firstWhere((r) => r.testId == testId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<TestRecord> saveRecord(dynamic record) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final testRecord = record as TestRecord;
    // Remove existing if same ID, then add
    _records.removeWhere((r) => r.testId == testRecord.testId);
    _records.add(testRecord);
    return testRecord;
  }

  @override
  Future<void> deleteRecord(String testId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _records.removeWhere((r) => r.testId == testId);
  }
}
