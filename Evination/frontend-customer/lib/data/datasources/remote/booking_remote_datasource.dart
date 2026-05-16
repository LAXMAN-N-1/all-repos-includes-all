import 'package:evination_customer_app/core/api/api_client.dart';
import 'package:evination_customer_app/core/api/api_endpoints.dart';

class BookingRemoteDataSource {
  final ApiClient _client;

  BookingRemoteDataSource(this._client);

  Future<Map<String, dynamic>> createBooking({
    required String eventName,
    required String eventType,
    required DateTime eventDate,
    required String location,
    required double budget,
    required List<String> services,
    String? requirements,
  }) async {
    try {
      final response = await _client.dio.post(
        '/bookings/',
        data: {
          'event_name': eventName,
          'event_type': eventType,
          'event_date': eventDate.toIso8601String(),
          'location': location,
          'budget': budget,
          'services': services,
          'requirements': requirements ?? '',
          'status': 'pending',
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await _client.dio.get('/bookings/');
      return response.data as List;
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }
}
