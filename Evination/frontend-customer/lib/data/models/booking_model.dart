class BookingModel {
  final int id;
  final String referenceId;
  final int customerId;
  final String eventName;
  final String eventType;
  final String eventDate;
  final String? eventTime;
  final String location;
  final String? city;
  final int? guestCount;
  final double budget;
  final List<String> services;
  final String requirements;
  final String status;
  final String? transactionId;
  final String bookingStep;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    required this.referenceId,
    required this.customerId,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    this.eventTime,
    required this.location,
    this.city,
    this.guestCount,
    required this.budget,
    required this.services,
    required this.requirements,
    required this.status,
    this.transactionId,
    required this.bookingStep,
    required this.createdAt,
    this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      referenceId: json['reference_id'],
      customerId: json['customer_id'],
      eventName: json['event_name'],
      eventType: json['event_type'],
      eventDate: json['event_date'],
      eventTime: json['event_time'],
      location: json['location'],
      city: json['city'],
      guestCount: json['guest_count'],
      budget: (json['budget'] as num).toDouble(),
      services: json['services'] is String
          ? (json['services'] as String).split(',').map((s) => s.trim()).toList()
          : List<String>.from(json['services'] ?? []),
      requirements: json['requirements'] ?? '',
      status: json['status'],
      transactionId: json['transaction_id'],
      bookingStep: json['booking_step'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_id': referenceId,
      'customer_id': customerId,
      'event_name': eventName,
      'event_type': eventType,
      'event_date': eventDate,
      'event_time': eventTime,
      'location': location,
      'city': city,
      'guest_count': guestCount,
      'budget': budget,
      'services': services,
      'requirements': requirements,
      'status': status,
      'transaction_id': transactionId,
      'booking_step': bookingStep,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
