import 'package:flutter/material.dart';
import '../../../models/verification.dart';
import '../../../services/service_interfaces.dart';
import '../../../core/enums/app_enums.dart';

enum VerifyStatus { idle, verifying, verified, failed, error }

class VerificationController extends ChangeNotifier {
  final VerificationService verificationService;

  VerificationController({required this.verificationService});

  VerifyStatus _status = VerifyStatus.idle;
  VerificationResult? _result;
  String? _error;
  String _manualTestId = '';

  VerifyStatus get status => _status;
  VerificationResult? get result => _result;
  String? get error => _error;
  String get manualTestId => _manualTestId;
  bool get isVerifying => _status == VerifyStatus.verifying;

  void setManualTestId(String id) {
    _manualTestId = id;
    notifyListeners();
  }

  Future<void> verifyById(String testId) async {
    _status = VerifyStatus.verifying;
    _result = null;
    _error = null;
    notifyListeners();

    try {
      final result = await verificationService.verifyRecord(testId);
      _result = result;
      _status = result.isValid ? VerifyStatus.verified : VerifyStatus.failed;
    } catch (e) {
      _error = e.toString();
      _status = VerifyStatus.error;
    }
    notifyListeners();
  }

  Future<void> verifyFromQr(String qrData) async {
    _status = VerifyStatus.verifying;
    _result = null;
    _error = null;
    notifyListeners();

    try {
      final result = await verificationService.verifyFromQr(qrData);
      _result = result;
      _status = result.isValid ? VerifyStatus.verified : VerifyStatus.failed;
    } catch (e) {
      _error = e.toString();
      _status = VerifyStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = VerifyStatus.idle;
    _result = null;
    _error = null;
    _manualTestId = '';
    notifyListeners();
  }
}
