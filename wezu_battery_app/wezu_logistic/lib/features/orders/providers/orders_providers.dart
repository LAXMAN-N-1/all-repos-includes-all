import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_constants.dart';
import '../../../core/base_notifier.dart';
import '../../../core/providers.dart';
import '../../../core/result.dart';
import '../../../models/order_model.dart';
import '../../../services/storage_service.dart';
import '../repository/orders_repository.dart';

// ─── Repository ─────────────────────────────────────────────────────

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(api: ref.read(apiClientProvider));
});

// ─── Filter State ───────────────────────────────────────────────────

/// Currently selected tab index (0 = Active, 1 = History).
final ordersTabProvider = StateProvider<int>((ref) => 0);

/// Sort option: 'date', 'priority', 'value', 'units'.
final ordersSortProvider = StateProvider<String>((ref) => 'date');

/// Sort order: 'asc', 'desc'.
final ordersSortOrderProvider = StateProvider<String>((ref) => 'desc');

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

Map<String, dynamic> _normalizeRealtimeOrderPayload(
  Map<String, dynamic> order,
) {
  final normalized = Map<String, dynamic>.from(order);
  final assignedDriver =
      _asStringKeyedMap(normalized['assigned_driver']) ??
      _asStringKeyedMap(normalized['driver']) ??
      _asStringKeyedMap(normalized['assignedDriver']);
  final assignedDriverId =
      normalized['assigned_driver_id'] ??
      normalized['driver_id'] ??
      normalized['assignedDriverId'] ??
      assignedDriver?['id'];
  final assignedDriverName =
      normalized['assigned_driver_name'] ??
      normalized['driver_name'] ??
      normalized['assignedDriverName'] ??
      assignedDriver?['full_name'] ??
      assignedDriver?['name'] ??
      assignedDriver?['display_name'];
  normalized['assigned_driver_id'] = assignedDriverId?.toString();
  normalized['assigned_driver_name'] = assignedDriverName?.toString();
  normalized['is_driver_assigned'] ??= assignedDriverId != null;
  return normalized;
}

OrderModel? _parseOrderUpdate(dynamic rawMessage) {
  try {
    dynamic decoded = rawMessage;
    if (rawMessage is String) {
      decoded = jsonDecode(rawMessage);
    } else if (rawMessage is List<int>) {
      decoded = jsonDecode(utf8.decode(rawMessage));
    }

    final message = _asStringKeyedMap(decoded);
    if (message == null || message['type'] != 'order_update') {
      return null;
    }

    final data = _asStringKeyedMap(message['data']);
    final orderPayload = _asStringKeyedMap(data?['order']);
    if (orderPayload == null) {
      return null;
    }

    return OrderModel.fromJson(_normalizeRealtimeOrderPayload(orderPayload));
  } catch (_) {
    return null;
  }
}

Uri _ordersStreamUri({required String token, String? orderId}) {
  final apiUri = Uri.parse(AppConstants.apiBaseUrl);
  final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
  final basePath = apiUri.path.replaceAll(RegExp(r'/+$'), '');
  final streamPath = orderId == null
      ? '$basePath/orders/stream'
      : '$basePath/orders/stream/$orderId';

  return Uri(
    scheme: wsScheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
    path: streamPath,
    queryParameters: {'token': token},
  );
}

bool _canUseRealtimeOrders(String? role) {
  final normalizedRole = (role ?? '').trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '',
  );
  const internalOperatorRoles = <String>{
    'superadmin',
    'operationsadmin',
    'securityadmin',
    'financeadmin',
    'supportmanager',
    'supportagent',
    'logisticsmanager',
    'dispatcher',
    'fleetmanager',
    'warehousemanager',
  };
  return internalOperatorRoles.contains(normalizedRole);
}

Duration _reconnectDelay(int attempt) {
  final boundedAttempt = attempt.clamp(0, 5);
  return Duration(seconds: math.min(30, 1 << boundedAttempt));
}

