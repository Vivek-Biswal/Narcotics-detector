import 'package:flutter/material.dart';
import '../../../core/enums/app_enums.dart';
import '../../../features/auth/controllers/auth_controller.dart';

class ResultController extends ChangeNotifier {
  TestResult? _result;
  double? _confidence;
  String? _substanceName;
  String? _colourDelta;
  String? _capturedImagePath;
  double? _latitude;
  double? _longitude;

  TestResult? get result => _result;
  double? get confidence => _confidence;
  String? get substanceName => _substanceName;
  String? get colourDelta => _colourDelta;
  String? get capturedImagePath => _capturedImagePath;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  void setFromAnalysis(Map<String, dynamic> analysisData) {
    final resultStr = analysisData['result'] as String? ?? 'inconclusive';
    _result = _parseResult(resultStr);
    _confidence = analysisData['confidence'] as double?;
    _substanceName = analysisData['substanceName'] as String?;
    _colourDelta = analysisData['colourDelta'] as String?;
    notifyListeners();
  }

  void setLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    notifyListeners();
  }

  void setImagePath(String path) {
    _capturedImagePath = path;
    notifyListeners();
  }

  void reset() {
    _result = null;
    _confidence = null;
    _substanceName = null;
    _colourDelta = null;
    _capturedImagePath = null;
    notifyListeners();
  }

  static TestResult _parseResult(String s) {
    switch (s.toLowerCase()) {
      case 'positive':
        return TestResult.positive;
      case 'negative':
        return TestResult.negative;
      default:
        return TestResult.inconclusive;
    }
  }
}
