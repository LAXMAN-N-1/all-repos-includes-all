import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
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
final batteriesAtStationProvider = FutureProvider.family<List<Battery>, int>((ref, stationId) async {
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
final batteryMonitoringProvider = FutureProvider.family<BatteryStatus, int>((ref, batteryId) async {
  final dio = ref.watch(authenticatedDioProvider);
  try {
    final response = await dio.get('/batteries/$batteryId');
    final data = response.data as Map<String, dynamic>;
    return BatteryStatus(
      chargePercentage: ((data['current_charge'] as num?) ?? 0).toDouble() / 100.0,
      healthPercentage: ((data['health_percentage'] as num?) ?? 0).toDouble() / 100.0,
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