int? _extractAuthStatusCode(Object error) {
  final message = error.toString();
  final statusMatch = RegExp(
    r'status code:\s*(\d+)',
    caseSensitive: false,
  ).firstMatch(message);
  if (statusMatch != null) {
    return int.tryParse(statusMatch.group(1) ?? '');
  }
  return null;
}

int? _extractRealtimeAuthStatusCode(dynamic rawMessage) {
  try {
    dynamic decoded = rawMessage;
    if (rawMessage is String) {
      decoded = jsonDecode(rawMessage);
    } else if (rawMessage is List<int>) {
      decoded = jsonDecode(utf8.decode(rawMessage));
    }

    final message = _asStringKeyedMap(decoded);
    if (message == null) return null;

    final type = (message['type']?.toString() ?? '').trim().toLowerCase();
    if (type != 'auth_error') {
      return null;
    }

    final status =
        message['status_code'] ?? message['status'] ?? message['code'];
    if (status is int) return status;
    if (status is num) return status.toInt();
    if (status is String) return int.tryParse(status.trim());
    return 401;
  } catch (_) {
    return null;
  }
}

class OrdersRealtimeController with WidgetsBindingObserver {
  final Ref _ref;
  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  bool _enabled = false;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;

  OrdersRealtimeController(this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  void setEnabled(bool enabled) {
    if (_disposed || _enabled == enabled) {
      return;
    }

    _enabled = enabled;
    if (_enabled) {
      unawaited(_connect());
    } else {
      unawaited(_disconnect(resetBackoff: true));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled || _disposed) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_reconnectNow());
    }
  }

  Future<void> _connect() async {
    if (!_enabled || _disposed || _connecting || _socket != null) {
      return;
    }
    _connecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      final token = await _ref.read(storageServiceProvider).getToken();
      if (!_enabled || _disposed) {
        return;
      }
      if (token == null || token.isEmpty) {
        _scheduleReconnect();
        return;
      }

      final wsUrl = _ordersStreamUri(token: token);
      final socket = await WebSocket.connect(wsUrl.toString());
      socket.pingInterval = const Duration(seconds: 20);
      if (!_enabled || _disposed) {
        await socket.close();
        return;
      }

      _socket = socket;
      _reconnectAttempt = 0;
      _socketSubscription = socket.listen(
        _onMessage,
        onDone: () => unawaited(_handleSocketClosed()),
        onError: (_) => unawaited(_handleSocketClosed()),
        cancelOnError: true,
      );
    } catch (error) {
      final statusCode = _extractAuthStatusCode(error);
      if (statusCode == 401 || statusCode == 403) {
        unawaited(_expireSession());
      } else {
        _scheduleReconnect();
      }
    } finally {
      _connecting = false;
    }
  }

  void _onMessage(dynamic rawMessage) {
    final authStatusCode = _extractRealtimeAuthStatusCode(rawMessage);
    if (authStatusCode == 401 || authStatusCode == 403) {
      unawaited(_expireSession());
      return;
    }

    final order = _parseOrderUpdate(rawMessage);
    if (order == null) {
      return;
    }
    _ref.read(ordersListProvider.notifier).upsertOrder(order);
  }

  Future<void> _handleSocketClosed() async {
    await _disconnectSocketOnly();
    if (_enabled && !_disposed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null || !_enabled || _disposed) {
      return;
    }
    final delay = _reconnectDelay(_reconnectAttempt);
    _reconnectAttempt++;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(_connect());
    });
  }

  Future<void> _reconnectNow() async {
    await _disconnectSocketOnly();
    _scheduleReconnect();
    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
      _reconnectTimer = null;
    }
    await _connect();
  }

  Future<void> _disconnectSocketOnly() async {
    final subscription = _socketSubscription;
    _socketSubscription = null;
    await subscription?.cancel();

    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  Future<void> _disconnect({bool resetBackoff = false}) async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (resetBackoff) {
      _reconnectAttempt = 0;
    }
    await _disconnectSocketOnly();
  }

  Future<void> _expireSession() async {
    if (_disposed) return;
    _enabled = false;
    await _disconnect(resetBackoff: true);
    _ref.read(isAuthenticatedProvider.notifier).state = false;
    _ref.read(authTokenProvider.notifier).state = null;
    await _ref.read(storageServiceProvider).clearTokens();
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disconnect(resetBackoff: true));
  }
}

