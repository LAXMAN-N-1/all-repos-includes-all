import 'dart:io';

import '../../../config/app_constants.dart';
import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/battery_model.dart';
import '../../../models/dashboard_report_model.dart';
import '../../../models/dashboard_stats_model.dart';
import '../../../models/dashboard_analytics_model.dart';
import '../../../models/dashboard_alert_model.dart';
import '../../../models/order_model.dart';
import '../../../services/api/api_client.dart';
import '../../notifications/repository/notifications_repository.dart';
import 'package:flutter/material.dart';

/// Repository for dashboard data operations.
/// Connects to backend dashboard APIs with graceful fallbacks
/// to operational endpoints when needed.
class DashboardRepository {
  final ApiClient _api;
  final NotificationsRepository _notificationsRepository;

  DashboardRepository({
    required ApiClient api,
    NotificationsRepository? notificationsRepository,
  }) : _api = api,
       _notificationsRepository =
           notificationsRepository ?? NotificationsRepository(api: api);

  /// Fetch dashboard overview metrics.
  /// Computes stats from operational endpoints to stay compatible across
  /// backend variants where `/analytics/dashboard` may be disabled.
  Future<Result<DashboardStats>> fetchStats() async {
    try {
      return Result.success(await _buildStatsFromOperationalData());
    } on ApiException catch (e) {
      return Result.failure(e.message, code: e.statusCode?.toString());
    } catch (e) {
      return Result.failure('Failed to load dashboard stats: $e');
    }
  }

  /// Fetch recent activity feed.
  /// Derives a timeline from recent orders for compatibility.
  Future<Result<List<ActivityItem>>> fetchRecentActivity({
    int limit = 10,
  }) async {
    return Result.success(await _buildActivityFallback(limit: limit));
  }

  Future<List<ActivityItem>> _buildActivityFallback({
    required int limit,
  }) async {
    try {
      final orders = await _fetchOrders(pageSize: limit);
      final sorted = List<OrderModel>.from(orders)
        ..sort(
          (a, b) => _effectiveOrderDate(b).compareTo(_effectiveOrderDate(a)),
        );

      return sorted.take(limit).map((order) {
        final activityType = switch (order.status) {
          OrderStatus.inTransit => ActivityType.shipmentInTransit,
          OrderStatus.delivered => ActivityType.orderDelivered,
          OrderStatus.failed => ActivityType.batteryFault,
          _ => ActivityType.orderCreated,
        };

        final title = switch (order.status) {
          OrderStatus.inTransit => 'Order ${order.id} dispatched',
          OrderStatus.delivered => 'Order ${order.id} delivered',
          OrderStatus.failed => 'Order ${order.id} failed',
          OrderStatus.cancelled => 'Order ${order.id} cancelled',
          _ => 'Order ${order.id} created',
        };

        return ActivityItem(
          id: order.id,
          title: title,
          type: activityType,
          timestamp: _effectiveOrderDate(order),
          referenceId: order.id,
        );
      }).toList();
    } catch (_) {
      return const <ActivityItem>[];
    }
  }

  /// Fetch analytics data for charts.
  /// Derived from operational endpoints (orders + batteries) for compatibility.
  Future<Result<DashboardAnalyticsData>> fetchAnalytics() async {
    try {
      return Result.success(await _buildAnalyticsFromOperationalData());
    } on ApiException catch (e) {
      return Result.failure(e.message, code: e.statusCode?.toString());
    } catch (e) {
      return Result.failure('Failed to load dashboard analytics: $e');
    }
  }

  /// Queue a dashboard report generation job.
  Future<Result<DashboardReportQueued>> queueDashboardReport({
    required DateTime from,
    required DateTime to,
    String format = 'csv',
    String timezone = 'UTC',
    List<String> includeSections = const [
      'kpis',
      'recent_activity',
      'orders',
      'inventory',
      'fleet',
    ],
  }) async {
    try {
      final response = await _api.post<dynamic>(
        '/analytics/reports/dashboard',
        data: {
          'from': from.toUtc().toIso8601String(),
          'to': to.toUtc().toIso8601String(),
          'timezone': timezone,
          'format': format,
          'include_sections': includeSections,
        },
      );
      final data = _extractDataMap(response);
      return Result.success(DashboardReportQueued.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message, code: e.statusCode?.toString());
    } catch (e) {
      return Result.failure('Failed to queue dashboard report: $e');
    }
  }

