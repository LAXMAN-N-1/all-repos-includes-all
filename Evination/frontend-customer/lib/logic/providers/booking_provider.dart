import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:evination_customer_app/data/datasources/remote/booking_remote_datasource.dart';
import 'package:evination_customer_app/data/models/booking_model.dart';
import 'package:evination_customer_app/core/api/api_client.dart';
import 'package:evination_customer_app/logic/adapters/booking_adapter.dart';
import 'package:evination_customer_app/presentation/providers/booking_provider.dart';

// Simple providers without code generation

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final bookingDataSourceProvider = Provider<BookingRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return BookingRemoteDataSource(client);
});

final bookingControllerProvider = StateNotifierProvider<BookingController, AsyncValue<void>>((ref) {
  return BookingController(ref.read(bookingDataSourceProvider));
});

class BookingController extends StateNotifier<AsyncValue<void>> {
  final BookingRemoteDataSource _dataSource;

  BookingController(this._dataSource) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>> createBooking({
    required String eventName,
    required String eventType,
    required DateTime eventDate,
    required String location,
    required double budget,
    required List<String> services,
    String? requirements,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _dataSource.createBooking(
        eventName: eventName,
        eventType: eventType,
        eventDate: eventDate,
        location: location,
        budget: budget,
        services: services,
        requirements: requirements,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// Provider that fetches bookings from API and converts to presentation model
final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final dataSource = ref.watch(bookingDataSourceProvider);
  final apiBookings = await dataSource.getMyBookings();
  
  // Convert List<dynamic> to List<BookingModel>
  final bookingModels = apiBookings
      .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
      .toList();
  
  // Convert to presentation models
  return BookingAdapter.fromApiList(bookingModels);
});
