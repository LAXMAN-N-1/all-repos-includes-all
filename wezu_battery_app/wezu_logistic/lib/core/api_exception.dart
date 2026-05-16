import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return ApiException(message: "Request to API server was cancelled");
      case DioExceptionType.connectionTimeout:
        return ApiException(message: "Connection timeout with API server");
      case DioExceptionType.receiveTimeout:
        return ApiException(message: "Receive timeout in connection with API server");
      case DioExceptionType.sendTimeout:
        return ApiException(message: "Send timeout in connection with API server");
      case DioExceptionType.connectionError:
        return ApiException(message: "Connection to API server failed due to internet connection");
      case DioExceptionType.badResponse:
        return ApiException.fromResponse(error.response);
      case DioExceptionType.badCertificate:
        return ApiException(message: "Bad certificate");
      case DioExceptionType.unknown:
        return ApiException(message: "Connection to API server failed due to internet connection");
    }
  }

  factory ApiException.fromResponse(Response? response) {
    if (response == null) {
      return ApiException(message: "Unknown error occurred");
    }
    
    final statusCode = response.statusCode;
    final data = response.data;
    
    String message = "Something went wrong";
    
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        message = data['message'];
      } else if (data.containsKey('error')) {
        message = data['error'];
      } else if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) {
          message = detail;
        } else if (detail is List) {
          // Handle list of validation errors
          message = detail.map((e) => e.toString()).join('\n');
          try {
             // Try to make it cleaner if it matches standard Pydantic error format
             message = detail.map((e) {
               if (e is Map) {
                 final loc = (e['loc'] as List?)?.last?.toString() ?? 'Field';
                 final msg = e['msg']?.toString() ?? 'Invalid';
                 return '$loc: $msg';
               }
               return e.toString();
             }).join('\n');
          } catch (_) {}
        }
      }
    } else if (data is String) {
      message = data;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  @override
  String toString() => message;
}
