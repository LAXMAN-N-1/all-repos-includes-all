// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bidding_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssignedVendorSimple _$AssignedVendorSimpleFromJson(
  Map<String, dynamic> json,
) => AssignedVendorSimple(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
);

Map<String, dynamic> _$AssignedVendorSimpleToJson(
  AssignedVendorSimple instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'amount': instance.amount,
  'rating': instance.rating,
};

BiddingEvent _$BiddingEventFromJson(Map<String, dynamic> json) => BiddingEvent(
  id: (json['id'] as num).toInt(),
  eventName: json['event_name'] as String,
  eventDate: DateTime.parse(json['event_date'] as String),
  eventType: json['event_type'] as String,
  status: json['status'] as String,
  categories: (json['categories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  location: json['location'] as String,
  description: json['description'] as String?,
  totalBids: (json['total_bids'] as num).toInt(),
  lowestBid: (json['lowest_bid'] as num).toDouble(),
  averageBid: (json['average_bid'] as num).toDouble(),
  highestBid: (json['highest_bid'] as num).toDouble(),
  timeLeft: json['time_left'] as String,
  assignedVendor: json['assigned_vendor'] == null
      ? null
      : AssignedVendorSimple.fromJson(
          json['assigned_vendor'] as Map<String, dynamic>,
        ),
  paymentStatus: json['payment_status'] as String,
);

Map<String, dynamic> _$BiddingEventToJson(BiddingEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_name': instance.eventName,
      'event_date': instance.eventDate.toIso8601String(),
      'event_type': instance.eventType,
      'status': instance.status,
      'categories': instance.categories,
      'location': instance.location,
      'description': instance.description,
      'total_bids': instance.totalBids,
      'lowest_bid': instance.lowestBid,
      'average_bid': instance.averageBid,
      'highest_bid': instance.highestBid,
      'time_left': instance.timeLeft,
      'assigned_vendor': instance.assignedVendor,
      'payment_status': instance.paymentStatus,
    };

BiddingEventDetail _$BiddingEventDetailFromJson(Map<String, dynamic> json) =>
    BiddingEventDetail(
      id: (json['id'] as num).toInt(),
      eventName: json['event_name'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      eventType: json['event_type'] as String,
      status: json['status'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      location: json['location'] as String,
      description: json['description'] as String?,
      totalBids: (json['total_bids'] as num).toInt(),
      lowestBid: (json['lowest_bid'] as num).toDouble(),
      averageBid: (json['average_bid'] as num).toDouble(),
      highestBid: (json['highest_bid'] as num).toDouble(),
      timeLeft: json['time_left'] as String,
      assignedVendor: json['assigned_vendor'] == null
          ? null
          : AssignedVendorSimple.fromJson(
              json['assigned_vendor'] as Map<String, dynamic>,
            ),
      paymentStatus: json['payment_status'] as String,
      venue: json['venue'] as String?,
      expectedGuests: (json['expected_guests'] as num?)?.toInt(),
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$BiddingEventDetailToJson(BiddingEventDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_name': instance.eventName,
      'event_date': instance.eventDate.toIso8601String(),
      'event_type': instance.eventType,
      'status': instance.status,
      'categories': instance.categories,
      'location': instance.location,
      'description': instance.description,
      'total_bids': instance.totalBids,
      'lowest_bid': instance.lowestBid,
      'average_bid': instance.averageBid,
      'highest_bid': instance.highestBid,
      'time_left': instance.timeLeft,
      'assigned_vendor': instance.assignedVendor,
      'payment_status': instance.paymentStatus,
      'venue': instance.venue,
      'expected_guests': instance.expectedGuests,
      'duration': instance.duration,
    };
