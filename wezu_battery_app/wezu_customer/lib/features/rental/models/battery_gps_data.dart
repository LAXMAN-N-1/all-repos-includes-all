import 'package:google_maps_flutter/google_maps_flutter.dart';

class BatteryGpsData {
  final String batteryId;
  final LatLng location;
  final double accuracy; // in meters
  final DateTime lastUpdated;
  final bool isInsideGeofence;
  final List<LatLng> history;

  BatteryGpsData({
    required this.batteryId,
    required this.location,
    required this.accuracy,
    required this.lastUpdated,
    required this.isInsideGeofence,
    required this.history,
  });

  BatteryGpsData copyWith({
    LatLng? location,
    double? accuracy,
    DateTime? lastUpdated,
    bool? isInsideGeofence,
    List<LatLng>? history,
  }) {
    return BatteryGpsData(
      batteryId: batteryId,
      location: location ?? this.location,
      accuracy: accuracy ?? this.accuracy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isInsideGeofence: isInsideGeofence ?? this.isInsideGeofence,
      history: history ?? this.history,
    );
  }
}
