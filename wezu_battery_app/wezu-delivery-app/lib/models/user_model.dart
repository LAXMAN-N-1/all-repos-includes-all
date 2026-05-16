class UserProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String profileImageUrl;
  final VehicleDetails vehicle;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.profileImageUrl,
    required this.vehicle,
  });

  factory UserProfile.empty() {
    return UserProfile(
      id: '',
      name: '',
      phone: '',
      email: '',
      address: '',
      profileImageUrl: '',
      vehicle: VehicleDetails.empty(),
    );
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    String? profileImageUrl,
    VehicleDetails? vehicle,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      vehicle: vehicle ?? this.vehicle,
    );
  }
}

class VehicleDetails {
  final String type;
  final String model;
  final String plateNumber;
  final String color;
  final String year;

  VehicleDetails({
    required this.type,
    required this.model,
    required this.plateNumber,
    required this.color,
    required this.year,
  });

  factory VehicleDetails.empty() {
    return VehicleDetails(
      type: '',
      model: '',
      plateNumber: '',
      color: '',
      year: '',
    );
  }

  VehicleDetails copyWith({
    String? type,
    String? model,
    String? plateNumber,
    String? color,
    String? year,
  }) {
    return VehicleDetails(
      type: type ?? this.type,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      year: year ?? this.year,
    );
  }
}
