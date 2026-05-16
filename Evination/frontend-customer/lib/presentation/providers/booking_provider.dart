import 'package:flutter_riverpod/flutter_riverpod.dart';

// Booking Model
class Booking {
  final String id;
  final String category;
  final DateTime date;
  final String location;
  final int guests;
  final List<String> services;
  final String status; // 'Awaiting Payment', 'Confirmed', 'Completed', 'Cancelled'
  final String refId;
  final double totalCost;
  final Map<String, dynamic> selectedVendors; // Map of ServiceName -> VendorDetails

  Booking({
    required this.id,
    required this.category,
    required this.date,
    required this.location,
    required this.guests,
    required this.services,
    this.status = 'Awaiting Payment',
    required this.refId,
    this.totalCost = 0.0,
    this.selectedVendors = const {},
  });

  Booking copyWith({
    String? status,
    double? totalCost,
    Map<String, dynamic>? selectedVendors,
  }) {
    return Booking(
      id: id,
      category: category,
      date: date,
      location: location,
      guests: guests,
      services: services,
      status: status ?? this.status,
      refId: refId,
      totalCost: totalCost ?? this.totalCost,
      selectedVendors: selectedVendors ?? this.selectedVendors,
    );
  }
}

// Notifier
class BookingNotifier extends StateNotifier<List<Booking>> {
  BookingNotifier() : super([]);

  void addBooking(Booking booking) {
    state = [...state, booking];
  }

  void updateStatus(String id, String newStatus) {
    state = [
      for (final booking in state)
        if (booking.id == id) booking.copyWith(status: newStatus) else booking
    ];
  }

  void updateId(String oldId, String newId) {
    state = [
      for (final booking in state)
        if (booking.id == oldId)
          Booking(
            id: newId,
            category: booking.category,
            date: booking.date,
            location: booking.location,
            guests: booking.guests,
            services: booking.services,
            status: booking.status,
            refId: booking.refId,
            totalCost: booking.totalCost,
            selectedVendors: booking.selectedVendors,
          )
        else
          booking
    ];
  }
  
  void updatePrice(String id, double price) {
    state = [
      for (final booking in state)
        if (booking.id == id) booking.copyWith(totalCost: price) else booking
    ];
  }

  void updateSelectedVendors(String id, Map<String, dynamic> vendors) {
    state = [
      for (final booking in state)
        if (booking.id == id) booking.copyWith(selectedVendors: vendors) else booking
    ];
  }
}

// Provider
final bookingProvider = StateNotifierProvider<BookingNotifier, List<Booking>>((ref) {
  return BookingNotifier();
});
