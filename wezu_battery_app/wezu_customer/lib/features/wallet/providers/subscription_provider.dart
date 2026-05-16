import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_plan.dart';
import '../models/subscription.dart';
import '../models/subscription_requests.dart';
import '../services/subscription_service.dart';
import '../../../core/network/dio_provider.dart';

// Subscription Service Provider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return SubscriptionService(dio);
});

// Get all available subscription plans
final subscriptionPlansProvider =
    FutureProvider<List<SubscriptionPlan>>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionPlans();
});

// Get active subscription
final activeSubscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getActiveSubscription();
});

// Get subscription history
final subscriptionHistoryProvider =
    FutureProvider<List<Subscription>>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionHistory();
});

// Subscription state notifier
class SubscriptionState {
  final Subscription? activeSubscription;
  final List<SubscriptionPlan> plans;
  final bool isLoading;
  final String? error;
  final SubscriptionPurchaseResponse? lastPurchase;

  SubscriptionState({
    this.activeSubscription,
    this.plans = const [],
    this.isLoading = false,
    this.error,
    this.lastPurchase,
  });

  SubscriptionState copyWith({
    Subscription? activeSubscription,
    List<SubscriptionPlan>? plans,
    bool? isLoading,
    String? error,
    SubscriptionPurchaseResponse? lastPurchase,
  }) {
    return SubscriptionState(
      activeSubscription: activeSubscription ?? this.activeSubscription,
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastPurchase: lastPurchase ?? this.lastPurchase,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _service;

  SubscriptionNotifier(this._service) : super(SubscriptionState()) {
    _initializeSubscription();
  }

  Future<void> _initializeSubscription() async {
    state = state.copyWith(isLoading: true);
    try {
      final plans = await _service.getSubscriptionPlans();
      final subscription = await _service.getActiveSubscription();

      state = state.copyWith(
        plans: plans,
        activeSubscription: subscription,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> purchaseSubscription({
    required int planId,
    required String paymentMethodId,
    bool autoRenew = true,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = SubscriptionPurchaseRequest(
        planId: planId,
        paymentMethodId: paymentMethodId,
        autoRenew: autoRenew,
      );

      final response = await _service.purchaseSubscription(request);
      final subscription = await _service.getActiveSubscription();

      state = state.copyWith(
        isLoading: false,
        activeSubscription: subscription,
        lastPurchase: response,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateAutoRenewal(int subscriptionId, bool autoRenew) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.updateAutoRenewal(subscriptionId, autoRenew);

      // Update local state
      final updated = state.activeSubscription?.copyWith(autoRenew: autoRenew);
      state = state.copyWith(
        isLoading: false,
        activeSubscription: updated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> cancelSubscription({
    required int subscriptionId,
    required String reason,
    String? feedback,
    bool refundImmediately = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final request = SubscriptionCancellationRequest(
        reason: reason,
        feedback: feedback,
        refundImmediately: refundImmediately,
      );

      await _service.cancelSubscription(subscriptionId, request);

      // Clear active subscription
      state = state.copyWith(
        isLoading: false,
        activeSubscription: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> manualRenewal(int subscriptionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.manualRenewal(subscriptionId);
      final subscription = await _service.getActiveSubscription();

      state = state.copyWith(
        isLoading: false,
        activeSubscription: subscription,
        lastPurchase: response,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refetchPlans() async {
    state = state.copyWith(isLoading: true);
    try {
      final plans = await _service.getSubscriptionPlans();
      state = state.copyWith(
        plans: plans,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refetchActiveSubscription() async {
    try {
      final subscription = await _service.getActiveSubscription();
      state = state.copyWith(activeSubscription: subscription);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Subscription State Notifier Provider
final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return SubscriptionNotifier(service);
});
