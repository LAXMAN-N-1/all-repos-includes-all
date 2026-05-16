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
    return SavedPaymentMethod(
      id: json['id']?.toString() ?? '',
      type: json['type'] == 'card'
          ? SavedPaymentMethodType.card
          : SavedPaymentMethodType.upi,
      last4: json['last4'],
      brand: json['brand'],
      upiId: json['upi_id'],
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
