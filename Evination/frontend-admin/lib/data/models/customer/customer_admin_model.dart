import 'package:json_annotation/json_annotation.dart';

part 'customer_admin_model.g.dart';

@JsonSerializable()
class CustomerStatModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  @JsonKey(name: 'join_date')
  final DateTime joinDate;
  @JsonKey(name: 'last_active')
  final DateTime? lastActive;
  
  @JsonKey(name: 'total_bookings')
  final int totalBookings;
  @JsonKey(name: 'active_bookings')
  final int activeBookings;
  @JsonKey(name: 'total_spent')
  final double totalSpent;
  @JsonKey(name: 'avg_spent')
  final double avgSpent;
  
  final String tier;
  final String status;

  CustomerStatModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    required this.joinDate,
    this.lastActive,
    required this.totalBookings,
    required this.activeBookings,
    required this.totalSpent,
    required this.avgSpent,
    required this.tier,
    required this.status,
  });

  factory CustomerStatModel.fromJson(Map<String, dynamic> json) => _$CustomerStatModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerStatModelToJson(this);
}

@JsonSerializable()
class CustomerDetailModel extends CustomerStatModel {
  final String? gender;
  final DateTime? anniversary;
  final Map<String, dynamic>? preferences;
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;

  CustomerDetailModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.location,
    required super.joinDate,
    super.lastActive,
    required super.totalBookings,
    required super.activeBookings,
    required super.totalSpent,
    required super.avgSpent,
    required super.tier,
    required super.status,
    this.gender,
    this.anniversary,
    this.preferences,
    this.adminNotes,
  });

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) => _$CustomerDetailModelFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerDetailModelToJson(this);
}
