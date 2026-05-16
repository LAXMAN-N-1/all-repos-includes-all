import 'package:flutter/material.dart';

enum TicketStatus { open, pending, resolved, closed }
enum TicketPriority { low, medium, high, urgent }

class SupportTicket {
  final String id;
  final String subject;
  final String orgName;
  final String category; // Technical, Billing, etc.
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime created;
  final String lastMessage;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.orgName,
    required this.category,
    required this.status,
    required this.priority,
    required this.created,
    required this.lastMessage,
  });
}

final List<SupportTicket> mockTickets = [
  SupportTicket(
    id: "TKT-9001",
    subject: "Payment API Failure",
    orgName: "Apollo Hospitals",
    category: "Technical",
    status: TicketStatus.open,
    priority: TicketPriority.high,
    created: DateTime.now().subtract(const Duration(hours: 2)),
    lastMessage: "We are getting 502 Bad Gateway on /payment endpoint.",
  ),
  SupportTicket(
    id: "TKT-9002",
    subject: "Invoice Discrepancy",
    orgName: "City Pharmacy",
    category: "Billing",
    status: TicketStatus.pending,
    priority: TicketPriority.medium,
    created: DateTime.now().subtract(const Duration(days: 1)),
    lastMessage: "The tax calculation seems off for item #3.",
  ),
  SupportTicket(
    id: "TKT-9003",
    subject: "Feature Request: Dark Mode Report",
    orgName: "Wellness Point",
    category: "Feature Request",
    status: TicketStatus.open,
    priority: TicketPriority.low,
    created: DateTime.now().subtract(const Duration(days: 2)),
    lastMessage: "Can we export reports in dark mode PDF?",
  ),
  SupportTicket(
    id: "TKT-8999",
    subject: "Account Locked",
    orgName: "Green Cross Clinic",
    category: "Account",
    status: TicketStatus.resolved,
    priority: TicketPriority.urgent,
    created: DateTime.now().subtract(const Duration(days: 5)),
    lastMessage: "Unlock processed. Please try again.",
  ),
];

class KnowledgeArticle {
  final String title;
  final String category;
  final int views;
  final String lastUpdated;

  KnowledgeArticle(this.title, this.category, this.views, this.lastUpdated);
}

final List<KnowledgeArticle> mockKBArticles = [
  KnowledgeArticle("Getting Started with Billing", "Billing", 1240, "2 days ago"),
  KnowledgeArticle("API Integration Guide", "Technical", 890, "1 week ago"),
  KnowledgeArticle("User Roles Explained", "Admin", 2100, "1 month ago"),
  KnowledgeArticle("Troubleshooting Login Issues", "Support", 560, "3 days ago"),
  KnowledgeArticle("Setting up Inventory Min/Max", "Inventory", 1450, "4 days ago"),
];

class ChatSession {
  final String orgName;
  final String user;
  final String lastMessage;
  final String time;
  final int unread;

  ChatSession(this.orgName, this.user, this.lastMessage, this.time, this.unread);
}

final List<ChatSession> mockChatSessions = [
  ChatSession("Apollo Hospitals", "Dr. Rajesh", "Is the system down?", "2m ago", 2),
  ChatSession("City Pharmacy", "Sarah L.", "Thanks for the help!", "1h ago", 0),
  ChatSession("Wellness Point", "John Doe", "I need an invoice copy.", "3h ago", 1),
];
