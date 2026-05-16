import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/settings_extra_models.dart';

// ── Station Defaults Provider ───────────────────────────
final stationDefaultsProvider =
    StateNotifierProvider<StationDefaultsNotifier, StationDefaultsState>((ref) {
  final auth = ref.watch(authProvider);
  return StationDefaultsNotifier(ref.watch(dioProvider),
      initialFetch: auth.isAuthenticated);
});

class StationDefaultsNotifier extends StateNotifier<StationDefaultsState> {
  final Dio _dio;
  StationDefaultsNotifier(this._dio, {bool initialFetch = true})
      : super(const StationDefaultsState()) {
    if (initialFetch) refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.stationDefaults);
      final payload = ApiResponse.asMap(response.data);
      final rawData = payload['station_defaults'] is Map
          ? Map<String, dynamic>.from(payload['station_defaults'] as Map)
          : payload;

      state = state.copyWith(
        isLoading: false,
        isRealTime: true,
        data: StationDefaultsDto.fromJson(rawData),
      );
    } on DioException catch (e) {
      log('STATION DEFAULTS API ERROR: [${e.response?.statusCode}] ${e.response?.data}');
      state = state.copyWith(
        isLoading: false,
        isRealTime: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to load station defaults'),
      );
    } catch (e) {
      log('STATION DEFAULTS UNEXPECTED ERROR: $e');
      state = state.copyWith(
          isLoading: false,
          isRealTime: false,
          error: 'Failed to load station defaults');
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true);
      await _dio.patch(ApiConstants.stationDefaults, data: data);
      await refresh();
      return true;
    } on DioException catch (e) {
      log('Update Station Defaults Error: ${e.message}', error: e);
      state = state.copyWith(
        isUpdating: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to update station defaults'),
      );
      return false;
    } catch (e) {
      log('Update Station Defaults Error: $e');
      state = state.copyWith(
          isUpdating: false, error: 'Failed to update station defaults');
      return false;
    }
  }
}

// ── Inventory Rules Provider ────────────────────────────
final inventoryRulesProvider =
    StateNotifierProvider<InventoryRulesNotifier, InventoryRulesState>((ref) {
  final auth = ref.watch(authProvider);
  return InventoryRulesNotifier(ref.watch(dioProvider),
      initialFetch: auth.isAuthenticated);
});

class InventoryRulesNotifier extends StateNotifier<InventoryRulesState> {
  final Dio _dio;
  InventoryRulesNotifier(this._dio, {bool initialFetch = true})
      : super(const InventoryRulesState()) {
    if (initialFetch) refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.inventoryRules);
      final payload = ApiResponse.asMap(response.data);
      final rawData = payload['inventory_rules'] is Map
          ? Map<String, dynamic>.from(payload['inventory_rules'] as Map)
          : payload;

      state = state.copyWith(
        isLoading: false,
        isRealTime: true,
        data: InventoryRulesDto.fromJson(rawData),
      );
    } on DioException catch (e) {
      log('INVENTORY RULES API ERROR: [${e.response?.statusCode}] ${e.response?.data}');
      state = state.copyWith(
        isLoading: false,
        isRealTime: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to load inventory rules'),
      );
    } catch (e) {
      log('INVENTORY RULES UNEXPECTED ERROR: $e');
      state = state.copyWith(
          isLoading: false,
          isRealTime: false,
          error: 'Failed to load inventory rules');
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true);
      await _dio.patch(ApiConstants.inventoryRules, data: data);
      await refresh();
      return true;
    } on DioException catch (e) {
      log('Update Inventory Rules Error: ${e.message}', error: e);
      state = state.copyWith(
        isUpdating: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to update inventory rules'),
      );
      return false;
    } catch (e) {
      log('Update Inventory Rules Error: $e');
      state = state.copyWith(
          isUpdating: false, error: 'Failed to update inventory rules');
      return false;
    }
  }
}

// ── Holiday Calendar Provider ───────────────────────────
final holidayCalendarProvider =
    StateNotifierProvider<HolidayCalendarNotifier, HolidayCalendarState>((ref) {
  final auth = ref.watch(authProvider);
  return HolidayCalendarNotifier(ref.watch(dioProvider),
      initialFetch: auth.isAuthenticated);
});

class HolidayCalendarNotifier extends StateNotifier<HolidayCalendarState> {
  final Dio _dio;
  HolidayCalendarNotifier(this._dio, {bool initialFetch = true})
      : super(const HolidayCalendarState()) {
    if (initialFetch) refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.holidayCalendar);
      final rawList = ApiResponse.asList(
        response.data,
        keys: const ['holiday_calendar', 'data', 'items'],
      );

      final holidays = rawList
          .whereType<Map>()
          .map((item) =>
              HolidayCalendarDto.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      state = state.copyWith(
        isLoading: false,
        holidays: holidays,
      );
    } on DioException catch (e) {
      log('Holiday Calendar API Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to load holiday calendar'),
      );
    } catch (e) {
      log('Holiday Calendar Error: $e');
      state = state.copyWith(
          isLoading: false, error: 'Failed to load holiday calendar');
    }
  }

  Future<bool> update(List<Map<String, dynamic>> data) async {
    try {
      state = state.copyWith(isUpdating: true);
      await _dio.patch(ApiConstants.holidayCalendar, data: data);
      await refresh();
      return true;
    } on DioException catch (e) {
      log('Update Holiday Calendar Error: ${e.message}', error: e);
      state = state.copyWith(
        isUpdating: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to update holiday calendar'),
      );
      return false;
    } catch (e) {
      log('Update Holiday Calendar Error: $e');
      state = state.copyWith(
          isUpdating: false, error: 'Failed to update holiday calendar');
      return false;
    }
  }
}

