import 'package:flutter/material.dart';

class FeatureFlag {
  final String key;
  final String name;
  final String description;
  bool isEnabled;
  final int rolloutPercentage;

  FeatureFlag({
    required this.key,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.rolloutPercentage,
  });
}

class AuditLog {
  final String id;
  final String adminName;
  final String action; // Create, Update, Delete
  final String target; // "Org: HealthPlus", "User: John"
  final DateTime timestamp;
  final String status;

  AuditLog({
    required this.id,
    required this.adminName,
    required this.action,
    required this.target,
    required this.timestamp,
    required this.status,
  });
}

final List<FeatureFlag> mockFeatureFlags = [
  FeatureFlag(
    key: "new_dashboard_v2", 
    name: "New Dashboard UI", 
    description: "Enable the new React-based dashboard layout.", 
    isEnabled: true, 
    rolloutPercentage: 25
  ),
  FeatureFlag(
    key: "ai_forecasting", 
    name: "AI Inventory Forecasting", 
    description: "Predictive analytics module for enterprise plans.", 
    isEnabled: false, 
    rolloutPercentage: 0
  ),
  FeatureFlag(
    key: "whatsapp_integration", 
    name: "WhatsApp Notifications", 
    description: "Allow sending prescription alerts via WhatsApp.", 
    isEnabled: true, 
    rolloutPercentage: 100
  ),
];

final List<AuditLog> mockAuditLogs = [
  AuditLog(id: "LOG-9921", adminName: "Super Admin", action: "UPDATE_CONFIG", target: "Global Settings", timestamp: DateTime.now().subtract(const Duration(minutes: 5)), status: "Success"),
  AuditLog(id: "LOG-9920", adminName: "Finance Mgr", action: "REFUND_invoice", target: "INV-2024-005", timestamp: DateTime.now().subtract(const Duration(hours: 1)), status: "Success"),
  AuditLog(id: "LOG-9919", adminName: "Support Agent", action: "SUSPEND_ORG", target: "Org: Fraud Pharmacy", timestamp: DateTime.now().subtract(const Duration(hours: 3)), status: "Success"),
  AuditLog(id: "LOG-9918", adminName: "System", action: "AUTO_BACKUP", target: "Database", timestamp: DateTime.now().subtract(const Duration(hours: 12)), status: "Failed"),
  AuditLog(id: "LOG-9917", adminName: "Super Admin", action: "CREATE_PLAN", target: "Plan: Enterprise Plus", timestamp: DateTime.now().subtract(const Duration(days: 1)), status: "Success"),
];
