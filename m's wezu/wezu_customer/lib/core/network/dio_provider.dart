import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:wezu_customer_app/core/constants/api_constants.dart';
import 'package:wezu_customer_app/features/auth/providers/auth_provider.dart';

const _storage = FlutterSecureStorage();
const _uuid = Uuid();

bool _isAuthEndpoint(String path) {
  return path.contains('/auth/login') ||
      path.contains('/auth/refresh') ||
      path.contains('/auth/register') ||
      path.contains('/auth/forgot-password') ||
      path.contains('/auth/reset-password') ||
      path.contains('/auth/register/request-otp') ||
      path.contains('/auth/register/verify-otp');
}

Future<String> _getOrCreateDeviceId() async {
  final existing = await _storage.read(key: 'device_id');
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }
  final generated = _uuid.v4();
  await _storage.write(key: 'device_id', value: generated);
  return generated;
}

final unauthenticatedDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.apiBaseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      if (options.headers['X-Device-ID'] == null) {
        options.headers['X-Device-ID'] = await _getOrCreateDeviceId();
      }
      return handler.next(options);
    },
  ));

  return dio;
});

final authenticatedDioProvider = Provider<Dio>((ref) {
  Completer<String?>? refreshCompleter;

  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.apiBaseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    followRedirects: true,
    maxRedirects: 3,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Keep idle connections alive for at most 15 s.
  // iOS kills sockets that have been backgrounded for longer; setting this
  // shorter than that threshold prevents Dio from trying to reuse dead sockets
  // when the app returns to foreground.
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
      () => HttpClient()..idleTimeout = const Duration(seconds: 15);

  Future<String?> refreshAccessTokenOnce() async {
    if (refreshCompleter != null) {
      return refreshCompleter!.future;
    }

    refreshCompleter = Completer<String?>();
    try {
      await ref.read(authProvider.notifier).refreshTokenAction();
      final newToken = await _storage.read(key: 'access_token');
      refreshCompleter!.complete(
        (newToken != null && newToken.isNotEmpty) ? newToken : null,
      );
    } catch (_) {
      refreshCompleter!.complete(null);
    } finally {
      Future.microtask(() {
        refreshCompleter = null;
      });
    }

    return refreshCompleter!.future;
  }

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Read JWT from secure storage (local backend token)
      final token = await _storage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      if (options.headers['X-Device-ID'] == null) {
        options.headers['X-Device-ID'] = await _getOrCreateDeviceId();
      }
      return handler.next(options);
    },
    onError: (e, handler) async {
      final request = e.requestOptions;

      // Retry once on stale-socket / connection-reset errors that occur when
      // the app returns from the background and the OS has already closed the
      // idle TCP connection that Dio was holding in its pool.
      // Only retry idempotent methods — POST/PUT/DELETE bodies may have been
      // partially transmitted before the socket died, making a retry unsafe.
      final alreadyConnectionRetried =
          request.extra['connection_retry'] == true;
      final isIdempotent = request.method == 'GET' || request.method == 'HEAD';
      if (!alreadyConnectionRetried &&
          isIdempotent &&
          e.type == DioExceptionType.connectionError) {
        request.extra['connection_retry'] = true;
        try {
          final response = await dio.fetch(request);
          return handler.resolve(response);
        } catch (_) {
          // Fall through to normal error handling if retry also fails.
        }
      }

      final alreadyRetried = request.extra['auth_retry'] == true;
      final shouldAttemptRefresh = e.response?.statusCode == 401 &&
          !alreadyRetried &&
          !_isAuthEndpoint(request.path);

      if (shouldAttemptRefresh) {
        final authNotifier = ref.read(authProvider.notifier);
        final newToken = await refreshAccessTokenOnce();
        if (newToken != null) {
          request.headers['Authorization'] = 'Bearer $newToken';
          request.extra['auth_retry'] = true;
          final response = await dio.fetch(request);
          return handler.resolve(response);
        }
        await authNotifier.logout();
      }
      return handler.next(e);
    },
  ));

  return dio;
});
