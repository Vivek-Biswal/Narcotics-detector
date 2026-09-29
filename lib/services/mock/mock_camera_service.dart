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