// ── Rental Settings Provider ─────────────────────────────
final rentalSettingsProvider =
    StateNotifierProvider<RentalSettingsNotifier, RentalSettingsState>((ref) {
  final auth = ref.watch(authProvider);
  return RentalSettingsNotifier(ref.watch(dioProvider),
      initialFetch: auth.isAuthenticated);
});

class RentalSettingsNotifier extends StateNotifier<RentalSettingsState> {
  final Dio _dio;
  RentalSettingsNotifier(this._dio, {bool initialFetch = true})
      : super(const RentalSettingsState()) {
    if (initialFetch) refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.rentalSettings);
      final payload = ApiResponse.asMap(response.data);
      final rawData = payload['rental_settings'] is Map
          ? Map<String, dynamic>.from(payload['rental_settings'] as Map)
          : payload;

      state = state.copyWith(
        isLoading: false,
        isRealTime: true,
        data: RentalSettingsDto.fromJson(rawData),
      );
    } on DioException catch (e) {
      log('RENTAL SETTINGS API ERROR: [${e.response?.statusCode}] ${e.response?.data}');
      state = state.copyWith(
        isLoading: false,
        isRealTime: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to load rental settings'),
      );
    } catch (e) {
      log('RENTAL SETTINGS UNEXPECTED ERROR: $e');
      state = state.copyWith(
        isLoading: false,
        isRealTime: false,
        error: 'Failed to load rental settings',
      );
    }
  }

  Future<bool> update(Map<String, dynamic> data) async {
    try {
      state = state.copyWith(isUpdating: true);
      
      // Update backend
      final response = await _dio.patch(ApiConstants.rentalSettings, data: data);
      
      final rawData = (response.data is Map && response.data.containsKey('rental_settings'))
          ? response.data['rental_settings'] as Map<String, dynamic>
          : response.data as Map<String, dynamic>? ?? data;

      state = state.copyWith(
        isUpdating: false,
        data: RentalSettingsDto.fromJson(rawData),
      );
      return false;
    } catch (e) {
      log('Update Rental Settings Error: $e');
      state = state.copyWith(
          isUpdating: false, error: 'Failed to update rental settings');
      return false;
    }
  }
}

// ── Active Sessions Provider ─────────────────────────────
final sessionsProvider =
    StateNotifierProvider<SessionsNotifier, SessionsState>((ref) {
  final auth = ref.watch(authProvider);
  return SessionsNotifier(ref.watch(dioProvider),
      initialFetch: auth.isAuthenticated);
});

class SessionsNotifier extends StateNotifier<SessionsState> {
  final Dio _dio;
  SessionsNotifier(this._dio, {bool initialFetch = true})
      : super(const SessionsState()) {
    if (initialFetch) refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiConstants.sessions);
      final rawList = ApiResponse.asList(
        response.data,
        keys: const ['sessions', 'data', 'items'],
      );

      final sessions = rawList
          .whereType<Map>()
          .map((item) => SessionDto.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      final sortedSessions = List<SessionDto>.from(sessions);
      _applySort(sortedSessions);

      if (kDebugMode)
        print('✅ Sessions loaded: ${sortedSessions.length} total');
      state = state.copyWith(
        isLoading: false,
        sessions: sortedSessions,
      );
    } on DioException catch (e) {
      log('Sessions Fetch Error: ${e.message}', error: e);
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to load active sessions'),
      );
    } catch (e) {
      log('Sessions Fetch Error: $e');
      state = state.copyWith(
          isLoading: false, error: 'Failed to load active sessions');
    }
  }

  void toggleSortOrder() {
    final newOrder = !state.isAscending;
    final sortedSessions = List<SessionDto>.from(state.sessions);
    _applySort(sortedSessions, isAscending: newOrder);
    state = state.copyWith(isAscending: newOrder, sessions: sortedSessions);
  }

  void _applySort(List<SessionDto> list, {bool? isAscending}) {
    final ascending = isAscending ?? state.isAscending;
    list.sort((a, b) {
      if (ascending) {
        return a.lastActiveAt.compareTo(b.lastActiveAt);
      } else {
        return b.lastActiveAt.compareTo(a.lastActiveAt);
      }
    });
  }

  Future<bool> revokeSession(int id) async {
    try {
      state = state.copyWith(revokingSessionId: id);
      await _dio.post('${ApiConstants.revokeSession}/$id');
      await refresh();
      state = state.copyWith(revokingSessionId: null);
      return true;
    } on DioException catch (e) {
      log('Revoke Session Error: ${e.message}', error: e);
      state = state.copyWith(
        revokingSessionId: null,
        error:
            ApiResponse.errorMessage(e, fallback: 'Failed to revoke session'),
      );
      return false;
    } catch (e) {
      log('Revoke Session Error: $e');
      state = state.copyWith(revokingSessionId: null);
      return false;
    }
  }

  Future<bool> revokeAllSessions() async {
    try {
      state = state.copyWith(revokingSessionId: -1); // -1 for all
      // Spec: POST /api/v1/auth/logout-all
      await _dio.post(ApiConstants.logoutAll);
      await refresh();
      state = state.copyWith(revokingSessionId: null);
      return true;
    } on DioException catch (e) {
      log('Revoke All Sessions Error: ${e.message}', error: e);
      state = state.copyWith(
        revokingSessionId: null,
        error: ApiResponse.errorMessage(e,
            fallback: 'Failed to revoke all sessions'),
      );
      return false;
    } catch (e) {
      log('Revoke All Sessions Error: $e');
      state = state.copyWith(revokingSessionId: null);
      return false;
    }
  }
}
