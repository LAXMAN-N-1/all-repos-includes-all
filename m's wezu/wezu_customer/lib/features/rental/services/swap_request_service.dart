import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';

class SwapStationOption {
  final int id;
  final String name;
  final String address;
  final String status;
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
    required this.status,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.availableBatteries,
    required this.bestBatterySoc,
    required this.latitude,
    required this.longitude,
    required this.operatingHours,
    this.batteryTypes = const [],
    this.totalStationCapacity,
  });

  // Parses StationResponse from GET /api/v1/swaps/stations.
  factory SwapStationOption.fromJson(Map<String, dynamic> json,
      {double? userLat, double? userLon}) {
    final lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
    final lon = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    final fallbackDistance = (json['distance'] as num?)?.toDouble();
    final distKm = (userLat != null && userLon != null)
        ? _haversineKm(userLat, userLon, lat, lon)
        : (fallbackDistance ?? 0.0);
    final availableBatteries = (json['available_batteries'] as num?)?.toInt() ??
        (json['available_slots'] as num?)?.toInt() ??
        0;
    final slots = (json['available_slots'] as num?)?.toInt();
    final openingTime = (json['opening_time'] as String?)?.trim();
    final closingTime = (json['closing_time'] as String?)?.trim();
    final is24x7 = json['is_24x7'] == true;
    final status = (json['status'] as String?)?.trim();
    final explicitOperatingHours = (json['operating_hours'] as String?)?.trim();
    final operatingHours =
        explicitOperatingHours != null && explicitOperatingHours.isNotEmpty
            ? explicitOperatingHours
            : is24x7
                ? '24/7'
                : (openingTime != null && closingTime != null)
                    ? '$openingTime - $closingTime'
                    : 'N/A';

    final batteryTypes = _extractBatteryTypes(json);

    return SwapStationOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown Station',
      address: json['address'] as String? ?? '',
      status: (status == null || status.isEmpty) ? 'active' : status,
      distanceKm: distKm,
      estimatedMinutes: distKm > 0 ? ((distKm / 30) * 60).ceil() : 0,
      availableBatteries: availableBatteries,
      bestBatterySoc: 0.0,
      latitude: lat,
      longitude: lon,
      operatingHours: operatingHours,
      batteryTypes: batteryTypes,
      totalStationCapacity: slots,
    );
  }

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // Backward-compatible getters used in UI widgets.
  int get availableSlots => availableBatteries;
  int get totalCapacity => totalStationCapacity ?? availableBatteries;
  List<String> get supportedBatteryTypes => batteryTypes;

  static List<String> _extractBatteryTypes(Map<String, dynamic> json) {
    final values = <String>{};

    void addType(dynamic raw) {
      if (raw is! String) return;
      final trimmed = raw.trim();
      if (trimmed.isNotEmpty) {
        values.add(trimmed);
      }
    }

    addType(json['battery_type']);

    for (final key in const [
      'battery_types',
      'supported_battery_types',
      'supported_models',
      'models',
      'battery_model_names',
    ]) {
      final raw = json[key];
      if (raw is List) {
        for (final entry in raw) {
          addType(entry);
        }
      }
    }

    final parsed = values.toList()..sort((a, b) => a.compareTo(b));
    return parsed;
  }
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

  List<Map<String, dynamic>> _extractListPayload(dynamic payload) {
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }
    if (payload is Map) {
      final candidates = [
        payload['data'],
        payload['items'],
        payload['results'],
        payload['stations'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map((entry) => Map<String, dynamic>.from(entry))
              .toList();
        }
      }
    }
    return const <Map<String, dynamic>>[];
  }

  /// Fetch all available swap stations from the backend.
  /// Calls: GET /api/v1/swaps/stations?lat=Y&lon=Z (location optional; backend sorts by distance when provided)
  Future<List<SwapStationOption>> getNearestSwapOptions({
    int? rentalId,
    double? latitude,
    double? longitude,
    String? batteryTypeFilter,
  }) async {
    var stationPayload = <Map<String, dynamic>>[];

    try {
      final response = await _dio.get(
        ApiConstants.swapStations,
        queryParameters: {
          if (latitude != null) 'lat': latitude,
          if (longitude != null) 'lon': longitude,
        },
      ).timeout(const Duration(seconds: 10));
      stationPayload = _extractListPayload(response.data);
    } catch (_) {}

    var options = stationPayload
        .map((json) => SwapStationOption.fromJson(
              json,
              userLat: latitude,
              userLon: longitude,
            ))
        .where((station) => station.id > 0)
        .toList();

    final normalizedType = batteryTypeFilter?.trim().toLowerCase();
    if (normalizedType != null && normalizedType.isNotEmpty) {
      options = options.where((station) {
        return station.supportedBatteryTypes
            .map((entry) => entry.trim().toLowerCase())
            .contains(normalizedType);
      }).toList();
    }

    return options;
  }

  /// Fetch the swap fee for a station. Calls: GET /swaps/price?station_id=X
  Future<double> getSwapFee(int stationId) async {
    final response = await _dio.get(
      ApiConstants.swapPrice,
      queryParameters: {'station_id': stationId},
    ).timeout(const Duration(seconds: 10));
    final data = response.data;
    if (data is Map) {
      return (data['swap_fee'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  /// Initiate a battery swap at a station.
  /// Calls: POST /swaps/initiate → creates pending swap session.
  /// Payment confirmation is a separate step (not triggered here).
  Future<Map<String, dynamic>> confirmSwapRequest({
    int? rentalId,
    required int stationId,
    int? newBatteryId,
    int? durationDays,
    String? batteryId,
  }) async {
    final payload = <String, dynamic>{
      'station_id': stationId,
      if (batteryId != null && batteryId.trim().isNotEmpty)
        'old_battery_serial': batteryId.trim(),
    };
    final response = await _dio
        .post(ApiConstants.swapInitiate, data: payload)
        .timeout(const Duration(seconds: 10));
    return Map<String, dynamic>.from(response.data as Map);
  }
}
