enum PlanType { daily, weekly, monthly }

enum PlanFrequency { daily, weekly, monthly }

class SubscriptionPlan {
  final int id;
  final String name;
  final String description;
  final PlanType type;
  final double price;
  final int durationDays;
  final bool unlimitedSwaps;
  final int swapsIncluded; // 0 if unlimited
  final List<String> benefits;
  final double originalPrice; // for showing savings
  final bool isPopular;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.durationDays,
    required this.unlimitedSwaps,
    required this.swapsIncluded,
    required this.benefits,
    required this.originalPrice,
    this.isPopular = false,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayPrice => '₹${price.toStringAsFixed(0)}';

  String get displayOriginalPrice => '₹${originalPrice.toStringAsFixed(0)}';

  double get savingsPercentage {
    if (originalPrice == 0) return 0;
    return ((originalPrice - price) / originalPrice) * 100;
  }

  String get durationDisplay {
    switch (type) {
      case PlanType.daily:
        return '/day';
      case PlanType.weekly:
        return '/week';
      case PlanType.monthly:
        return '/month';
    }
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      type: PlanType.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['type'] as String).toLowerCase(),
        orElse: () => PlanType.monthly,
      ),
      price: (json['price'] as num).toDouble(),
      durationDays: json['duration_days'] as int,
      unlimitedSwaps: json['unlimited_swaps'] as bool,
      swapsIncluded: json['swaps_included'] as int? ?? 0,
      benefits: List<String>.from(json['benefits'] as List? ?? []),
      originalPrice: (json['original_price'] as num).toDouble(),
      isPopular: json['is_popular'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory SubscriptionPlan.mockDaily() {
    final now = DateTime.now();
    return SubscriptionPlan(
      id: 1,
      name: 'Daily Pass',
      description: 'Unlimited swaps for one day',
      type: PlanType.daily,
      price: 99.0,
      durationDays: 1,
      unlimitedSwaps: true,
      swapsIncluded: 0,
      benefits: [
        'Unlimited swaps',
        'Access all stations',
        'Priority support',
      ],
      originalPrice: 149.0,
      isPopular: false,
      imageUrl: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.toString().split('.').last,
        'price': price,
        'duration_days': durationDays,
        'unlimited_swaps': unlimitedSwaps,
        'swaps_included': swapsIncluded,
        'benefits': benefits,
        'original_price': originalPrice,
        'is_popular': isPopular,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
