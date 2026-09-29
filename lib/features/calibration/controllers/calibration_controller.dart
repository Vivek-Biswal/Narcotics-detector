import 'package:flutter/material.dart';
import '../../../services/service_interfaces.dart';
import '../../../core/enums/app_enums.dart';

class CalibrationController extends ChangeNotifier {
  final ImageAnalysisService imageAnalysisService;

  CalibrationController({required this.imageAnalysisService});

  bool _isProcessing = false;
  double _progress = 0;
  CalibrationStep? _currentStep;
  String? _currentStepLabel;
  bool _completed = false;
  String? _error;
  Map<String, dynamic>? _analysisResult;

  bool get isProcessing => _isProcessing;
  double get progress => _progress;
  CalibrationStep? get currentStep => _currentStep;
  String? get currentStepLabel => _currentStepLabel;
  bool get completed => _completed;
  String? get error => _error;
  Map<String, dynamic>? get analysisResult => _analysisResult;

  Future<void> startCalibration(String imagePath) async {
    _isProcessing = true;
    _completed = false;
    _progress = 0;
    _error = null;
    notifyListeners();

    try {
      await for (final stepData
          in imageAnalysisService.runCalibration(imagePath)) {
        _currentStepLabel = stepData['label'] as String?;
        _progress = (stepData['progress'] as double?) ?? 0;

        final stepName = stepData['step'] as String?;
        _currentStep = _stepFromString(stepName);
        notifyListeners();
      }

      // Get classification result
      _analysisResult =
          await imageAnalysisService.classifyResult(imagePath);
      _completed = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void reset() {
    _isProcessing = false;
    _progress = 0;
    _currentStep = null;
    _currentStepLabel = null;
    _completed = false;
    _error = null;
    _analysisResult = null;
    notifyListeners();
  }

  static CalibrationStep? _stepFromString(String? s) {
    if (s == null) return null;
    switch (s) {
      case 'detectingCard':
        return CalibrationStep.detectingCard;
      case 'normalizingColour':
        return CalibrationStep.normalizingColour;
      case 'detectingTestArea':
        return CalibrationStep.detectingTestArea;
      case 'analysingColour':
        return CalibrationStep.analysingColour;
      case 'preparingResult':
        return CalibrationStep.preparingResult;
      default:
        return null;
    }
  }
}
