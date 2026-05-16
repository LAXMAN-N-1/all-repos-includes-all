import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum DriverStatus {
  available,
  onRoute,
  busy,
  offline,
  break_time;

  String get label {
    switch (this) {
      case DriverStatus.available:
        return 'Available';
      case DriverStatus.onRoute:
        return 'On Route';
      case DriverStatus.busy:
        return 'Busy';
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.break_time:
        return 'On Break';
    }
  }

  Color get color {
    switch (this) {
      case DriverStatus.available:
        return AppColors.success;
      case DriverStatus.onRoute:
        return AppColors.info;
      case DriverStatus.busy:
        return AppColors.warning;
      case DriverStatus.offline:
        return AppColors.textHint;
      case DriverStatus.break_time:
        return AppColors.warning;
    }
  }

  static DriverStatus fromString(String value) {
    final normalized = value.toLowerCase().replaceAll('_', '');
    return DriverStatus.values.firstWhere(
      (e) => e.name.toLowerCase().replaceAll('_', '') == normalized,
      orElse: () => DriverStatus.available,
    );
  }
}

class DriverModel extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final DriverStatus status;
  final String vehicleType; // e.g., 'Van', 'Bike'
  final String vehiclePlate;
  final double currentLat;
  final double currentLng;
  final int currentBatteryLevel; // Device battery
  final int completedDeliveries;
  final double rating;
  final double locationAccuracy; // GPS accuracy in metres

  const DriverModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.vehicleType,
    required this.vehiclePlate,
    required this.currentLat,
    required this.currentLng,
    this.currentBatteryLevel = 100,
    this.completedDeliveries = 0,
    this.rating = 5.0,
    this.locationAccuracy = 0.0,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      status: DriverStatus.fromString(json['status'] as String? ?? 'available'),
      vehicleType: json['vehicle_type'] as String? ?? 'Unknown',
      vehiclePlate: json['vehicle_plate'] as String? ?? '',
      currentLat: (json['current_lat'] as num?)?.toDouble() ?? 0.0,
      currentLng: (json['current_lng'] as num?)?.toDouble() ?? 0.0,
      currentBatteryLevel: json['current_battery_level'] as int? ?? 100,
      completedDeliveries: json['completed_deliveries'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      locationAccuracy: (json['location_accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone_number': phoneNumber,
    'status': status.name,
    'vehicle_type': vehicleType,
    'vehicle_plate': vehiclePlate,
    'current_lat': currentLat,
    'current_lng': currentLng,
    'current_battery_level': currentBatteryLevel,
    'completed_deliveries': completedDeliveries,
    'rating': rating,
    'location_accuracy': locationAccuracy,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    currentLat,
    currentLng,
    locationAccuracy,
  ];

  DriverModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    DriverStatus? status,
    String? vehicleType,
    String? vehiclePlate,
    double? currentLat,
    double? currentLng,
    int? currentBatteryLevel,
    int? completedDeliveries,
    double? rating,
    double? locationAccuracy,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      currentBatteryLevel: currentBatteryLevel ?? this.currentBatteryLevel,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      rating: rating ?? this.rating,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
    );
  }
}
