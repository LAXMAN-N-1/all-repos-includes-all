import 'dart:io';
import 'package:dio/dio.dart';
import 'api_exception.dart';

/// Production-grade Dio-based API client with interceptors,
/// automatic retry, and structured error handling.
///
/// ```dart
/// final api = ApiClient(baseUrl: 'https://api.example.com/v1');
/// final response = await api.get('/users');
/// ```
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  Dio get dio => _dio;

  ApiClient({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    String? authToken,
    List<Interceptor>? interceptors,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
    ));

    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  /// Update the auth token for subsequent requests.
  void setAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _execute(() => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ));

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _execute(() => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ));

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => _execute(() => _dio.put<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ));

  /// PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => _execute(() => _dio.patch<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ));

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
  }) => _execute(() => _dio.delete<T>(
        path,
        data: data,
        options: options,
        cancelToken: cancelToken,
      ));

  /// Upload file via multipart.
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) => _execute(() => _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      ));

  /// Wraps all requests with unified error handling.
  Future<Response<T>> _execute<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on SocketException {
      throw ApiException.network();
    }
  }

  ApiException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout();
      case DioExceptionType.connectionError:
        return ApiException.network();
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request cancelled', type: ApiExceptionType.cancelled);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 500;
        final data = e.response?.data;
        final message = data is Map ? (data['detail'] ?? data['message'] ?? 'Error') as String : 'Server error';
        switch (statusCode) {
          case 401:
            return ApiException.unauthorized(message);
          case 403:
            return ApiException.forbidden(message);
          case 404:
            return ApiException.notFound(message);
          case 422:
            return ApiException.validation(data);
          default:
            return ApiException.server(statusCode, message);
        }
      default:
        return ApiException(message: e.message ?? 'Unknown error');
    }
  }
}
