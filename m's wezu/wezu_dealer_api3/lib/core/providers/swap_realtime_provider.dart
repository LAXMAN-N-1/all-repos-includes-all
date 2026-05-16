import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../api/api_client.dart';
import 'auth_provider.dart';
import '../../features/stations/providers/stations_provider.dart';
import '../../features/stations/providers/station_detail_provider.dart';

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

// ─── Helpers ────────────────────────────────────────────────────────

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return null;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

Duration _reconnectDelay(int attempt) =>
    Duration(seconds: math.min(30, 1 << attempt.clamp(0, 5)));

String? _supabaseToken() =>
    supabase.Supabase.instance.client.auth.currentSession?.accessToken;

// ─── Controller ─────────────────────────────────────────────────────

class SwapRealtimeController with WidgetsBindingObserver {
  final Ref _ref;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSub;
  Timer? _reconnectTimer;
  bool _enabled = false;
  bool _connecting = false;
  bool _disposed = false;
  bool _streamReady = false;
  int _reconnectAttempt = 0;
  List<int> _dealerStationIds = [];

  SwapRealtimeController(this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

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
      _streamReady = false;
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
      if (raw is String) decoded = jsonDecode(raw);
      else if (raw is List<int>) decoded = jsonDecode(utf8.decode(raw));
      final msg = _asMap(decoded);
      if (msg == null) return;

      final type = (msg['type']?.toString() ?? '').trim().toLowerCase();

      switch (type) {
        case 'swaps_stream_ready':
          _streamReady = true;
          final ids = msg['dealer_station_ids'];
          if (ids is List) {
            _dealerStationIds =
                ids.map((e) => _asInt(e)).whereType<int>().toList();
          }
          break;

        case 'swap_update':
          _handleSwapUpdate(msg);
          break;

        case 'inventory_update':
          _handleInventoryUpdate(msg);
          break;
      }
    } catch (_) {}
  }

  void _handleSwapUpdate(Map<String, dynamic> msg) {
    final data = _asMap(msg['data']) ?? msg;
    final stationId = _asInt(data['station_id']);

    // Refresh swap state for the affected station (and global view).
    _ref.invalidate(swapStateProvider(stationId));
    _ref.invalidate(swapStateProvider(null));
    if (stationId != null) {
      _ref.invalidate(dealerSwapsListProvider(stationId));
    }
    _ref.invalidate(dealerSwapsListProvider(null));
  }

  void _handleInventoryUpdate(Map<String, dynamic> msg) {
    final data = _asMap(msg['data']) ?? msg;
    final stationId = _asInt(data['station_id']);

    final availableBatteries = _asInt(data['available_batteries']);
    final availableSlots = _asInt(data['available_slots']);

    // Patch in-memory station list.
    final stationState = _ref.read(stationsProvider);
    final stations = stationState.stations;
    if (stationId != null && (availableBatteries != null || availableSlots != null)) {
      final updated = stations.map((s) {
        if (s.id != stationId) return s;
        return s.copyWith(
          availableBatteries:
              availableBatteries ?? s.availableBatteries,
          availableSlots: availableSlots ?? s.availableSlots,
        );
      }).toList();
      _ref.read(stationsProvider.notifier).state =
          stationState.copyWith(stations: updated);
    }

    // Also invalidate per-station battery provider to force refetch.
    if (stationId != null) {
      _ref.invalidate(dealerBatteriesProvider(stationId));
    }
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
    _streamReady = false;
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
    unawaited(_disconnect(resetBackoff: true));
  }
}

// ─── Providers ──────────────────────────────────────────────────────

final swapRealtimeControllerProvider =
    Provider<SwapRealtimeController>((ref) {
  final controller = SwapRealtimeController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

/// Activate by watching in the top-level widget:
///   `ref.watch(swapRealtimeBootstrapProvider);`
final swapRealtimeBootstrapProvider = Provider<void>((ref) {
  final controller = ref.watch(swapRealtimeControllerProvider);
  final authState = ref.watch(authProvider);
  controller.setEnabled(authState.isAuthenticated);
});
