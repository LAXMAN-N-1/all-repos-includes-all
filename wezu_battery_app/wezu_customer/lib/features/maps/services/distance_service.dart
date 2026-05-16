import 'dart:math';

/// Utility service for distance calculations
class DistanceService {
  /// Haversine formula to calculate distance between two coordinates in meters
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  /// Format distance as human-readable string
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Estimate travel time in minutes (rough: 30 km/h average city speed)
  static int estimateTravelTime(double meters) {
    const averageSpeedMps = 30000 / 3600; // 30 km/h in m/s
    return (meters / averageSpeedMps / 60).ceil();
  }
}
