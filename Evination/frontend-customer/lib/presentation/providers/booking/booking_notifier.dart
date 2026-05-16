import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/booking/create_booking_usecase.dart';
import '../../../domain/repositories/i_booking_repository.dart';
import '../../../data/models/booking/booking_model.dart';
import '../app/app_provider.dart';

class BookingState {
  final List<BookingModel> myBookings;
  final bool isLoading;
  final String? error;

  BookingState({required this.myBookings, required this.isLoading, this.error});

  BookingState.initial() : myBookings = [], isLoading = false, error = null;
}

// Note: Repository and UseCase providers should be in app_provider.dart, normally
// Adding here for completeness in the task.

class BookingNotifier extends StateNotifier<BookingState> {
  final CreateBookingUseCase _createBookingUseCase;
  final IBookingRepository _repository;

  BookingNotifier(this._createBookingUseCase, this._repository) : super(BookingState.initial());

  Future<void> fetchMyBookings() async {
    state = BookingState(myBookings: state.myBookings, isLoading: true);
    try {
      final bookings = await _repository.getMyBookings();
      state = BookingState(myBookings: bookings, isLoading: false);
    } catch (e) {
      state = BookingState(myBookings: state.myBookings, isLoading: false, error: e.toString());
    }
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    state = BookingState(myBookings: state.myBookings, isLoading: true);
    try {
      await _createBookingUseCase.execute(data);
      await fetchMyBookings();
    } catch (e) {
      state = BookingState(myBookings: state.myBookings, isLoading: false, error: e.toString());
    }
  }
}

// In a real setup, these would be in app_provider.dart
// final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
//   ...
// });
