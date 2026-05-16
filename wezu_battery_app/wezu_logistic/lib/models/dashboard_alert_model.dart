import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';

enum AlertSeverity {
  critical,
  warning,
  info;

  Color get color {
    switch (this) {
      case AlertSeverity.critical:
        return AppColors.error;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertSeverity.critical:
        return AppColors.errorLight;
      case AlertSeverity.warning:
        return AppColors.warningLight;
      case AlertSeverity.info:
        return AppColors.infoLight;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertSeverity.critical:
        return Icons.report_problem_rounded;
      case AlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case AlertSeverity.info:
        return Icons.info_outline_rounded;
    }
  }
}

enum AlertType { lowStock, pendingTask, announcement, other }

class DashboardAlert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertType type;
  final DateTime timestamp;
  final String? actionLabel;
  final String? actionData; // Could be a route or URL
  final String? appScope;

  const DashboardAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.type,
    required this.timestamp,
    this.actionLabel,
    this.actionData,
    this.appScope,
  });

  factory DashboardAlert.fromJson(Map<String, dynamic> json) {
    final rawSeverity = (json['severity'] ?? json['type'] ?? 'info').toString();
    final rawType = (json['notification_type'] ?? json['type'] ?? 'other')
        .toString();
    final rawTimestamp = json['timestamp'] ?? json['created_at'];

    DateTime parsedTimestamp;
    if (rawTimestamp is String) {
      parsedTimestamp = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else {
      parsedTimestamp = DateTime.now();
    }

    return DashboardAlert(
      id: json['id']?.toString() ?? '',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Notification',
      message: (json['message'] as String?)?.trim() ?? '',
      severity: _parseSeverity(rawSeverity),
      type: _parseType(rawType),
      timestamp: parsedTimestamp,
      actionLabel: json['action_label'] as String?,
      actionData: json['action_data'] as String?,
      appScope: json['app_scope']?.toString(),
    );
  }

  static AlertSeverity _parseSeverity(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AlertSeverity.info,
    );
  }

  static AlertType _parseType(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('stock')) return AlertType.lowStock;
    if (normalized.contains('pending')) return AlertType.pendingTask;
    if (normalized.contains('announce')) return AlertType.announcement;
    return AlertType.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => AlertType.other,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    severity,
    type,
    timestamp,
    actionLabel,
    actionData,
    appScope,
  ];
}
