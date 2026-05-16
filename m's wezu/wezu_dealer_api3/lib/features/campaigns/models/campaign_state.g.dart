// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CampaignDto _$CampaignDtoFromJson(Map<String, dynamic> json) => _CampaignDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      desc: json['desc'] as String,
      status: json['status'] as String,
      dates: json['dates'] as String,
      redemptions: json['redemptions'] as String,
      revenue: json['revenue'] as String,
    );

Map<String, dynamic> _$CampaignDtoToJson(_CampaignDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'desc': instance.desc,
      'status': instance.status,
      'dates': instance.dates,
      'redemptions': instance.redemptions,
      'revenue': instance.revenue,
    };
