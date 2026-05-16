/// Generic wrapper for API responses.
/// Provides consistent response handling across the app.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  /// Create a successful response.
  factory ApiResponse.success({
    T? data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  /// Create a failure response.
  factory ApiResponse.failure({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message ?? 'Something went wrong',
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Parse from JSON with a data parser function.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && dataParser != null
          ? dataParser(json['data'])
          : null,
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() =>
      'ApiResponse(success: $success, statusCode: $statusCode, message: $message)';
}
