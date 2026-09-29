import '../service_interfaces.dart';

/// Mock image analysis service.
/// TODO: Replace with real OpenCV processing via FastAPI endpoint
/// or platform channels to native OpenCV library.
class MockImageAnalysisService implements ImageAnalysisService {
  @override
  Future<Map<String, dynamic>> detectReferenceCard(String imagePath) async {
    // TODO: Call FastAPI /detect-reference endpoint with image bytes
    await Future.delayed(const Duration(seconds: 2));
    return {
      'detected': true,
      'bounds': {'x': 40, 'y': 120, 'width': 200, 'height': 120},
      'confidence': 0.94,
      'lighting': 'adequate',
      'orientation': 'correct',
    };
  }

  @override
  Stream<Map<String, dynamic>> runCalibration(String imagePath) async* {
    // TODO: Replace with real calibration pipeline via FastAPI
    final steps = [
      {'step': 'detectingCard', 'label': 'Detecting reference card...', 'progress': 0.2},
      {'step': 'normalizingColour', 'label': 'Normalizing colours...', 'progress': 0.4},
      {'step': 'detectingTestArea', 'label': 'Detecting test area...', 'progress': 0.6},
      {'step': 'analysingColour', 'label': 'Analysing colour change...', 'progress': 0.8},
      {'step': 'preparingResult', 'label': 'Preparing result...', 'progress': 1.0},
    ];

    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 800));
      yield step;
    }
  }

  @override
  Future<Map<String, dynamic>> classifyResult(String imagePath) async {
    // TODO: Replace with real ML classification result from FastAPI
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'result': 'positive',
      'confidence': 0.92,
      'substanceName': 'Heroin Class A (presumptive)',
      'colourDelta': 'ΔE = 42.3',
      'testType': 'Marquis Reagent',
    };
  }
}
