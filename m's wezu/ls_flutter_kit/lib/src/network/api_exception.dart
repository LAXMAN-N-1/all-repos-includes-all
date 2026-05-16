/// Structured API exception for consistent error handling across the app.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final ApiExceptionType type;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.type = ApiExceptionType.unknown,
  });

  factory ApiException.network([String? message]) => ApiException(
        message: message ?? 'No internet connection',
        type: ApiExceptionType.network,
      );

  factory ApiException.timeout([String? message]) => ApiException(
        message: message ?? 'Request timed out',
        type: ApiExceptionType.timeout,
      );

  factory ApiException.server(int statusCode, [String? message]) => ApiException(
        message: message ?? 'Server error ($statusCode)',
        statusCode: statusCode,
        type: ApiExceptionType.server,
      );

  factory ApiException.unauthorized([String? message]) => ApiException(
        message: message ?? 'Unauthorized — please log in again',
        statusCode: 401,
        type: ApiExceptionType.unauthorized,
      );

  factory ApiException.forbidden([String? message]) => ApiException(
        message: message ?? 'You don\'t have permission',
        statusCode: 403,
        type: ApiExceptionType.forbidden,
      );

  factory ApiException.notFound([String? message]) => ApiException(
        message: message ?? 'Resource not found',
        statusCode: 404,
        type: ApiExceptionType.notFound,
      );

  factory ApiException.validation(dynamic errors) => ApiException(
        message: 'Validation failed',
        statusCode: 422,
        data: errors,
        type: ApiExceptionType.validation,
      );

  bool get isAuth => type == ApiExceptionType.unauthorized || type == ApiExceptionType.forbidden;

  @override
  String toString() => 'ApiException($type): $message';
}

enum ApiExceptionType {
  network,
  timeout,
  server,
  unauthorized,
  forbidden,
  notFound,
  validation,
  cancelled,
  unknown,
}

/// Typed wrapper for API responses.
class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;
  final Map<String, dynamic>? meta;

  const ApiResponse({this.data, this.message, this.success = true, this.meta});

  factory ApiResponse.success(T data, {String? message, Map<String, dynamic>? meta}) =>
      ApiResponse(data: data, message: message, success: true, meta: meta);

  factory ApiResponse.error(String message) =>
      ApiResponse(message: message, success: false);
}
