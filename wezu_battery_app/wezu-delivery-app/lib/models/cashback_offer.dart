import 'package:flutter/material.dart';

enum OfferCategory { recharge, rental }

extension OfferCategoryX on OfferCategory {
  Color get cardColor {
    switch (this) {
      case OfferCategory.recharge:
        return const Color(0xFF1B5E20); // deep green
      case OfferCategory.rental:
        return const Color(0xFF0D47A1); // deep blue
    }
  }

  Color get accentColor {
    switch (this) {
      case OfferCategory.recharge:
        return const Color(0xFF66BB6A);
      case OfferCategory.rental:
        return const Color(0xFF42A5F5);
    }
  }

  String get label {
    switch (this) {
      case OfferCategory.recharge:
        return 'Recharge Offer';
      case OfferCategory.rental:
        return 'Rental Offer';
    }
  }
}

class CashbackOffer {
  final String id;
  final String title;
  final String description;
  final String terms;
  final DateTime expiryDate;
  final OfferCategory category;

  const CashbackOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.terms,
    required this.expiryDate,
    required this.category,
  });

  factory CashbackOffer.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] as String? ?? '').toLowerCase();
    return CashbackOffer(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      terms: json['terms'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      category: catStr == 'rental'
          ? OfferCategory.rental
          : OfferCategory.recharge,
    );
  }
}
