import 'package:flutter/material.dart';

enum TenantStatus { active, trial, suspended, canceled }
enum SubscriptionPlan { basic, pro, enterprise }

class Tenant {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final SubscriptionPlan plan;
  final TenantStatus status;
  final int usersCount;
  final double mrr;
  final DateTime joinDate;

  Tenant({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.plan,
    required this.status,
    required this.usersCount,
    required this.mrr,
    required this.joinDate,
  });
}

final List<Tenant> mockTenants = [
  Tenant(
    id: "ORG-001",
    name: "Apollo Hospitals",
    contactPerson: "Dr. Prathap",
    email: "admin@apollo.com",
    plan: SubscriptionPlan.enterprise,
    status: TenantStatus.active,
    usersCount: 154,
    mrr: 2500.0,
    joinDate: DateTime(2023, 1, 15),
  ),
  Tenant(
    id: "ORG-002",
    name: "City Pharmacy Chain",
    contactPerson: "Rajesh Kumar",
    email: "rajesh@citymeds.in",
    plan: SubscriptionPlan.pro,
    status: TenantStatus.active,
    usersCount: 12,
    mrr: 450.0,
    joinDate: DateTime(2023, 3, 10),
  ),
  Tenant(
    id: "ORG-003",
    name: "Green Cross Clinic",
    contactPerson: "Sarah Jones",
    email: "sarah@greencross.com",
    plan: SubscriptionPlan.basic,
    status: TenantStatus.trial,
    usersCount: 5,
    mrr: 0.0,
    joinDate: DateTime.now().subtract(const Duration(days: 5)),
  ),
  Tenant(
    id: "ORG-004",
    name: "MediCare Plus",
    contactPerson: "Michael Chen",
    email: "m.chen@medicare.com",
    plan: SubscriptionPlan.enterprise,
    status: TenantStatus.suspended,
    usersCount: 45,
    mrr: 1200.0,
    joinDate: DateTime(2022, 11, 20),
  ),
  Tenant(
    id: "ORG-005",
    name: "Wellness Point",
    contactPerson: "Priya Sharma",
    email: "priya@wellness.com",
    plan: SubscriptionPlan.pro,
    status: TenantStatus.active,
    usersCount: 8,
    mrr: 450.0,
    joinDate: DateTime(2023, 6, 01),
  ),
];
