import 'package:dio/dio.dart';
import 'dart:developer';

/// Interceptor for logging API requests and responses.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('--> ${options.method.toUpperCase()} ${options.uri}');
    log('Headers: ${options.headers}');
    if (options.data != null) {
      log('Body: ${options.data}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('<-- ${response.statusCode} ${response.requestOptions.uri}');
    // Avoid logging large responses if needed, but logging everything for now
    // log('Response: ${response.data}'); 
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('Message: ${err.message}');
    if (err.response?.data != null) {
      print('Error Data: ${err.response?.data}');
    }
    return handler.next(err);
  }
}
