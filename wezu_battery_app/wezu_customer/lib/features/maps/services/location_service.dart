import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationService {
  // Center on Ongole for consistent demo experience as requested
  static const LatLng ongole = LatLng(15.5057, 80.0493);

  Future<Position> getCurrentPositionWithFallback() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getFallbackPosition();
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getFallbackPosition();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getFallbackPosition();
      }

      // Robust 5 second timeout for faster fallback UX
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => _getFallbackPosition(),
      );
    } catch (e) {
      debugPrint("Location Error: $e. Falling back to Ongole.");
      return _getFallbackPosition();
    }
  }

  Position _getFallbackPosition() {
    return Position(
      longitude: 80.0493,
      latitude: 15.5057,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}

final locationServiceProvider = Provider((ref) => LocationService());
