import 'package:json_annotation/json_annotation.dart';

part 'event_stats_model.g.dart';

@JsonSerializable()
class EventStats {
  final int totalEvents;
  final int activeEvents;
  final int totalAttendees;
  final double totalBudget;

  EventStats({
    required this.totalEvents,
    required this.activeEvents,
    required this.totalAttendees,
    required this.totalBudget,
  });

  factory EventStats.fromJson(Map<String, dynamic> json) => _$EventStatsFromJson(json);
  Map<String, dynamic> toJson() => _$EventStatsToJson(this);
}
