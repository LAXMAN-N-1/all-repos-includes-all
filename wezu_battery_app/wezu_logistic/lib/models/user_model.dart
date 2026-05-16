import 'package:equatable/equatable.dart';

/// Represents a dealer/user in the system.
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? dealershipName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.dealershipName,
    this.phone,
    this.avatarUrl,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? asStringOrNull(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      if (value is num || value is bool) {
        return value.toString();
      }
      return null;
    }

    DateTime? parseDate(dynamic value) {
      final raw = asStringOrNull(value);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    }

    return UserModel(
      id: asStringOrNull(json['id']) ?? '',
      name:
          asStringOrNull(json['full_name']) ??
          asStringOrNull(json['name']) ??
          'User',
      email: asStringOrNull(json['email']) ?? '',
      role: () {
        final roleObj = json['role'];
        if (roleObj is String) return roleObj;
        if (roleObj is Map<String, dynamic> && roleObj['name'] != null) {
          return roleObj['name'].toString();
        }
        final currentRoleObj = json['current_role'];
        if (currentRoleObj is String) return currentRoleObj;
        if (currentRoleObj is Map<String, dynamic> &&
            currentRoleObj['name'] != null) {
          return currentRoleObj['name'].toString();
        }
        return 'logistics_manager';
      }(),
      dealershipName: asStringOrNull(json['dealership_name']),
      phone:
          asStringOrNull(json['phone_number']) ?? asStringOrNull(json['phone']),
      avatarUrl:
          asStringOrNull(json['profile_picture']) ??
          asStringOrNull(json['avatar_url']),
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'dealership_name': dealershipName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? dealershipName,
    String? phone,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      dealershipName: dealershipName ?? this.dealershipName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    dealershipName,
    phone,
    avatarUrl,
    createdAt,
  ];
}
