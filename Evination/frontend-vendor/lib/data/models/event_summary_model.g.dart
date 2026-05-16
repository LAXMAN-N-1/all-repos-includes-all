// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventSummary _$EventSummaryFromJson(Map<String, dynamic> json) => EventSummary(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  type: json['type'] as String,
  date: json['date'] as String,
  location: json['location'] as String,
  attendees: (json['attendees'] as num).toInt(),
  budget: (json['budget'] as num).toDouble(),
  manager: json['manager'] as String?,
  status: json['status'] as String,
);

Map<String, dynamic> _$EventSummaryToJson(EventSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'type': instance.type,
      'date': instance.date,
      'location': instance.location,
      'attendees': instance.attendees,
      'budget': instance.budget,
      'manager': instance.manager,
      'status': instance.status,
    };
