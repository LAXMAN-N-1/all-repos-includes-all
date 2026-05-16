import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/station.dart';
import '../models/filter_state.dart';
import '../repositories/station_repository.dart';
import '../../../core/network/dio_provider.dart';
import '../services/location_service.dart';
import 'filter_providers.dart';

// Provider for the Repository
final stationRepositoryProvider = Provider<StationRepository>((ref) {
  final apiClient = ref.watch(authenticatedDioProvider);
  return StationRepositoryImpl(apiClient);
});

final defaultLocation = Position(
  longitude: 78.3823,
  latitude: 17.4416,
  timestamp: DateTime.now(),
  accuracy: 0,
  altitude: 0,
  heading: 0,
  speed: 0,
  speedAccuracy: 0,
  altitudeAccuracy: 0,
  headingAccuracy: 0,
);

// Provider for User Location
final userLocationProvider = FutureProvider<Position>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentPositionWithFallback();
});

// Stream Provider for Continuous Location Updates
final userLocationStreamProvider = StreamProvider<Position>((ref) async* {
  final locationService = ref.watch(locationServiceProvider);

  // Initial position
  yield await locationService.getCurrentPositionWithFallback();

  const locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10,
  );

  yield* Geolocator.getPositionStream(locationSettings: locationSettings);
});

enum StationSortFilter { distance, availability, rating }

final stationSortProvider =
    StateProvider<StationSortFilter>((ref) => StationSortFilter.distance);

final stationFilterProvider = Provider<StationFilterState>((ref) {
  return ref.watch(filterNotifierProvider);
});

final selectedStationProvider = StateProvider<Station?>((ref) => null);

// Provider to trigger a search from the filter UI
final searchAreaRequestedProvider = StateProvider<bool>((ref) => false);

// Provider for Nearby Stations with Sorting and Filtering
final nearbyStationsProvider = FutureProvider<List<Station>>((ref) async {
  final repository = ref.watch(stationRepositoryProvider);

  // Use one-time location fetch instead of the live stream.
  // The live stream rebuilds this provider on every GPS tick (every 10m),
  // causing one API request per consumer per tick — 3+ simultaneous floods.
  // Periodic refresh is handled by StationLocatorScreen's auto-refresh timer.
  final locationAsync = ref.watch(userLocationProvider);

  final userLocation = locationAsync.when(
    data: (pos) => pos,
    loading: () => defaultLocation,
    error: (_, __) => defaultLocation,
  );

  final sortBy = ref.watch(stationSortProvider);
  final filters = ref.watch(stationFilterProvider);

  var stations = await repository.getNearbyStations(
      userLocation.latitude, userLocation.longitude);

  // Calculate distances and Apply Filtering
  stations = stations.where((station) {
    // 1. Calculate Distance
    station.distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      station.latitude,
      station.longitude,
    );

    // 2. Radius Filter
    if (station.distance! > filters.maxRadius * 1000) {
      return false;
    }

    // 3. Price Filter
    if (station.pricePerHour < filters.minPrice ||
        station.pricePerHour > filters.maxPrice) {
      return false;
    }

    // 4. Rating Filter
    if (station.rating < filters.minRating) {
      return false;
    }

    // 5. Availability Filter
    if (filters.onlyAvailable && station.status != 'active') {
      return false;
    }
    if (filters.onlyAvailable && station.availableBatteries == 0) {
      return false;
    }

    // 6. Battery Type Filter
    if (filters.batteryTypes.isNotEmpty &&
        !filters.batteryTypes.contains(station.batteryType)) {
      return false;
    }

    // 7. Charging Speed Filter
    if (filters.chargingSpeeds.isNotEmpty &&
        !filters.chargingSpeeds.contains(station.chargingSpeed)) {
      return false;
    }

    // 8. 24/7 Filter
    if (filters.is24x7 && !station.is24x7) {
      return false;
    }

    // 9. Capacity Filter
    if (station.batteryCapacity < filters.minCapacity) {
      return false;
    }

    // 10. Dealer Filter
    if (filters.isDealer != null && station.isDealer != filters.isDealer) {
      return false;
    }

    // 11. Open Now Filter
    if (filters.isOpenNow) {
      if (!station.is24x7) {
        final now = DateTime.now();
        final hour = now.hour;
        final openHour =
            int.tryParse(station.openingTime?.split(':').first ?? '0') ?? 0;
        final closeHour =
            int.tryParse(station.closingTime?.split(':').first ?? '23') ?? 23;
        if (hour < openHour || hour >= closeHour) {
          return false;
        }
      }
    }

    // 12. Amenities Filter
    if (filters.amenities.isNotEmpty) {
      for (final amenity in filters.amenities) {
        if (!station.amenities.contains(amenity)) {
          return false;
        }
      }
    }

    return true;
  }).toList();

  // Sorting
  switch (sortBy) {
    case StationSortFilter.distance:
      stations.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
      break;
    case StationSortFilter.availability:
      stations
          .sort((a, b) => b.availableBatteries.compareTo(a.availableBatteries));
      break;
    case StationSortFilter.rating:
      stations.sort((a, b) => b.rating.compareTo(a.rating));
      break;
  }

  return stations;
});
