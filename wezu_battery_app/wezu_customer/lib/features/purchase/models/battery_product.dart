class BatteryProduct {
  final String id;
  final String sku;
  final String name;
  final String brand;
  final int capacityMah;
  final int voltage;
  final String type; // 'Li-Ion', 'LiFePO4'
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockCount;
  final List<BatteryVariant> variants;
  final List<String> imageUrls;
  final String description;
  final int warrantyMonths;
  final List<String> keyFeatures;
  final Map<String, String> specifications;

  BatteryProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.brand,
    required this.capacityMah,
    required this.voltage,
    required this.type,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    this.inStock = true,
    required this.stockCount,
    this.variants = const [],
    required this.imageUrls,
    required this.description,
    required this.warrantyMonths,
    this.keyFeatures = const [],
    this.specifications = const {},
  });

  factory BatteryProduct.fromJson(Map<String, dynamic> json) {
    return BatteryProduct(
      id: json['id'].toString(),
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      capacityMah: json['capacity_mah'] ?? 0,
      voltage: (json['voltage'] ?? 0).toInt(),
      type: json['battery_type'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      rating: (json['average_rating'] ?? 0.0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      inStock: json['in_stock'] ?? (json['stock_quantity'] ?? 0) > 0,
      stockCount: json['stock_quantity'] ?? 0,
      imageUrls: json['image_url'] != null ? [json['image_url']] : (json['images'] != null ? (json['images'] as List).map((i) => i['url'] as String).toList() : []),
      description: json['description'] ?? '',
      warrantyMonths: json['warranty_months'] ?? 12,
      variants: json['variants'] != null 
        ? (json['variants'] as List).map((v) => BatteryVariant.fromJson(v)).toList()
        : [],
      keyFeatures: json['key_features'] != null
        ? (json['key_features'] as List).map((f) => f.toString()).toList()
        : [],
      specifications: json['specifications'] != null
        ? Map<String, String>.from(json['specifications'])
        : {},
    );
  }
}

class BatteryVariant {
  final String id;
  final String name;
  final String sku;
  final double price;
  final int stockQuantity;
  final String? color;
  final int? capacityMah;

  BatteryVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.stockQuantity,
    this.color,
    this.capacityMah,
  });

  factory BatteryVariant.fromJson(Map<String, dynamic> json) {
    return BatteryVariant(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      color: json['color'],
      capacityMah: json['capacity_mah'],
    );
  }
}
