import 'package:json_annotation/json_annotation.dart';
import 'bid_model.dart';

part 'customer_view_model.g.dart';

@JsonSerializable()
class CustomerViewResponse {
  @JsonKey(name: 'event_id')
  final int eventId;
  @JsonKey(name: 'event_name')
  final String eventName;
  @JsonKey(name: 'event_date')
  final DateTime eventDate;
  @JsonKey(name: 'event_location')
  final String? eventLocation;
  @JsonKey(name: 'event_venue')
  final String? eventVenue;
  @JsonKey(name: 'event_guests')
  final int? eventGuests;
  
  @JsonKey(name: 'assigned_bid')
  final Bid? assignedBid;
  @JsonKey(name: 'top_bids')
  final List<Bid> topBids;

  CustomerViewResponse({
    required this.eventId,
    required this.eventName,
    required this.eventDate,
    this.eventLocation,
    this.eventVenue,
    this.eventGuests,
    this.assignedBid,
    required this.topBids,
  });

  factory CustomerViewResponse.fromJson(Map<String, dynamic> json) => _$CustomerViewResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerViewResponseToJson(this);
}
