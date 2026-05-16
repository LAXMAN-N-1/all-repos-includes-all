import 'dart:developer' show log;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/station_state.dart';
import 'stations_provider.dart';

// ── Dealer Quick Stats Provider ─────────────────────────────
// Stats are derived from the already-loaded stations list.
// The backend does not expose a dedicated /dealers/stations/stats endpoint
// on this deployment — aggregating from /dealers/stations is equivalent.
final dealerQuickStatsProvider = Provider<DealerStatsDto>((ref) {
  final stationState = ref.watch(stationsProvider);
  final stations = stationState.stations;
  final avgRating = stations.isEmpty
      ? 0.0
      : stations.fold(0.0, (sum, s) => sum + s.rating) / stations.length;
  return DealerStatsDto(
    availableBatteries:
        stations.fold(0, (sum, s) => sum + s.availableBatteries),
    totalBatteries: stations.fold(0, (sum, s) => sum + s.maxCapacity),
    ongoingRentals: stations.fold(0, (sum, s) => sum + s.ongoingRentals),
    currentSwaps: stations.fold(0, (sum, s) => sum + s.activeSwaps),
    avgRating: avgRating,
    stationCount: stations.length,
  );
});

// ── Dealer Batteries Provider ───────────────────────────────
// NOTE: /dealers/stations/batteries?station_id=X returns 422 because the
// backend router parses "batteries" as the {station_id} path parameter.
// Use /dealers/me/inventory instead and filter by station_id client-side.
final dealerBatteriesProvider =
    FutureProvider.family<List<BatteryDto>, int?>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get(
      ApiConstants.inventory,
      queryParameters: {'limit': 200, 'page': 1},
    );
    final rawData = res.data;
    List rawList = [];
    if (rawData is Map) {
      final inner = rawData['data'];
      if (inner is Map) {
        rawList = (inner['batteries'] ?? inner['items'] ?? []) as List;
      } else if (inner is List) {
        rawList = inner;
      }
    } else if (rawData is List) {
      rawList = rawData;
    }
    final all = rawList.whereType<Map>().map((e) => BatteryDto(
          id: (e['battery_id'] ?? e['id'] ?? 0) as int,
          serialNumber: e['serial_number']?.toString() ?? '',
          stationName: e['station_name']?.toString() ?? '',
          stationId: (e['station_id'] ?? 0) as int,
          status: e['current_status']?.toString() ?? e['status']?.toString() ?? 'available',
          chargePercentage: (e['charge_level'] ?? e['current_charge'] ?? 100.0 as num).toDouble(),
          healthPercentage: (e['health_percentage'] ?? e['health'] ?? 100.0 as num).toDouble(),
          cycleCount: (e['cycle_count'] ?? 0) as int,
          batteryType: e['battery_type']?.toString() ?? '',
          currentCustomer: e['current_customer']?.toString(),
          rentalStartTime: e['rental_start_time']?.toString(),
          lastRental: e['last_rental']?.toString(),
          daysIdle: (e['days_idle'] ?? 0) as int,
          faultDescription: e['fault_reason']?.toString() ?? e['fault_description']?.toString(),
          lastChargedAt: e['last_charged_at']?.toString(),
          createdAt: e['created_at']?.toString(),
        )).toList();
    // Filter by station client-side if requested
    if (stationId != null) {
      return all.where((b) => b.stationId == stationId).toList();
    }
    return all;
  } catch (e) {
    log('DealerBatteries error: $e');
    rethrow;
  }
});

