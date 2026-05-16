import '../../../config/app_constants.dart';
import '../../../core/api_exception.dart';
import '../../../core/result.dart';
import '../../../models/dashboard_alert_model.dart';
import '../../../services/api/api_client.dart';

abstract class NotificationsApiClient {
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters});

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
}

class _ApiClientAdapter implements NotificationsApiClient {
  final ApiClient _api;

  _ApiClientAdapter(this._api);

  @override
  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _api.get<T>(path, queryParameters: queryParameters);
  }

  @override
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _api.post<T>(path, data: data, queryParameters: queryParameters);
  }

  @override
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _api.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  @override
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _api.put<T>(path, data: data, queryParameters: queryParameters);
  }

  @override
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _api.delete<T>(path, data: data, queryParameters: queryParameters);
  }
}

class NotificationsRepository {
  final NotificationsApiClient _api;

  NotificationsRepository({required ApiClient api})
    : _api = _ApiClientAdapter(api);

  NotificationsRepository.withClient(this._api);

  Future<Result<void>> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceId,
  }) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      return Result.failure('Device token is required');
    }

    try {
      await _runWithAppScopeFallback(
        (includeAppScope) => _api.post<Map<String, dynamic>>(
          '/notifications/device-token',
          data: {
            'token': normalizedToken,
            'platform': platform,
            if (deviceId != null && deviceId.trim().isNotEmpty)
              'device_id': deviceId.trim(),
            if (includeAppScope)
              'app_scope': AppConstants.notificationsAppScope,
          },
        ),
      );
      return Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to register device token: $e');
    }
  }

  Future<Result<void>> unregisterDeviceToken({
    String? token,
    String? deviceId,
  }) async {
    try {
      await _runWithAppScopeFallback(
        (includeAppScope) => _api.delete<Map<String, dynamic>>(
          '/notifications/device-token',
          data: {
            if (token != null && token.trim().isNotEmpty) 'token': token.trim(),
            if (deviceId != null && deviceId.trim().isNotEmpty)
              'device_id': deviceId.trim(),
            if (includeAppScope)
              'app_scope': AppConstants.notificationsAppScope,
          },
        ),
      );
      return Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to unregister device token: $e');
    }
  }

  Future<Result<List<DashboardAlert>>> fetchNotifications({
    int skip = 0,
    int limit = 100,
    bool unreadOnly = false,
    bool includeGlobal = true,
  }) async {
    try {
      final response = await _fetchNotificationsWithFallback(
        skip: skip,
        limit: limit,
        unreadOnly: unreadOnly,
        includeGlobal: includeGlobal,
      );
      final list = _extractList(response);
      final items = list
          .whereType<Map>()
          .map((item) => DashboardAlert.fromJson(_stringKeyedMap(item)))
          .toList();
      return Result.success(items);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to fetch notifications: $e');
    }
  }

  Future<Result<void>> markAllRead({bool includeGlobal = true}) async {
    try {
      try {
        await _runWithAppScopeFallback(
          (includeAppScope) => _api.patch<Map<String, dynamic>>(
            '/notifications/read-all',
            queryParameters: {
              'include_global': includeGlobal,
              if (includeAppScope)
                'app_scope': AppConstants.notificationsAppScope,
            },
          ),
        );
      } on ApiException catch (e) {
        if (e.statusCode != 405) rethrow;
        await _runWithAppScopeFallback(
          (includeAppScope) => _api.put<Map<String, dynamic>>(
            '/notifications/read-all',
            queryParameters: {
              'include_global': includeGlobal,
              if (includeAppScope)
                'app_scope': AppConstants.notificationsAppScope,
            },
          ),
        );
      }
      return Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to mark all notifications as read: $e');
    }
  }

  Future<Result<void>> clearAll({bool includeGlobal = true}) async {
    try {
      await _runWithAppScopeFallback(
        (includeAppScope) => _api.delete<Map<String, dynamic>>(
          '/notifications',
          queryParameters: {
            'include_global': includeGlobal,
            if (includeAppScope)
              'app_scope': AppConstants.notificationsAppScope,
          },
        ),
      );
      return Result.success(null);
    } on ApiException catch (e) {
      return Result.failure(e.message);
    } catch (e) {
      return Result.failure('Failed to clear notifications: $e');
    }
  }

  Future<T> _runWithAppScopeFallback<T>(
    Future<T> Function(bool includeAppScope) request,
  ) async {
    try {
      return await request(true);
    } on ApiException catch (e) {
      if (!_shouldRetryWithoutAppScope(e)) {
        rethrow;
      }
      return request(false);
    }
  }

  Future<dynamic> _fetchNotificationsWithFallback({
    required int skip,
    required int limit,
    required bool unreadOnly,
    required bool includeGlobal,
  }) async {
    final query = <String, dynamic>{
      'skip': skip,
      'limit': limit,
      'unread_only': unreadOnly,
      'include_global': includeGlobal,
    };

    try {
      return await _runWithAppScopeFallback(
        (includeAppScope) => _api.get<dynamic>(
          '/notifications/my',
          queryParameters: {
            ...query,
            if (includeAppScope)
              'app_scope': AppConstants.notificationsAppScope,
          },
        ),
      );
    } on ApiException catch (e) {
      // Some backend variants expose GET /notifications instead of /notifications/my.
      if (e.statusCode != 404 && e.statusCode != 405) rethrow;
      return _runWithAppScopeFallback(
        (includeAppScope) => _api.get<dynamic>(
          '/notifications',
          queryParameters: {
            ...query,
            if (includeAppScope)
              'app_scope': AppConstants.notificationsAppScope,
          },
        ),
      );
    }
  }

  bool _shouldRetryWithoutAppScope(ApiException error) {
    final statusCode = error.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return false;
    }
    final message = error.message.toLowerCase();
    if (message.contains('app_scope')) {
      return true;
    }
    return statusCode == 400 || statusCode == 404 || statusCode == 422;
  }

  Map<String, dynamic> _stringKeyedMap(Map map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List<dynamic>) return response;
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List<dynamic>) return data;
      final items = response['items'];
      if (items is List<dynamic>) return items;
    }
    return const <dynamic>[];
  }
}
