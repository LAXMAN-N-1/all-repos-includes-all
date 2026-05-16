class AddressModel {
  final int id;
  final int userId;
  final String title;
  final String fullAddress;
  final double? lat;
  final double? lng;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.fullAddress,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final latValue = json['lat'] ?? json['latitude'];
    final lngValue = json['lng'] ?? json['longitude'];
    final street = (json['street_address'] ?? json['address_line1'] ?? '')
        .toString()
        .trim();
    final city = (json['city'] ?? '').toString().trim();
    final state = (json['state'] ?? '').toString().trim();
    final postal = (json['postal_code'] ?? json['pincode'] ?? '')
        .toString()
        .trim();

    final composedAddress = [
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (postal.isNotEmpty) postal,
    ].join(', ');

    return AddressModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? json['type'] ?? '').toString(),
      fullAddress: (json['full_address'] ?? composedAddress).toString(),
      lat: (latValue as num?)?.toDouble(),
      lng: (lngValue as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  AddressModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? fullAddress,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'full_address': fullAddress,
    'lat': lat,
    'lng': lng,
    'is_default': isDefault,
  };
}