  /// Fetch report generation status by report ID.
  Future<Result<DashboardReportStatus>> fetchDashboardReportStatus(
    String reportId,
  ) async {
    try {
      final response = await _api.get<dynamic>('/analytics/reports/$reportId');
      final data = _extractDataMap(response);
      return Result.success(DashboardReportStatus.fromJson(data));
    } on ApiException catch (e) {
      return Result.failure(e.message, code: e.statusCode?.toString());
    } catch (e) {
      return Result.failure('Failed to fetch report status: $e');
    }
  }

  /// Poll report status with a bounded exponential-ish backoff.
  Future<Result<DashboardReportStatus>> waitForDashboardReport(
    String reportId, {
    int maxAttempts = 7,
  }) async {
    const delays = <Duration>[
      Duration(seconds: 1),
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
      Duration(seconds: 5),
      Duration(seconds: 8),
    ];

    DashboardReportStatus? lastStatus;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = await fetchDashboardReportStatus(reportId);
      if (result.isFailure) {
        return result;
      }

      final status = result.dataOrNull;
      if (status == null) {
        return Result.failure('Missing report status payload.');
      }
      lastStatus = status;
      if (status.isTerminal) {
        return Result.success(status);
      }

      if (attempt < maxAttempts - 1) {
        final delay = attempt < delays.length ? delays[attempt] : delays.last;
        await Future.delayed(delay);
      }
    }

