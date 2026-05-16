import 'package:equatable/equatable.dart';

class GeoPoint extends Equatable {
  final double lat;
  final double lng;

  const GeoPoint({required this.lat, required this.lng});

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  List<Object?> get props => [lat, lng];
}

class OptimizedWaypoint extends Equatable {
  final int sequenceIndex;
  final String orderId;
  final GeoPoint location;
  final DateTime? estimatedArrival;
  final String? address;

  const OptimizedWaypoint({
    required this.sequenceIndex,
    required this.orderId,
    required this.location,
    this.estimatedArrival,
    this.address,
  });

  factory OptimizedWaypoint.fromJson(Map<String, dynamic> json) {
    return OptimizedWaypoint(
      sequenceIndex: json['sequence_index'] as int,
      orderId: json['order_id'] as String,
      location: GeoPoint.fromJson(json['location']),
      estimatedArrival: json['estimated_arrival'] != null
          ? DateTime.parse(json['estimated_arrival'])
          : null,
      address: json['address'] as String?,
    );
  }

  @override
  List<Object?> get props => [sequenceIndex, orderId, location, estimatedArrival, address];
}

class DeliveryRouteModel extends Equatable {
  final String? routeId;
  final List<OptimizedWaypoint> waypoints;
  final String overviewPolyline;
  final int totalDistanceMeters;
  final int totalDurationSeconds;
  final String trafficCongestionLevel;

  const DeliveryRouteModel({
    this.routeId,
    required this.waypoints,
    required this.overviewPolyline,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    this.trafficCongestionLevel = 'low',
  });

  factory DeliveryRouteModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRouteModel(
      routeId: json['route_id']?.toString(),
      waypoints: (json['optimized_waypoints'] as List)
          .map((e) => OptimizedWaypoint.fromJson(e))
          .toList(),
      overviewPolyline: json['overview_polyline'] as String,
      totalDistanceMeters: json['total_distance_meters'] as int,
      totalDurationSeconds: json['total_duration_seconds'] as int,
      trafficCongestionLevel: json['traffic_congestion_level'] as String? ?? 'low',
    );
  }

  @override
  List<Object?> get props => [routeId, waypoints, overviewPolyline, totalDistanceMeters, totalDurationSeconds];
}
