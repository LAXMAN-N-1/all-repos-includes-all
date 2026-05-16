class SubscriptionPurchaseRequest {
  final int planId;
  final String paymentMethodId;
  final bool autoRenew;

  SubscriptionPurchaseRequest({
    required this.planId,
    required this.paymentMethodId,
    this.autoRenew = true,
  });

  Map<String, dynamic> toJson() => {
        'plan_id': planId,
        'payment_method_id': paymentMethodId,
        'auto_renew': autoRenew,
      };
}

class SubscriptionPurchaseResponse {
  final int subscriptionId;
  final String transactionId;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  SubscriptionPurchaseResponse({
    required this.subscriptionId,
    required this.transactionId,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory SubscriptionPurchaseResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPurchaseResponse(
      subscriptionId: json['subscription_id'] as int,
      transactionId: json['transaction_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      endDate: DateTime.parse(json['end_date'] as String).toLocal(),
      status: json['status'] as String,
    );
  }
}

class SubscriptionCancellationRequest {
  final String reason;
  final String? feedback;
  final bool refundImmediately;

  SubscriptionCancellationRequest({
    required this.reason,
    this.feedback,
    this.refundImmediately = false,
  });

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'feedback': feedback,
        'refund_immediately': refundImmediately,
      };
}

class SubscriptionCancellationResponse {
  final int subscriptionId;
  final double refundAmount;
  final DateTime cancellationDate;
  final String status;
  final String message;

  SubscriptionCancellationResponse({
    required this.subscriptionId,
    required this.refundAmount,
    required this.cancellationDate,
    required this.status,
    required this.message,
  });

  factory SubscriptionCancellationResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionCancellationResponse(
      subscriptionId: json['subscription_id'] as int,
      refundAmount: (json['refund_amount'] as num).toDouble(),
      cancellationDate: DateTime.parse(json['cancellation_date'] as String).toLocal(),
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }
}
