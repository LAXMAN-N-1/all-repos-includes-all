import 'dart:developer' as dev;
import 'package:dio/dio.dart';

/// Injects JWT Bearer token into every request and handles 401 token refresh.
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  final Future<String?> Function()? refreshToken;
  final void Function()? onAuthFailure;

  AuthInterceptor({
    required this.getToken,
    this.refreshToken,
    this.onAuthFailure,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && refreshToken != null) {
      try {
        final newToken = await refreshToken!();
        if (newToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        }
      } catch (_) {}
      onAuthFailure?.call();
    }
    handler.next(err);
  }
}

/// Retries failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor({this.maxRetries = 3, this.baseDelay = const Duration(seconds: 1)});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);

    if (!isRetryable) return handler.next(err);

    for (var attempt = 1; attempt <= maxRetries; attempt++) {
      await Future.delayed(baseDelay * attempt);
      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (_) {
        if (attempt == maxRetries) return handler.next(err);
      }
    }
    handler.next(err);
  }
}

/// Prints request/response details in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    dev.log('→ ${options.method} ${options.path}', name: 'API');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    dev.log('← ${response.statusCode} ${response.requestOptions.path}', name: 'API');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    dev.log('✖ ${err.response?.statusCode ?? 'ERR'} ${err.requestOptions.path}: ${err.message}', name: 'API');
    handler.next(err);
  }
}
