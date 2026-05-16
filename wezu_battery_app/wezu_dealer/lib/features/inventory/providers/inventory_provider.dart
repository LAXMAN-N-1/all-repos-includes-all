import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../models/inventory_state.dart';

// Provides metrics for the KPI banner
final inventoryMetricsProvider =
    StateNotifierProvider<InventoryMetricsNotifier, InventoryMetricsState>(
        (ref) {
  return InventoryMetricsNotifier(ref.watch(dioProvider));
});

class InventoryMetricsNotifier extends StateNotifier<InventoryMetricsState> {
  final Dio _dio;

  InventoryMetricsNotifier(this._dio) : super(const InventoryMetricsState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('${ApiConstants.inventory}/metrics');
      final data = ApiResponse.asMap(response.data);

      final metrics = InventoryMetricsDto(
        totalStock: (data['total_stock'] as num?)?.toInt() ?? 0,
        available: (data['available'] as num?)?.toInt() ?? 0,
        reserved: (data['reserved'] as num?)?.toInt() ?? 0,
        rented: (data['rented'] as num?)?.toInt() ?? 0,
        maintenance: (data['maintenance'] as num?)?.toInt() ?? 0,
        charging: (data['charging'] as num?)?.toInt() ?? 0,
        damaged: (data['damaged'] as num?)?.toInt() ?? 0,
        lowStockCount: (data['low_stock_count'] as num?)?.toInt() ?? 0,
      );

      state = state.copyWith(isLoading: false, data: metrics);
    } on DioException catch (e) {
      log('Inventory Metrics API Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: ApiResponse.errorMessage(e, fallback: 'Failed to load metrics'),
      );
    } catch (e) {
      log('Inventory Metrics API Error: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to load metrics');
    }
  }

  void incrementDamaged() {
    state = state.copyWith(
      data: state.data.copyWith(
        damaged: state.data.damaged + 1,
      ),
    );
  }
}

// Provides the paginated table list of batteries
final inventoryBatteriesProvider =
    StateNotifierProvider<InventoryBatteriesNotifier, InventoryListState>(
        (ref) {
  return InventoryBatteriesNotifier(ref.watch(dioProvider));
});

class InventoryBatteriesNotifier extends StateNotifier<InventoryListState> {
  final Dio _dio;

  // Internal state for filters
  String? _currentStatusFilter;
  String? _currentSearch;
  String _sortBy = 'health';
  String _sortOrder = 'asc';
  int _currentPage = 1;

  InventoryBatteriesNotifier(this._dio) : super(const InventoryListState()) {
    fetchPage();
  }

  void setFilter(String? status) {
    _currentStatusFilter = status;
    _currentPage = 1;
    fetchPage();
  }

  void setSearch(String? query) {
    _currentSearch = (query != null && query.trim().isEmpty) ? null : query;
    _currentPage = 1;
    fetchPage();
  }

  void setSort(String sortBy, {String? sortOrder}) {
    if (sortBy == _sortBy && sortOrder == null) {
      // Toggle order when re-clicking same column
      _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
    } else {
      _sortBy = sortBy;
      _sortOrder = sortOrder ?? 'asc';
    }
    _currentPage = 1;
    fetchPage();
  }

