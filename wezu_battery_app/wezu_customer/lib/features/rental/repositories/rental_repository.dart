import 'package:dio/dio.dart';
import '../models/rental.dart';
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
        'battery_id': batteryId,
        'start_station_id': stationId,
        'duration_days': durationDays,
        'promo_code': promoCode,
      },
    ).timeout(const Duration(seconds: 10));
    return Rental.fromJson(response.data);
  }

  @override
  Future<Rental> confirmRental(int rentalId, String paymentReference) async {
    final response = await _dio.post(
      '${ApiConstants.rentals}/$rentalId/confirm',
      data: {'payment_reference': paymentReference},
    ).timeout(const Duration(seconds: 10));
    return Rental.fromJson(response.data);
  }

  @override
  Future<List<Rental>> getActiveRentals() async {
    final response = await _dio
        .get(ApiConstants.rentalsActive)
        .timeout(const Duration(seconds: 10));
    if (response.data is List) {
      return (response.data as List)
          .map((json) => Rental.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<List<Rental>> getRentalHistory() async {
    final response = await _dio
        .get(ApiConstants.rentalsHistory)
        .timeout(const Duration(seconds: 10));
    if (response.data is List) {
      return (response.data as List)
          .map((json) => Rental.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<Rental> returnRental(int rentalId, int stationId) async {
    final response = await _dio.post(
      '${ApiConstants.rentals}/$rentalId/return',
      queryParameters: {'station_id': stationId},
    ).timeout(const Duration(seconds: 10));
    return Rental.fromJson(response.data);
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