// ── Active Rentals Provider ─────────────────────────────────
final activeRentalsProvider =
    FutureProvider.family<List<ActiveRentalDto>, int?>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final params = <String, dynamic>{};
    if (stationId != null) params['station_id'] = stationId;
    final res = await dio.get(ApiConstants.dealerActiveRentals,
        queryParameters: params);
    final rawData2 = res.data;
    final rawList = rawData2 is List
        ? rawData2
        : (rawData2 is Map ? (rawData2['data'] is List ? rawData2['data'] as List : []) : <dynamic>[]);
    return rawList
        .map((e) => ActiveRentalDto(
              id: e['id'] ?? 0,
              customerName: e['customer_name']?.toString() ?? 'Unknown',
              customerPhone: e['customer_phone']?.toString() ?? '',
              customerInitial: (e['customer_name']?.toString() ?? 'U')
                  .substring(0, 1)
                  .toUpperCase(),
              batteryCode: e['battery_code']?.toString() ?? '',
              batteryId: e['battery_id'] ?? 0,
              stationName: e['station_name']?.toString() ?? '',
              stationId: e['station_id'] ?? 0,
              startTime: e['start_time']?.toString() ?? '',
              expectedReturn: e['expected_return']?.toString() ?? '',
              totalAmount: (e['total_amount'] ?? 0.0).toDouble(),
              lateFee: (e['late_fee'] ?? 0.0).toDouble(),
              status: e['status']?.toString() ?? 'active',
              durationMinutes: e['duration_minutes'] ?? 0,
            ))
        .toList();
  } catch (e) {
    log('ActiveRentals error: $e');
    rethrow;
  }
});

// ── Station Activity Provider ──────────────────────────────
final stationActivityProvider =
    FutureProvider.family<List<ActivityEventDto>, int>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final res =
        await dio.get('${ApiConstants.dealerStationBase}/$stationId/activity');
    final rawData3 = res.data;
    final rawList = rawData3 is List
        ? rawData3
        : (rawData3 is Map ? (rawData3['data'] is List ? rawData3['data'] as List : []) : <dynamic>[]);
    return rawList
        .map((e) => ActivityEventDto.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    log('StationActivity error: $e');
    rethrow;
  }
});

// ── Station Transactions Provider ──────────────────────────
final stationTransactionsProvider =
    FutureProvider.family<List<TransactionDto>, int>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio
        .get('${ApiConstants.dealerStationBase}/$stationId/transactions');
    final rawData4 = res.data;
    final rawList = rawData4 is List
        ? rawData4
        : (rawData4 is Map ? (rawData4['data'] is List ? rawData4['data'] as List : []) : <dynamic>[]);
    return rawList
        .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    log('StationTransactions error: $e');
    rethrow;
  }
});

// ── Dealer Swaps List Provider ─────────────────────────────
final dealerSwapsListProvider =
    FutureProvider.family<List<SwapDto>, int?>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final params = <String, dynamic>{};
    if (stationId != null) params['station_id'] = stationId;
    final res =
        await dio.get(ApiConstants.dealerSwapsList, queryParameters: params);
    final rawData5 = res.data;
    final rawList = rawData5 is List
        ? rawData5
        : (rawData5 is Map ? (rawData5['data'] is List ? rawData5['data'] as List : rawData5['swaps'] is List ? rawData5['swaps'] as List : []) : <dynamic>[]);
    return rawList
        .map((e) => SwapDto.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    log('DealerSwapsList error: $e');
    rethrow;
  }
});

// ══════════════════════════════════════════════════════════
// SWAP STATE ENGINE — Backend-backed swap + port state
// ══════════════════════════════════════════════════════════

class SwapScreenState {
  final List<StationSwapDataDto> stationData;
  final List<SwapEventDto> events;
  final bool isLive;

  const SwapScreenState({
    this.stationData = const [],
    this.events = const [],
    this.isLive = true,
  });

  SwapScreenState copyWith({
    List<StationSwapDataDto>? stationData,
    List<SwapEventDto>? events,
    bool? isLive,
  }) =>
      SwapScreenState(
        stationData: stationData ?? this.stationData,
        events: events ?? this.events,
        isLive: isLive ?? this.isLive,
      );

  // Aggregate counts
  int get totalPorts => stationData.fold(0, (s, d) => s + d.totalPorts);
  int get activeSwaps => stationData.fold(
      0, (s, d) => s + d.ports.where((p) => p.state == 'active').length);
  int get readyPorts => stationData.fold(
      0, (s, d) => s + d.ports.where((p) => p.state == 'ready').length);
  int get chargingPorts => stationData.fold(
      0, (s, d) => s + d.ports.where((p) => p.state == 'charging').length);
  int get faultPorts => stationData.fold(
      0, (s, d) => s + d.ports.where((p) => p.state == 'fault').length);
}

class SwapStateNotifier extends StateNotifier<SwapScreenState> {
  final Ref _ref;
  final int? _stationId;
  bool _isRefreshing = false;
  int _swapCompletedToday = 0;
  List<int> _hourlySwaps = List.filled(24, 0);

