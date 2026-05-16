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
import '../../../models/battery_model.dart';
import '../repository/inventory_repository.dart';

// ─── Repository ─────────────────────────────────────────────────────

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(api: ref.read(apiClientProvider));
});

// ─── Stats Provider ─────────────────────────────────────────────────

final inventoryStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(inventoryRepositoryProvider);
  final result = await repository.fetchInventoryStats();
  return result.when(
    success: (stats) => stats,
    failure: (_, __) => {
      'total': 0,
      'available': 0,
      'charging': 0,
      'deployed': 0,
      'faulty': 0,
      'maintenance': 0,
      'low_health': 0,
      'warranty_expiring': 0,
    },
  );
});

// ─── Filter, Search & Sort State ────────────────────────────────────

/// Currently selected filter (null = All).
final inventoryFilterProvider = StateProvider<BatteryStatus?>((ref) {
  return null;
});

/// Search query text.
final inventorySearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Sort option: 'id', 'charge', 'date'.
final inventorySortProvider = StateProvider<String>((ref) => 'id');

/// Sort order: 'asc', 'desc'.
final inventorySortOrderProvider = StateProvider<String>((ref) => 'asc');

/// View mode: true = List, false = Grid.
final inventoryViewModeProvider = StateProvider<bool>((ref) => true);

// ─── Battery Detail Provider ────────────────────────────────────────

// ─── Battery Detail Provider ────────────────────────────────────────
// Moved to bottom of file

// ─── Battery List Provider ──────────────────────────────────────────

final inventoryListProvider =
    StateNotifierProvider<
      InventoryListNotifier,
      AsyncState<List<BatteryModel>>
    >((ref) {
      final notifier = InventoryListNotifier(
        ref.read(inventoryRepositoryProvider),
      );

      // Auto-reload when filter, search, or sort changes
      void reload() {
        notifier.loadBatteries(
          filter: ref.read(inventoryFilterProvider),
          searchQuery: ref.read(inventorySearchQueryProvider),
          sortBy: ref.read(inventorySortProvider),
          sortOrder: ref.read(inventorySortOrderProvider),
        );
      }

      ref.listen(inventoryFilterProvider, (_, __) => reload());
      ref.listen(inventorySearchQueryProvider, (_, __) => reload());
      ref.listen(inventorySortProvider, (_, __) => reload());
      ref.listen(inventorySortOrderProvider, (_, __) => reload());

      return notifier;
    });

class InventoryListNotifier extends BasePaginatedNotifier<BatteryModel> {
  final InventoryRepository _repository;
  BatteryStatus? _currentFilter;
  String _currentSearch = '';
  String _currentSortBy = 'id';
  String _currentSortOrder = 'asc';

  InventoryListNotifier(this._repository);

  /// Load first page of batteries.
  Future<void> loadBatteries({
    BatteryStatus? filter,
    String? searchQuery,
    String sortBy = 'id',
    String sortOrder = 'asc',
  }) {
    _currentFilter = filter;
    _currentSearch = searchQuery ?? '';
    _currentSortBy = sortBy;
    _currentSortOrder = sortOrder;

    return loadPage(
      (page) => _repository.fetchBatteries(
        page: page,
        filter: _currentFilter,
        searchQuery: _currentSearch.isNotEmpty ? _currentSearch : null,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      ),
    );
  }

  /// Load next page of batteries.
  Future<void> loadMore() {
    return loadNextPage(
      (page) => _repository.fetchBatteries(
        page: page,
        filter: _currentFilter,
        searchQuery: _currentSearch.isNotEmpty ? _currentSearch : null,
        sortBy: _currentSortBy,
        sortOrder: _currentSortOrder,
      ),
    );
  }

  /// Update a battery's status locally (optimistic) and on server.
  Future<void> updateStatus(String batteryId, BatteryStatus newStatus) async {
    // Optimistic update
    updateItem((b) => b.id == batteryId, (b) => b.copyWith(status: newStatus));

    // Server update
    final result = await _repository.updateBatteryStatus(batteryId, newStatus);
    result.when(
      success: (updated) {
        updateItem((b) => b.id == batteryId, (_) => updated);
      },
      failure: (message, code) {
        // Revert — reload from server
        loadBatteries(
          filter: _currentFilter,
          searchQuery: _currentSearch,
          sortBy: _currentSortBy,
          sortOrder: _currentSortOrder,
        );
      },
    );
  }
}