final ordersRealtimeControllerProvider = Provider<OrdersRealtimeController>((
  ref,
) {
  final controller = OrdersRealtimeController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

final ordersRealtimeBootstrapProvider = Provider<void>((ref) {
  final controller = ref.watch(ordersRealtimeControllerProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUser = ref.watch(currentUserProvider);
  final shouldEnable =
      isAuthenticated && _canUseRealtimeOrders(currentUser?.role);
  controller.setEnabled(shouldEnable);
});

// ─── Order Stats Provider ───────────────────────────────────────────

final ordersStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(ordersRepositoryProvider);
  final result = await repo.fetchOrderStats();
  return result.when(
    success: (stats) => stats,
    failure: (_, __) => <String, dynamic>{
      'total_orders': 0,
      'pending': 0,
      'in_transit': 0,
      'delivered': 0,
      'failed': 0,
      'urgent': 0,
      'total_value': 0.0,
      'total_units': 0,
    },
  );
});

// ─── Orders List Provider ───────────────────────────────────────────

final ordersListProvider =
    StateNotifierProvider<OrdersListNotifier, AsyncState<List<OrderModel>>>((
      ref,
    ) {
      final notifier = OrdersListNotifier(ref.read(ordersRepositoryProvider));

      // Active tab: pending + in_transit; History: delivered + failed + cancelled
      ref.listen(ordersTabProvider, (_, tabIndex) {
        final statuses = tabIndex == 0
            ? [OrderStatus.pending, OrderStatus.inTransit]
            : [
                OrderStatus.delivered,
                OrderStatus.failed,
                OrderStatus.cancelled,
              ];
        notifier.loadOrders(
          statuses: statuses,
          sortBy: ref.read(ordersSortProvider),
          sortOrder: ref.read(ordersSortOrderProvider),
        );
      });

      ref.listen(ordersSortProvider, (_, sortBy) {
        final tabIndex = ref.read(ordersTabProvider);
        final statuses = tabIndex == 0
            ? [OrderStatus.pending, OrderStatus.inTransit]
            : [
                OrderStatus.delivered,
                OrderStatus.failed,
                OrderStatus.cancelled,
              ];
        notifier.loadOrders(
          statuses: statuses,
          sortBy: sortBy,
          sortOrder: ref.read(ordersSortOrderProvider),
        );
      });

      ref.listen(ordersSortOrderProvider, (_, sortOrder) {
        final tabIndex = ref.read(ordersTabProvider);
        final statuses = tabIndex == 0
            ? [OrderStatus.pending, OrderStatus.inTransit]
            : [
                OrderStatus.delivered,
                OrderStatus.failed,
                OrderStatus.cancelled,
              ];
        notifier.loadOrders(
          statuses: statuses,
          sortBy: ref.read(ordersSortProvider),
          sortOrder: sortOrder,
        );
      });

      // Initial load
      final tabIndex = ref.read(ordersTabProvider);
      final initialStatuses = tabIndex == 0
          ? [OrderStatus.pending, OrderStatus.inTransit]
          : [OrderStatus.delivered, OrderStatus.failed, OrderStatus.cancelled];
      notifier.loadOrders(
        statuses: initialStatuses,
        sortBy: ref.read(ordersSortProvider),
        sortOrder: ref.read(ordersSortOrderProvider),
      );

      return notifier;
    });

class OrdersListNotifier extends BasePaginatedNotifier<OrderModel> {
  final OrdersRepository _repository;
  List<OrderStatus>? _currentStatuses;
  String? _currentSearchQuery;
  String _currentSortBy = 'date';
  String _currentSortOrder = 'desc';

  OrdersListNotifier(this._repository);

  Future<void> loadOrders({
    List<OrderStatus>? statuses,
    String? searchQuery,
    String? sortBy,
    String? sortOrder,
  }) {
    _currentStatuses = statuses ?? _currentStatuses;
    _currentSearchQuery = searchQuery;
    _currentSortBy = sortBy ?? _currentSortBy;
    _currentSortOrder = sortOrder ?? _currentSortOrder;
    return loadPage(
      (page) => _repository.fetchOrders(
        page: page,
        statuses: _currentStatuses,
        searchQuery: _currentSearchQuery,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      ),
    );
  }

  Future<void> loadMore() {
    return loadNextPage(
      (page) => _repository.fetchOrders(
        page: page,
        statuses: _currentStatuses,
        searchQuery: _currentSearchQuery,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      ),
    );
  }

  Future<void> search(String query) {
    return loadOrders(searchQuery: query);
  }

  bool _matchesCurrentFilters(OrderModel order) {
    final statuses = _currentStatuses;
    if (statuses != null &&
        statuses.isNotEmpty &&
        !statuses.contains(order.status)) {
      return false;
    }

    final query = _currentSearchQuery?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      final searchable = [
        order.id,
        order.customerName,
        order.destination ?? '',
        order.assignedDriverId ?? '',
        order.assignedDriverName ?? '',
      ].join(' ').toLowerCase();
      if (!searchable.contains(query)) {
        return false;
      }
    }
    return true;
  }

  void upsertOrder(OrderModel order) {
    final exists = allItems.any((item) => item.id == order.id);
    final shouldShow = _matchesCurrentFilters(order);

    if (exists && !shouldShow) {
      removeItem((item) => item.id == order.id);
      return;
    }

    if (exists) {
      updateItem((item) => item.id == order.id, (_) => order);
      return;
    }

    if (shouldShow) {
      prependItem(order);
    }
  }

  void applyOrderUpdate(OrderModel updatedOrder) {
    upsertOrder(updatedOrder);
  }

  Future<void> refreshCurrent() {
    return loadOrders(
      statuses: _currentStatuses,
      searchQuery: _currentSearchQuery,
      sortBy: _currentSortBy,
      sortOrder: _currentSortOrder,
    );
  }

  Future<void> cancelOrder(String orderId) async {
    updateItem(
      (o) => o.id == orderId,
      (o) => o.copyWith(status: OrderStatus.cancelled),
    );
    final result = await _repository.cancelOrder(orderId);
    result.when(
      success: (updated) => updateItem((o) => o.id == orderId, (_) => updated),
      failure: (message, code) => loadOrders(statuses: _currentStatuses),
    );
  }

  Future<void> markInTransit(String orderId) async {
    updateItem(
      (o) => o.id == orderId,
      (o) => o.copyWith(status: OrderStatus.inTransit),
    );
    final result = await _repository.markInTransit(orderId);
    result.when(
      success: (updated) => updateItem((o) => o.id == orderId, (_) => updated),
      failure: (message, code) => loadOrders(statuses: _currentStatuses),
    );
  }
}

