class User {
  final int id;
  final String? email; // Changed to nullable for Phone Auth
  final String? fullName;
  final String? googleId;
  final String? profilePicture;
  final String? phoneNumber;
  final String? address;
  final String? kycStatus;
  final bool isActive;
  final bool isSuperuser;

  User({
    required this.id,
    this.email, // Now optional
    this.fullName,
    this.googleId,
    this.profilePicture,
    this.phoneNumber,
    this.address,
    this.kycStatus,
    this.isActive = true,
    this.isSuperuser = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'],
      fullName: json['full_name'],
      googleId: json['google_id'],
      profilePicture: json['profile_picture'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      kycStatus: json['kyc_status']?.toString().toUpperCase() ?? 'PENDING',
      isActive: json['is_active'] == true,
      isSuperuser: json['is_superuser'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'google_id': googleId,
      'profile_picture': profilePicture,
      'phone_number': phoneNumber,
      'address': address,
      'kyc_status': kycStatus,
      'is_active': isActive,
      'is_superuser': isSuperuser,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? googleId,
    String? profilePicture,
    String? phoneNumber,
    String? address,
    String? kycStatus,
    bool? isActive,
    bool? isSuperuser,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      googleId: googleId ?? this.googleId,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      kycStatus: kycStatus ?? this.kycStatus,
      isActive: isActive ?? this.isActive,
      isSuperuser: isSuperuser ?? this.isSuperuser,
    );
  }
}


