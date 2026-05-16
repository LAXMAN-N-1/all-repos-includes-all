import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String bookingId,
    required double amount,
    required String currency,
    required String status, // Pending, Completed, Failed
    required String paymentMethod,
    required DateTime transactionDate,
    String? transactionReference,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
}
