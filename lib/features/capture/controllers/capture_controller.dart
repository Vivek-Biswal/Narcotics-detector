import 'package:flutter/material.dart';
import '../../../services/service_interfaces.dart';
import '../../../core/enums/app_enums.dart';

class CaptureController extends ChangeNotifier {
  final CameraService cameraService;
  final LocationService locationService;

  CaptureController({
    required this.cameraService,
    required this.locationService,
  });

  CaptureState _state = CaptureState.idle;
  String? _capturedImagePath;
  String? _error;
  double? _latitude;
  double? _longitude;

  CaptureState get state => _state;
  String? get capturedImagePath => _capturedImagePath;
  String? get error => _error;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  Future<void> initialize() async {
    _state = CaptureState.previewing;
    notifyListeners();
    await cameraService.initialize();
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final loc = await locationService.getCurrentLocation();
      _latitude = loc['latitude'];
      _longitude = loc['longitude'];
    } catch (_) {
      // Location is optional — fail silently
    }
  }

  Future<void> capture() async {
    _state = CaptureState.idle;
    notifyListeners();
    try {
      final path = await cameraService.captureImage();
      if (path != null) {
        _capturedImagePath = path;
        _state = CaptureState.captured;
      } else {
        _state = CaptureState.previewing;
      }
    } catch (e) {
      _error = e.toString();
      _state = CaptureState.qualityWarning;
    }
    notifyListeners();
  }

  void retake() {
    _capturedImagePath = null;
    _state = CaptureState.previewing;
    _error = null;
    notifyListeners();
  }

  void confirmCapture() {
    // Proceed — capturedImagePath is set
    notifyListeners();
  }

  @override
  void dispose() {
    cameraService.dispose();
    super.dispose();
  }
}
