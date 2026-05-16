// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerStatModel _$CustomerStatModelFromJson(Map<String, dynamic> json) =>
    CustomerStatModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      joinDate: DateTime.parse(json['join_date'] as String),
      lastActive: json['last_active'] == null
          ? null
          : DateTime.parse(json['last_active'] as String),
      totalBookings: (json['total_bookings'] as num).toInt(),
      activeBookings: (json['active_bookings'] as num).toInt(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      avgSpent: (json['avg_spent'] as num).toDouble(),
      tier: json['tier'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$CustomerStatModelToJson(CustomerStatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'location': instance.location,
      'join_date': instance.joinDate.toIso8601String(),
      'last_active': instance.lastActive?.toIso8601String(),
      'total_bookings': instance.totalBookings,
      'active_bookings': instance.activeBookings,
      'total_spent': instance.totalSpent,
      'avg_spent': instance.avgSpent,
      'tier': instance.tier,
      'status': instance.status,
    };

CustomerDetailModel _$CustomerDetailModelFromJson(Map<String, dynamic> json) =>
    CustomerDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      joinDate: DateTime.parse(json['join_date'] as String),
      lastActive: json['last_active'] == null
          ? null
          : DateTime.parse(json['last_active'] as String),
      totalBookings: (json['total_bookings'] as num).toInt(),
      activeBookings: (json['active_bookings'] as num).toInt(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      avgSpent: (json['avg_spent'] as num).toDouble(),
      tier: json['tier'] as String,
      status: json['status'] as String,
      gender: json['gender'] as String?,
      anniversary: json['anniversary'] == null
          ? null
          : DateTime.parse(json['anniversary'] as String),
      preferences: json['preferences'] as Map<String, dynamic>?,
      adminNotes: json['admin_notes'] as String?,
    );

Map<String, dynamic> _$CustomerDetailModelToJson(
  CustomerDetailModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'location': instance.location,
  'join_date': instance.joinDate.toIso8601String(),
  'last_active': instance.lastActive?.toIso8601String(),
  'total_bookings': instance.totalBookings,
  'active_bookings': instance.activeBookings,
  'total_spent': instance.totalSpent,
  'avg_spent': instance.avgSpent,
  'tier': instance.tier,
  'status': instance.status,
  'gender': instance.gender,
  'anniversary': instance.anniversary?.toIso8601String(),
  'preferences': instance.preferences,
  'admin_notes': instance.adminNotes,
};
