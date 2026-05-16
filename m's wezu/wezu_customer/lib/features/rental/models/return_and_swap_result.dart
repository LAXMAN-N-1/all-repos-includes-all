import 'rental.dart';

class ReturnAndSwapResult {
  final Rental rental;
  final int? swapSessionId;
  final String? swapStatus;
  final double? swapFee;
  final int? swapNewBatteryId;
  final String? swapError;
  final int? newRentalId;

  bool get swapSucceeded => swapSessionId != null && swapError == null;

  ReturnAndSwapResult({
    required this.rental,
    this.swapSessionId,
    this.swapStatus,
    this.swapFee,
    this.swapNewBatteryId,
    this.swapError,
    this.newRentalId,
  });

  factory ReturnAndSwapResult.fromJson(Map<String, dynamic> json) {
    final rentalRaw = json['rental'];
    final rentalJson = rentalRaw is Map<String, dynamic>
        ? rentalRaw
        : Map<String, dynamic>.from(json);
    return ReturnAndSwapResult(
      rental: Rental.fromJson(rentalJson),
      swapSessionId: (json['swap_session_id'] as num?)?.toInt(),
      swapStatus: json['swap_status']?.toString(),
      swapFee: (json['swap_fee'] as num?)?.toDouble(),
      swapNewBatteryId: (json['swap_new_battery_id'] as num?)?.toInt(),
      swapError: json['swap_error']?.toString(),
      newRentalId: (json['new_rental_id'] as num?)?.toInt(),
    );
  }
}
