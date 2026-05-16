import 'battery.dart';

class Rental {
  final int id;
  final int userId;
  final Battery battery;
  final int pickupStationId;
  final String status; // active, completed, pending_payment
  final DateTime startTime;
  final DateTime? endTime;
  final double totalAmount;
  final double dailyRate;
  final double damageDeposit;
  final double discountAmount;
  final int durationDays;
  final String? paymentTransactionId;
  final double lateFeeAmount;
  final bool isOverdue;
  final int? swapStationId;
  final DateTime? swapRequestedAt;
  final String? waiverStatus; // none, pending, approved, rejected
  final bool issueReported;
  final List<RentalEvent> events;

  Rental({
    required this.id,
    required this.userId,
    required this.battery,
    required this.pickupStationId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.totalAmount,
    required this.dailyRate,
    required this.damageDeposit,
    required this.discountAmount,
    required this.durationDays,
    this.paymentTransactionId,
    this.lateFeeAmount = 0.0,
    this.isOverdue = false,
    this.swapStationId,
    this.swapRequestedAt,
    this.waiverStatus = 'none',
    this.issueReported = false,
    this.events = const [],
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    final batteryJson = json['battery'] is Map<String, dynamic>
        ? json['battery'] as Map<String, dynamic>
        : <String, dynamic>{'id': json['battery_id'] ?? 0};
    final totalAmount = (json['total_price'] as num?)?.toDouble() ??
        (json['total_amount'] as num?)?.toDouble() ??
        0.0;
    final durationDays = (json['rental_duration_days'] as num?)?.toInt() ??
        (json['duration_days'] as num?)?.toInt() ??
        1;
    return Rental(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      battery: Battery.fromJson(batteryJson),
      pickupStationId:
          json['pickup_station_id'] ?? json['start_station_id'] ?? 0,
      status: json['status']?.toString() ?? 'pending_payment',
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      endTime: json['end_time'] != null
          ? DateTime.tryParse(json['end_time'].toString())?.toLocal()
          : null,
      totalAmount: totalAmount,
      dailyRate: (json['daily_rate'] as num?)?.toDouble() ??
          (durationDays > 0 ? totalAmount / durationDays : 0.0),
      damageDeposit: (json['damage_deposit'] as num?)?.toDouble() ??
          (json['security_deposit'] as num?)?.toDouble() ??
          0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      durationDays: durationDays,
      paymentTransactionId: json['payment_transaction_id'],
      lateFeeAmount: (json['late_fee_amount'] as num?)?.toDouble() ??
          (json['late_fee'] as num?)?.toDouble() ??
          0.0,
      isOverdue: json['is_overdue'] ?? false,
      swapStationId: json['swap_station_id'],
      swapRequestedAt: json['swap_requested_at'] != null
          ? DateTime.tryParse(json['swap_requested_at'].toString())?.toLocal()
          : null,
      waiverStatus: json['waiver_status'] ?? 'none',
      issueReported: json['issue_reported'] ?? false,
      events: json['events'] != null
          ? (json['events'] as List)
              .map((e) => RentalEvent.fromJson(e))
              .toList()
          : [],
    );
  }
}

class RentalEvent {
  final String eventType;
  final String? description;
  final DateTime createdAt;

  RentalEvent({
    required this.eventType,
    this.description,
    required this.createdAt,
  });

  factory RentalEvent.fromJson(Map<String, dynamic> json) {
    return RentalEvent(
      eventType: json['event_type'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
