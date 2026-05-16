import 'package:flutter/material.dart';

class Announcement {
  final String id;
  final String title;
  final String type; // Banner, Modal, Email
  final String status; // Active, Draft, Scheduled
  final int views;
  final int clicks;
  final DateTime date;

  Announcement(this.id, this.title, this.type, this.status, this.views, this.clicks, this.date);
}

class TrainingVideo {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String thumbnailColor; 

  TrainingVideo(this.id, this.title, this.category, this.duration, this.thumbnailColor);
}

final List<Announcement> mockAnnouncements = [
  Announcement("ANC-101", "Black Friday Sale - 50% Off Plans", "Banner", "Active", 1240, 350, DateTime.now()),
  Announcement("ANC-102", "New Feature: AI Forecasting", "Modal", "Scheduled", 0, 0, DateTime.now().add(const Duration(days: 2))),
  Announcement("ANC-103", "System Maintenance Warning", "Email", "Sent", 5000, 4200, DateTime.now().subtract(const Duration(days: 5))),
];

final List<TrainingVideo> mockVideos = [
  TrainingVideo("VID-01", "Getting Started with AuraMed", "Onboarding", "5:20", "FF5722"), 
  TrainingVideo("VID-02", "How to Manage Inventory", "Operations", "12:15", "4CAF50"),
  TrainingVideo("VID-03", "Setting up Tax Rules", "Finance", "8:45", "2196F3"),
  TrainingVideo("VID-04", "Handling Returns & Refunds", "Sales", "6:30", "9C27B0"),
];
