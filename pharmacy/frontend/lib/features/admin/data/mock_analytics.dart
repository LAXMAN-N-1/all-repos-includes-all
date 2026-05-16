import 'package:flutter/material.dart';

class RevenueDataPoint {
  final String month;
  final double revenue;
  final double growth;

  RevenueDataPoint(this.month, this.revenue, this.growth);
}

class ExportJob {
  final String id;
  final String type; // "Invoices", "Users", "Activity"
  final DateTime requestedAt;
  final String status; // "Completed", "Processing"
  final double sizeMB;
  final String downloadUrl;

  ExportJob(this.id, this.type, this.requestedAt, this.status, this.sizeMB, this.downloadUrl);
}

final List<RevenueDataPoint> mockRevenueTrend = [
  RevenueDataPoint("Jan", 45000, 5.0),
  RevenueDataPoint("Feb", 48000, 6.6),
  RevenueDataPoint("Mar", 52000, 8.3),
  RevenueDataPoint("Apr", 51000, -1.9),
  RevenueDataPoint("May", 56000, 9.8),
  RevenueDataPoint("Jun", 62000, 10.7),
];

final List<ExportJob> mockExports = [
  ExportJob("EXP-1001", "All Invoices (Q1 2024)", DateTime.now().subtract(const Duration(hours: 1)), "Completed", 12.5, "https://example.com/d"),
  ExportJob("EXP-1002", "User Activity Logs", DateTime.now().subtract(const Duration(hours: 4)), "Completed", 45.2, "https://example.com/d"),
  ExportJob("EXP-1003", "Full Database Dump", DateTime.now().subtract(const Duration(days: 1)), "Expired", 250.0, ""),
  ExportJob("EXP-1004", "New Tenants List", DateTime.now(), "Processing", 0.0, ""),
  ExportJob("EXP-1004", "New Tenants List", DateTime.now(), "Processing", 0.0, ""),
];

class UsageMetric {
  final String metric;
  final String value;
  final String limit;
  final double percentage;
  final String trend; // +5%
  
  UsageMetric(this.metric, this.value, this.limit, this.percentage, this.trend);
}

final List<UsageMetric> mockUsageStats = [
  UsageMetric("API Calls (Monthly)", "2.4M", "5M", 0.48, "+12%"),
  UsageMetric("Storage Used", "450 GB", "1 TB", 0.45, "+2%"),
  UsageMetric("Active Users", "1,240", "2,000", 0.62, "+5%"),
  UsageMetric("Bandwidth", "1.2 TB", "5 TB", 0.24, "-1%"),
  UsageMetric("Email Sent", "15,000", "50,000", 0.30, "+8%"),
];
