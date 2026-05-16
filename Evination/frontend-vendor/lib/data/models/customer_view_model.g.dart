// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_view_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerViewResponse _$CustomerViewResponseFromJson(
  Map<String, dynamic> json,
) => CustomerViewResponse(
  eventId: (json['event_id'] as num).toInt(),
  eventName: json['event_name'] as String,
  eventDate: json['event_date'] == null
      ? null
      : DateTime.parse(json['event_date'] as String),
  eventLocation: json['event_location'] as String?,
  eventVenue: json['event_venue'] as String?,
  eventGuests: (json['event_guests'] as num?)?.toInt(),
  assignedBid: json['assigned_bid'] == null
      ? null
      : Bid.fromJson(json['assigned_bid'] as Map<String, dynamic>),
  topBids: (json['top_bids'] as List<dynamic>)
      .map((e) => Bid.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CustomerViewResponseToJson(
  CustomerViewResponse instance,
) => <String, dynamic>{
  'event_id': instance.eventId,
  'event_name': instance.eventName,
  'event_date': instance.eventDate?.toIso8601String(),
  'event_location': instance.eventLocation,
  'event_venue': instance.eventVenue,
  'event_guests': instance.eventGuests,
  'assigned_bid': instance.assignedBid,
  'top_bids': instance.topBids,
};
