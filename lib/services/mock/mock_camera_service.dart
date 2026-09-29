import '../service_interfaces.dart';

/// Mock camera service — returns a placeholder image path.
/// TODO: Replace with camera plugin (camera or camera_awesome).
class MockCameraService implements CameraService {
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initialized = true;
  }

  @override
  Future<String?> captureImage() async {
    // Simulate capture delay
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Return real image path from camera plugin
    return 'mock://captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  bool get isInitialized => _initialized;
}

/// Mock image analysis service.
/// TODO: Replace with real REST calls to FastAPI + OpenCV pipeline.
class MockImageAnalysisService implements ImageAnalysisService {
  @override
  Future<Map<String, dynamic>> detectReferenceCard(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    // Mock: always detect the card
    return {
      'detected': true,
      'confidence': 0.94,
      'bounds': {'x': 40, 'y': 120, 'width': 200, 'height': 120},
      'lightingOk': true,
    };
  }

  @override
  Stream<Map<String, dynamic>> runCalibration(String imagePath) async* {
    final steps = [
      {'step': 'detectingCard', 'label': 'Detecting reference card', 'progress': 0.2},
      {'step': 'normalizingColour', 'label': 'Normalizing colour channels', 'progress': 0.4},
      {'step': 'detectingTestArea', 'label': 'Detecting test area', 'progress': 0.6},
      {'step': 'analysingColour', 'label': 'Analysing colour response', 'progress': 0.8},
      {'step': 'preparingResult', 'label': 'Preparing result', 'progress': 1.0},
    ];

    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 900));
      yield step;
    }
  }

  @override
  Future<Map<String, dynamic>> classifyResult(String imagePath) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Replace with real ML model result classification
    return {
      'result': 'positive',
      'confidence': 0.92,
      'colourDelta': 'ΔE = 42.3',
      'substanceName': 'Heroin Class A (presumptive)',
    };
  }
}
