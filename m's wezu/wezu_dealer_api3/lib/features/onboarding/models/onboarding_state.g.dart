// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OnboardingStatusDto _$OnboardingStatusDtoFromJson(Map<String, dynamic> json) =>
    _OnboardingStatusDto(
      currentStage: json['current_stage'] as String,
      riskScore: (json['risk_score'] as num?)?.toDouble(),
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$OnboardingStatusDtoToJson(
        _OnboardingStatusDto instance) =>
    <String, dynamic>{
      'current_stage': instance.currentStage,
      'risk_score': instance.riskScore,
      'history': instance.history,
    };