  void nextPage() {
    _currentPage++;
    fetchPage();
  }

  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      fetchPage();
    }
  }

  Future<void> fetchPage() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = <String, dynamic>{
        'page': _currentPage,
        'limit': 20,
        'sortBy': _sortBy,
        'sortOrder': _sortOrder,
      };
      if (_currentStatusFilter != null && _currentStatusFilter != 'all') {
        queryParams['status'] = _currentStatusFilter;
      }
      if (_currentSearch != null) {
        queryParams['search'] = _currentSearch;
      }

      final response =
          await _dio.get(ApiConstants.inventory, queryParameters: queryParams);
      final dynamic responseData = response.data;

      List rawList = [];
      int total = 0;

      if (responseData is Map) {
        final data = responseData['data'];
        if (data is Map) {
          // Backend returns "batteries" key, not "items"
          rawList = data['batteries'] ?? data['items'] ?? [];
          // Total lives inside data.pagination.total
          final pagination = data['pagination'];
          if (pagination is Map) {
            total = (pagination['total'] as num?)?.toInt() ?? 0;
          } else {
            total = (data['total'] as num?)?.toInt() ?? 0;
          }
        } else if (data is List) {
          rawList = data;
        }
      } else if (responseData is List) {
        rawList = responseData;
      }

      final parsed = rawList.map((e) {
        final Map<String, dynamic> item = e is Map<String, dynamic> ? e : {};
        return BatteryItemDto.fromJson(item);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        items: parsed,
        page: _currentPage,
        total: total,
      );
    } on DioException catch (e) {
      log('Inventory Batteries API Error: $e');
      state = state.copyWith(
        isLoading: false,
        error:
            ApiResponse.errorMessage(e, fallback: 'Failed to load batteries'),
      );
    } catch (e) {
      log('Inventory Batteries API Error: $e');
      state =
          state.copyWith(isLoading: false, error: 'Failed to load batteries');
    }
  }

  /// Update a single battery's status via API
  Future<bool> updateBatteryStatus(int batteryId, String newStatus,
      {String? reason}) async {
    try {
      // Optimistic local update so UI reflects immediately
      state = state.copyWith(
          items: state.items.map((b) {
        if (b.batteryId == batteryId) {
          return b.copyWith(currentStatus: newStatus, faultReason: reason);
        }
        return b;
      }).toList());

      await _dio.post(
        '${ApiConstants.inventory.replaceAll('/inventory', '')}/batteries/$batteryId/status',
        data: {
          'status': newStatus,
          if (reason != null) 'reason': reason,
        },
      );
      // Wait for backend refresh
      await fetchPage();
      return true;
    } catch (e) {
      log('Update Battery Status Error: $e');
      return false;
    }
  }

  /// Bulk update status for multiple batteries
  Future<bool> bulkUpdateStatus(List<int> batteryIds, String newStatus,
      {String? reason}) async {
    try {
      await _dio.post(
        '${ApiConstants.inventory.replaceAll('/inventory', '')}/batteries/bulk-status',
        data: {
          'battery_ids': batteryIds,
          'status': newStatus,
          if (reason != null) 'reason': reason,
        },
      );
      await fetchPage();
      return true;
    } catch (e) {
      log('Bulk Update Status Error: $e');
      return false;
    }
  }

  /// Submit a stock replenishment request
  Future<bool> requestStock({
    required int quantity,
    int? modelId,
    String? modelName,
    String priority = 'normal',
    String? reason,
    String? notes,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.inventory.replaceAll('/inventory', '')}/stock-requests',
        data: {
          'quantity': quantity,
          if (modelId != null) 'model_id': modelId,
          if (modelName != null) 'model_name': modelName,
          'priority': priority,
          if (reason != null) 'reason': reason,
          if (notes != null) 'notes': notes,
        },
      );
      return true;
    } catch (e) {
      log('Request Stock Error: $e');
      return false;
    }
  }
}

// Holds the currently selected battery from the table for the Right Panel (Deep Dive)
final selectedBatteryProvider = StateProvider<BatteryItemDto?>((ref) => null);

// Holds multiple selected IDs for bulk actions
final selectedInventoryIdsProvider = StateProvider<Set<int>>((ref) => {});

// Telemetry provider — pulls real data from backend with fallback
final batteryTelemetryProvider = FutureProvider.family<List<TelemetryPointDto>, int>((ref, batteryId) async {
  final dio = ref.read(dioProvider);
  // Real API call to the telematics service
  final response = await dio.get('/telematics/battery/$batteryId/history');
  
  if (response.data != null && response.data['success'] == true) {
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) {
      return TelemetryPointDto(
        timestamp: DateTime.parse(json['timestamp'].toString()),
        soc: (json['soc'] as num).toDouble(),
        temperature: (json['temperature'] as num).toDouble(),
      );
    }).toList();
  }
  
  return []; // Return empty if API succeeds but has no data or success is false
});
