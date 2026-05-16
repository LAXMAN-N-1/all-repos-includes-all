class DealerUser {
  final dynamic id;
  final String name;
  final String email;
  final String role;
  final bool isOnline;

  // Auth specific properties
  final dynamic dealerId;
  final String businessName;
  final bool isApproved;
  final String applicationStage;

  // Role details
  final int? roleId;
  final String? roleName;
  final String? roleIcon;
  final String? roleColor;

  // Status & metadata
  final String status;
  final String? phone;
  final String? department;
  final String? profilePicture;
  final String? lastLogin;
  final String? createdAt;
  final String? createdBy;
  final String? inviteSentAt;
  final bool forcePasswordChange;

  final List<int> stationIds;
  final Map<String, List<String>> permissions;

  DealerUser({
    this.id = 'unknown',
    this.name = 'Unknown User',
    this.email = '',
    this.role = 'Viewer',
    this.isOnline = false,

    this.dealerId = 0,
    this.businessName = '',
    this.isApproved = false,
    this.applicationStage = '',

    this.roleId,
    this.roleName,
    this.roleIcon,
    this.roleColor,

    this.status = 'active',
    this.phone,
    this.department,
    this.profilePicture,
    this.lastLogin,
    this.createdAt,
    this.createdBy,
    this.inviteSentAt,
    this.forcePasswordChange = false,

    this.stationIds = const [],
    this.permissions = const {},
  });

  // Getters for old references
  String get fullName => name;
  String get userType => role;

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory DealerUser.fromJson(Map<String, dynamic> json) {
    // Parse permissions
    Map<String, List<String>> perms = {};
    if (json['permissions'] is Map) {
      (json['permissions'] as Map).forEach((key, value) {
        if (value is List) {
          perms[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    }

    return DealerUser(
      id: json['id'] ?? 'unknown',
      name: json['name'] ?? json['full_name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      role: json['role'] ?? json['role_name'] ?? json['userType'] ?? json['user_type'] ?? 'Viewer',
      isOnline: json['is_online'] ?? false,

      dealerId: json['dealer_id'] ?? 0,
      businessName: json['business_name'] ?? '',
      isApproved: json['is_approved'] ?? json['is_active'] ?? json['isApproved'] ?? false,
      applicationStage: json['application_stage'] ?? json['current_stage'] ?? json['applicationStage'] ?? '',

      roleId: json['role_id'],
      roleName: json['role_name'],
      roleIcon: json['role_icon'],
      roleColor: json['role_color'],

      status: json['status'] ?? 'active',
      phone: json['phone_number'],
      department: json['department'],
      profilePicture: json['profile_picture'],
      lastLogin: json['last_login'],
      createdAt: json['created_at'],
      createdBy: json['created_by'],
      inviteSentAt: json['invite_sent_at'],
      forcePasswordChange: json['force_password_change'] ?? json['must_change_password'] ?? false,

      stationIds: (json['station_ids'] as List?)?.map((e) => int.parse(e.toString())).toList() ?? [],
      permissions: perms,
    );
  }
}
