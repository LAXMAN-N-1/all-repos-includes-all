// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      recipientType: json['recipient_type'] as String,
      recipientId: (json['recipient_id'] as num).toInt(),
      title: json['title'] as String,
      message: json['message'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient_type': instance.recipientType,
      'recipient_id': instance.recipientId,
      'title': instance.title,
      'message': instance.message,
      'reference_type': instance.referenceType,
      'reference_id': instance.referenceId,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
    };
