class User {
  final int id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? profilePicture;
  final bool isActive;
  final DateTime? createdAt;
  
  User({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.profilePicture,
    required this.isActive,
    this.createdAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
