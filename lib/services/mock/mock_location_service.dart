import '../service_interfaces.dart';

/// Mock location service.
/// TODO: Replace with geolocator plugin for real GPS coordinates.
class MockLocationService implements LocationService {
  @override
  Future<Map<String, double>> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // TODO: Call geolocator.getCurrentPosition()
    return {
      'latitude': 28.4595 + (DateTime.now().millisecond / 100000),
      'longitude': 77.0266 + (DateTime.now().microsecond / 100000),
    };
  }
}
