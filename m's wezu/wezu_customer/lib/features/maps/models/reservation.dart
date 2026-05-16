enum ReservationStatus { active, completed, cancelled, expired }

class Reservation {
  final int id;
  final int stationId;
  final String stationName;
  final String stationAddress;
  final String batteryType;
  final DateTime startTime;
  final DateTime expiryTime;
  final ReservationStatus status;
  final double latitude;
  final double longitude;
  final double? fee;

  Reservation({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.stationAddress,
    required this.batteryType,
    required this.startTime,
    required this.expiryTime,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.fee,
  });

  bool get isExpired => DateTime.now().isAfter(expiryTime);

  Duration get remainingTime => expiryTime.difference(DateTime.now());

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      stationId: json['station_id'],
      stationName: json['station_name'] ?? '',
      stationAddress: json['station_address'] ?? '',
      batteryType: json['battery_type'] ?? 'Unknown',
      startTime: DateTime.parse(json['start_time']).toLocal(),
      expiryTime: DateTime.parse(json['expiry_time']).toLocal(),
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReservationStatus.active,
      ),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      fee: (json['fee'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'station_name': stationName,
      'station_address': stationAddress,
      'battery_type': batteryType,
      'start_time': startTime.toIso8601String(),
      'expiry_time': expiryTime.toIso8601String(),
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'fee': fee,
    };
  }

  Reservation copyWith({
    int? id,
    int? stationId,
    String? stationName,
    String? stationAddress,
    String? batteryType,
    DateTime? startTime,
    DateTime? expiryTime,
    ReservationStatus? status,
    double? latitude,
    double? longitude,
    double? fee,
  }) {
    return Reservation(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      stationAddress: stationAddress ?? this.stationAddress,
      batteryType: batteryType ?? this.batteryType,
      startTime: startTime ?? this.startTime,
      expiryTime: expiryTime ?? this.expiryTime,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fee: fee ?? this.fee,
    );
  }
}