// ─── Create Order Provider ──────────────────────────────────────────

final createOrderProvider =
    StateNotifierProvider<CreateOrderNotifier, AsyncState<OrderModel>>((ref) {
      return CreateOrderNotifier(ref.read(ordersRepositoryProvider), ref);
    });

class CreateOrderNotifier extends BaseNotifier<OrderModel> {
  final OrdersRepository _repository;
  final Ref _ref;

  CreateOrderNotifier(this._repository, this._ref);

  Future<Result<OrderModel>> createOrder({
    required int units,
    required String destination,
    required List<String> assignedBatteryIds,
    String? notes,
    String? customerName,
    String? customerPhone,
    OrderPriority priority = OrderPriority.normal,
    double? totalValue,
    String? trackingNumber,
    int? assignedDriverId,
    DateTime? orderDate,
    DateTime? dispatchDate,
    DateTime? estimatedDelivery,
    double? latitude,
    double? longitude,
  }) async {
    state = AsyncState.loading();
    final result = await _repository.createOrder(
      units: units,
      destination: destination,
      assignedBatteryIds: assignedBatteryIds,
      notes: notes,
      customerName: customerName,
      customerPhone: customerPhone,
      priority: priority,
      totalValue: totalValue,
      trackingNumber: trackingNumber,
      assignedDriverId: assignedDriverId,
      orderDate: orderDate,
      dispatchDate: dispatchDate,
      estimatedDelivery: estimatedDelivery,
      latitude: latitude,
      longitude: longitude,
    );

    result.when(
      success: (order) {
        state = AsyncState.loaded(order);
        final listNotifier = _ref.read(ordersListProvider.notifier);
        listNotifier.prependItem(order);
      },
      failure: (message, _) {
        state = AsyncState.error(message);
      },
    );
    return result;
  }
}

