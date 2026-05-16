import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/earnings_repository.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final EarningsRepository _earningsRepository;
  final ApiService _api;
  final StorageService _storage;

  bool _isOnline = false;
  bool _isTogglingStatus = false;
  String? _lastStatusError;

  // Driver dashboard stats from backend
  int _todaysJobs = 0;
  int _completedToday = 0;
  double _todaysEarnings = 0.0;
  double _rating = 0.0;

  DashboardViewModel({
    required OrderRepository orderRepository,
    required EarningsRepository earningsRepository,
    required ApiService api,
    required StorageService storage,
  }) : _orderRepository = orderRepository,
       _earningsRepository = earningsRepository,
       _api = api,
       _storage = storage {
    _orderRepository.addListener(notifyListeners);
    _earningsRepository.addListener(notifyListeners);
    _loadDashboard();
  }

  @override
  void dispose() {
    _orderRepository.removeListener(notifyListeners);
    _earningsRepository.removeListener(notifyListeners);
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isOnline => _isOnline;
  bool get isTogglingStatus => _isTogglingStatus;
  String? get lastStatusError => _lastStatusError;
  double get walletBalance => _earningsRepository.totalBalance;
  int get todaysSwaps => _todaysJobs;
  double get rating => _rating;
  int get completedToday => _completedToday;
  double get todaysEarnings => _todaysEarnings;

  int get activeSwapCount => _orderRepository.orders
      .where(
        (o) =>
            o.status == OrderStatus.pickingUp ||
            o.status == OrderStatus.delivering,
      )
      .length;

  int get completedDeliveries => _orderRepository.orders
      .where((o) => o.status == OrderStatus.delivered)
      .length;

  String get batteryHealth => 'Excellent'; // Could come from IoT/telemetry

  List<Map<String, dynamic>> get nearbyStations =>
      const []; // TODO: fetch from /stations/nearby

  List<Order> get recentActivity {
    final completed =
        _orderRepository.orders
            .where((o) => o.status == OrderStatus.delivered)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return completed.take(5).toList();
  }

  List<Order> get activeOrders => _orderRepository.orders
      .where(
        (o) =>
            o.status == OrderStatus.pickingUp ||
            o.status == OrderStatus.delivering,
      )
      .toList();

  // ── Load ───────────────────────────────────────────────────────────────────

  /// Fetch driver dashboard stats from GET /logistics/dashboard
  Future<void> _loadDashboard() async {
    try {
      final data = await _api.get('/logistics/dashboard');
      final stats = data['data'] ?? data;
      _todaysJobs =
          _asInt(
            stats['today_jobs'] ?? stats['todays_jobs'] ?? stats['total_jobs'],
          ) ??
          0;
      _completedToday =
          _asInt(stats['completed_today'] ?? stats['completed_jobs']) ?? 0;
      final earningsValue =
          (stats['todays_earnings'] ?? stats['total_earnings']) as num?;
      _todaysEarnings = earningsValue?.toDouble() ?? 0.0;
      _rating = (stats['rating'] as num?)?.toDouble() ?? 0.0;
      _isOnline = stats['is_online'] == true;
      notifyListeners();
    } on ApiException {
      // Backend not reachable — keep defaults
    }
  }

  // ── Online toggle ──────────────────────────────────────────────────────────

  /// Toggle driver online/offline status.
  /// Calls PUT /logistics/drivers/{id}/status with status=online|offline
  Future<bool> toggleOnlineStatus(bool value) async {
    if (_isTogglingStatus) return false;
    final previous = _isOnline;
    _lastStatusError = null;
    _isTogglingStatus = true;
    _isOnline = value;
    notifyListeners();
    try {
      final driverId = await _ensureDriverProfileId();
      if (driverId != null) {
        await _api.put(
          '/logistics/drivers/$driverId/status',
          body: value ? 'online' : 'offline',
        );
      } else {
        _isOnline = previous;
        _lastStatusError = 'Driver profile is missing. Please sign in again.';
        return false;
      }
      return true;
    } on ApiException catch (e) {
      _isOnline = previous;
      _lastStatusError = e.message;
      return false;
    } catch (e) {
      _isOnline = previous;
      _lastStatusError = e.toString();
      return false;
    } finally {
      _isTogglingStatus = false;
      notifyListeners();
    }
  }

  /// Refresh all dashboard data.
  Future<void> refresh() async {
    await Future.wait([
      _loadDashboard(),
      _orderRepository.fetchAssignments(),
      _earningsRepository.fetchBalance(),
    ]);
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Future<int?> _ensureDriverProfileId() async {
    final cached = await _storage.getDriverProfileId();
    if (cached != null && cached > 0) return cached;

    try {
      final response = await _api.get('/drivers/me');
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final id = _asInt(data['id']);
        if (id != null && id > 0) {
          await _storage.setDriverProfileId(id);
          return id;
        }
      }
    } on ApiException {
      // No-op; caller handles missing id.
    }
    return null;
  }
}
