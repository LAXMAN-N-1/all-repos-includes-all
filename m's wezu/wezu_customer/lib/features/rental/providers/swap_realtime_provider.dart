import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../core/constants/api_constants.dart';
import '../../auth/providers/auth_provider.dart';

// ─── Swap event model ────────────────────────────────────────────────

class SwapRealtimeEvent {
  final int swapId;
  final int userId;
  final int stationId;
  final int? dealerId;
  final String status;
  final int? newBatteryId;
  final int? oldBatteryId;
  final double amount;

  const SwapRealtimeEvent({
    required this.swapId,
    required this.userId,
    required this.stationId,
    this.dealerId,
    required this.status,
    this.newBatteryId,
    this.oldBatteryId,
    required this.amount,
  });

  static SwapRealtimeEvent? fromMap(Map<String, dynamic> m) {
    int? _i(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    final swapId = _i(m['swap_id']);
    final userId = _i(m['user_id']);
    final stationId = _i(m['station_id']);
    final status = m['status']?.toString();
    if (swapId == null ||
        userId == null ||
        stationId == null ||
        status == null) {
      return null;
    }
    return SwapRealtimeEvent(
      swapId: swapId,
      userId: userId,
      stationId: stationId,
      dealerId: _i(m['dealer_id']),
      status: status,
      newBatteryId: _i(m['new_battery_id']),
      oldBatteryId: _i(m['old_battery_id']),
      amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─── URI helper ─────────────────────────────────────────────────────

Uri _swapsStreamUri() {
  final apiBase = ApiConstants.apiBaseUrl;
  final apiUri = Uri.parse(apiBase.endsWith('/') ? apiBase : '$apiBase/');
  final wsScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';
  return Uri(
    scheme: wsScheme,
    host: apiUri.host,
    port: apiUri.hasPort ? apiUri.port : null,
    path: '${apiUri.path.replaceAll(RegExp(r'/+$'), '')}/swaps/stream',
  );
}

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return null;
}

Duration _reconnectDelay(int attempt) =>
    Duration(seconds: math.min(30, 1 << attempt.clamp(0, 5)));

String? _supabaseToken() =>
    supabase.Supabase.instance.client.auth.currentSession?.accessToken;

// ─── Controller ─────────────────────────────────────────────────────

class CustomerSwapRealtimeController with WidgetsBindingObserver {
  final Ref _ref;
  final StreamController<SwapRealtimeEvent> _eventsController =
      StreamController<SwapRealtimeEvent>.broadcast();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSub;
  Timer? _reconnectTimer;
  bool _enabled = false;
  bool _connecting = false;
  bool _disposed = false;
  int _reconnectAttempt = 0;

  CustomerSwapRealtimeController(this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Broadcast stream of completed swap events for this user.
  Stream<SwapRealtimeEvent> get swapEvents => _eventsController.stream;

  void setEnabled(bool enabled) {
    if (_disposed || _enabled == enabled) return;
    _enabled = enabled;
    if (_enabled) {
      unawaited(_connect());
    } else {
      unawaited(_disconnect(resetBackoff: true));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled || _disposed) return;
    if (state == AppLifecycleState.resumed) unawaited(_reconnectNow());
  }

  Future<void> _connect() async {
    if (!_enabled || _disposed || _connecting || _socket != null) return;
    _connecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    try {
      final token = _supabaseToken();
      if (!_enabled || _disposed) return;
      if (token == null || token.isEmpty) {
        _scheduleReconnect();
        return;
      }

      final wsUrl = _swapsStreamUri();
      final socket = await WebSocket.connect(
        wsUrl.toString(),
        protocols: ['bearer', token],
      );
      socket.pingInterval = const Duration(seconds: 20);
      if (!_enabled || _disposed) {
        await socket.close();
        return;
      }
      _socket = socket;
      _reconnectAttempt = 0;
      _socketSub = socket.listen(
        _onMessage,
        onDone: () => unawaited(_handleClosed()),
        onError: (_) => unawaited(_handleClosed()),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _onMessage(dynamic raw) {
    try {
      dynamic decoded = raw;
      if (raw is String)
        decoded = jsonDecode(raw);
      else if (raw is List<int>) decoded = jsonDecode(utf8.decode(raw));
      final msg = _asMap(decoded);
      if (msg == null) return;

      final type = (msg['type']?.toString() ?? '').trim().toLowerCase();
      if (type != 'swap_update') return;

      final data = _asMap(msg['data']) ?? msg;
      final event = SwapRealtimeEvent.fromMap(data);
      if (event != null && !_eventsController.isClosed) {
        _eventsController.add(event);
      }
    } catch (_) {}
  }

  Future<void> _handleClosed() async {
    await _disconnectSocketOnly();
    if (_enabled && !_disposed) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null || !_enabled || _disposed) return;
    final delay = _reconnectDelay(_reconnectAttempt);
    _reconnectAttempt++;
    _reconnectTimer = Timer(delay, () {
      _reconnectTimer = null;
      unawaited(_connect());
    });
  }

  Future<void> _reconnectNow() async {
    await _disconnectSocketOnly();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _connect();
  }

  Future<void> _disconnectSocketOnly() async {
    final sub = _socketSub;
    _socketSub = null;
    await sub?.cancel();
    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  Future<void> _disconnect({bool resetBackoff = false}) async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    if (resetBackoff) _reconnectAttempt = 0;
    await _disconnectSocketOnly();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _eventsController.close();
    unawaited(_disconnect(resetBackoff: true));
  }
}

// ─── Providers ──────────────────────────────────────────────────────

final customerSwapRealtimeControllerProvider =
    Provider<CustomerSwapRealtimeController>((ref) {
  final controller = CustomerSwapRealtimeController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Bootstrap: watch in the root widget or a persistent shell widget.
final customerSwapRealtimeBootstrapProvider = Provider<void>((ref) {
  final controller = ref.watch(customerSwapRealtimeControllerProvider);
  final authState = ref.watch(authProvider);
  controller.setEnabled(authState.isAuthenticated);
});

/// Latest swap event stream — use in UI widgets to react to swap completions.
/// Example: listen in order tracking screen to refresh status on swap_update.
final swapRealtimeEventsProvider = StreamProvider<SwapRealtimeEvent>((ref) {
  final controller = ref.watch(customerSwapRealtimeControllerProvider);
  return controller.swapEvents;
});
