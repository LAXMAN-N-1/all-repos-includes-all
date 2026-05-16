enum SubscriptionStatus { active, expired, cancelled, pending }

class Subscription {
  final int id;
  final int userId;
  final int planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;
  final bool autoRenew;
  final DateTime? nextRenewalDate;
  final int swapsUsed;
  final int swapsLimit; // 0 if unlimited
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentMethodId;
  final String? transactionId;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.autoRenew,
    this.nextRenewalDate,
    required this.swapsUsed,
    required this.swapsLimit,
    required this.createdAt,
    required this.updatedAt,
    this.paymentMethodId,
    this.transactionId,
  });

  Subscription copyWith({
    int? id,
    int? userId,
    int? planId,
    String? planName,
    DateTime? startDate,
    DateTime? endDate,
    SubscriptionStatus? status,
    bool? autoRenew,
    DateTime? nextRenewalDate,
    int? swapsUsed,
    int? swapsLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentMethodId,
    String? transactionId,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      autoRenew: autoRenew ?? this.autoRenew,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      swapsUsed: swapsUsed ?? this.swapsUsed,
      swapsLimit: swapsLimit ?? this.swapsLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  bool get isActive => status == SubscriptionStatus.active;

  bool get isExpired => status == SubscriptionStatus.expired;

  bool get isCancelled => status == SubscriptionStatus.cancelled;

  bool get isUnlimited => swapsLimit == 0;

  int get swapsRemaining => isUnlimited ? 0 : (swapsLimit - swapsUsed);

  Duration get daysRemaining => endDate.difference(DateTime.now());

  int get daysRemainingCount => daysRemaining.inDays;

  bool get renewsSoon => isActive && daysRemainingCount <= 3;

  String get statusDisplay {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.pending:
        return 'Pending';
    }
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      planId: json['plan_id'] as int,
      planName: json['plan_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: SubscriptionStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last ==
            (json['status'] as String).toLowerCase(),
        orElse: () => SubscriptionStatus.active,
      ),
      autoRenew: json['auto_renew'] as bool,
      nextRenewalDate: json['next_renewal_date'] != null
          ? DateTime.parse(json['next_renewal_date'] as String)
          : null,
      swapsUsed: json['swaps_used'] as int? ?? 0,
      swapsLimit: json['swaps_limit'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paymentMethodId: json['payment_method_id'] as String?,
      transactionId: json['transaction_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'plan_id': planId,
        'plan_name': planName,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status.toString().split('.').last,
        'auto_renew': autoRenew,
        'next_renewal_date': nextRenewalDate?.toIso8601String(),
        'swaps_used': swapsUsed,
        'swaps_limit': swapsLimit,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'payment_method_id': paymentMethodId,
        'transaction_id': transactionId,
      };
}
