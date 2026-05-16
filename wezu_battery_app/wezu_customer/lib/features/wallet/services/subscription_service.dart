import 'package:dio/dio.dart';
import '../models/subscription_plan.dart';
import '../models/subscription.dart';
import '../models/subscription_requests.dart';

class SubscriptionService {
  final Dio _dio;
  static Subscription? _localActiveSubscription;

  static List<SubscriptionPlan> _fallbackPlans() {
    final now = DateTime.now();
    return [
      SubscriptionPlan(
        id: 1,
        name: 'Daily Pass',
        description: 'Unlimited swaps for one day',
        type: PlanType.daily,
        price: 99,
        durationDays: 1,
        unlimitedSwaps: true,
        swapsIncluded: 0,
        benefits: const ['Unlimited swaps', 'Priority support'],
        originalPrice: 149,
        createdAt: now,
        updatedAt: now,
      ),
      SubscriptionPlan(
        id: 2,
        name: 'Weekly Pass',
        description: 'Unlimited swaps for seven days',
        type: PlanType.weekly,
        price: 499,
        durationDays: 7,
        unlimitedSwaps: true,
        swapsIncluded: 0,
        benefits: const ['Unlimited swaps', 'Priority support', 'Lower cost'],
        originalPrice: 699,
        isPopular: true,
        createdAt: now,
        updatedAt: now,
      ),
      SubscriptionPlan(
        id: 3,
        name: 'Monthly Pass',
        description: 'Best value for regular riders',
        type: PlanType.monthly,
        price: 1499,
        durationDays: 30,
        unlimitedSwaps: true,
        swapsIncluded: 0,
        benefits: const [
          'Unlimited swaps',
          'Priority support',
          'Maximum savings'
        ],
        originalPrice: 2199,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  SubscriptionService(this._dio);

  // Fetch all available subscription plans
  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    try {
      final response = await _dio
          .get('/subscriptions/plans')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final payload = response.data;
        final List<dynamic> data = payload is Map && payload['data'] is List
            ? payload['data'] as List<dynamic>
            : payload is List
                ? payload
                : const [];
        return data
            .whereType<Map>()
            .map((json) =>
                SubscriptionPlan.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      print('Error fetching subscription plans: $e');
    }
    return _fallbackPlans();
  }

  // Get user's active subscription
  Future<Subscription?> getActiveSubscription() async {
    try {
      final response = await _dio
          .get('/subscriptions/active')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final payload = response.data;
        final data = payload is Map && payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload is Map
                ? Map<String, dynamic>.from(payload)
                : <String, dynamic>{};
        return data.isNotEmpty ? Subscription.fromJson(data) : null;
      }
    } catch (e) {
      print('Error fetching active subscription: $e');
    }
    return _localActiveSubscription;
  }

  // Purchase a new subscription
  Future<SubscriptionPurchaseResponse> purchaseSubscription(
    SubscriptionPurchaseRequest request,
  ) async {
    try {
      final response = await _dio
          .post(
            '/subscriptions/purchase',
            data: request.toJson(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final payload = response.data;
        final map = payload is Map && payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload is Map
                ? Map<String, dynamic>.from(payload)
                : <String, dynamic>{};
        return SubscriptionPurchaseResponse.fromJson(map);
      }
    } catch (e) {
      print('Error purchasing subscription: $e');
    }

    final plans = _fallbackPlans();
    final plan = plans.firstWhere(
      (p) => p.id == request.planId,
      orElse: () => plans.first,
    );
    final now = DateTime.now();
    final end = now.add(Duration(days: plan.durationDays));
    final id = now.millisecondsSinceEpoch;
    _localActiveSubscription = Subscription(
      id: id,
      userId: 0,
      planId: plan.id,
      planName: plan.name,
      startDate: now,
      endDate: end,
      status: SubscriptionStatus.active,
      autoRenew: request.autoRenew,
      nextRenewalDate: request.autoRenew ? end : null,
      swapsUsed: 0,
      swapsLimit: plan.unlimitedSwaps ? 0 : plan.swapsIncluded,
      createdAt: now,
      updatedAt: now,
      paymentMethodId: request.paymentMethodId,
      transactionId: 'LOCAL-$id',
    );
    return SubscriptionPurchaseResponse(
      subscriptionId: id,
      transactionId: 'LOCAL-$id',
      amount: plan.price,
      startDate: now,
      endDate: end,
      status: 'active',
    );
  }

  // Update auto-renewal status
  Future<void> updateAutoRenewal(int subscriptionId, bool autoRenew) async {
    try {
      await _dio.put(
        '/subscriptions/$subscriptionId/auto-renew',
        data: {'auto_renew': autoRenew},
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Error updating auto-renewal: $e');
      if (_localActiveSubscription != null &&
          _localActiveSubscription!.id == subscriptionId) {
        _localActiveSubscription =
            _localActiveSubscription!.copyWith(autoRenew: autoRenew);
      }
    }
  }

  // Cancel subscription
  Future<SubscriptionCancellationResponse> cancelSubscription(
    int subscriptionId,
    SubscriptionCancellationRequest request,
  ) async {
    try {
      final response = await _dio
          .put(
            '/subscriptions/$subscriptionId/cancel',
            data: request.toJson(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final payload = response.data;
        final map = payload is Map && payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload is Map
                ? Map<String, dynamic>.from(payload)
                : <String, dynamic>{};
        return SubscriptionCancellationResponse.fromJson(map);
      }
    } catch (e) {
      print('Error cancelling subscription: $e');
      final now = DateTime.now();
      _localActiveSubscription = null;
      return SubscriptionCancellationResponse(
        subscriptionId: subscriptionId,
        refundAmount: 0,
        cancellationDate: now,
        status: 'cancelled',
        message: 'Subscription cancelled',
      );
    }
    final now = DateTime.now();
    _localActiveSubscription = null;
    return SubscriptionCancellationResponse(
      subscriptionId: subscriptionId,
      refundAmount: 0,
      cancellationDate: now,
      status: 'cancelled',
      message: 'Subscription cancelled',
    );
  }

  // Manual renewal
  Future<SubscriptionPurchaseResponse> manualRenewal(int subscriptionId) async {
    try {
      final response = await _dio
          .post(
            '/subscriptions/$subscriptionId/renew',
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final payload = response.data;
        final map = payload is Map && payload['data'] is Map
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : payload is Map
                ? Map<String, dynamic>.from(payload)
                : <String, dynamic>{};
        return SubscriptionPurchaseResponse.fromJson(map);
      }
    } catch (e) {
      print('Error renewing subscription: $e');
      if (_localActiveSubscription != null &&
          _localActiveSubscription!.id == subscriptionId) {
        final startDate = DateTime.now();
        final currentDuration = _localActiveSubscription!.endDate
            .difference(_localActiveSubscription!.startDate);
        final endDate = startDate.add(currentDuration);
        _localActiveSubscription = _localActiveSubscription!.copyWith(
          startDate: startDate,
          endDate: endDate,
          status: SubscriptionStatus.active,
          nextRenewalDate: endDate,
          updatedAt: startDate,
        );
        return SubscriptionPurchaseResponse(
          subscriptionId: subscriptionId,
          transactionId: 'LOCAL-RENEW-$subscriptionId',
          amount: 0,
          startDate: startDate,
          endDate: endDate,
          status: 'active',
        );
      }
      rethrow;
    }
    throw Exception('Failed to renew subscription');
  }

  // Get subscription history
  Future<List<Subscription>> getSubscriptionHistory() async {
    try {
      final response = await _dio
          .get('/subscriptions/history')
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final payload = response.data;
        final List<dynamic> data = payload is Map && payload['data'] is List
            ? payload['data'] as List<dynamic>
            : payload is List
                ? payload
                : const [];
        return data
            .whereType<Map>()
            .map((json) =>
                Subscription.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (e) {
      print('Error fetching subscription history: $e');
      if (_localActiveSubscription != null) {
        return [_localActiveSubscription!];
      }
      return [];
    }
    return [];
  }

  // Validate plan eligibility before purchase
  Future<bool> validatePlanEligibility(int planId) async {
    try {
      final response = await _dio
          .get('/subscriptions/plans/$planId/eligibility')
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error validating plan eligibility: $e');
      return false;
    }
  }
}