  SwapStateNotifier(this._ref, this._stationId)
      : super(const SwapScreenState()) {
    refresh();
  }

  List<int> get hourlySwaps => List.unmodifiable(_hourlySwaps);
  int get swapCompletedToday => _swapCompletedToday;

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final dio = _ref.read(dioProvider);
      final params = _stationId != null
          ? <String, dynamic>{'station_id': _stationId}
          : null;

      List<dynamic> _safeList(dynamic data) {
        if (data is List) return data;
        if (data is Map) {
          if (data['data'] is List) return data['data'] as List;
          if (data['stations'] is List) return data['stations'] as List;
          if (data['swaps'] is List) return data['swaps'] as List;
          if (data['batteries'] is List) return data['batteries'] as List;
          if (data['rentals'] is List) return data['rentals'] as List;
        }
        return <dynamic>[];
      }

      final stationRes = await dio.get(ApiConstants.stations);
      final stationsRaw = _safeList(stationRes.data)
          .whereType<Map<String, dynamic>>()
          .where((s) => _stationId == null || s['id'] == _stationId)
          .toList();

      final swapsRes =
          await dio.get(ApiConstants.dealerSwapsList, queryParameters: params);
      final swapsRaw = _safeList(swapsRes.data)
          .whereType<Map<String, dynamic>>()
          .toList();

      final rentalsRes = await dio.get(ApiConstants.dealerActiveRentals,
          queryParameters: params);
      final rentalsRaw = _safeList(rentalsRes.data)
          .whereType<Map<String, dynamic>>()
          .toList();

      // NOTE: /dealers/stations/batteries?station_id=X returns 422 because
      // the backend router interprets "batteries" as a station_id path param.
      // Use /dealers/me/inventory instead — same data, correct routing.
      List<Map<String, dynamic>> batteriesRaw = [];
      try {
        final batteriesRes = await dio.get(ApiConstants.inventory,
            queryParameters: params);
        final rawData = batteriesRes.data;
        List rawList = [];
        if (rawData is Map) {
          final inner = rawData['data'];
          if (inner is Map) {
            rawList = (inner['batteries'] ?? inner['items']) as List? ?? [];
          } else if (inner is List) {
            rawList = inner;
          }
        } else if (rawData is List) {
          rawList = rawData;
        }
        batteriesRaw = rawList.whereType<Map<String, dynamic>>().toList();
      } catch (_) {
        // non-fatal — ports will show without battery detail enrichment
      }

      final details = await Future.wait(stationsRaw.map((s) async {
        final sid = s['id'];
        if (sid is! int) return <String, dynamic>{};
        final res = await dio.get('${ApiConstants.stations}/$sid');
        return (res.data as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};
      }));

      final batteryById = <int, Map<String, dynamic>>{};
      for (final b in batteriesRaw) {
        final id = b['id'];
        if (id is int) batteryById[id] = b;
      }

      final activeRentalByBattery = <int, Map<String, dynamic>>{};
      for (final r in rentalsRaw) {
        final bid = r['battery_id'];
        if (bid is int && bid > 0) activeRentalByBattery[bid] = r;
      }

