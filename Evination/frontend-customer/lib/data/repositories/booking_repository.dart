import 'package:dio/dio.dart';
import 'package:evination_customer_app/core/api/api_client.dart';
import 'package:evination_customer_app/core/api/api_endpoints.dart';
import 'package:evination_customer_app/data/models/booking_model.dart';

class BookingRepository {
  final ApiClient _client;

  BookingRepository(this._client);

  /// Fetch all bookings for the current user
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.bookings);
      
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
      
      return [];
    } on DioException catch (e) {
      print('Error fetching bookings: ${e.message}');
      rethrow;
    }
  }

  /// Create a new booking
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.bookings,
        data: bookingData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingModel.fromJson(response.data);
      }
      
      throw Exception('Failed to create booking: ${response.statusCode}');
    } on DioException catch (e) {
      print('Error creating booking: ${e.message}');
      rethrow;
    }
  }
}
