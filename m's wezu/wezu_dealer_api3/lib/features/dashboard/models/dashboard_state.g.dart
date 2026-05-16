// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardMetrics _$DashboardMetricsFromJson(Map<String, dynamic> json) =>
    _DashboardMetrics(
      totalBatteries: (json['totalBatteries'] as num?)?.toInt() ?? 0,
      totalDamaged: (json['totalDamaged'] as num?)?.toInt() ?? 0,
      activeRentals: (json['activeRentals'] as num?)?.toInt() ?? 0,
      revenueThisMonth: (json['revenueThisMonth'] as num?)?.toDouble() ?? 0.0,
      totalStations: (json['totalStations'] as num?)?.toInt() ?? 0,
      activeStations: (json['activeStations'] as num?)?.toInt() ?? 0,
      openTickets: (json['openTickets'] as num?)?.toInt() ?? 0,
      customerSatisfaction:
          (json['customerSatisfaction'] as num?)?.toDouble() ?? 0.0,
      totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
      batteryUsageStats: json['batteryUsageStats'] as String?,
      inventorySummary: (json['inventorySummary'] as List<dynamic>?)
              ?.map((e) => InventorySummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      weeklyRevenue: (json['weeklyRevenue'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
      weeklyDays: (json['weeklyDays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DashboardMetricsToJson(_DashboardMetrics instance) =>
    <String, dynamic>{
      'totalBatteries': instance.totalBatteries,
      'totalDamaged': instance.totalDamaged,
      'activeRentals': instance.activeRentals,
      'revenueThisMonth': instance.revenueThisMonth,
      'totalStations': instance.totalStations,
      'activeStations': instance.activeStations,
      'openTickets': instance.openTickets,
      'customerSatisfaction': instance.customerSatisfaction,
      'totalSales': instance.totalSales,
      'batteryUsageStats': instance.batteryUsageStats,
      'inventorySummary': instance.inventorySummary,
      'weeklyRevenue': instance.weeklyRevenue,
      'weeklyDays': instance.weeklyDays,
    };

_InventorySummary _$InventorySummaryFromJson(Map<String, dynamic> json) =>
    _InventorySummary(
      batteryModel: json['batteryModel'] as String,
      available: (json['available'] as num).toInt(),
      reserved: (json['reserved'] as num).toInt(),
      damaged: (json['damaged'] as num).toInt(),
    );

Map<String, dynamic> _$InventorySummaryToJson(_InventorySummary instance) =>
    <String, dynamic>{
      'batteryModel': instance.batteryModel,
      'available': instance.available,
      'reserved': instance.reserved,
      'damaged': instance.damaged,
    };

_DashboardAlert _$DashboardAlertFromJson(Map<String, dynamic> json) =>
    _DashboardAlert(
      type: json['type'] as String,
      severity: json['severity'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$DashboardAlertToJson(_DashboardAlert instance) =>
    <String, dynamic>{
      'type': instance.type,
      'severity': instance.severity,
      'title': instance.title,
      'message': instance.message,
      'data': instance.data,
    };

_DashboardActivity _$DashboardActivityFromJson(Map<String, dynamic> json) =>
    _DashboardActivity(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$DashboardActivityToJson(_DashboardActivity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
    };
