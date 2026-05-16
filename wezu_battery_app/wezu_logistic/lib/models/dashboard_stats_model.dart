import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Dashboard overview metrics.
class DashboardStats extends Equatable {
  final int availableBatteries;
  final int inTransitBatteries;
  final int pendingOrders;
  final int issueCount;
  final int totalBatteries;
  final int sentToday;
  final double sentTrend; // percentage (e.g. 12.5 for +12.5%)
  final int receivedToday;
  final int pendingReceipts;
  final double revenue;
  final int monthlyDispatch;

  const DashboardStats({
    required this.availableBatteries,
    required this.inTransitBatteries,
    required this.pendingOrders,
    required this.issueCount,
    this.totalBatteries = 0,
    this.sentToday = 0,
    this.sentTrend = 0.0,
    this.receivedToday = 0,
    this.pendingReceipts = 0,
    this.revenue = 0.0,
    this.monthlyDispatch = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      availableBatteries: _toInt(json['available_batteries']),
      inTransitBatteries: _toInt(json['deployed_batteries']) > 0
          ? _toInt(json['deployed_batteries'])
          : _toInt(json['in_transit_batteries']),
      pendingOrders: _toInt(json['pending_orders']),
      issueCount: _toInt(json['issue_count']),
      totalBatteries: _toInt(json['total_batteries']),
      sentToday: _toInt(json['sent_today']),
      sentTrend: _toDouble(json['sent_trend']),
      receivedToday: _toInt(json['received_today']),
      pendingReceipts: _toInt(json['pending_receipts']),
      revenue: _toDouble(json['revenue']),
      monthlyDispatch: _toInt(json['monthly_dispatch']),
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsedInt = int.tryParse(value.trim());
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value.trim());
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return fallback;
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  /// Empty stats for initial/loading state.
  factory DashboardStats.empty() => const DashboardStats(
    availableBatteries: 0,
    inTransitBatteries: 0,
    pendingOrders: 0,
    issueCount: 0,
  );

  @override
  List<Object?> get props => [
    availableBatteries,
    inTransitBatteries,
    pendingOrders,
    issueCount,
    totalBatteries,
    sentToday,
    sentTrend,
    receivedToday,
    pendingReceipts,
    revenue,
    monthlyDispatch,
  ];
}

/// Type of activity event on the dashboard.
enum ActivityType {
  batteryReceived,
  batterySwapped,
  orderDelivered,
  shipmentInTransit,
  inventoryAudit,
  batteryFault,
  orderCreated,
  lowInventory;

  IconData get icon {
    switch (this) {
      case ActivityType.batteryReceived:
        return Icons.add_circle_outline;
      case ActivityType.batterySwapped:
        return Icons.swap_horiz_rounded;
      case ActivityType.orderDelivered:
        return Icons.check_circle_outline;
      case ActivityType.shipmentInTransit:
        return Icons.local_shipping_outlined;
      case ActivityType.inventoryAudit:
        return Icons.inventory_2_outlined;
      case ActivityType.batteryFault:
        return Icons.warning_amber_rounded;
      case ActivityType.orderCreated:
        return Icons.receipt_long_outlined;
      case ActivityType.lowInventory:
        return Icons.production_quantity_limits_rounded;
    }
  }

  static ActivityType fromString(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    return ActivityType.values.firstWhere(
      (e) =>
          e.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ==
          normalized,
      orElse: () => ActivityType.inventoryAudit,
    );
  }
}

/// A single recent activity item on the dashboard.
class ActivityItem extends Equatable {
  final String id;
  final String title;
  final ActivityType type;
  final DateTime timestamp;
  final String? referenceId;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.type,
    required this.timestamp,
    this.referenceId,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Activity',
      type: ActivityType.fromString(json['type']?.toString() ?? ''),
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      referenceId: json['reference_id']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, title, type, timestamp];
}
