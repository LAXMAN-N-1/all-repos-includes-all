import 'package:dio/dio.dart';
import 'package:frontend/core/storage/storage_service.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:8000/api/v1'; // Localhost backend
  final Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add Bearer Token
        final token = await _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token expired or invalid -> Clear storage
          // In a real app, trigger a global logout event here
          await _storageService.deleteToken();
        }
        return handler.next(e);
      },
      onResponse: (response, handler) {
        // Log response or transform data if needed
        return handler.next(response);
      },
    ));
  }

  Dio get client => _dio;
}
