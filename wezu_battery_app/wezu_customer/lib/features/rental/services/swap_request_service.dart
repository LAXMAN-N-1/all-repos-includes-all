import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class SwapStationOption {
  final int id;
  final String name;
  final String address;
  final double distanceKm;
  final int estimatedMinutes;
  final int availableBatteries;
  final double bestBatterySoc;
  final double latitude;
  final double longitude;
  final String operatingHours;
  final List<String> batteryTypes;
  final int? totalStationCapacity;

  SwapStationOption({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.availableBatteries,
    required this.bestBatterySoc,
    required this.latitude,
    required this.longitude,
    required this.operatingHours,
    this.batteryTypes = const ['X1', 'X2', 'X3'],
    this.totalStationCapacity,
  });

  factory SwapStationOption.fromJson(Map<String, dynamic> json) {
    final totalCapacity = (json['total_capacity'] as num?)?.toInt();
    final supported = json['supported_battery_types'];
    return SwapStationOption(
      id: (json['station_id'] as num?)?.toInt() ?? 0,
      name: json['station_name'] as String? ?? 'Unknown Station',
      address: json['address'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedMinutes: json['travel_time_minutes'] as int? ?? 0,
      availableBatteries: json['available_batteries'] as int? ?? 0,
      bestBatterySoc: (json['best_battery_soc'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      operatingHours: json['operating_hours'] as String? ?? '24/7',
      batteryTypes: supported is List
          ? supported.map((item) => item.toString()).toList()
          : const ['X1', 'X2', 'X3'],
      totalStationCapacity: totalCapacity,
    );
  }

  // Backward-compatible getters used in UI widgets.
  int get availableSlots => availableBatteries;
  int get totalCapacity => totalStationCapacity ?? availableBatteries;
  List<String> get supportedBatteryTypes => batteryTypes;
}

class SwapRequestService {
  final Dio _dio;

  SwapRequestService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// Fetch nearby swap station options from the backend.
  /// Calls: GET /swaps/suggestions?rental_id=X&user_latitude=Y&user_longitude=Z
  Future<List<SwapStationOption>> getNearestSwapOptions({
    int? rentalId,
    double? latitude,
    double? longitude,
    String? batteryTypeFilter,
  }) async {
    final response = await _dio.get(
      '/swaps/suggestions',
      queryParameters: {
        if (rentalId != null) 'rental_id': rentalId,
        if (latitude != null) 'user_latitude': latitude,
        if (longitude != null) 'user_longitude': longitude,
        if (batteryTypeFilter != null && batteryTypeFilter.isNotEmpty)
          'battery_type': batteryTypeFilter,
      },
    ).timeout(const Duration(seconds: 10));

    if (response.data is List) {
      return (response.data as List)
          .map((json) => SwapStationOption.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Confirm a battery swap at a station.
  /// Calls: POST /swaps/initiate
  Future<bool> confirmSwapRequest({
    int? rentalId,
    required int stationId,
    int? newBatteryId,
    int? durationDays,
    String? batteryId,
  }) async {
    final resolvedRentalId = rentalId ?? int.tryParse(batteryId ?? '');
    final resolvedBatteryId = newBatteryId ?? int.tryParse(batteryId ?? '');

    final payload = <String, dynamic>{
      'station_id': stationId,
      if (resolvedRentalId != null) 'rental_id': resolvedRentalId,
      if (resolvedBatteryId != null) 'new_battery_id': resolvedBatteryId,
      if (durationDays != null) 'duration_days': durationDays,
    };

    final response = await _dio.post(
      '/swaps/initiate',
      data: payload,
    ).timeout(const Duration(seconds: 10));
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
