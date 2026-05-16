// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_status_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KycStatusDto _$KycStatusDtoFromJson(Map<String, dynamic> json) =>
    _KycStatusDto(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      status: json['application_state'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      adminComments: json['adminComments'] as String?,
      submittedAt: json['submitted_at'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      riskScore: (json['risk_score'] as num?)?.toDouble(),
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$KycStatusDtoToJson(_KycStatusDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'application_state': instance.status,
      'rejection_reason': instance.rejectionReason,
      'adminComments': instance.adminComments,
      'submitted_at': instance.submittedAt,
      'reviewed_at': instance.reviewedAt,
      'risk_score': instance.riskScore,
      'history': instance.history,
    };
