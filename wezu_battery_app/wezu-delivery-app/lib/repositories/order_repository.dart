import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderRepository extends ChangeNotifier {
  final ApiService _api;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderRepository({required ApiService api}) : _api = api {
    fetchAssignments();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  /// Fetch all assigned orders for the current driver from the backend.
  /// Calls GET /logistics/me/assignments
  Future<void> fetchAssignments() async {
    _setLoading(true);
    _error = null;
    try {
      final list = await _api.getList('/logistics/me/assignments');
      _orders = list
          .whereType<Map<String, dynamic>>()
          .map(Order.fromJson)
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch only active (in-transit) deliveries.
  /// Calls GET /logistics/deliveries/active
  Future<List<Order>> fetchActiveDeliveries() async {
    try {
      final list = await _api.getList('/logistics/deliveries/active');
      return list
          .whereType<Map<String, dynamic>>()
          .map(Order.fromJson)
          .toList();
    } on ApiException {
      return [];
    }
  }

  /// Fetch completed delivery history.
  /// Calls GET /logistics/deliveries/history
  Future<List<Order>> fetchHistory({int skip = 0, int limit = 50}) async {
    try {
      final list = await _api.getList(
        '/logistics/deliveries/history',
        queryParams: {'skip': '$skip', 'limit': '$limit'},
      );
      return list
          .whereType<Map<String, dynamic>>()
          .map(Order.fromJson)
          .toList();
    } on ApiException {
      return [];
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  /// Update order status on the backend and refresh local state.
  /// Calls `PUT /logistics/orders/{id}/status?status=...`
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final statusStr = _statusToString(status);
    try {
      await _api.put(
        '/logistics/orders/$orderId/status',
        queryParams: {'status': statusStr},
      );
      // Update local list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      }
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await fetchAssignments();
  }

  /// Upload proof of delivery for an order.
  /// Calls POST /logistics/orders/{id}/pod
  Future<bool> uploadPod(
    String orderId, {
    required String podUrl,
    String? otp,
  }) async {
    try {
      await _api.post(
        '/logistics/orders/$orderId/pod',
        body: {'pod_url': podUrl, if (otp != null) 'otp': otp},
      );
      return true;
    } on ApiException {
      return false;
    }
  }

  // ── Pagination helper ─────────────────────────────────────────────────────

  Future<void> fetchMoreHistory() async {
    final history = await fetchHistory(skip: _orders.length);
    _orders.addAll(history);
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _statusToString(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.pickingUp:
        return 'picking_up';
      case OrderStatus.delivering:
        return 'in_transit';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
