import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/filter_state.dart';

class FilterNotifier extends StateNotifier<StationFilterState> {
  FilterNotifier() : super(StationFilterState()) {
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('station_filters');
      if (jsonStr != null) {
        final Map<String, dynamic> map = json.decode(jsonStr);
        state = StationFilterState(
          maxRadius: (map['maxRadius'] as num?)?.toDouble() ?? 50.0,
          minPrice: (map['minPrice'] as num?)?.toDouble() ?? 0.0,
          maxPrice: (map['maxPrice'] as num?)?.toDouble() ?? 200.0,
          minRating: (map['minRating'] as num?)?.toDouble() ?? 0.0,
          onlyAvailable: map['onlyAvailable'] ?? false,
          batteryTypes: List<String>.from(map['batteryTypes'] ?? []),
          minCapacity: map['minCapacity'] ?? 40,
          isDealer: map['isDealer'],
          isOpenNow: map['isOpenNow'] ?? false,
          is24x7: map['is24x7'] ?? false,
          chargingSpeeds: List<String>.from(map['chargingSpeeds'] ?? []),
          amenities: List<String>.from(map['amenities'] ?? []),
        );
      }
    } catch (e) {
      // Keep default state on error
    }
  }

  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'maxRadius': state.maxRadius,
        'minPrice': state.minPrice,
        'maxPrice': state.maxPrice,
        'minRating': state.minRating,
        'onlyAvailable': state.onlyAvailable,
        'batteryTypes': state.batteryTypes,
        'minCapacity': state.minCapacity,
        'isDealer': state.isDealer,
        'isOpenNow': state.isOpenNow,
        'is24x7': state.is24x7,
        'chargingSpeeds': state.chargingSpeeds,
        'amenities': state.amenities,
      };
      await prefs.setString('station_filters', json.encode(map));
    } catch (e) {
      // Ignore save errors
    }
  }

  void updateFilters(StationFilterState newState) {
    state = newState;
    _saveFilters();
  }

  void resetAll() {
    state = StationFilterState();
    _saveFilters();
  }

  /// Count of active filters for badge display
  int get activeFilterCount {
    int count = 0;
    if (state.maxRadius != 50.0) count++;
    if (state.minPrice != 0.0 || state.maxPrice != 200.0) count++;
    if (state.minRating != 0.0) count++;
    if (state.onlyAvailable) count++;
    if (state.isOpenNow) count++;
    if (state.is24x7) count++;
    if (state.batteryTypes.isNotEmpty) count++;
    if (state.chargingSpeeds.isNotEmpty) count++;
    if (state.amenities.isNotEmpty) count++;
    if (state.isDealer != null) count++;
    return count;
  }
}

final filterNotifierProvider =
    StateNotifierProvider<FilterNotifier, StationFilterState>((ref) {
  return FilterNotifier();
});
