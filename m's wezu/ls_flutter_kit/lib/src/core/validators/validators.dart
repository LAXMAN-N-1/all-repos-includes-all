/// Composable form field validators.
///
/// ```dart
/// TextFormField(
///   validator: Validators.compose([
///     Validators.required('Email is required'),
///     Validators.email(),
///   ]),
/// )
/// ```
class Validators {
  Validators._();

  /// Compose multiple validators into one.
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  static String? Function(String?) required([String message = 'This field is required']) {
    return (value) => (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? Function(String?) email([String message = 'Enter a valid email']) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(value) ? null : message;
    };
  }

  static String? Function(String?) phone([String message = 'Enter a valid phone number']) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(value) ? null : message;
    };
  }

  static String? Function(String?) minLength(int min, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return value.length < min ? (message ?? 'Minimum $min characters required') : null;
    };
  }

  static String? Function(String?) maxLength(int max, [String? message]) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return value.length > max ? (message ?? 'Maximum $max characters allowed') : null;
    };
  }

  static String? Function(String?) pattern(RegExp regex, [String message = 'Invalid format']) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      return regex.hasMatch(value) ? null : message;
    };
  }

  static String? Function(String?) password({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireDigit = true,
    bool requireSpecial = false,
  }) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < minLength) return 'At least $minLength characters';
      if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) return 'Include an uppercase letter';
      if (requireDigit && !value.contains(RegExp(r'[0-9]'))) return 'Include a digit';
      if (requireSpecial && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Include a special character';
      return null;
    };
  }

  static String? Function(String?) match(String Function() getOther, [String message = 'Fields do not match']) {
    return (value) => value != getOther() ? message : null;
  }
}
