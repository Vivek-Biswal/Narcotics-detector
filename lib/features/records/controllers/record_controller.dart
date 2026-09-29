import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../services/service_interfaces.dart';
import '../../../repositories/test_repository.dart';
import '../../../models/test_record.dart';
import '../../../core/enums/app_enums.dart';

enum RecordStatus { idle, saving, saved, error }

class RecordController extends ChangeNotifier {
  final RecordService recordService;
  final TestRepository testRepository;
  final QrService qrService;

  RecordController({
    required this.recordService,
    required this.testRepository,
    required this.qrService,
  });

  RecordStatus _status = RecordStatus.idle;
  TestRecord? _currentRecord;
  String? _error;
  String? _qrData;

  RecordStatus get status => _status;
  TestRecord? get currentRecord => _currentRecord;
  String? get error => _error;
  String? get qrData => _qrData;

  void prepareNewRecord({
    required TestResult result,
    required String operatorId,
    required String testId,
    required double latitude,
    required double longitude,
    required String imagePath,
    double? confidence,
    String? substanceName,
  }) {
    // TODO: Replace with real SHA-256 hash of actual image bytes
    final mockHash =
        'a3f4b2c1d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    _currentRecord = TestRecord(
      testId: testId,
      result: result,
      operatorId: operatorId,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
      imageHash: mockHash,
      digitalSignature: 'PENDING', // TODO: Real ECDSA/RSA signature
      verificationStatus: VerificationStatus.pending,
      confidenceScore: confidence,
      substanceName: substanceName,
      verificationId: 'VER-${const Uuid().v4().substring(0, 8).toUpperCase()}',
    );
    _status = RecordStatus.idle;
    notifyListeners();
  }

  Future<void> saveRecord() async {
    if (_currentRecord == null) return;

    _status = RecordStatus.saving;
    _error = null;
    notifyListeners();

    try {
      // TODO: Sign record with operator's private key before saving
      // TODO: Call FastAPI endpoint to store record
      final saved = await testRepository.save(_currentRecord!);
      _currentRecord = saved.copyWith(
        verificationStatus: VerificationStatus.verified,
        digitalSignature: 'VALID',
      );
      _qrData = qrService.generateQrData(
        _currentRecord!.testId,
        _currentRecord!.verificationId ?? '',
      );
      _status = RecordStatus.saved;
    } catch (e) {
      _error = e.toString();
      _status = RecordStatus.error;
    }
    notifyListeners();
  }

  void loadRecord(TestRecord record) {
    _currentRecord = record;
    _qrData = qrService.generateQrData(
      record.testId,
      record.verificationId ?? '',
    );
    _status = RecordStatus.saved;
    notifyListeners();
  }

  void reset() {
    _status = RecordStatus.idle;
    _currentRecord = null;
    _error = null;
    _qrData = null;
    notifyListeners();
  }
}
