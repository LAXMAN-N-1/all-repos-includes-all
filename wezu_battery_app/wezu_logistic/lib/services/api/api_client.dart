import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import '../../config/app_constants.dart';
import '../../core/api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// A wrapper around Dio that provides a simplified API for making HTTP requests.
/// Handles standard configuration, interceptors, and error mapping.
class ApiClient {
  final Dio _dio;
  final bool enableLogging;
  final bool useMocks;

  ApiClient({
    required AuthInterceptor authInterceptor,
    this.enableLogging = true,
    this.useMocks = false, // Toggle for testing without backend
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: AppConstants.apiBaseUrl,
           connectTimeout: AppConstants.connectTimeout,
           receiveTimeout: AppConstants.receiveTimeout,
           responseType: ResponseType.json,
         ),
       ) {
    _dio.interceptors.add(authInterceptor);

    if (enableLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }

    // Add smart retry logic
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  // ─── Generic Request Helpers ────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (useMocks) return _mockRequest<T>(path);
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (useMocks) return _mockRequest<T>(path);
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (useMocks) return _mockRequest<T>(path);
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (useMocks) return _mockRequest<T>(path);
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (useMocks) return _mockRequest<T>(path);
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<int>> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (useMocks) {
      throw ApiException(
        message: 'Binary downloads are not available in mock mode',
      );
    }
    try {
      final mergedOptions = (options ?? Options()).copyWith(
        responseType: ResponseType.bytes,
      );
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: mergedOptions,
        cancelToken: cancelToken,
      );
      final data = response.data;
      if (data is List<int>) return data;
      if (data is Uint8List) return data;
      if (data is String) return utf8.encode(data);
      throw ApiException(message: 'Unexpected binary response payload');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // ─── Mock Logic ─────────────────────────────────────────────────────

  Future<T> _mockRequest<T>(String path) async {
    // await Future.delayed(const Duration(milliseconds: 800)); // Removed for instant loading

    // Simple mock routing based on path
    if (path.contains('/dealer/dashboard')) {
      // Combined stats and analytics
      return {
            'stats': {
              'available_batteries': 42,
              'deployed_batteries': 18,
              'pending_orders': 5,
              'issue_count': 2,
              'total_batteries': 160,
              'sent_today': 14,
              'sent_trend': 10.5,
              'received_today': 8,
              'pending_receipts': 2,
              'revenue': 12500.0,
              'monthly_dispatch': 340,
            },
            'analytics': {
              'battery_status_distribution': [
                {'label': 'Available', 'value': 70, 'color': '#4CAF50'},
                {'label': 'In Transit', 'value': 40, 'color': '#2196F3'},
                {'label': 'Charging', 'value': 30, 'color': '#FFC107'},
                {'label': 'Faulty', 'value': 20, 'color': '#F44336'},
              ],
              'battery_health_distribution': [
                {'label': 'Good (>90%)', 'value': 110, 'color': '#4CAF50'},
                {'label': 'Fair (70-90%)', 'value': 35, 'color': '#FF9800'},
                {'label': 'Poor (<70%)', 'value': 15, 'color': '#F44336'},
              ],
              'cycle_count_distribution': [
                {'category': 'New (<100)', 'value': 50},
                {'category': 'Mid (100-300)', 'value': 80},
                {'category': 'High (300+)', 'value': 30},
              ],
              'daily_dispatch_trend': List.generate(7, (index) {
                final date = DateTime.now().subtract(Duration(days: 6 - index));
                final value = [120, 145, 110, 160, 135, 180, 155][index];
                return {'date': date.toIso8601String(), 'value': value};
              }),
              'inventory_level_trend': List.generate(7, (index) {
                final date = DateTime.now().subtract(Duration(days: 6 - index));
                final value = [850, 840, 860, 830, 870, 855, 845][index];
                return {'date': date.toIso8601String(), 'value': value};
              }),
              'station_dispatch_distribution': [
                {'category': 'Hub A', 'value': 350},
                {'category': 'Hub B', 'value': 280},
                {'category': 'Station X', 'value': 150},
                {'category': 'Station Y', 'value': 120},
                {'category': 'HQ', 'value': 400},
              ],
            },
          }
          as T;
    }

    if (path.contains('/dealer/activities')) {
      return [
            {
              'id': '1',
              'title': 'Stock Received: 50 Batteries from HQ',
              'type': 'batteryReceived',
              'timestamp': DateTime.now()
                  .subtract(const Duration(minutes: 5))
                  .toIso8601String(),
            },
            {
              'id': '2',
              'title': 'Order #1234 Dispatched',
              'type': 'orderDelivered',
              'timestamp': DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
            },
            {
              'id': '3',
              'title': 'Low Inventory: Hub B',
              'type': 'lowInventory',
              'timestamp': DateTime.now()
                  .subtract(const Duration(hours: 4))
                  .toIso8601String(),
            },
          ]
          as T;
    }

    if (path.contains('/dealer/alerts')) {
      return [
            {
              'id': '1',
              'title': 'Low Inventory: Hub B',
              'message': 'Battery stock is below safety threshold (8 units).',
              'severity': 'critical',
              'type': 'lowStock',
              'timestamp': DateTime.now()
                  .subtract(const Duration(minutes: 30))
                  .toIso8601String(),
              'action_label': 'Restock',
            },
            {
              'id': '2',
              'title': 'Pending Approval',
              'message': 'Order #1234 requires dispatch approval.',
              'severity': 'warning',
              'type': 'pendingTask',
              'timestamp': DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
              'action_label': 'Review',
            },
          ]
          as T;
    }

    if (path.contains('/inventory/stats')) {
      return {
            'total': 160,
            'available': 45,
            'charging': 20,
            'faulty': 5,
            'maintenance': 5,
          }
          as T;
    }

    // Existing mocks...
    if (path.contains('/auth/login') || path.contains('/auth/me')) {
      final user = {
        'id': '1',
        'name': 'Demo User',
        'email': 'dealer@example.com',
        'role': 'dealer',
        'dealership_name': 'Wezu Motors',
        'phone': '9876543210',
        'avatar_url': null,
      };

      if (path.contains('/auth/me')) return user as T;

      return {'token': 'mock-jwt-token-12345', 'user': user} as T;
    }

    if (path.contains('/batteries')) {
      return [
            {'id': 'BAT-001', 'model': 'Li-Ion 5000', 'status': 'Full'},
            {'id': 'BAT-002', 'model': 'Li-Ion 5000', 'status': 'Low'},
          ]
          as T;
    }

    throw ApiException(message: "Mock data not found for $path");
  }
}
