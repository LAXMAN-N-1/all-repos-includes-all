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
class BiddingServiceRequest {
  final int id;
  final String category;
  final String? description;
  @JsonKey(name: 'lowestBid')
  final double lowestBid;
  @JsonKey(name: 'highestBid')
  final double highestBid;
  @JsonKey(name: 'bidsCount')
  final int bidsCount;
  final bool hasPlacedBid;

  BiddingServiceRequest({
    required this.id,
    required this.category,
    this.description,
    required this.lowestBid,
    required this.highestBid,
    required this.bidsCount,
    this.hasPlacedBid = false,
  });

  factory BiddingServiceRequest.fromJson(Map<String, dynamic> json) => _$BiddingServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BiddingServiceRequestToJson(this);
}

@JsonSerializable()
class BiddingEvent {
  final int id;
  @JsonKey(name: 'eventName')
  final String eventName;
  @JsonKey(name: 'eventDate')
  final DateTime? eventDate; // Made nullable or parse from grouping
  @JsonKey(name: 'eventType')
  final String eventType;
  // Status might not be in grouping response but keeping for compatibility
  final String status; 
  final List<String> categories;
  final String location;
  final String? description;
  
  // Aggregated Bids
  @JsonKey(name: 'total_bids', defaultValue: 0)
  final int totalBids;
  @JsonKey(name: 'lowestBid')
  final double lowestBid;
  @JsonKey(name: 'average_bid', defaultValue: 0.0)
  final double averageBid;
  @JsonKey(name: 'highestBid')
  final double highestBid;
  
  @JsonKey(name: 'timeLeft')
  final String timeLeft;
  @JsonKey(name: 'assigned_vendor')
  final AssignedVendorSimple? assignedVendor;
  @JsonKey(name: 'payment_status', defaultValue: 'pending')
  final String paymentStatus;

  // NEW: List of individual services
  @JsonKey(defaultValue: [])
  final List<BiddingServiceRequest> services;

  BiddingEvent({
    required this.id,
    required this.eventName,
    this.eventDate,
    required this.eventType,
    this.status = 'Open',
    required this.categories,
    required this.location,
    this.description,
    this.totalBids = 0,
    required this.lowestBid,
    this.averageBid = 0.0,
    required this.highestBid,
    required this.timeLeft,
    this.assignedVendor,
    this.paymentStatus = 'pending',
    required this.services,
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
    super.eventDate,
    required super.eventType,
    super.status = 'Open',
    required super.categories,
    required super.location,
    super.description,
    super.totalBids = 0,
    required super.lowestBid,
    super.averageBid = 0.0,
    required super.highestBid,
    required super.timeLeft,
    super.assignedVendor,
    super.paymentStatus = 'pending',
    required super.services,
    this.venue,
    this.expectedGuests,
    this.duration,
  });

  factory BiddingEventDetail.fromJson(Map<String, dynamic> json) => _$BiddingEventDetailFromJson(json);
  Map<String, dynamic> toJson() => _$BiddingEventDetailToJson(this);
}