    if (lastStatus != null) {
      return Result.success(lastStatus);
    }
    return Result.failure('Report is still processing.');
  }

  /// Convert relative API paths (e.g. /api/v1/...) to absolute URL.
  String resolveApiUrl(String pathOrUrl) {
    final trimmed = pathOrUrl.trim();
    if (trimmed.isEmpty) return trimmed;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      return uri.toString();
    }

    final apiBase = Uri.parse(AppConstants.apiBaseUrl);
    return apiBase.resolveUri(Uri.parse(trimmed)).toString();
  }

  /// Download report bytes.
  /// Uses signed download URL directly when query signature is present.
  /// Falls back to authenticated API client for legacy paths.
  Future<Result<List<int>>> downloadDashboardReportFile(String fileUrl) async {
    try {
      final resolvedUrl = resolveApiUrl(fileUrl);
      final resolvedUri = Uri.parse(resolvedUrl);

      final bytes = _isLikelySignedReportUrl(resolvedUri)
          ? await _downloadViaSignedUrl(resolvedUri)
          : await _api.getBytes(resolvedUrl);

      if (bytes.isEmpty) {
        return Result.failure('Report download returned an empty file.');
      }
      return Result.success(bytes);
    } on ApiException catch (e) {
      return Result.failure(e.message, code: e.statusCode?.toString());
    } catch (e) {
      return Result.failure('Failed to download report: $e');
    }
  }

  Future<List<int>> _downloadViaSignedUrl(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, '*/*');
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: 'Report download failed (HTTP ${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }

      final buffer = <int>[];
      await for (final chunk in response) {
        buffer.addAll(chunk);
      }
      return buffer;
    } finally {
      client.close(force: true);
    }
  }

  bool _isLikelySignedReportUrl(Uri uri) {
    final path = uri.path.toLowerCase();
    final hasReportDownloadPath =
        path.contains('/analytics/reports/') && path.endsWith('/download');
    if (!hasReportDownloadPath || uri.queryParameters.isEmpty) {
      return false;
    }

    const knownSignatureKeys = <String>{
      'token',
      'download_token',
      'sig',
      'signature',
      'expires',
      'exp',
    };
    final keys = uri.queryParameters.keys
        .map((key) => key.toLowerCase())
        .toSet();
    if (keys.any(knownSignatureKeys.contains)) {
      return true;
    }

    // If backend includes any query params on report download URL,
    // treat it as signed and avoid attaching auth headers.
    return true;
  }

  /// Fetch active alerts from notifications endpoint.
  Future<Result<List<DashboardAlert>>> fetchAlerts() async {
    try {
      return _notificationsRepository.fetchNotifications(
        includeGlobal: true,
        skip: 0,
        limit: 100,
        unreadOnly: false,
      );
    } catch (_) {
      return Result.success([]);
    }
  }

  Future<Result<void>> markAllAlertsRead() {
    return _notificationsRepository.markAllRead(includeGlobal: true);
  }

  Future<Result<void>> clearAllAlerts() {
    return _notificationsRepository.clearAll(includeGlobal: true);
  }

  Future<List<BatteryModel>> _fetchBatteries({int pageSize = 500}) async {
    final rawItems = await _fetchPaginatedList(
      '/batteries/',
      pageSize: pageSize,
      maxPages: 60,
    );
    final batteries = <BatteryModel>[];
    for (final item in rawItems.whereType<Map>()) {
      final mapped = item.map((key, value) => MapEntry(key.toString(), value));
      try {
        batteries.add(BatteryModel.fromJson(mapped));
      } catch (e) {
        debugPrint('DashboardRepository: Skipped malformed battery row: $e');
      }
    }
    return batteries;
  }

  Future<List<OrderModel>> _fetchOrders({int pageSize = 500}) async {
    final rawItems = await _fetchPaginatedList(
      '/orders/',
      pageSize: pageSize,
      maxPages: 40,
      baseQueryParameters: const {'sort_order': 'desc'},
    );
    final orders = <OrderModel>[];
    for (final item in rawItems.whereType<Map>()) {
      final mapped = item.map((key, value) => MapEntry(key.toString(), value));
      try {
        orders.add(OrderModel.fromJson(mapped));
      } catch (e) {
        debugPrint('DashboardRepository: Skipped malformed order row: $e');
      }
    }
    return orders;
  }

  Future<List<dynamic>> _fetchPaginatedList(
    String path, {
    int pageSize = 500,
    int maxPages = 40,
    Map<String, dynamic>? baseQueryParameters,
  }) async {
    final items = <dynamic>[];
    var skip = 0;
    String? previousPageSignature;

    for (var page = 0; page < maxPages; page++) {
      final response = await _api.get<dynamic>(
        path,
        queryParameters: {
          ...?baseQueryParameters,
          'skip': skip,
          'limit': pageSize,
          'include_pagination': true,
        },
      );

      final pageItems = _extractList(response);
      if (pageItems.isEmpty) break;

      final pageSignature = _buildPageSignature(pageItems);
      if (pageSignature.isNotEmpty && pageSignature == previousPageSignature) {
        // Defensive break if backend ignores skip/limit and returns same page repeatedly.
        break;
      }
      previousPageSignature = pageSignature;

      items.addAll(pageItems);
      if (pageItems.length < pageSize) break;

      final hasMore = _extractHasMore(response);
      if (hasMore == false) break;

      skip += pageItems.length;
    }

    return items;
  }

  bool? _extractHasMore(dynamic response) {
    final root = _asMap(response);
    if (root == null) return null;

    final pagination = _asMap(root['pagination']);
    final paginationHasMore = pagination?['has_more'];
    if (paginationHasMore is bool) return paginationHasMore;

    final nestedData = _asMap(root['data']);
    final nestedPagination = _asMap(nestedData?['pagination']);
    final nestedHasMore = nestedPagination?['has_more'];
    if (nestedHasMore is bool) return nestedHasMore;

    return null;
  }

  String _buildPageSignature(List<dynamic> items) {
    if (items.isEmpty) return '';
    final first = _asMap(items.first);
    final last = _asMap(items.last);
    final firstKey =
        first?['id'] ?? first?['serial_number'] ?? items.first.toString();
    final lastKey =
        last?['id'] ?? last?['serial_number'] ?? items.last.toString();
    return '$firstKey|$lastKey|${items.length}';
  }

  Future<DashboardStats> _buildStatsFromOperationalData() async {
    List<BatteryModel> batteries = const <BatteryModel>[];
    List<OrderModel> orders = const <OrderModel>[];
    Object? batteriesError;
    Object? ordersError;

    try {
      batteries = await _fetchBatteries();
    } catch (e) {
      batteriesError = e;
    }

    try {
      orders = await _fetchOrders();
    } catch (e) {
      ordersError = e;
    }

    if (batteriesError != null && ordersError != null) {
      throw ApiException(
        message:
            'Failed to load dashboard stats from /batteries and /orders endpoints.',
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final totalBatteries = batteries.length;
    final availableBatteries = batteries
        .where((b) => b.status == BatteryStatus.available)
        .length;
    final inTransitBatteries = batteries
        .where(
          (b) =>
              b.status == BatteryStatus.deployed ||
              b.status == BatteryStatus.inTransit,
        )
        .length;
    final issueCount = batteries
        .where(
          (b) =>
              b.status == BatteryStatus.faulty ||
              b.status == BatteryStatus.maintenance,
        )
        .length;

    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;

    final sentToday = orders
        .where(
          (o) => _isSentOrder(o) && _isSameDay(_effectiveOrderDate(o), today),
        )
        .length;
    final sentYesterday = orders
        .where(
          (o) =>
              _isSentOrder(o) && _isSameDay(_effectiveOrderDate(o), yesterday),
        )
        .length;

    final sentTrend = sentYesterday == 0
        ? (sentToday > 0 ? 100.0 : 0.0)
        : ((sentToday - sentYesterday) / sentYesterday) * 100;

    final receivedToday = batteries
        .where((b) => _isSameDay(b.createdAt, today))
        .length;

    final pendingReceipts = orders
        .where((o) => o.status == OrderStatus.inTransit)
        .length;

    final revenue = orders
        .where(
          (o) =>
              o.status != OrderStatus.failed &&
              o.status != OrderStatus.cancelled,
        )
        .fold<double>(0, (sum, order) => sum + order.totalValue);

    final monthlyDispatch = orders
        .where(
          (o) => _isSentOrder(o) && _isSameMonth(_effectiveOrderDate(o), now),
        )
        .fold<int>(
          0,
          (sum, order) => sum + (order.units > 0 ? order.units : 1),
        );

    return DashboardStats(
      availableBatteries: availableBatteries,
      inTransitBatteries: inTransitBatteries,
      pendingOrders: pendingOrders,
      issueCount: issueCount,
      totalBatteries: totalBatteries,
      sentToday: sentToday,
      sentTrend: sentTrend,
      receivedToday: receivedToday,
      pendingReceipts: pendingReceipts,
      revenue: revenue,
      monthlyDispatch: monthlyDispatch,
    );
  }

  Future<DashboardAnalyticsData> _buildAnalyticsFromOperationalData() async {
    List<BatteryModel> batteries = const <BatteryModel>[];
    List<OrderModel> orders = const <OrderModel>[];
    Object? batteriesError;
    Object? ordersError;

    try {
      batteries = await _fetchBatteries();
    } catch (e) {
      batteriesError = e;
    }

    try {
      orders = await _fetchOrders();
    } catch (e) {
      ordersError = e;
    }

    if (batteriesError != null && ordersError != null) {
      throw ApiException(
        message:
            'Failed to load dashboard analytics from /batteries and /orders endpoints.',
      );
    }

    final statusCounts = <String, int>{
      'Available': batteries
          .where((b) => b.status == BatteryStatus.available)
          .length,
      'In Transit': batteries
          .where(
            (b) =>
                b.status == BatteryStatus.inTransit ||
                b.status == BatteryStatus.deployed,
          )
          .length,
      'Charging': batteries
          .where((b) => b.status == BatteryStatus.charging)
          .length,
      'Faulty': batteries.where((b) => b.status == BatteryStatus.faulty).length,
      'Maintenance': batteries
          .where((b) => b.status == BatteryStatus.maintenance)
          .length,
    };

    final batteryStatusDistribution = [
      if ((statusCounts['Available'] ?? 0) > 0)
        PieChartDataPoint(
          label: 'Available',
          value: (statusCounts['Available'] ?? 0).toDouble(),
          color: Colors.green,
        ),
      if ((statusCounts['In Transit'] ?? 0) > 0)
        PieChartDataPoint(
          label: 'In Transit',
          value: (statusCounts['In Transit'] ?? 0).toDouble(),
          color: Colors.blue,
        ),
      if ((statusCounts['Charging'] ?? 0) > 0)
        PieChartDataPoint(
          label: 'Charging',
          value: (statusCounts['Charging'] ?? 0).toDouble(),
          color: Colors.orange,
        ),
      if ((statusCounts['Faulty'] ?? 0) > 0)
        PieChartDataPoint(
          label: 'Faulty',
          value: (statusCounts['Faulty'] ?? 0).toDouble(),
          color: Colors.red,
        ),
      if ((statusCounts['Maintenance'] ?? 0) > 0)
        PieChartDataPoint(
          label: 'Maintenance',
          value: (statusCounts['Maintenance'] ?? 0).toDouble(),
          color: Colors.purple,
        ),
    ];

    final goodHealth = batteries.where((b) => b.healthPercentage >= 90).length;
    final fairHealth = batteries
        .where((b) => b.healthPercentage >= 70 && b.healthPercentage < 90)
        .length;
    final poorHealth = batteries.where((b) => b.healthPercentage < 70).length;

    final batteryHealthDistribution = [
      if (goodHealth > 0)
        PieChartDataPoint(
          label: 'Good (>90%)',
          value: goodHealth.toDouble(),
          color: Colors.green,
        ),
      if (fairHealth > 0)
        PieChartDataPoint(
          label: 'Fair (70-90%)',
          value: fairHealth.toDouble(),
          color: Colors.orange,
        ),
      if (poorHealth > 0)
        PieChartDataPoint(
          label: 'Poor (<70%)',
          value: poorHealth.toDouble(),
          color: Colors.red,
        ),
    ];

    final cycleNew = batteries.where((b) => b.cycleCount < 100).length;
    final cycleMid = batteries
        .where((b) => b.cycleCount >= 100 && b.cycleCount <= 300)
        .length;
    final cycleHigh = batteries.where((b) => b.cycleCount > 300).length;

    final cycleCountDistribution = [
      if (cycleNew > 0)
        CategoryValue(category: 'New (<100)', value: cycleNew.toDouble()),
      if (cycleMid > 0)
        CategoryValue(category: 'Mid (100-300)', value: cycleMid.toDouble()),
      if (cycleHigh > 0)
        CategoryValue(category: 'High (300+)', value: cycleHigh.toDouble()),
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final recentDays = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );

    final dailyDispatchTrend = recentDays.map((day) {
      final value = orders
          .where(
            (o) => _isSentOrder(o) && _isSameDay(_effectiveOrderDate(o), day),
          )
          .fold<double>(
            0,
            (sum, order) => sum + (order.units > 0 ? order.units : 1),
          );
      return TimePoint(date: day, value: value);
    }).toList();

    final inventoryLevelTrend = recentDays.map((day) {
      final delivered = orders
          .where(
            (o) =>
                o.status == OrderStatus.delivered &&
                _isSameDay(_effectiveOrderDate(o), day),
          )
          .length;
      return TimePoint(date: day, value: delivered.toDouble());
    }).toList();

    final pendingOrders = orders
        .where((o) => o.status == OrderStatus.pending)
        .length;
    final inTransitOrders = orders
        .where((o) => o.status == OrderStatus.inTransit)
        .length;
    final deliveredOrders = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final failedOrders = orders
        .where(
          (o) =>
              o.status == OrderStatus.failed ||
              o.status == OrderStatus.cancelled,
        )
        .length;

    final stationDispatchDistribution = [
      if (pendingOrders > 0)
        CategoryValue(category: 'Pending', value: pendingOrders.toDouble()),
      if (inTransitOrders > 0)
        CategoryValue(
          category: 'In Transit',
          value: inTransitOrders.toDouble(),
        ),
      if (deliveredOrders > 0)
        CategoryValue(category: 'Delivered', value: deliveredOrders.toDouble()),
      if (failedOrders > 0)
        CategoryValue(category: 'Failed', value: failedOrders.toDouble()),
    ];

    return DashboardAnalyticsData(
      batteryStatusDistribution: batteryStatusDistribution,
      batteryHealthDistribution: batteryHealthDistribution,
      cycleCountDistribution: cycleCountDistribution,
      dailyDispatchTrend: dailyDispatchTrend,
      inventoryLevelTrend: inventoryLevelTrend,
      stationDispatchDistribution: stationDispatchDistribution,
    );
  }

  Map<String, dynamic> _extractDataMap(dynamic response) {
    final root = _asMap(response) ?? <String, dynamic>{};
    final nestedData = _asMap(root['data']);
    return nestedData ?? root;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, data) => MapEntry(key.toString(), data));
    }
    return null;
  }

  List<dynamic> _extractList(dynamic response) {
    dynamic root = response;
    for (var depth = 0; depth < 4; depth++) {
      if (root is List<dynamic>) {
        return root;
      }
      final mapRoot = _asMap(root);
      if (mapRoot == null) {
        return const <dynamic>[];
      }

      for (final key in const [
        'data',
        'items',
        'orders',
        'drivers',
        'transfers',
        'batteries',
        'results',
        'records',
        'rows',
      ]) {
        final candidate = mapRoot[key];
        if (candidate is List<dynamic>) {
          return candidate;
        }
      }

      root =
          mapRoot['data'] ??
          mapRoot['items'] ??
          mapRoot['results'] ??
          mapRoot['records'];
    }
    return const <dynamic>[];
  }

  bool _isSentOrder(OrderModel order) =>
      order.status == OrderStatus.inTransit ||
      order.status == OrderStatus.delivered;

  DateTime _effectiveOrderDate(OrderModel order) =>
      order.dispatchDate ?? order.deliveredAt ?? order.updatedAt;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