// ─── Single Order Detail ────────────────────────────────────────────

final orderDetailProvider = StateNotifierProvider.autoDispose
    .family<OrderDetailNotifier, AsyncState<OrderModel>, String>((
      ref,
      orderId,
    ) {
      final notifier = OrderDetailNotifier(
        ref.read(ordersRepositoryProvider),
        ref.read(storageServiceProvider),
        ref,
      );
      notifier.load(orderId);
      notifier.startRealtime(orderId);
      return notifier;
    });

class OrderDetailNotifier extends BaseNotifier<OrderModel>
    with WidgetsBindingObserver {
  final OrdersRepository _repository;
  final StorageService _storage;
  final Ref _ref;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  String? _orderId;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;

  OrderDetailNotifier(this._repository, this._storage, this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  void startRealtime(String orderId) {
    _orderId = orderId;
    unawaited(_connectRealtime());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed || _orderId == null) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      unawaited(_reconnectRealtimeNow());
    }
  }

  Future<void> _connectRealtime() async {
    if (_disposed || _connecting || _socket != null || _orderId == null) {
      return;
    }
    _connecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    try {
      final token = await _storage.getToken();
      if (_disposed || _orderId == null) {
        return;
      }
      if (token == null || token.isEmpty) {
        _scheduleRealtimeReconnect();
        return;
      }

      final wsUrl = _ordersStreamUri(token: token, orderId: _orderId);
      final socket = await WebSocket.connect(wsUrl.toString());
      socket.pingInterval = const Duration(seconds: 20);
      if (_disposed || _orderId == null) {
        await socket.close();
        return;
      }

      _socket = socket;
      _reconnectAttempt = 0;
      _socketSubscription = socket.listen(
        _onRealtimeMessage,
        onDone: () => unawaited(_handleRealtimeSocketClosed()),
        onError: (_) => unawaited(_handleRealtimeSocketClosed()),
        cancelOnError: true,
      );
    } catch (error) {
      final statusCode = _extractAuthStatusCode(error);
      if (statusCode == 401 || statusCode == 403) {
        unawaited(_expireSession());
      } else {
        _scheduleRealtimeReconnect();
      }
    } finally {
      _connecting = false;
    }
  }

  void _onRealtimeMessage(dynamic rawMessage) {
    final authStatusCode = _extractRealtimeAuthStatusCode(rawMessage);
    if (authStatusCode == 401 || authStatusCode == 403) {
      unawaited(_expireSession());
      return;
    }

    final order = _parseOrderUpdate(rawMessage);
    if (order == null || order.id != _orderId) {
      return;
    }
    applyRealtimeOrderUpdate(order);
  }

  Future<void> _handleRealtimeSocketClosed() async {
    await _disconnectRealtimeSocketOnly();
    if (!_disposed && _orderId != null) {
      _scheduleRealtimeReconnect();
    }
  }

  void _scheduleRealtimeReconnect() {
    if (_reconnectTimer != null || _disposed || _orderId == null) {
      return;
    }
    final delay = _reconnectDelay(_reconnectAttempt);
    _reconnectAttempt++;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(_connectRealtime());
    });
  }

  Future<void> _disconnectRealtimeSocketOnly() async {
    final subscription = _socketSubscription;
    _socketSubscription = null;
    await subscription?.cancel();

    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  Future<void> _reconnectRealtimeNow() async {
    await _disconnectRealtimeSocketOnly();
    _scheduleRealtimeReconnect();
    if (_reconnectTimer != null) {
      _reconnectTimer!.cancel();
      _reconnectTimer = null;
    }
    await _connectRealtime();
  }

  Future<void> _stopRealtime() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _disconnectRealtimeSocketOnly();
  }

  Future<void> _expireSession() async {
    if (_disposed) return;
    _orderId = null;
    await _stopRealtime();
    _ref.read(isAuthenticatedProvider.notifier).state = false;
    _ref.read(authTokenProvider.notifier).state = null;
    await _storage.clearTokens();
    state = AsyncState.error('Session expired. Please log in again.');
  }

  void applyRealtimeOrderUpdate(OrderModel updatedOrder) {
    state = AsyncState.loaded(updatedOrder);
    _ref.read(ordersListProvider.notifier).upsertOrder(updatedOrder);
  }

  Future<void> load(String id) => execute(() => _repository.getOrderById(id));

  Future<Result<OrderModel>> _runMutation(
    Future<Result<OrderModel>> Function() mutation,
  ) async {
    state = AsyncState.loading();
    final result = await mutation();
    result.when(
      success: (updatedOrder) => state = AsyncState.loaded(updatedOrder),
      failure: (message, _) => state = AsyncState.error(message),
    );
    return result;
  }

  Future<Result<OrderModel>> assignDriver(
    String driverId, {
    String? driverName,
  }) async {
    final currentOrder = currentData;
    if (currentOrder == null) {
      return Result.failure('Order not loaded');
    }
    final trimmedDriverId = driverId.trim();
    if (trimmedDriverId.isEmpty) {
      return Result.failure('Invalid driver ID format.');
    }

    final optimisticOrder = currentOrder.copyWith(
      assignedDriverId: trimmedDriverId,
      assignedDriverName: driverName ?? currentOrder.assignedDriverName,
    );
    state = AsyncState.loaded(optimisticOrder);
    _ref.read(ordersListProvider.notifier).upsertOrder(optimisticOrder);

    final result = await _repository.assignDriver(
      currentOrder.id,
      trimmedDriverId,
      currentOrder: optimisticOrder,
    );
    result.when(
      success: (updatedOrder) {
        state = AsyncState.loaded(updatedOrder);
        _ref.read(ordersListProvider.notifier).upsertOrder(updatedOrder);
      },
      failure: (_, __) {
        state = AsyncState.loaded(currentOrder);
        _ref.read(ordersListProvider.notifier).upsertOrder(currentOrder);
      },
    );
    return result;
  }

  Future<Result<OrderModel>> markInTransit() async {
    final currentOrder = currentData;
    if (currentOrder == null) {
      return Result.failure('Order not loaded');
    }
    return _runMutation(() => _repository.markInTransit(currentOrder.id));
  }

  Future<Result<OrderModel>> markFailed(String reason) async {
    final currentOrder = currentData;
    if (currentOrder == null) {
      return Result.failure('Order not loaded');
    }
    return _runMutation(() => _repository.markFailed(currentOrder.id, reason));
  }

  Future<Result<OrderModel>> submitProofOfDelivery({
    required String imageUrl,
    String? notes,
    String? signatureUrl,
    String? recipientName,
  }) async {
    final currentOrder = currentData;
    if (currentOrder == null) {
      return Result.failure('Order not loaded');
    }
    return _runMutation(
      () => _repository.submitProofOfDelivery(
        currentOrder.id,
        imageUrl: imageUrl,
        notes: notes,
        signatureUrl: signatureUrl,
        recipientName: recipientName,
      ),
    );
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stopRealtime());
    super.dispose();
  }
}

// ─── Search Recommendations ─────────────────────────────────────────

final ordersSearchRecommendationsProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final repo = ref.read(ordersRepositoryProvider);
      return repo.getSearchRecommendations(query);
    });
