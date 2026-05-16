/// Represents a saved payment method — either a card or a UPI ID.
library;

enum PaymentMethodType { card, upi }

/// Known card brands used to pick icons in the UI.
enum CardBrand { visa, mastercard, rupay, amex, diners, unknown }

CardBrand _cardBrandFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'visa':
      return CardBrand.visa;
    case 'mastercard':
      return CardBrand.mastercard;
    case 'rupay':
      return CardBrand.rupay;
    case 'amex':
    case 'american express':
      return CardBrand.amex;
    case 'diners':
      return CardBrand.diners;
    default:
      return CardBrand.unknown;
  }
}

class PaymentMethod {
  final String id;
  final PaymentMethodType type;

  // Card fields
  final String? last4;
  final CardBrand? brand;
  final String? expiryMonth; // '08'
  final String? expiryYear; // '2027'

  // UPI fields
  final String? upiId;

  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.isDefault,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.upiId,
  });

  /// Human-readable primary label shown in the list.
  String get displayName {
    if (type == PaymentMethodType.upi) return upiId ?? 'UPI';
    final brandLabel = brand != null && brand != CardBrand.unknown
        ? _brandLabel(brand!)
        : 'Card';
    return '$brandLabel •••• ${last4 ?? ''}';
  }

  String get expiryLabel {
    if (expiryMonth == null || expiryYear == null) return '';
    return 'Expires $expiryMonth/${expiryYear!.substring(2)}';
  }

  /// Returns a copy with [isDefault] overridden.
  PaymentMethod copyWith({bool? isDefault}) {
    return PaymentMethod(
      id: id,
      type: type,
      isDefault: isDefault ?? this.isDefault,
      last4: last4,
      brand: brand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      upiId: upiId,
    );
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'card';
    final type = typeStr == 'upi'
        ? PaymentMethodType.upi
        : PaymentMethodType.card;
    return PaymentMethod(
      id: json['id'] as String,
      type: type,
      isDefault: (json['is_default'] as bool?) ?? false,
      last4: json['last4'] as String?,
      brand: _cardBrandFromString(json['brand'] as String?),
      expiryMonth: json['expiry_month'] as String?,
      expiryYear: json['expiry_year'] as String?,
      upiId: json['upi_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type == PaymentMethodType.upi ? 'upi' : 'card',
      'is_default': isDefault,
      if (last4 != null) 'last4': last4,
      if (brand != null) 'brand': brand!.name,
      if (expiryMonth != null) 'expiry_month': expiryMonth,
      if (expiryYear != null) 'expiry_year': expiryYear,
      if (upiId != null) 'upi_id': upiId,
    };
  }
}

String _brandLabel(CardBrand brand) {
  switch (brand) {
    case CardBrand.visa:
      return 'Visa';
    case CardBrand.mastercard:
      return 'Mastercard';
    case CardBrand.rupay:
      return 'RuPay';
    case CardBrand.amex:
      return 'Amex';
    case CardBrand.diners:
      return 'Diners';
    case CardBrand.unknown:
      return 'Card';
  }
}
