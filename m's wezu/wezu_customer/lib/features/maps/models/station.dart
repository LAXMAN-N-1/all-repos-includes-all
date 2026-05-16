import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide Cluster, ClusterManager;
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart'
    as cm;
import '../../rental/models/battery.dart';
import 'review.dart';

class Station implements cm.ClusterItem {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String status;
  final double rating;
  final int totalReviews;
  final int availableBatteries;
  final int totalSlots;
  final bool is24x7;
  final String? openingTime;
  final String? closingTime;
  final String? contactEmail;
  final String? contactPhone;
  final List<String> amenities;
  final List<String> images;
  final List<Review>? reviews;
  final List<Battery>? batteries;
  double? distance; // Client-side calculation

  final double pricePerHour;
  final String batteryType;
  final int batteryCapacity;
  final bool isDealer;
  final int socPercentage;
  final double temperature;
  final String healthStatus; // Healthy, Warming, Critical

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.rating,
    required this.totalReviews,
    required this.availableBatteries,
    required this.totalSlots,
    required this.is24x7,
    this.openingTime,
    this.closingTime,
    this.contactEmail,
    this.contactPhone,
    this.amenities = const [],
    this.images = const [],
    this.reviews,
    this.batteries,
    this.distance,
    this.pricePerHour = 50.0,
    this.batteryType = 'Li-ion',
    this.batteryCapacity = 2000,
    this.chargingSpeed = 'Standard',
    this.isDealer = false,
    this.socPercentage = 0,
    this.temperature = 25.0,
    this.healthStatus = 'Healthy',
  });

  final String chargingSpeed; // Standard, Fast, Ultra

  @override
  LatLng get location => LatLng(latitude, longitude);

  @override
  String get geohash =>
      cm.Geohash.encode(latLng: location, codeLength: 12);
  String get openingHours {
    if (is24x7) return '24x7';
    if (openingTime != null && closingTime != null) {
      return '$openingTime - $closingTime';
    }
    return '09:00 AM - 09:00 PM';
  }

  String get contactNumber => contactPhone ?? 'Not Available';

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Station',
      address: json['address'] ?? 'No Address',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 15.5057,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 80.0493,
      status: json['status'] ?? 'unknown',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      availableBatteries: json['available_batteries'] ?? 0,
      totalSlots: json['total_slots'] ?? 0,
      is24x7: json['is_24x7'] ?? false,
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      amenities: json['amenities'] is List
          ? List<String>.from(json['amenities'])
          : (json['amenities'] is String &&
                  (json['amenities'] as String).isNotEmpty)
              ? (json['amenities'] as String)
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .replaceAll('"', '')
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
              : [],
      images: json['images'] != null && json['images'] is List
          ? (json['images'] as List)
              .map((x) => x is String ? x : (x['url']?.toString() ?? ''))
              .where((x) => x.isNotEmpty)
              .toList()
          : (json['images'] is String && (json['images'] as String).isNotEmpty)
              ? (json['images'] as String)
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.startsWith('http'))
                  .toList()
              : [],
      distance: (json['distance'] as num?)?.toDouble(),
      reviews: json['reviews'] != null && json['reviews'] is List
          ? (json['reviews'] as List).map((i) => Review.fromJson(i)).toList()
          : null,
      batteries: json['batteries'] != null && json['batteries'] is List
          ? (json['batteries'] as List).map((i) => Battery.fromJson(i)).toList()
          : null,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 50.0,
      batteryType: json['battery_type'] ?? 'Li-ion',
      batteryCapacity: json['battery_capacity'] ?? 2000,
      chargingSpeed: json['charging_speed'] ?? 'Standard',
      isDealer: json['is_dealer'] ?? false,
      socPercentage: json['soc_percentage'] ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      healthStatus: json['health_status'] ?? 'Healthy',
    );
  }
}
