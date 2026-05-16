import 'package:dio/dio.dart';
import 'package:wezu_customer_app/core/constants/api_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class ApiClient {
  static const _storage = FlutterSecureStorage();
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Read JWT from secure storage (local backend token)
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (_shouldRetry(error)) {
          try {
            return handler.resolve(await _retry(error.requestOptions));
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  bool _shouldRetry(DioException error) {
    if (error.type == DioExceptionType.cancel ||
        error.type == DioExceptionType.badResponse) {
      return false;
    }
    // Never retry on Connection Refused (errno 61 iOS / 111 Android) — server is simply not reachable
    if (error.error is SocketException) {
      final code = (error.error as SocketException).osError?.errorCode;
      if (code == 61 || code == 111) return false;
    }
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        retryCount++;
        // Exponential backoff
        await Future.delayed(Duration(seconds: retryCount * 2));
        return await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );
      } catch (e) {
        if (retryCount >= maxRetries) rethrow;
      }
    }
    throw Exception('Failed after $maxRetries retries');
  }

  Dio get dio => _dio;
}

final apiClient = ApiClient().dio;
