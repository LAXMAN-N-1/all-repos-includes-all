class CashbackOffer {
  final String id;
  final String title;
  final String description;
  final DateTime expiryDate;
  final String category;
  final String terms;

  CashbackOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.expiryDate,
    required this.category,
    required this.terms,
  });

  factory CashbackOffer.fromJson(Map<String, dynamic> json) {
    return CashbackOffer(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      expiryDate:
          DateTime.tryParse(json['expiry_date'] ?? '')?.toLocal() ?? DateTime.now(),
      category: json['category'] ?? 'recharge',
      terms: json['terms'] ?? '',
    );
  }
}

class TransferRequest {
  final String recipientPhone;
  final double amount;
  final String? note;

  TransferRequest({
    required this.recipientPhone,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipient_phone': recipientPhone,
      'amount': amount,
      if (note != null) 'note': note,
    };
  }
}

enum SavedPaymentMethodType { card, upi }

class SavedPaymentMethod {
  final String id;
  final SavedPaymentMethodType type;
  final String? last4;
  final String? brand;
  final String? upiId;
  final bool isDefault;

  SavedPaymentMethod({
    required this.id,
    required this.type,
    this.last4,
    this.brand,
    this.upiId,
    required this.isDefault,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    final details = json['details'] is Map<String, dynamic>
        ? json['details'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final typeRaw = json['type']?.toString() ?? 'upi';
    return SavedPaymentMethod(
      id: json['id']?.toString() ?? '',
      type: typeRaw == 'card'
          ? SavedPaymentMethodType.card
          : SavedPaymentMethodType.upi,
      last4: json['last4']?.toString() ?? details['last4']?.toString(),
      brand: json['brand']?.toString() ?? details['brand']?.toString(),
      upiId: json['upi_id']?.toString() ?? details['upi_id']?.toString(),
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'last4': last4,
      'brand': brand,
      'upi_id': upiId,
      'is_default': isDefault,
    };
  }
}
