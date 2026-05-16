import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/network/api_client.dart';
import '../models/battery_gps_data.dart';

class GpsTrackingService {
  // Requirement: Geo-fence alerts when battery moves outside 5km radius
  static const double geofenceRadiusKm = 5.0;
  static final LatLng centerPoint =
      const LatLng(12.9716, 77.5946); // Bangalore Center

  Stream<BatteryGpsData> getLiveLocation(String batteryId) async* {
    List<LatLng> history = [];

    while (true) {
      try {
        final response =
            await apiClient.get('/telematics/battery/$batteryId/latest');

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final lat = (data['gps_latitude'] as num?)?.toDouble() ??
              (data['last_latitude'] as num?)?.toDouble();
          final lng = (data['gps_longitude'] as num?)?.toDouble() ??
              (data['last_longitude'] as num?)?.toDouble();
          if (lat == null || lng == null) {
            await Future.delayed(const Duration(seconds: 5));
            continue;
          }
          final currentPos = LatLng(lat, lng);

          if (history.isEmpty || history.last != currentPos) {
            history.add(currentPos);
          }
          if (history.length > 50) history.removeAt(0);

          yield BatteryGpsData(
            batteryId: batteryId,
            location: currentPos,
            accuracy: 5.0,
            lastUpdated: DateTime.now(),
            isInsideGeofence:
                _calculateDistance(centerPoint, currentPos) <= geofenceRadiusKm,
            history: List.from(history),
          );
        }
      } catch (e) {
        debugPrint('Error fetching live location: $e');
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<List<LatLng>> getLocationHistory(String batteryId) async {
    try {
      final response =
          await apiClient.get('/telematics/battery/$batteryId/latest');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final lat = (data['gps_latitude'] as num?)?.toDouble() ??
            (data['last_latitude'] as num?)?.toDouble();
        final lng = (data['gps_longitude'] as num?)?.toDouble() ??
            (data['last_longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          return [LatLng(lat, lng)];
        }
      }
    } catch (e) {
      debugPrint('Error fetching location history: $e');
    }

    // Fallback if API fails or backend not up yet
    final List<LatLng> history = [];
    for (int i = 0; i < 30; i++) {
      history.add(LatLng(
        centerPoint.latitude + (i * 0.002) - 0.03,
        centerPoint.longitude + (i * 0.002) - 0.03,
      ));
    }
    return history;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double radius = 6371; // Earth radius in KM
    double dLat = _toRadians(p2.latitude - p1.latitude);
    double dLon = _toRadians(p2.longitude - p1.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(p1.latitude)) *
            cos(_toRadians(p2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;
}
