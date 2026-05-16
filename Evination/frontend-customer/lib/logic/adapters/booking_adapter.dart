import 'package:evination_customer_app/data/models/booking_model.dart';
import 'package:evination_customer_app/presentation/providers/booking_provider.dart';

/// Adapter to convert API BookingModel to presentation Booking
class BookingAdapter {
  static Booking fromApiModel(BookingModel apiBooking) {
    return Booking(
      id: apiBooking.id.toString(),
      category: apiBooking.eventType,
      date: DateTime.parse(apiBooking.eventDate),
      location: apiBooking.location,
      guests: apiBooking.guestCount ?? 100,
      services: apiBooking.services,
      status: _mapStatus(apiBooking.status),
      refId: apiBooking.referenceId,
      totalCost: apiBooking.budget,
      selectedVendors: {},
    );
  }

  static String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'under_process':
        return 'Awaiting Payment';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Awaiting Payment';
    }
  }

  static List<Booking> fromApiList(List<BookingModel> apiBookings) {
    return apiBookings.map((booking) => fromApiModel(booking)).toList();
  }
}
