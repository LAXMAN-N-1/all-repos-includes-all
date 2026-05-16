import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required int id,
    required String referenceId,
    required int customerId,
    required String eventName,
    required String eventType,
    required String eventDate,
    String? eventTime,
    required String location,
    String? city,
    String? guestCount,
    required double budget,
    String? requirements,
    required String status,
    String? transactionId,
    required String bookingStep,
    required DateTime createdAt,
    // New fields for Bidding System
    String? subCategory,
    List<String>? images,
    double? latitude,
    double? longitude,
    @Default('pending') String paymentStatus,
    @Default('none') String escrowStatus,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
}
