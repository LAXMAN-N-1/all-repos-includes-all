import 'package:json_annotation/json_annotation.dart';

part 'lead_model.g.dart';

@JsonSerializable()
class LeadModel {
  final int id;
  @JsonKey(name: 'event_name')
  final String eventName;
  @JsonKey(name: 'event_type')
  final String eventType;
  @JsonKey(name: 'event_date')
  final String eventDate;
  final String? city;
  final String? location;
  final double budget;
  final String status;
  final String? requirements;
  
  // New Fields
  @JsonKey(name: 'sub_category')
  final String? subCategory;
  @JsonKey(name: 'guest_count')
  final String? guestCount;

  LeadModel({
    required this.id,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    this.city,
    this.location,
    required this.budget,
    required this.status,
    this.requirements,
    this.subCategory,
    this.guestCount
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) => _$LeadModelFromJson(json);
  Map<String, dynamic> toJson() => _$LeadModelToJson(this);
}
