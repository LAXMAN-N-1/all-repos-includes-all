import 'package:equatable/equatable.dart';

class RoutePoint extends Equatable {
  final double lat;
  final double lng;
  final DateTime timestamp;

  const RoutePoint({required this.lat, required this.lng, required this.timestamp});

  @override
  List<Object?> get props => [lat, lng, timestamp];
}

class DeliveryShift extends Equatable {
  final String id;
  final String driverId;
  final DateTime startTime;
  final DateTime? endTime;
  final List<String> assignedOrderIds;
  final List<RoutePoint> routeHistory;

  const DeliveryShift({
    required this.id,
    required this.driverId,
    required this.startTime,
    this.endTime,
    this.assignedOrderIds = const [],
    this.routeHistory = const [],
  });

  bool get isActive => endTime == null;

  @override
  List<Object?> get props => [id, driverId, startTime, endTime, assignedOrderIds];
}