      final stationData = <StationSwapDataDto>[];
      for (final detail in details) {
        final station = (detail['station'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
        final sid = station['id'] is int ? station['id'] as int : 0;
        final sname = station['name']?.toString() ?? 'Station';
        final slotsRaw = (detail['slots'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .toList();

        final ports = <SwapPortDto>[];
        for (final slot in slotsRaw) {
          final portNumber =
              slot['slot_number'] is int ? slot['slot_number'] as int : 0;
          final batteryId =
              slot['battery_id'] is int ? slot['battery_id'] as int : null;
          final battery = batteryId != null ? batteryById[batteryId] : null;
          final rental =
              batteryId != null ? activeRentalByBattery[batteryId] : null;

          final slotStatus = slot['status']?.toString().toLowerCase() ?? '';
          final batteryStatus =
              battery?['status']?.toString().toLowerCase() ?? '';
          final faultDescription = battery?['fault_description']?.toString();

          String state;
          if (rental != null) {
            state = 'active';
          } else if (slotStatus == 'charging' || batteryStatus == 'charging') {
            state = 'charging';
          } else if (slotStatus == 'maintenance' ||
              slotStatus == 'error' ||
              batteryStatus == 'maintenance' ||
              batteryStatus == 'faulty' ||
              batteryStatus == 'retired') {
            state = 'fault';
          } else if (slotStatus == 'ready' ||
              batteryStatus == 'available' ||
              batteryStatus == 'ready') {
            state = 'ready';
          } else if (slotStatus == 'reserved') {
            state = 'reserved';
          } else {
            state = 'offline';
          }

          ports.add(SwapPortDto(
            portNumber: portNumber,
            state: state,
            customerName: rental?['customer_name']?.toString(),
            customerId: rental != null ? 'CUS-${rental['id']}' : null,
            batteryCode: battery?['serial_number']?.toString(),
            chargePercent:
                (battery?['current_charge'] as num?)?.toDouble() ?? 0.0,
            healthPercentage:
                (battery?['health_percentage'] as num?)?.toDouble() ?? 100.0,
            swapStartedAt: rental?['start_time']?.toString(),
            faultCode: faultDescription,
            lastUsedAt: battery?['last_rental']?.toString() ??
                battery?['last_charged_at']?.toString(),
            reservationExpiry: null,
          ));
        }

        final totalPorts = slotsRaw.isNotEmpty
            ? slotsRaw.length
            : (station['total_slots'] is int
                ? station['total_slots'] as int
                : 0);
        stationData.add(StationSwapDataDto(
          stationId: sid,
          stationName: sname,
          ports: ports,
          totalPorts: totalPorts,
          activeSwaps: ports.where((p) => p.state == 'active').length,
          availablePorts: ports.where((p) => p.state == 'ready').length,
        ));
      }

      final events = swapsRaw.map((sw) {
        final status = sw['status']?.toString().toLowerCase() ?? '';
        final customer = sw['customer_name']?.toString() ?? 'Customer';
        final stationName = sw['station_name']?.toString() ?? '';
        String description;
        String eventType;
        if (status.contains('completed') || status.contains('success')) {
          description = 'Swap completed for $customer at $stationName';
          eventType = 'completed';
        } else if (status.contains('fail') || status.contains('error')) {
          description = 'Swap failed for $customer at $stationName';
          eventType = 'fault';
        } else {
          description = 'Swap in progress for $customer at $stationName';
          eventType = 'active';
        }
        return SwapEventDto(
          description: description,
          timestamp: sw['created_at']?.toString() ?? '',
          batteryCode: sw['old_battery_code']?.toString() ?? '',
          stationName: stationName,
          eventType: eventType,
        );
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _hourlySwaps = List.filled(24, 0);
      _swapCompletedToday = 0;
      final now = DateTime.now();
      for (final sw in swapsRaw) {
        final created = DateTime.tryParse(sw['created_at']?.toString() ?? '');
        if (created == null) continue;
        final local = created.toLocal();
        if (local.year == now.year &&
            local.month == now.month &&
            local.day == now.day) {
          _hourlySwaps[local.hour] = _hourlySwaps[local.hour] + 1;
          final status = sw['status']?.toString().toLowerCase() ?? '';
          if (status.contains('completed') || status.contains('success')) {
            _swapCompletedToday++;
          }
        }
      }

      state = state.copyWith(
        stationData: stationData,
        events: events.take(50).toList(),
        isLive: true,
      );
    } catch (e) {
      log('SwapState refresh error: $e');
      state = state.copyWith(isLive: false);
    } finally {
      _isRefreshing = false;
    }
  }

  void markPortFixed(int stationId, int portNumber) {
    _updatePort(
        stationId,
        portNumber,
        (p) => p.copyWith(
              state: 'ready',
              lastUsedAt: DateTime.now().toIso8601String(),
              faultCode: null,
            ));
    _pushEvent(
        'Port #$portNumber manually marked as fixed', stationId, 'resolved');
  }

  void markPortOffline(int stationId, int portNumber) {
    _updatePort(stationId, portNumber, (p) => p.copyWith(state: 'offline'));
    _pushEvent('Port #$portNumber marked offline', stationId, 'warning');
  }

  void reservePort(int stationId, int portNumber, String expiryMinutes) {
    final expiry = DateTime.now()
        .add(Duration(minutes: int.tryParse(expiryMinutes) ?? 15))
        .toIso8601String();
    _updatePort(stationId, portNumber,
        (p) => p.copyWith(state: 'reserved', reservationExpiry: expiry));
    _pushEvent('Port #$portNumber reserved for $expiryMinutes minutes',
        stationId, 'active');
  }

  void _updatePort(int stationId, int portNumber,
      SwapPortDto Function(SwapPortDto) mapPort) {
    final updated = state.stationData.map((sd) {
      if (sd.stationId != stationId) return sd;
      final ports = sd.ports
          .map((p) => p.portNumber == portNumber ? mapPort(p) : p)
          .toList();
      final activeSwaps = ports.where((p) => p.state == 'active').length;
      final availablePorts = ports.where((p) => p.state == 'ready').length;
      return sd.copyWith(
          ports: ports,
          activeSwaps: activeSwaps,
          availablePorts: availablePorts);
    }).toList();
    state = state.copyWith(stationData: updated);
  }

  void _pushEvent(String description, int stationId, String eventType) {
    final stationName = state.stationData
        .firstWhere(
          (s) => s.stationId == stationId,
          orElse: () => const StationSwapDataDto(stationId: 0, stationName: ''),
        )
        .stationName;
    final events = [
      SwapEventDto(
        description: description,
        timestamp: DateTime.now().toIso8601String(),
        stationName: stationName,
        eventType: eventType,
      ),
      ...state.events,
    ].take(50).toList();
    state = state.copyWith(events: events);
  }
}

// ── Provider ────────────────────────────────────────────────
final swapStateProvider =
    StateNotifierProvider.family<SwapStateNotifier, SwapScreenState, int?>(
        (ref, stationId) {
  return SwapStateNotifier(ref, stationId);
});

// ── Reviews Provider ────────────────────────────────────────
final stationReviewsProvider =
    FutureProvider.family<List<ReviewDto>, int?>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final params = <String, dynamic>{};
    if (stationId != null) params['station_id'] = stationId;
    final res =
        await dio.get(ApiConstants.dealerReviews, queryParameters: params);
    final rawData6 = res.data;
    final rawList = rawData6 is List
        ? rawData6
        : (rawData6 is Map ? (rawData6['data'] is List ? rawData6['data'] as List : rawData6['reviews'] is List ? rawData6['reviews'] as List : []) : <dynamic>[]);
    return rawList
        .map((e) => ReviewDto(
              id: e['id'] ?? 0,
              customerName: e['customer_name']?.toString() ?? 'Anonymous',
              customerInitial: (e['customer_name']?.toString() ?? 'A')
                  .substring(0, 1)
                  .toUpperCase(),
              rating: e['rating'] ?? 5,
              reviewText: e['comment']?.toString(),
              stationName: e['station_name']?.toString() ?? '',
              stationId: e['station_id'] ?? 0,
              createdAt: e['created_at']?.toString() ?? '',
              dealerReply: e['response_from_station']?.toString(),
              repliedAt: e['replied_at']?.toString(),
              isVerifiedRental: e['is_verified_rental'] ?? false,
            ))
        .toList();
  } catch (e) {
    log('Reviews error: $e');
    rethrow;
  }
});

class StationReviewActions {
  final Ref _ref;
  StationReviewActions(this._ref);

  Future<void> replyToReview({
    required int reviewId,
    required String replyText,
    int? stationId,
  }) async {
    final dio = _ref.read(dioProvider);
    await dio.post(
      '${ApiConstants.dealerReviews}/$reviewId/reply',
      data: {'reply_text': replyText},
    );
    _ref.invalidate(stationReviewsProvider(stationId));
  }
}

final stationReviewActionsProvider = Provider<StationReviewActions>((ref) {
  return StationReviewActions(ref);
});

// ── Station Detail Provider (enhanced) ──────────────────────
final stationDetailProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, stationId) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get('${ApiConstants.stations}/$stationId');
    return res.data as Map<String, dynamic>;
  } catch (e) {
    log('StationDetail error: $e');
    rethrow;
  }
});

// ── stations_provider.dart is imported at the top ─────────────
