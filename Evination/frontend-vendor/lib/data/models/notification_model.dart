import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  @JsonKey(name: 'recipient_type')
  final String recipientType;
  @JsonKey(name: 'recipient_id')
  final int recipientId;
  final String title;
  final String message;
  @JsonKey(name: 'reference_type')
  final String? referenceType;
  @JsonKey(name: 'reference_id')
  final String? referenceId;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientType,
    required this.recipientId,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
