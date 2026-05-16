import 'package:flutter/material.dart';

class ServerNode {
  final String id;
  final String name;
  final String region;
  final String status; // Online, Offline, Warning
  final double cpuUsage;
  final double memoryUsage;
  final int uptimeDays;

  ServerNode({
    required this.id,
    required this.name,
    required this.region,
    required this.status,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.uptimeDays,
  });
}

class SystemError {
  final String id;
  final String timestamp;
  final String level; // Critical, Error, Warning
  final String message;
  final String source;

  SystemError({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    required this.source,
  });
}

final List<ServerNode> mockServers = [
  ServerNode(id: "SRV-01", name: "Core API Server", region: "AWS ap-south-1", status: "Online", cpuUsage: 45.2, memoryUsage: 60.5, uptimeDays: 14),
  ServerNode(id: "SRV-02", name: "Worker Node 1", region: "AWS ap-south-1", status: "Online", cpuUsage: 78.1, memoryUsage: 82.0, uptimeDays: 14),
  ServerNode(id: "SRV-03", name: "Database Primary", region: "AWS ap-south-1", status: "Online", cpuUsage: 22.0, memoryUsage: 45.0, uptimeDays: 45),
  ServerNode(id: "SRV-04", name: "Redis Cache", region: "AWS ap-south-1", status: "Warning", cpuUsage: 12.0, memoryUsage: 91.5, uptimeDays: 45),
  ServerNode(id: "SRV-05", name: "Legacy Sync", region: "AWS ap-south-1", status: "Offline", cpuUsage: 0.0, memoryUsage: 0.0, uptimeDays: 0),
];

final List<SystemError> mockErrors = [
  SystemError(id: "ERR-5921", timestamp: "Today, 10:23 AM", level: "Critical", message: "Database connection pool exhausted", source: "app-backend"),
  SystemError(id: "ERR-5920", timestamp: "Today, 10:15 AM", level: "Error", message: "Payment gateway timeout (Stripe)", source: "billing-service"),
  SystemError(id: "ERR-5919", timestamp: "Today, 09:45 AM", level: "Warning", message: "High memory usage detected > 90%", source: "cache-redis"),
  SystemError(id: "ERR-5918", timestamp: "Yesterday, 11:30 PM", level: "Error", message: "Failed to generate invoice PDF", source: "pdf-worker"),
  SystemError(id: "ERR-5917", timestamp: "Yesterday, 10:12 PM", level: "Warning", message: "Slow query detected (2.4s)", source: "db-report"),
];

class DatabaseMetric {
  final String name;
  final String status; // Healthy, Degraded
  final int connections;
  final int activeQueries;
  final double cacheHitRatio;
  final double diskUsage; // GB
  final double diskLimit; // GB

  DatabaseMetric(this.name, this.status, this.connections, this.activeQueries, this.cacheHitRatio, this.diskUsage, this.diskLimit);
}

final List<DatabaseMetric> mockDBMetrics = [
  DatabaseMetric("Primary (Write)", "Healthy", 245, 12, 98.5, 450, 1000),
  DatabaseMetric("Replica 1 (Read)", "Healthy", 890, 45, 99.1, 450, 1000),
  DatabaseMetric("Replica 2 (Read)", "Degraded", 120, 8, 85.0, 448, 1000),
  DatabaseMetric("Analytics DB (OLAP)", "Healthy", 15, 3, 92.4, 1200, 5000),
];
