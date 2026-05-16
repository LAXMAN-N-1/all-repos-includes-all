import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../maps/models/station.dart';
import '../repositories/battery_repository.dart';
import '../repositories/rental_repository.dart';
import '../services/swap_request_service.dart';
import '../models/battery.dart';
import '../models/rental.dart';

// Repositories
final batteryRepositoryProvider = Provider<BatteryRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return BatteryRepositoryImpl(dio);
});

final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return RentalRepositoryImpl(dio);
});

// Swap Service Provider
final swapRequestServiceProvider = Provider<SwapRequestService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return SwapRequestService(dio);
});

// Data Providers
final batteriesAtStationProvider = FutureProvider.autoDispose
    .family<List<Battery>, int>((ref, stationId) async {
  final repository = ref.watch(batteryRepositoryProvider);
  return repository.getBatteriesAtStation(stationId);
});

final activeRentalsProvider = FutureProvider<List<Rental>>((ref) async {
  final repository = ref.watch(rentalRepositoryProvider);
  return repository.getActiveRentals();
});

final rentalHistoryProvider = FutureProvider<List<Rental>>((ref) async {
  final repository = ref.watch(rentalRepositoryProvider);
  return repository.getRentalHistory();
});

bool _isOperationalStation(Station station) {
  final normalized = station.status.trim().toLowerCase();
  return normalized == 'active' ||
      normalized == 'ready' ||
      normalized == 'open';
}

Station _stationFromSwapOption(SwapStationOption option) {
  return Station(
    id: option.id,
    name: option.name,
    address: option.address,
    latitude: option.latitude,
    longitude: option.longitude,
    status: option.status,
    rating: 0,
    totalReviews: 0,
    availableBatteries: option.availableBatteries,
    totalSlots: option.totalCapacity,
    is24x7: option.operatingHours.toLowerCase() == '24/7',
    distance: option.distanceKm > 0 ? option.distanceKm * 1000 : null,
  );
}

final rentalStationOptionsProvider = FutureProvider<List<Station>>((ref) async {
  final swapService = ref.watch(swapRequestServiceProvider);
  final options = await swapService.getNearestSwapOptions();

  final deduped = <int, Station>{};
  for (final option in options) {
    final station = _stationFromSwapOption(option);
    if (!_isOperationalStation(station)) continue;
    if (station.availableBatteries <= 0) continue;
    deduped[station.id] = station;
  }

  final stations = deduped.values.toList();
  stations.sort((a, b) {
    final availabilityOrder =
        b.availableBatteries.compareTo(a.availableBatteries);
    if (availabilityOrder != 0) return availabilityOrder;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return stations;
});

class BatteryStatus {
  final double chargePercentage;
  final double healthPercentage;
  final double temperature;
  final double voltage;

  BatteryStatus({
    required this.chargePercentage,
    required this.healthPercentage,
    required this.temperature,
    required this.voltage,
  });
}

// Battery telemetry from seeded DB data (no real-time IoT for MVP)
// Polls the battery endpoint once per provider lifecycle
final batteryMonitoringProvider =
    FutureProvider.family<BatteryStatus, int>((ref, batteryId) async {
  final dio = ref.watch(authenticatedDioProvider);
  try {
    final response = await dio.get('/batteries/$batteryId');
    final data = response.data as Map<String, dynamic>;
    return BatteryStatus(
      chargePercentage:
          ((data['current_charge'] as num?) ?? 0).toDouble() / 100.0,
      healthPercentage:
          ((data['health_percentage'] as num?) ?? 0).toDouble() / 100.0,
      temperature: 0.0, // No IoT telemetry for MVP
      voltage: ((data['voltage'] as num?) ?? 48.0).toDouble(),
    );
  } catch (_) {
    // Graceful fallback using seeded defaults
    return BatteryStatus(
      chargePercentage: 0.85,
      healthPercentage: 0.95,
      temperature: 0.0,
      voltage: 48.0,
    );
  }
});
