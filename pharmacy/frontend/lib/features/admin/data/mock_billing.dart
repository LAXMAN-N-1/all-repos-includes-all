import 'package:flutter/material.dart';

enum PlanTier { basic, professional, enterprise }

class PricingPlan {
  final String id;
  final String name;
  final double price;
  final PlanTier tier;
  final List<String> features;
  final int maxUsers;
  final int maxStores;

  PricingPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.tier,
    required this.features,
    required this.maxUsers,
    required this.maxStores,
  });
}

class Invoice {
  final String id;
  final String orgName;
  final double amount;
  final DateTime date;
  final String status; // Paid, Pending, Failed

  Invoice({
    required this.id,
    required this.orgName,
    required this.amount,
    required this.date,
    required this.status,
  });
}

final List<PricingPlan> mockPlans = [
  PricingPlan(
    id: "PLAN-001",
    name: "Basic Starter",
    price: 49.00,
    tier: PlanTier.basic,
    features: ["Single Store", "Basic Inventory", "5 Users", "Email Support"],
    maxUsers: 5,
    maxStores: 1,
  ),
  PricingPlan(
    id: "PLAN-002",
    name: "Professional",
    price: 199.00,
    tier: PlanTier.professional,
    features: ["Up to 5 Stores", "Advanced Analytics", "20 Users", "Priority Support", "API Access"],
    maxUsers: 20,
    maxStores: 5,
  ),
  PricingPlan(
    id: "PLAN-003",
    name: "Enterprise",
    price: 499.00,
    tier: PlanTier.enterprise,
    features: ["Unlimited Stores", "AI Forecasting", "Unlimited Users", "Dedicated Account Manager", "White-labeling"],
    maxUsers: 9999,
    maxStores: 9999,
  ),
];

final List<Invoice> mockInvoices = [
  Invoice(id: "INV-2024-001", orgName: "Apollo Hospitals", amount: 499.00, date: DateTime.now().subtract(const Duration(days: 2)), status: "Paid"),
  Invoice(id: "INV-2024-002", orgName: "City Pharmacy", amount: 199.00, date: DateTime.now().subtract(const Duration(days: 5)), status: "Paid"),
  Invoice(id: "INV-2024-003", orgName: "Wellness Point", amount: 199.00, date: DateTime.now().subtract(const Duration(days: 12)), status: "Paid"),
  Invoice(id: "INV-2024-004", orgName: "Green Cross Clinic", amount: 49.00, date: DateTime.now().subtract(const Duration(days: 15)), status: "Failed"),
  Invoice(id: "INV-2024-005", orgName: "MediCare Plus", amount: 499.00, date: DateTime.now().subtract(const Duration(days: 20)), status: "Refunded"),
];

class Subscription {
  final String id;
  final String orgName;
  final String planName;
  final double price;
  final String status; // Active, Canceled, Past Due
  final DateTime nextBillingDate;
  final int usersUsed;
  final int usersLimit;

  Subscription({
    required this.id,
    required this.orgName,
    required this.planName,
    required this.price,
    required this.status,
    required this.nextBillingDate,
    required this.usersUsed,
    required this.usersLimit,
  });
}

final List<Subscription> mockSubscriptions = [
  Subscription(id: "SUB-8821", orgName: "Apollo Hospitals", planName: "Enterprise", price: 499.00, status: "Active", nextBillingDate: DateTime.now().add(const Duration(days: 12)), usersUsed: 45, usersLimit: 9999),
  Subscription(id: "SUB-9932", orgName: "City Pharmacy", planName: "Professional", price: 199.00, status: "Active", nextBillingDate: DateTime.now().add(const Duration(days: 5)), usersUsed: 12, usersLimit: 20),
  Subscription(id: "SUB-1234", orgName: "Wellness Point", planName: "Professional", price: 199.00, status: "Past Due", nextBillingDate: DateTime.now().subtract(const Duration(days: 2)), usersUsed: 18, usersLimit: 20),
  Subscription(id: "SUB-5521", orgName: "Green Cross Clinic", planName: "Basic Starter", price: 49.00, status: "Canceled", nextBillingDate: DateTime.now().add(const Duration(days: 28)), usersUsed: 3, usersLimit: 5),
  Subscription(id: "SUB-7743", orgName: "MediCare Plus", planName: "Enterprise", price: 499.00, status: "Active", nextBillingDate: DateTime.now().add(const Duration(days: 15)), usersUsed: 82, usersLimit: 9999),
];

class RevenueDataPoint {
  final String month;
  final double revenue;
  final double expenses;

  RevenueDataPoint(this.month, this.revenue, this.expenses);
}

final List<RevenueDataPoint> mockRevenueChart = [
  RevenueDataPoint("Jan", 45000, 12000),
  RevenueDataPoint("Feb", 49000, 13500),
  RevenueDataPoint("Mar", 52000, 14000),
  RevenueDataPoint("Apr", 48000, 15000),
  RevenueDataPoint("May", 58000, 18000),
  RevenueDataPoint("Jun", 64000, 21000),
];
