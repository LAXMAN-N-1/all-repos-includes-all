class DealerRole {
  final dynamic id;
  final String name;
  final String description;
  final int usersCount;
  final Map<String, List<String>> permissions;
  final String iconName;
  final String colorHex;
  final bool isSystem; // Prevent deleting core roles like Super Admin
  final DateTime updatedAt;

  DealerRole({
    required this.id,
    required this.name,
    required this.description,
    this.usersCount = 0,
    this.permissions = const {},
    this.iconName = 'eye',
    this.colorHex = '#8B8D97',
    this.isSystem = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory DealerRole.fromJson(Map<String, dynamic> json) {
    // Map backend permissions or use defaults for demo
    final dynamic perms = json['permissions'];
    Map<String, List<String>> parsedPerms = {};
    if (perms is Map) {
      perms.forEach((k, v) {
        if (v is List) {
          parsedPerms[k.toString()] = v.map((e) => e.toString()).toList();
        }
      });
    }

    return DealerRole(
      id: json['id'] ?? 'unknown',
      name: json['name'] ?? 'Unknown Role',
      description: json['description'] ?? 'No description available',
      usersCount: json['users_count'] ?? json['users'] ?? 0,
      permissions: parsedPerms,
      iconName: json['icon'] ?? 'eye',
      colorHex: json['color'] ?? '#8B8D97',
      isSystem: json['is_system'] ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}