// ─── Single Battery Detail ──────────────────────────────────────────

final batteryDetailProvider =
    StateNotifierProvider.family<
      BatteryDetailNotifier,
      AsyncState<BatteryModel>,
      String
    >((ref, batteryId) {
      final notifier = BatteryDetailNotifier(
        ref.read(inventoryRepositoryProvider),
      );
      notifier.load(batteryId);
      return notifier;
    });

class BatteryDetailNotifier extends BaseNotifier<BatteryModel> {
  final InventoryRepository _repository;

  BatteryDetailNotifier(this._repository);

  Future<void> load(String id) => execute(() => _repository.getBatteryById(id));
}

Map<String, dynamic>? _asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

Duration _inventoryReconnectDelay(int attempt) {
  final boundedAttempt = attempt.clamp(0, 5);
  return Duration(seconds: math.min(30, 1 << boundedAttempt));
}

bool _canUseInventoryRealtime(String? role) {
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

Uri _inventoryStreamUri({required String token}) {
  final apiUri = Uri.parse(AppConstants.apiBaseUrl);
  final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
  final basePath = apiUri.path.replaceAll(RegExp(r'/+$'), '');
  return Uri(
    scheme: wsScheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
    path: '$basePath/orders/stream',
    queryParameters: {'token': token},
  );
}

class InventoryLocationRef {
  final String locationType;
  final int locationId;

  factory InventoryLocationRef({
    required String locationType,
    required int locationId,
  }) {
    return InventoryLocationRef._(
      locationType: locationType.trim().toLowerCase(),
      locationId: locationId,
    );
  }

  const InventoryLocationRef._({
    required this.locationType,
    required this.locationId,
  });

  String get key => '$locationType:$locationId';

  static InventoryLocationRef? fromMap(Map<String, dynamic> map) {
    final rawType = map['location_type'];
    final locationType = rawType?.toString().trim().toLowerCase();
    final locationId = _asInt(map['location_id']);
    if (locationType == null || locationType.isEmpty || locationId == null) {
      return null;
    }
    return InventoryLocationRef(
      locationType: locationType,
      locationId: locationId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryLocationRef &&
        other.locationType == locationType &&
        other.locationId == locationId;
  }

  @override
  int get hashCode => Object.hash(locationType, locationId);
}

class InventoryRealtimeUpdate {
  final String eventType;
  final int? transferId;
  final String? transferStatus;
  final List<String> batteryIds;
  final Set<InventoryLocationRef> affectedLocations;

  const InventoryRealtimeUpdate({
    required this.eventType,
    required this.transferId,
    required this.transferStatus,
    required this.batteryIds,
    required this.affectedLocations,
  });
}

InventoryRealtimeUpdate? _parseInventoryRealtimeUpdate(
  Map<String, dynamic> message,
) {
  if (message['type'] != 'inventory_update') {
    return null;
  }

  final data = _asStringKeyedMap(message['data']);
  if (data == null) {
    return null;
  }

  final rawEventType = data['event_type']?.toString();
  final eventType = rawEventType?.trim().toLowerCase();
  if (eventType == null || eventType.isEmpty) {
    return null;
  }

  final affectedLocations = <InventoryLocationRef>{};
  final rawLocations = data['affected_locations'];
  if (rawLocations is List) {
    for (final item in rawLocations) {
      final map = _asStringKeyedMap(item);
      if (map == null) continue;
      final location = InventoryLocationRef.fromMap(map);
      if (location != null) {
        affectedLocations.add(location);
      }
    }
  }

  final rawBatteryIds = data['battery_ids'];
  final batteryIds = rawBatteryIds is List
      ? rawBatteryIds.map((item) => item.toString()).toList()
      : const <String>[];

  return InventoryRealtimeUpdate(
    eventType: eventType,
    transferId: _asInt(data['transfer_id']),
    transferStatus: data['transfer_status']?.toString(),
    batteryIds: batteryIds,
    affectedLocations: affectedLocations,
  );
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

class InventoryLocationRealtimeController with WidgetsBindingObserver {
  final Ref _ref;
  final StreamController<InventoryRealtimeUpdate> _updatesController =
      StreamController<InventoryRealtimeUpdate>.broadcast();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  Timer? _reconnectTimer;
  bool _enabled = false;
  bool _connecting = false;
  bool _disposed = false;
  bool _streamReady = false;
  bool _supportsInventorySubscriptions = false;
  int _reconnectAttempt = 0;
  final Set<InventoryLocationRef> _activeSubscriptions = {};

  InventoryLocationRealtimeController(this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  Stream<InventoryRealtimeUpdate> get updates => _updatesController.stream;

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

  void subscribeLocation(InventoryLocationRef location) {
    if (_disposed) return;
    if (_activeSubscriptions.add(location)) {
      _sendLocationSubscriptionCommand(
        'subscribe_inventory_location',
        location,
      );
    }
  }

  void unsubscribeLocation(InventoryLocationRef location) {
    if (_disposed) return;
    if (_activeSubscriptions.remove(location)) {
      _sendLocationSubscriptionCommand(
        'unsubscribe_inventory_location',
        location,
      );
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

  void _sendLocationSubscriptionCommand(
    String command,
    InventoryLocationRef location,
  ) {
    final socket = _socket;
    if (socket == null || !_streamReady || !_supportsInventorySubscriptions) {
      return;
    }

    try {
      socket.add(
        jsonEncode({
          'command': command,
          'location_type': location.locationType,
          'location_id': location.locationId,
        }),
      );
    } catch (_) {
      // Command send failures are recovered by reconnect + resubscribe.
    }
  }

  void _resubscribeActiveLocations() {
    for (final location in _activeSubscriptions) {
      _sendLocationSubscriptionCommand(
        'subscribe_inventory_location',
        location,
      );
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

      final wsUrl = _inventoryStreamUri(token: token);
      final socket = await WebSocket.connect(wsUrl.toString());
      socket.pingInterval = const Duration(seconds: 20);
      if (!_enabled || _disposed) {
        await socket.close();
        return;
      }

      _socket = socket;
      _streamReady = false;
      _supportsInventorySubscriptions = false;
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
    try {
      dynamic decoded = rawMessage;
      if (rawMessage is String) {
        decoded = jsonDecode(rawMessage);
      } else if (rawMessage is List<int>) {
        decoded = jsonDecode(utf8.decode(rawMessage));
      }

      final message = _asStringKeyedMap(decoded);
      if (message == null) return;
      final type = (message['type']?.toString() ?? '').trim().toLowerCase();
      if (type.isEmpty) return;

      final statusCode =
          _asInt(message['status_code']) ??
          _asInt(message['status']) ??
          _asInt(message['code']);
      if (statusCode == 401 || statusCode == 403) {
        unawaited(_expireSession());
        return;
      }

      if (type == 'orders_stream_ready') {
        _streamReady = true;
        _supportsInventorySubscriptions =
            message['supports_inventory_location_subscriptions'] == true;
        if (_supportsInventorySubscriptions) {
          _resubscribeActiveLocations();
        }
        return;
      }

      if (type == 'inventory_update') {
        final update = _parseInventoryRealtimeUpdate(message);
        if (update != null) {
          _updatesController.add(update);
        }
        return;
      }

      if (type == 'inventory_subscription_error') {
        final data = _asStringKeyedMap(message['data']);
        final nestedStatusCode =
            _asInt(data?['status_code']) ??
            _asInt(data?['status']) ??
            _asInt(data?['code']);
        if (nestedStatusCode == 401 || nestedStatusCode == 403) {
          unawaited(_expireSession());
        }
      }
    } catch (_) {
      // Ignore malformed frames.
    }
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
    final delay = _inventoryReconnectDelay(_reconnectAttempt);
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
    _streamReady = false;
    _supportsInventorySubscriptions = false;
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
    if (_disposed) {
      return;
    }
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
    _updatesController.close();
    unawaited(_disconnect(resetBackoff: true));
  }
}

final inventoryRealtimeControllerProvider =
    Provider<InventoryLocationRealtimeController>((ref) {
      final controller = InventoryLocationRealtimeController(ref);
      ref.onDispose(controller.dispose);
      return controller;
    });

final inventoryRealtimeBootstrapProvider = Provider<void>((ref) {
  final controller = ref.watch(inventoryRealtimeControllerProvider);
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final currentUser = ref.watch(currentUserProvider);
  final shouldEnable =
      isAuthenticated && _canUseInventoryRealtime(currentUser?.role);
  controller.setEnabled(shouldEnable);
});

const Object _locationStateUnset = Object();

class TransferLocationBatteriesState {
  final InventoryLocationRef? sourceLocation;
  final InventoryLocationRef? destinationLocation;
  final Map<String, List<BatteryModel>> batteriesByLocation;
  final Set<String> loadingLocationKeys;
  final Map<String, String> errorsByLocation;

  const TransferLocationBatteriesState({
    this.sourceLocation,
    this.destinationLocation,
    this.batteriesByLocation = const {},
    this.loadingLocationKeys = const {},
    this.errorsByLocation = const {},
  });

  TransferLocationBatteriesState copyWith({
    Object? sourceLocation = _locationStateUnset,
    Object? destinationLocation = _locationStateUnset,
    Map<String, List<BatteryModel>>? batteriesByLocation,
    Set<String>? loadingLocationKeys,
    Map<String, String>? errorsByLocation,
  }) {
    return TransferLocationBatteriesState(
      sourceLocation: identical(sourceLocation, _locationStateUnset)
          ? this.sourceLocation
          : sourceLocation as InventoryLocationRef?,
      destinationLocation: identical(destinationLocation, _locationStateUnset)
          ? this.destinationLocation
          : destinationLocation as InventoryLocationRef?,
      batteriesByLocation: batteriesByLocation ?? this.batteriesByLocation,
      loadingLocationKeys: loadingLocationKeys ?? this.loadingLocationKeys,
      errorsByLocation: errorsByLocation ?? this.errorsByLocation,
    );
  }

  List<BatteryModel> batteriesFor(InventoryLocationRef? location) {
    if (location == null) return const [];
    return batteriesByLocation[location.key] ?? const [];
  }

  bool isLoadingFor(InventoryLocationRef? location) {
    if (location == null) return false;
    return loadingLocationKeys.contains(location.key);
  }

  String? errorFor(InventoryLocationRef? location) {
    if (location == null) return null;
    return errorsByLocation[location.key];
  }
}

final transferLocationBatteriesProvider =
    StateNotifierProvider.autoDispose<
      TransferLocationBatteriesNotifier,
      TransferLocationBatteriesState
    >((ref) {
      final notifier = TransferLocationBatteriesNotifier(
        repository: ref.read(inventoryRepositoryProvider),
        realtimeController: ref.read(inventoryRealtimeControllerProvider),
      );
      ref.onDispose(notifier.dispose);
      return notifier;
    });

class TransferLocationBatteriesNotifier
    extends StateNotifier<TransferLocationBatteriesState> {
  final InventoryRepository _repository;
  final InventoryLocationRealtimeController _realtimeController;
  final Map<String, Future<void>> _inFlightByKey = {};
  final Map<String, Timer> _debounceByKey = {};
  StreamSubscription<InventoryRealtimeUpdate>? _realtimeSubscription;
  bool _disposed = false;

  TransferLocationBatteriesNotifier({
    required InventoryRepository repository,
    required InventoryLocationRealtimeController realtimeController,
  }) : _repository = repository,
       _realtimeController = realtimeController,
       super(const TransferLocationBatteriesState()) {
    _realtimeSubscription = _realtimeController.updates.listen(
      _handleInventoryUpdate,
    );
  }

  Set<InventoryLocationRef> get _trackedLocations => {
    if (state.sourceLocation != null) state.sourceLocation!,
    if (state.destinationLocation != null) state.destinationLocation!,
  };

  Future<void> setTrackedLocations({
    InventoryLocationRef? sourceLocation,
    InventoryLocationRef? destinationLocation,
  }) async {
    if (_disposed) return;

    final previous = _trackedLocations;
    final next = <InventoryLocationRef>{
      if (sourceLocation != null) sourceLocation,
      if (destinationLocation != null) destinationLocation,
    };

    state = state.copyWith(
      sourceLocation: sourceLocation,
      destinationLocation: destinationLocation,
    );

    for (final removed in previous) {
      if (!next.contains(removed)) {
        _realtimeController.unsubscribeLocation(removed);
        _debounceByKey.remove(removed.key)?.cancel();
      }
    }
    for (final location in next) {
      if (!previous.contains(location)) {
        _realtimeController.subscribeLocation(location);
      }
      unawaited(refetchLocation(location));
    }

    _pruneStaleLocationState(next);
  }

  Future<void> clearTrackedLocations() async {
    if (_disposed) return;

    final tracked = _trackedLocations;
    for (final location in tracked) {
      _realtimeController.unsubscribeLocation(location);
      _debounceByKey.remove(location.key)?.cancel();
    }

    state = state.copyWith(
      sourceLocation: null,
      destinationLocation: null,
      batteriesByLocation: const {},
      loadingLocationKeys: const {},
      errorsByLocation: const {},
    );
  }

  Future<void> safetyRefetchAfterTransferCreate({
    required InventoryLocationRef sourceLocation,
  }) {
    return refetchLocation(sourceLocation);
  }

  Future<void> safetyRefetchAfterTransferLifecycle({
    required InventoryLocationRef sourceLocation,
    required InventoryLocationRef destinationLocation,
  }) async {
    await Future.wait([
      refetchLocation(sourceLocation),
      refetchLocation(destinationLocation),
    ]);
  }

  Future<void> refetchLocation(
    InventoryLocationRef location, {
    bool debounced = false,
  }) async {
    if (_disposed) return;
    if (debounced) {
      _debounceByKey[location.key]?.cancel();
      _debounceByKey[location.key] = Timer(
        const Duration(milliseconds: 250),
        () {
          _debounceByKey.remove(location.key);
          unawaited(_performRefetch(location));
        },
      );
      return;
    }
    await _performRefetch(location);
  }

  Future<void> _performRefetch(InventoryLocationRef location) async {
    final key = location.key;
    final inFlight = _inFlightByKey[key];
    if (inFlight != null) {
      return inFlight;
    }

    final future = _fetchLocation(location);
    _inFlightByKey[key] = future;
    try {
      await future;
    } finally {
      _inFlightByKey.remove(key);
    }
  }

  Future<void> _fetchLocation(InventoryLocationRef location) async {
    if (_disposed) return;

    final key = location.key;
    final loadingKeys = Set<String>.from(state.loadingLocationKeys)..add(key);
    state = state.copyWith(loadingLocationKeys: loadingKeys);

    final result = await _repository.getLocationBatteries(
      location.locationType,
      location.locationId,
      status: 'available',
      skip: 0,
      limit: 500,
    );

    if (_disposed) return;

    result.when(
      success: (batteries) {
        final sorted = List<BatteryModel>.from(batteries)
          ..sort((a, b) => a.serialNumber.compareTo(b.serialNumber));
        final byLocation = Map<String, List<BatteryModel>>.from(
          state.batteriesByLocation,
        );
        byLocation[key] = sorted;
        final nextLoading = Set<String>.from(state.loadingLocationKeys)
          ..remove(key);
        final nextErrors = Map<String, String>.from(state.errorsByLocation)
          ..remove(key);
        state = state.copyWith(
          batteriesByLocation: byLocation,
          loadingLocationKeys: nextLoading,
          errorsByLocation: nextErrors,
        );
      },
      failure: (message, _) {
        final nextLoading = Set<String>.from(state.loadingLocationKeys)
          ..remove(key);
        final nextErrors = Map<String, String>.from(state.errorsByLocation)
          ..[key] = message;
        state = state.copyWith(
          loadingLocationKeys: nextLoading,
          errorsByLocation: nextErrors,
        );
      },
    );
  }

  void _handleInventoryUpdate(InventoryRealtimeUpdate update) {
    if (_disposed || update.affectedLocations.isEmpty) {
      return;
    }
    final tracked = _trackedLocations;
    if (tracked.isEmpty) {
      return;
    }

    for (final location in tracked) {
      if (update.affectedLocations.contains(location)) {
        unawaited(refetchLocation(location, debounced: true));
      }
    }
  }

  void _pruneStaleLocationState(Set<InventoryLocationRef> activeLocations) {
    final activeKeys = activeLocations.map((location) => location.key).toSet();
    final byLocation = Map<String, List<BatteryModel>>.from(
      state.batteriesByLocation,
    )..removeWhere((key, _) => !activeKeys.contains(key));
    final loadingKeys = Set<String>.from(state.loadingLocationKeys)
      ..removeWhere((key) => !activeKeys.contains(key));
    final errors = Map<String, String>.from(state.errorsByLocation)
      ..removeWhere((key, _) => !activeKeys.contains(key));
    state = state.copyWith(
      batteriesByLocation: byLocation,
      loadingLocationKeys: loadingKeys,
      errorsByLocation: errors,
    );
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    final tracked = _trackedLocations;
    for (final location in tracked) {
      _realtimeController.unsubscribeLocation(location);
    }
    for (final timer in _debounceByKey.values) {
      timer.cancel();
    }
    _debounceByKey.clear();
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
