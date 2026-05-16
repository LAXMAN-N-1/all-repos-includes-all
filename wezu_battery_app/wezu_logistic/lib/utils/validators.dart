import '../config/app_constants.dart';

/// Form validation functions for consistent input validation.
class Validators {
  Validators._();

  // Supports modern TLDs (for example `.energy`) and common local-part chars.
  static final RegExp _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates an email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (value.length > AppConstants.maxEmailLength) {
      return 'Email is too long';
    }
    if (!_emailPattern.hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password strength.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'Password is too long';
    }
    return null;
  }

  /// Validates password confirmation.
  static String? confirmPassword(String? value, String password) {
    final passwordError = Validators.password(value);
    if (passwordError != null) return passwordError;
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a phone number (10 digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != AppConstants.phoneLength) {
      return 'Please enter a valid ${AppConstants.phoneLength}-digit phone number';
    }
    return null;
  }

  /// Validates a minimum length.
  static String? minLength(
    String? value,
    int min, [
    String fieldName = 'This field',
  ]) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  /// Validates a numeric value.
  static String? numeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }
}
