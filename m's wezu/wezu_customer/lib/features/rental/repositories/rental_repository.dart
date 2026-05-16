import 'package:dio/dio.dart';
import '../models/rental.dart';
import '../models/return_and_swap_result.dart';
import '../../../core/constants/api_constants.dart';

abstract class RentalRepository {
  Future<Map<String, dynamic>> calculatePrice({
    required int batteryId,
    required int durationDays,
    String? promoCode,
  });

  Future<Rental> initiateRental({
    required int batteryId,
    required int stationId,
    required int durationDays,
    String? promoCode,
  });

  Future<Rental> confirmRental(int rentalId, String paymentReference);

  Future<List<Rental>> getActiveRentals();

  Future<List<Rental>> getRentalHistory();

  Future<Rental> returnRental(int rentalId, int stationId);

  Future<ReturnAndSwapResult> returnRentalWithSwap(
      int rentalId, int stationId, int newBatteryId);

  // Rental Actions
  Future<Map<String, dynamic>> extendRental(int rentalId, int hours);
  Future<Map<String, dynamic>> pauseRental(int rentalId);
  Future<Map<String, dynamic>> resumeRental(int rentalId);
  Future<Map<String, dynamic>> getLateFees(int rentalId);
  Future<Map<String, dynamic>> requestWaiver(int rentalId, String reason);
  Future<Map<String, dynamic>> reportIssue(
      int rentalId, String category, String? description);
}

class RentalRepositoryImpl implements RentalRepository {
  final Dio _dio;

  RentalRepositoryImpl(this._dio);

  bool _isEndpointRemoved(DioException e) {
    final code = e.response?.statusCode ?? 0;
    return code == 404 || code == 410;
  }

  List<Rental> _decodeRentalList(dynamic payload) {
    dynamic listPayload = payload;
    if (payload is Map) {
      listPayload = payload['data'] ??
          payload['items'] ??
          payload['results'] ??
          payload['rentals'];
    }

    if (listPayload is! List) return [];

    return listPayload
        .whereType<Map>()
        .map((json) => Rental.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  bool _isActiveStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'active' || normalized == 'overdue';
  }

  bool _isHistoryStatus(String status) {
    final normalized = status.toLowerCase();
    return normalized == 'completed' || normalized == 'cancelled';
  }

  Future<List<Rental>> _fetchRentalList(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio
        .get(url, queryParameters: queryParameters)
        .timeout(const Duration(seconds: 10));
    return _decodeRentalList(response.data);
  }

  @override
  Future<Map<String, dynamic>> calculatePrice({
    required int batteryId,
    required int durationDays,
    String? promoCode,
  }) async {
    final response = await _dio.post(
      ApiConstants.calculatePrice,
      data: {
        'battery_id': batteryId,
        'duration_days': durationDays,
        'promo_code': promoCode,
      },
    );
    return response.data;
  }

  @override
  Future<Rental> initiateRental({
    required int batteryId,
    required int stationId,
    required int durationDays,
    String? promoCode,
  }) async {
    final response = await _dio.post(
      ApiConstants.initiateRental,
      data: {
        'station_id': stationId,
        'duration_days': durationDays,
        if (promoCode != null) 'promo_code': promoCode,
      },
    ).timeout(const Duration(seconds: 10));
    final raw = response.data;
    final json = (raw is Map && raw['data'] is Map)
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return Rental.fromJson(json);
  }

  @override
  Future<Rental> confirmRental(int rentalId, String paymentReference) async {
    final response = await _dio
        .post(
          '${ApiConstants.rentals}/$rentalId/confirm',
        )
        .timeout(const Duration(seconds: 10));
    final raw = response.data;
    final json = (raw is Map && raw['data'] is Map)
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return Rental.fromJson(json);
  }

  @override
  Future<List<Rental>> getActiveRentals() async {
    return _fetchRentalList(
      ApiConstants.rentals,
      queryParameters: const {'status': 'active'},
    );
  }

  @override
  Future<List<Rental>> getRentalHistory() async {
    return _fetchRentalList(ApiConstants.rentals);
  }

  @override
  Future<Rental> returnRental(int rentalId, int stationId) async {
    final result = await returnRentalWithSwap(rentalId, stationId, -1);
    return result.rental;
  }

  @override
  Future<ReturnAndSwapResult> returnRentalWithSwap(
      int rentalId, int stationId, int newBatteryId) async {
    final data = <String, dynamic>{'return_station_id': stationId};
    if (newBatteryId > 0) {
      data['swap_on_return'] = true;
      data['new_battery_id'] = newBatteryId;
    }
    final response = await _dio
        .post('${ApiConstants.rentals}/$rentalId/return', data: data)
        .timeout(const Duration(seconds: 15));
    final raw = response.data;
    final json = (raw is Map && raw['data'] is Map)
        ? raw['data'] as Map<String, dynamic>
        : raw as Map<String, dynamic>;
    return ReturnAndSwapResult.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> extendRental(int rentalId, int hours) async {
    final endDate =
        DateTime.now().add(Duration(hours: hours)).toIso8601String();
    final response = await _dio.post(
      '${ApiConstants.rentalExtend}/$rentalId/extend',
      data: {
        'requested_end_date': endDate,
        'reason': 'Customer requested via app',
      },
    ).timeout(const Duration(seconds: 10));
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> pauseRental(int rentalId) async {
    final now = DateTime.now();
    final pauseEnd = now.add(const Duration(days: 1)); // Default pause
    final response = await _dio.post(
      '${ApiConstants.rentalPause}/$rentalId/pause',
      data: {
        'pause_start_date': now.toIso8601String(),
        'pause_end_date': pauseEnd.toIso8601String(),
        'reason': 'Customer requested pause',
      },
    ).timeout(const Duration(seconds: 10));
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> resumeRental(int rentalId) async {
    final response = await _dio
        .post(
          '${ApiConstants.rentalResume}/$rentalId/resume',
        )
        .timeout(const Duration(seconds: 10));
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getLateFees(int rentalId) async {
    final response = await _dio
        .get(
          '${ApiConstants.rentalLateFees}/$rentalId/late-fees',
        )
        .timeout(const Duration(seconds: 10));
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> requestWaiver(
      int rentalId, String reason) async {
    final response = await _dio.post(
      '${ApiConstants.rentalWaiver}/$rentalId/late-fees/waiver',
      data: {
        'requested_waiver_amount': 0,
        'reason': reason,
      },
    ).timeout(const Duration(seconds: 10));
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> reportIssue(
      int rentalId, String category, String? description) async {
    final response = await _dio.post(
      '${ApiConstants.rentalReportIssue}/$rentalId/report-issue',
      data: {
        'issue_type': category,
        'description': description ?? category,
        'severity': 'medium',
      },
    ).timeout(const Duration(seconds: 10));
    return response.data;
  }
}
