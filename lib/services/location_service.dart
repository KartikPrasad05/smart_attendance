import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Safely get current GPS location
  /// Returns Position or null if:
  /// - Location disabled
  /// - Permission denied
  /// - Any error occurs
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check GPS ON/OFF
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      // Check Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // If still denied → return null
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // Fetch the current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

    } catch (e) {
      // Any error → return null safely
      return null;
    }
  }

  /// Calculate distance between two coordinates in meters
  static double distance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  /// Check if student is inside allowed GPS range (default: 30 meters)
  static Future<bool> isWithinRange({
    required double centerLat,
    required double centerLng,
    double radius = 30,
  }) async {
    final pos = await getCurrentLocation();
    if (pos == null) return false;

    final d = distance(centerLat, centerLng, pos.latitude, pos.longitude);
    return d <= radius;
  }
}
