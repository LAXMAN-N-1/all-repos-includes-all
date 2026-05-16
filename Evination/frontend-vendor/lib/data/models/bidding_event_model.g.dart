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

BiddingServiceRequest _$BiddingServiceRequestFromJson(
  Map<String, dynamic> json,
) => BiddingServiceRequest(
  id: (json['id'] as num).toInt(),
  category: json['category'] as String,
  description: json['description'] as String?,
  lowestBid: (json['lowestBid'] as num).toDouble(),
  highestBid: (json['highestBid'] as num).toDouble(),
  bidsCount: (json['bidsCount'] as num).toInt(),
  hasPlacedBid: json['hasPlacedBid'] as bool? ?? false,
);

Map<String, dynamic> _$BiddingServiceRequestToJson(
  BiddingServiceRequest instance,
) => <String, dynamic>{
  'id': instance.id,
  'category': instance.category,
  'description': instance.description,
  'lowestBid': instance.lowestBid,
  'highestBid': instance.highestBid,
  'bidsCount': instance.bidsCount,
  'hasPlacedBid': instance.hasPlacedBid,
};

BiddingEvent _$BiddingEventFromJson(Map<String, dynamic> json) => BiddingEvent(
  id: (json['id'] as num).toInt(),
  eventName: json['eventName'] as String,
  eventDate: json['eventDate'] == null
      ? null
      : DateTime.parse(json['eventDate'] as String),
  eventType: json['eventType'] as String,
  status: json['status'] as String? ?? 'Open',
  categories: (json['categories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  location: json['location'] as String,
  description: json['description'] as String?,
  totalBids: (json['total_bids'] as num?)?.toInt() ?? 0,
  lowestBid: (json['lowestBid'] as num).toDouble(),
  averageBid: (json['average_bid'] as num?)?.toDouble() ?? 0.0,
  highestBid: (json['highestBid'] as num).toDouble(),
  timeLeft: json['timeLeft'] as String,
  assignedVendor: json['assigned_vendor'] == null
      ? null
      : AssignedVendorSimple.fromJson(
          json['assigned_vendor'] as Map<String, dynamic>,
        ),
  paymentStatus: json['payment_status'] as String? ?? 'pending',
  services:
      (json['services'] as List<dynamic>?)
          ?.map(
            (e) => BiddingServiceRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
);

Map<String, dynamic> _$BiddingEventToJson(BiddingEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventName': instance.eventName,
      'eventDate': instance.eventDate?.toIso8601String(),
      'eventType': instance.eventType,
      'status': instance.status,
      'categories': instance.categories,
      'location': instance.location,
      'description': instance.description,
      'total_bids': instance.totalBids,
      'lowestBid': instance.lowestBid,
      'average_bid': instance.averageBid,
      'highestBid': instance.highestBid,
      'timeLeft': instance.timeLeft,
      'assigned_vendor': instance.assignedVendor,
      'payment_status': instance.paymentStatus,
      'services': instance.services,
    };

BiddingEventDetail _$BiddingEventDetailFromJson(Map<String, dynamic> json) =>
    BiddingEventDetail(
      id: (json['id'] as num).toInt(),
      eventName: json['eventName'] as String,
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.parse(json['eventDate'] as String),
      eventType: json['eventType'] as String,
      status: json['status'] as String? ?? 'Open',
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      location: json['location'] as String,
      description: json['description'] as String?,
      totalBids: (json['total_bids'] as num?)?.toInt() ?? 0,
      lowestBid: (json['lowestBid'] as num).toDouble(),
      averageBid: (json['average_bid'] as num?)?.toDouble() ?? 0.0,
      highestBid: (json['highestBid'] as num).toDouble(),
      timeLeft: json['timeLeft'] as String,
      assignedVendor: json['assigned_vendor'] == null
          ? null
          : AssignedVendorSimple.fromJson(
              json['assigned_vendor'] as Map<String, dynamic>,
            ),
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      services:
          (json['services'] as List<dynamic>?)
              ?.map(
                (e) =>
                    BiddingServiceRequest.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      venue: json['venue'] as String?,
      expectedGuests: (json['expected_guests'] as num?)?.toInt(),
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$BiddingEventDetailToJson(BiddingEventDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventName': instance.eventName,
      'eventDate': instance.eventDate?.toIso8601String(),
      'eventType': instance.eventType,
      'status': instance.status,
      'categories': instance.categories,
      'location': instance.location,
      'description': instance.description,
      'total_bids': instance.totalBids,
      'lowestBid': instance.lowestBid,
      'average_bid': instance.averageBid,
      'highestBid': instance.highestBid,
      'timeLeft': instance.timeLeft,
      'assigned_vendor': instance.assignedVendor,
      'payment_status': instance.paymentStatus,
      'services': instance.services,
      'venue': instance.venue,
      'expected_guests': instance.expectedGuests,
      'duration': instance.duration,
    };
