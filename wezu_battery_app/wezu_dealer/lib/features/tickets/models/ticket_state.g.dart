// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketMessage _$TicketMessageFromJson(Map<String, dynamic> json) =>
    _TicketMessage(
      id: (json['id'] as num).toInt(),
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );

Map<String, dynamic> _$TicketMessageToJson(_TicketMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderName': instance.senderName,
      'senderAvatar': instance.senderAvatar,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': instance.type,
    };

_StatusChangeEvent _$StatusChangeEventFromJson(Map<String, dynamic> json) =>
    _StatusChangeEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      dotColor: json['dotColor'] as String,
    );

Map<String, dynamic> _$StatusChangeEventToJson(_StatusChangeEvent instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'description': instance.description,
      'dotColor': instance.dotColor,
    };

_TicketDto _$TicketDtoFromJson(Map<String, dynamic> json) => _TicketDto(
      id: (json['id'] as num).toInt(),
      subject: json['subject'] as String,
      description: json['description'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      customerAvatar: json['customerAvatar'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      category: json['category'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedToAvatar: json['assignedToAvatar'] as String?,
      slaDeadline: json['slaDeadline'] == null
          ? null
          : DateTime.parse(json['slaDeadline'] as String),
      stationName: json['stationName'] as String?,
      batteryId: json['batteryId'] as String?,
      transactionId: json['transactionId'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      sourceChannel: json['sourceChannel'] as String? ?? 'Mobile App',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => TicketMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map(
                  (e) => StatusChangeEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCritical: json['isCritical'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
    );

Map<String, dynamic> _$TicketDtoToJson(_TicketDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'description': instance.description,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'customerAvatar': instance.customerAvatar,
      'priority': instance.priority,
      'status': instance.status,
      'category': instance.category,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'assignedToName': instance.assignedToName,
      'assignedToAvatar': instance.assignedToAvatar,
      'slaDeadline': instance.slaDeadline?.toIso8601String(),
      'stationName': instance.stationName,
      'batteryId': instance.batteryId,
      'transactionId': instance.transactionId,
      'tags': instance.tags,
      'sourceChannel': instance.sourceChannel,
      'messages': instance.messages,
      'statusHistory': instance.statusHistory,
      'isCritical': instance.isCritical,
      'isResolved': instance.isResolved,
    };

_TicketMetric _$TicketMetricFromJson(Map<String, dynamic> json) =>
    _TicketMetric(
      label: json['label'] as String,
      value: json['value'] as String,
      trend: json['trend'] as String?,
      color: json['color'] as String,
    );

Map<String, dynamic> _$TicketMetricToJson(_TicketMetric instance) =>
    <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'trend': instance.trend,
      'color': instance.color,
    };
