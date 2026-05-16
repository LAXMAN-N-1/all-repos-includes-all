import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/station_state.dart';

final stationsProvider =
    StateNotifierProvider<StationsNotifier, StationState>((ref) {
  return StationsNotifier(ref.watch(dioProvider));
});

class StationsNotifier extends StateNotifier<StationState> {
  final Dio _dio;

  StationsNotifier(this._dio) : super(const StationState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _dio.get(ApiConstants.stations);
      
      final rawList = ApiResponse.asList(response.data);
      final parsed = rawList.map((e) {
        return StationDto(
          id: e['id'] ?? 0,
          name: e['name']?.toString() ?? 'Unknown',
          address: e['address']?.toString() ?? '',
          city: e['city']?.toString() ?? '',
          status: e['status']?.toString() ?? 'OPERATIONAL',
          totalSlots: e['total_slots'] ?? 0,
          createdAt: e['created_at']?.toString() ?? '',
          latitude: (e['latitude'] ?? 0.0).toDouble(),
          longitude: (e['longitude'] ?? 0.0).toDouble(),
          stationType: e['station_type']?.toString() ?? 'automated',
          availableBatteries: e['available_batteries'] ?? 0,
          availableSlots: e['available_slots'] ?? 0,
          is24x7: e['is_24x7'] ?? false,
          rating: (e['rating'] ?? 0.0).toDouble(),
          activeSwaps: e['active_swaps'] ?? 0,
          utilizationPercent: (e['utilization_percent'] ?? 0.0).toDouble(),
          ongoingRentals: e['ongoing_rentals'] ?? e['rented_batteries'] ?? 0,
          chargingBatteries: e['charging_batteries'] ?? 0,
          faultyBatteries: e['damaged_batteries'] ?? 0,
          maxCapacity: e['total_batteries'] ?? e['total_slots'] ?? 0,
          contactPhone: e['contact_phone']?.toString(),
          operatingHours: e['operating_hours']?.toString(),
          lastMaintenanceDate: e['last_maintenance_date']?.toString(),
          lastHeartbeat: e['last_heartbeat']?.toString(),
        );
      }).toList();

      state = state.copyWith(isLoading: false, stations: parsed);
    } on DioException catch (e) {
      log('Stations API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load stations'),
      );
    } catch (e) {
      log('Stations Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred.',
      );
    }
  }
}
