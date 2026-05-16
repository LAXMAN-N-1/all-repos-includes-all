// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsuranceModelImpl _$$InsuranceModelImplFromJson(Map<String, dynamic> json) =>
    _$InsuranceModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverageAmount: (json['coverageAmount'] as num).toDouble(),
      premiumAmount: (json['premiumAmount'] as num).toDouble(),
      providerName: json['providerName'] as String,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'Active',
    );

Map<String, dynamic> _$$InsuranceModelImplToJson(
        _$InsuranceModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'coverageAmount': instance.coverageAmount,
      'premiumAmount': instance.premiumAmount,
      'providerName': instance.providerName,
      'features': instance.features,
      'status': instance.status,
    };
