import 'package:flutter/material.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime lastLogin;
  final String avatarUrl;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastLogin,
    this.avatarUrl = "",
  });
}

class Role {
  final String id;
  final String name;
  final String description;
  final int usersCount;
  final List<String> permissions;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.usersCount,
    required this.permissions,
  });
}

final List<AdminUser> mockAdmins = [
  AdminUser(
    id: "ADM-001",
    name: "Murari Super",
    email: "murari@auramed.com",
    role: "Super Admin",
    status: "Active",
    lastLogin: DateTime.now(),
  ),
  AdminUser(
    id: "ADM-002",
    name: "Sarah Finance",
    email: "sarah.f@auramed.com",
    role: "Finance Manager",
    status: "Active",
    lastLogin: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  AdminUser(
    id: "ADM-003",
    name: "Mike Support",
    email: "mike.s@auramed.com",
    role: "Support Lead",
    status: "Active",
    lastLogin: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AdminUser(
    id: "ADM-004",
    name: "Dev Team",
    email: "devops@auramed.com",
    role: "Technical Admin",
    status: "Inactive",
    lastLogin: DateTime.now().subtract(const Duration(days: 20)),
  ),
];

final List<Role> mockRoles = [
  Role(
    id: "ROLE-001", 
    name: "Super Admin", 
    description: "Full access to all modules and system settings.", 
    usersCount: 1, 
    permissions: ["All Access"]
  ),
  Role(
    id: "ROLE-002", 
    name: "Finance Manager", 
    description: "Access to Billing, Invoices, and Revenue Reports.", 
    usersCount: 3, 
    permissions: ["View Billing", "Manage Plans", "Refund Invoices", "View Revenue"]
  ),
  Role(
    id: "ROLE-003", 
    name: "Support Lead", 
    description: "Manage tickets, knowledge base, and user inquiries.", 
    usersCount: 12, 
    permissions: ["View Tickets", "Reply Tickets", "Manage KB", "View Users"]
  ),
  Role(
    id: "ROLE-004", 
    name: "Viewer", 
    description: "Read-only access to dashboards and reports.", 
    usersCount: 5, 
    permissions: ["View Dashboard", "View Reports"]
  ),
];
