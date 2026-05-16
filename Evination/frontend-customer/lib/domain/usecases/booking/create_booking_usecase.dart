import '../../repositories/i_booking_repository.dart';
import '../../../data/models/booking/booking_model.dart';

class CreateBookingUseCase {
  final IBookingRepository _repository;

  CreateBookingUseCase(this._repository);

  Future<BookingModel> execute(Map<String, dynamic> bookingData) async {
    return await _repository.createBooking(bookingData);
  }
}
