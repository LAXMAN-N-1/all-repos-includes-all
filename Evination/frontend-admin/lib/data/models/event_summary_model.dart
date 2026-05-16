import 'package:json_annotation/json_annotation.dart';

part 'event_summary_model.g.dart';

@JsonSerializable()
class EventSummary {
  final int id;
  final String name;
  final String category;
  final String type;
  final String date;
  final String location;
  @JsonKey(name: 'attendees')
  final int attendees;
  @JsonKey(name: 'budget')
  final double budget;
  final String? manager;
  final String status;

  EventSummary({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.date,
    required this.location,
    required this.attendees,
    required this.budget,
    this.manager,
    required this.status,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) => _$EventSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EventSummaryToJson(this);
}
