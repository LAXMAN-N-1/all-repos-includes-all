import 'package:dio/dio.dart';
import '../../storage_service.dart';

/// Interceptor that injects the Bearer token into headers.
class AuthInterceptor extends Interceptor {
  final StorageService storageService;
  final void Function()? onUnauthenticated;

  AuthInterceptor(this.storageService, {this.onUnauthenticated});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storageService.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Create a new headers map to ensure we don't modify a frozen map
    // (though Dio's headers map is usually mutable)

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 means auth is invalid/expired.
    // 403 can happen for role/permission checks (e.g., admin-only endpoints)
    // and should not force a global logout.
    if (err.response?.statusCode == 401) {
      onUnauthenticated?.call();
    }
    return handler.next(err);
  }
}
