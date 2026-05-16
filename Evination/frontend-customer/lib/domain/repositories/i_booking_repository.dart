import '../../data/models/booking/booking_model.dart';

abstract class IBookingRepository {
  Future<BookingModel> createBooking(Map<String, dynamic> data);
  Future<List<BookingModel>> getMyBookings();
}
