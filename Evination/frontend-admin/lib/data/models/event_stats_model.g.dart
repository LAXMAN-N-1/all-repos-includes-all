// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventStats _$EventStatsFromJson(Map<String, dynamic> json) => EventStats(
  totalEvents: (json['totalEvents'] as num).toInt(),
  activeEvents: (json['activeEvents'] as num).toInt(),
  totalAttendees: (json['totalAttendees'] as num).toInt(),
  totalBudget: (json['totalBudget'] as num).toDouble(),
);

Map<String, dynamic> _$EventStatsToJson(EventStats instance) =>
    <String, dynamic>{
      'totalEvents': instance.totalEvents,
      'activeEvents': instance.activeEvents,
      'totalAttendees': instance.totalAttendees,
      'totalBudget': instance.totalBudget,
    };
