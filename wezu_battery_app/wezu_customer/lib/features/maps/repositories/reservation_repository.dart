import 'package:dio/dio.dart';
import '../models/reservation.dart';

abstract class ReservationRepository {
  Future<Reservation> reserveBattery({
    required int stationId,
    required String batteryType,
    int durationMinutes = 15,
  });

  Future<Reservation?> getActiveReservation();

  Future<void> cancelReservation(int reservationId);

  Future<ReservationStatus> getReservationStatus(int reservationId);
}

class ReservationRepositoryImpl implements ReservationRepository {
  final Dio _dio;

  ReservationRepositoryImpl(this._dio);

  @override
  Future<Reservation> reserveBattery({
    required int stationId,
    required String batteryType,
    int durationMinutes = 15,
  }) async {
    try {
      final response = await _dio.post(
        '/stations/$stationId/reserve',
        data: {
          'battery_type': batteryType,
          'duration_minutes': durationMinutes,
        },
      );
      return Reservation.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Reservation?> getActiveReservation() async {
    try {
      final response = await _dio.get('/reservations/active');
      if (response.data == null || response.data.isEmpty) return null;
      return Reservation.fromJson(response.data);
    } catch (e) {
      // Return null if no active reservation found or on error
      return null;
    }
  }

  @override
  Future<void> cancelReservation(int reservationId) async {
    try {
      await _dio.put('/reservations/$reservationId/cancel');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ReservationStatus> getReservationStatus(int reservationId) async {
    try {
      final response = await _dio.get('/reservations/$reservationId/status');
      final statusStr = response.data['status'] as String;
      return ReservationStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => ReservationStatus.expired,
      );
    } catch (e) {
      return ReservationStatus.expired;
    }
  }
}
