import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DashboardAnalyticsData extends Equatable {
  final List<PieChartDataPoint> batteryStatusDistribution;
  final List<TimePoint> dailyDispatchTrend;
  final List<TimePoint> inventoryLevelTrend;

  final List<CategoryValue> stationDispatchDistribution;
  final List<PieChartDataPoint> batteryHealthDistribution;
  final List<CategoryValue> cycleCountDistribution;

  const DashboardAnalyticsData({
    required this.batteryStatusDistribution,
    required this.dailyDispatchTrend,
    required this.inventoryLevelTrend,
    required this.stationDispatchDistribution,
    required this.batteryHealthDistribution,
    required this.cycleCountDistribution,
  });

  factory DashboardAnalyticsData.empty() {
    return const DashboardAnalyticsData(
      batteryStatusDistribution: [],
      dailyDispatchTrend: [],
      inventoryLevelTrend: [],
      stationDispatchDistribution: [],
      batteryHealthDistribution: [],
      cycleCountDistribution: [],
    );
  }

  factory DashboardAnalyticsData.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsData(
      batteryStatusDistribution:
          (json['battery_status_distribution'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => PieChartDataPoint.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList() ??
          [],
      dailyDispatchTrend:
          (json['daily_dispatch_trend'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => TimePoint.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList() ??
          [],
      inventoryLevelTrend:
          (json['inventory_level_trend'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => TimePoint.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList() ??
          [],
      stationDispatchDistribution:
          (json['station_dispatch_distribution'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => CategoryValue.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList() ??
          [],
      batteryHealthDistribution:
          (json['battery_health_distribution'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => PieChartDataPoint.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList() ??
          [],
      cycleCountDistribution:
          (json['cycle_count_distribution'] as List?)
              ?.whereType<Map>()
              .map(
                (e) => CategoryValue.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ),
              )
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    batteryStatusDistribution,
    dailyDispatchTrend,
    inventoryLevelTrend,
    stationDispatchDistribution,
    batteryHealthDistribution,
    cycleCountDistribution,
  ];
}

class PieChartDataPoint extends Equatable {
  final String label;
  final double value;
  final Color color;

  const PieChartDataPoint({
    required this.label,
    required this.value,
    required this.color,
  });

  factory PieChartDataPoint.fromJson(Map<String, dynamic> json) {
    return PieChartDataPoint(
      label: json['label'] as String,
      value: (json['value'] as num).toDouble(),
      // Expecting hex string for color from API, e.g. "#FF0000" or int value
      // Simple fallback for now or parsing from hex string
      color: _parseColor(json['color']),
    );
  }

  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) return Color(colorValue);
    if (colorValue is String) {
      final hexCode = colorValue.replaceAll('#', '').trim();
      if (hexCode.isEmpty) return Colors.grey;
      try {
        if (hexCode.length == 8) {
          return Color(int.parse(hexCode, radix: 16));
        }
        return Color(int.parse('FF$hexCode', radix: 16));
      } catch (_) {
        return Colors.grey;
      }
    }
    return Colors.grey;
  }

  @override
  List<Object?> get props => [label, value, color];
}

class TimePoint extends Equatable {
  final DateTime date;
  final double value;

  const TimePoint({required this.date, required this.value});

  factory TimePoint.fromJson(Map<String, dynamic> json) {
    return TimePoint(
      date: DateTime.parse(json['date'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, value];
}

class CategoryValue extends Equatable {
  final String category;
  final double value;

  const CategoryValue({required this.category, required this.value});

  factory CategoryValue.fromJson(Map<String, dynamic> json) {
    return CategoryValue(
      category: json['category'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [category, value];
}
