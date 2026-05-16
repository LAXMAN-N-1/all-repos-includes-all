import 'package:flutter/material.dart';

class BackupEntry {
  final String id;
  final DateTime timestamp;
  final String type; // Full, Incremental
  final String size;
  final String status; // Success, Failed

  BackupEntry(this.id, this.timestamp, this.type, this.size, this.status);
}

class IntegrationService {
  final String id;
  final String name;
  final String category; // Payment, SMS, Email, CRM
  final String logoSymbol; // Just first letter for mock
  final bool isConnected;

  IntegrationService(this.id, this.name, this.category, this.logoSymbol, this.isConnected);
}

final List<BackupEntry> mockBackups = [
  BackupEntry("BKP-2024-03-15", DateTime.now().subtract(const Duration(hours: 2)), "Incremental", "450 MB", "Success"),
  BackupEntry("BKP-2024-03-14", DateTime.now().subtract(const Duration(days: 1)), "Incremental", "430 MB", "Success"),
  BackupEntry("BKP-2024-03-13", DateTime.now().subtract(const Duration(days: 2)), "Full Backup", "2.1 GB", "Success"),
  BackupEntry("BKP-2024-03-12", DateTime.now().subtract(const Duration(days: 3)), "Incremental", "420 MB", "Failed"),
];

final List<IntegrationService> mockIntegrations = [
  IntegrationService("INT-01", "Stripe", "Payment", "S", true),
  IntegrationService("INT-02", "Razorpay", "Payment", "R", false),
  IntegrationService("INT-03", "Twilio", "SMS", "T", true),
  IntegrationService("INT-04", "SendGrid", "Email", "S", true),
  IntegrationService("INT-05", "Slack", "Communication", "S", false),
  IntegrationService("INT-06", "AWS S3", "Storage", "A", true),
  IntegrationService("INT-07", "Google Analytics", "Analytics", "G", false),
  IntegrationService("INT-08", "Salesforce", "CRM", "S", false),
];
