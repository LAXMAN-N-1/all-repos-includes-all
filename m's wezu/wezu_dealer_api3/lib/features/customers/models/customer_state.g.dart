// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomerDto _$CustomerDtoFromJson(Map<String, dynamic> json) => _CustomerDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      totalRentals: (json['totalRentals'] as num).toInt(),
      status: json['status'] as String,
      joinedAt: json['joinedAt'] as String?,
    );

Map<String, dynamic> _$CustomerDtoToJson(_CustomerDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'totalRentals': instance.totalRentals,
      'status': instance.status,
      'joinedAt': instance.joinedAt,
    };
