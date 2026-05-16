// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lead_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeadModel _$LeadModelFromJson(Map<String, dynamic> json) => LeadModel(
  id: (json['id'] as num).toInt(),
  eventName: json['event_name'] as String,
  eventType: json['event_type'] as String,
  eventDate: json['event_date'] as String,
  city: json['city'] as String?,
  location: json['location'] as String?,
  budget: (json['budget'] as num).toDouble(),
  status: json['status'] as String,
  requirements: json['requirements'] as String?,
  subCategory: json['sub_category'] as String?,
  guestCount: json['guest_count'] as String?,
);

Map<String, dynamic> _$LeadModelToJson(LeadModel instance) => <String, dynamic>{
  'id': instance.id,
  'event_name': instance.eventName,
  'event_type': instance.eventType,
  'event_date': instance.eventDate,
  'city': instance.city,
  'location': instance.location,
  'budget': instance.budget,
  'status': instance.status,
  'requirements': instance.requirements,
  'sub_category': instance.subCategory,
  'guest_count': instance.guestCount,
};
