import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/driver_model.dart';
import '../../../services/api/api_client.dart';

class DriverRepository {
  final ApiClient _api;

  DriverRepository({required ApiClient api}) : _api = api;

  /// Fetch all drivers from logistics fleet endpoints.
  Future<Result<List<DriverModel>>> fetchDrivers({DriverStatus? status}) async {
    try {
      final response = await _api.get<dynamic>(
        '/logistics/drivers',
        queryParameters: {'skip': 0, 'limit': 200},
      );

      final items = _extractList(
        response,
      ).map(_toDriverModel).whereType<DriverModel>().toList();

      final filtered = status == null
          ? items
          : items.where((driver) => driver.status == status).toList();
      return Result.success(filtered);
    } on ApiException catch (e) {
      // Internal-operator accounts should be able to list drivers.
      // If forbidden, return empty list instead of probing /drivers/me
      // (which is driver-profile specific and causes noisy 404s).
      if (e.statusCode == 403) {
        return Result.success(const <DriverModel>[]);
      }

      // Fallback for driver-profile based accounts.
      if (e.statusCode == 404) {
        try {
          final me = await _api.get<dynamic>('/drivers/me');
          final data = _toMap(me['data'] ?? me);
          if (data == null) return Result.success(const <DriverModel>[]);
          final selfDriver = _toDriverModel(data);
          if (selfDriver == null) return Result.success(const <DriverModel>[]);
          if (status != null && selfDriver.status != status) {
            return Result.success(const <DriverModel>[]);
          }
          return Result.success([selfDriver]);
        } on ApiException catch (_) {
          return Result.failure(e.message);
        }
      }
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to load drivers: $e');
    }
  }

  /// Create a new driver profile.
  Future<Result<DriverModel>> createDriver(DriverModel driver) async {
    final userId = _parseInt(driver.id);
    if (userId == null || userId <= 0) {
      return Result.failure(
        'Driver ID must be a valid numeric user ID to create a backend profile.',
      );
    }

    try {
      final payload = <String, dynamic>{
        'user_id': userId,
        'license_number': 'LIC-${driver.vehiclePlate.trim().toUpperCase()}',
        'vehicle_type': driver.vehicleType.trim(),
        'vehicle_plate': driver.vehiclePlate.trim().toUpperCase(),
      };

      final response = await _api.post<dynamic>(
        '/logistics/drivers',
        data: payload,
      );
      final data = _toMap(response['data'] ?? response);
      if (data == null) {
        return Result.failure('Unexpected create-driver response payload.');
      }
      final created = _toDriverModel(data);
      if (created == null) {
        return Result.failure('Created driver response is missing ID.');
      }
      return Result.success(created);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to create driver: $e');
    }
  }

  /// Update driver online/offline availability.
  Future<Result<DriverModel>> updateStatus(
    String id,
    DriverStatus status,
  ) async {
    final isOnline = status != DriverStatus.offline;

    try {
      await _api.put<dynamic>(
        '/logistics/drivers/$id/availability',
        queryParameters: {'is_online': isOnline},
      );
      return fetchDriver(id);
    } on ApiException catch (e) {
      // Fallback to legacy status endpoint that accepts raw string body.
      try {
        await _api.put<dynamic>(
          '/logistics/drivers/$id/status',
          data: isOnline ? 'online' : 'offline',
        );
        return fetchDriver(id);
      } on ApiException {
        return Result.failure(e.message);
      }
    } catch (e) {
      return Result.failure('Failed to update status: $e');
    }
  }

  /// Fetch a single driver by profile ID.
  Future<Result<DriverModel>> fetchDriver(String id) async {
    try {
      final response = await _api.get<dynamic>('/logistics/drivers/$id');
      final data = _toMap(response['data'] ?? response);
      if (data == null) return Result.failure('Driver payload missing');
      final driver = _toDriverModel(data);
      if (driver == null) return Result.failure('Driver payload invalid');
      return Result.success(driver);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to fetch driver: $e');
    }
  }

  /// Update editable profile fields.
  Future<Result<DriverModel>> updateDriverProfile(
    String driverId, {
    String? name,
    String? phoneNumber,
    String? vehicleType,
    String? vehiclePlate,
    String? licenseNumber,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phone_number': phoneNumber.trim(),
        if (vehicleType != null && vehicleType.trim().isNotEmpty)
          'vehicle_type': vehicleType.trim(),
        if (vehiclePlate != null && vehiclePlate.trim().isNotEmpty)
          'vehicle_plate': vehiclePlate.trim().toUpperCase(),
        if (licenseNumber != null && licenseNumber.trim().isNotEmpty)
          'license_number': licenseNumber.trim().toUpperCase(),
      };

      if (payload.isEmpty) {
        return Result.failure('No profile fields provided to update.');
      }

      final response = await _api.put<dynamic>(
        '/logistics/drivers/$driverId',
        data: payload,
      );
      final data = _toMap(response['data'] ?? response);
      if (data == null) return Result.failure('Driver payload missing');
      final driver = _toDriverModel(data);
      if (driver == null) return Result.failure('Driver payload invalid');
      return Result.success(driver);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to update driver profile: $e');
    }
  }

  /// Location update endpoint is not exposed in logistics APIs currently.
  Future<Result<DriverModel>> updateLocation(
    String id,
    double lat,
    double lng,
    double accuracy,
  ) async {
    return Result.failure(
      'Driver location updates are not available in the current backend API.',
    );
  }

  DriverModel? _toDriverModel(Map<String, dynamic> json) {
    final idValue = json['id'];
    if (idValue == null) return null;

    final isOnline = _asBool(json['is_online']) ?? false;
    final statusRaw = (json['status'] ?? '').toString().trim();
    final status = statusRaw.isNotEmpty
        ? DriverStatus.fromString(statusRaw)
        : (isOnline ? DriverStatus.available : DriverStatus.offline);

    return DriverModel(
      id: idValue.toString(),
      name: (json['name'] ?? json['full_name'] ?? 'Driver #$idValue')
          .toString(),
      phoneNumber: (json['phone_number'] ?? '').toString(),
      status: status,
      vehicleType: (json['vehicle_type'] ?? 'Unknown').toString(),
      vehiclePlate: (json['vehicle_plate'] ?? '').toString(),
      currentLat:
          _asDouble(json['current_latitude'] ?? json['current_lat']) ?? 0.0,
      currentLng:
          _asDouble(json['current_longitude'] ?? json['current_lng']) ?? 0.0,
      currentBatteryLevel: _asInt(json['current_battery_level']) ?? 100,
      completedDeliveries:
          _asInt(json['total_deliveries'] ?? json['completed_deliveries']) ?? 0,
      rating: _asDouble(json['rating']) ?? 5.0,
      locationAccuracy: _asDouble(json['location_accuracy']) ?? 0.0,
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic payload) {
    final map = _toMap(payload);
    if (map == null) return const <Map<String, dynamic>>[];

    final raw = map['data'] is List ? map['data'] : payload;
    if (raw is! List) return const <Map<String, dynamic>>[];
    return raw.map(_toMap).whereType<Map<String, dynamic>>().toList();
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  int? _parseInt(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final withoutPrefix = trimmed.toUpperCase().startsWith('D-')
        ? trimmed.substring(2)
        : trimmed;
    return int.tryParse(withoutPrefix);
  }
}
