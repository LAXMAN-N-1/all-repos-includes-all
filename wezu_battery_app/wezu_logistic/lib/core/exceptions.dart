/// Core exceptions used across the application.
/// Provide structured error handling at every layer.

/// Base exception for all app-specific errors.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when an API request fails.
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  factory NetworkException.timeout() => const NetworkException(
        message: 'Request timed out. Please check your connection.',
        code: 'TIMEOUT',
      );

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection.',
        code: 'NO_CONNECTION',
      );

  factory NetworkException.serverError([int? statusCode]) => NetworkException(
        message: 'Server error. Please try again later.',
        code: 'SERVER_ERROR',
        statusCode: statusCode,
      );

  factory NetworkException.unauthorized() => const NetworkException(
        message: 'Session expired. Please log in again.',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );
}

/// Thrown when local storage operations fail.
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Thrown when form or input validation fails.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}
