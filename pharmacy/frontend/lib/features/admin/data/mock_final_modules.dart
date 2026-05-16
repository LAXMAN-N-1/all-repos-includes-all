import 'package:flutter/material.dart';

class SandboxEvent {
  final String id;
  final String action;
  final String status;
  final String timestamp;

  SandboxEvent(this.id, this.action, this.status, this.timestamp);
}

class AppVersion {
  final String version;
  final String platform;
  final String releaseDate;
  final bool isMandatory;
  final double adoptionRate;

  AppVersion(this.version, this.platform, this.releaseDate, this.isMandatory, this.adoptionRate);
}

class NotificationLog {
  final String title;
  final String message;
  final String type; // Alert, Info, Success
  final String time;
  final bool isRead;

  NotificationLog(this.title, this.message, this.type, this.time, this.isRead);
}

final List<SandboxEvent> mockSandboxEvents = [
  SandboxEvent("EVT-001", "Simulate Payment Failure", "Success", "2 mins ago"),
  SandboxEvent("EVT-002", "Trigger Webhook: Order Created", "Success", "15 mins ago"),
  SandboxEvent("EVT-003", "Reset Test Org Data", "Processing", "Just now"),
];

final List<AppVersion> mockAppVersions = [
  AppVersion("2.1.0", "Android", "Mar 15, 2024", true, 85.5),
  AppVersion("2.1.0", "iOS", "Mar 16, 2024", true, 78.2),
  AppVersion("2.2.0-beta", "Android", "Mar 20, 2024", false, 5.0),
];

final List<NotificationLog> mockNotifications = [
  NotificationLog("High CPU Usage", "Server SRV-02 is running at 98% load.", "Alert", "10 mins ago", false),
  NotificationLog("New Tenant Signup", "MediCare Plus joined the Pro Plan.", "Success", "2 hours ago", false),
  NotificationLog("Backup Completed", "Daily snapshot finished successfully.", "Info", "4 hours ago", true),
  NotificationLog("Failed Payment", "Invoice #9921 payment failed.", "Alert", "Yesterday", true),
];
