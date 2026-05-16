import 'package:json_annotation/json_annotation.dart';

part 'bidding_event_model.g.dart';

@JsonSerializable()
class AssignedVendorSimple {
  final int id;
  final String name;
  final double amount;
  final double rating;

  AssignedVendorSimple({
    required this.id,
    required this.name,
    required this.amount,
    required this.rating,
  });

  factory AssignedVendorSimple.fromJson(Map<String, dynamic> json) => _$AssignedVendorSimpleFromJson(json);
  Map<String, dynamic> toJson() => _$AssignedVendorSimpleToJson(this);
}

@JsonSerializable()
class BiddingEvent {
  final int id;
  @JsonKey(name: 'event_name')
  final String eventName;
  @JsonKey(name: 'event_date')
  final DateTime eventDate;
  @JsonKey(name: 'event_type')
  final String eventType;
  final String status;
  final List<String> categories;
  final String location;
  final String? description;
  
  @JsonKey(name: 'total_bids')
  final int totalBids;
  @JsonKey(name: 'lowest_bid')
  final double lowestBid;
  @JsonKey(name: 'average_bid')
  final double averageBid;
  @JsonKey(name: 'highest_bid')
  final double highestBid;
  
  @JsonKey(name: 'time_left')
  final String timeLeft;
  @JsonKey(name: 'assigned_vendor')
  final AssignedVendorSimple? assignedVendor;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  BiddingEvent({
    required this.id,
    required this.eventName,
    required this.eventDate,
    required this.eventType,
    required this.status,
    required this.categories,
    required this.location,
    this.description,
    required this.totalBids,
    required this.lowestBid,
    required this.averageBid,
    required this.highestBid,
    required this.timeLeft,
    this.assignedVendor,
    required this.paymentStatus,
  });

  factory BiddingEvent.fromJson(Map<String, dynamic> json) => _$BiddingEventFromJson(json);
  Map<String, dynamic> toJson() => _$BiddingEventToJson(this);
}

@JsonSerializable()
class BiddingEventDetail extends BiddingEvent {
  final String? venue;
  @JsonKey(name: 'expected_guests')
  final int? expectedGuests;
  final String? duration;

  BiddingEventDetail({
    required super.id,
    required super.eventName,
    required super.eventDate,
    required super.eventType,
    required super.status,
    required super.categories,
    required super.location,
    super.description,
    required super.totalBids,
    required super.lowestBid,
    required super.averageBid,
    required super.highestBid,
    required super.timeLeft,
    super.assignedVendor,
    required super.paymentStatus,
    this.venue,
    this.expectedGuests,
    this.duration,
  });

  factory BiddingEventDetail.fromJson(Map<String, dynamic> json) => _$BiddingEventDetailFromJson(json);
  Map<String, dynamic> toJson() => _$BiddingEventDetailToJson(this);
}
