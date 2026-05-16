import 'package:flutter/material.dart';

/// Convenient extension methods on [BuildContext] for quick access
/// to theme, colors, text styles, and media query.
extension BuildContextExtensions on BuildContext {
  // ─── Theme ────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // ─── Media Query ──────────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get viewPadding => mediaQuery.viewPadding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  // ─── Navigation ───────────────────────────────────────────────────
  NavigatorState get navigator => Navigator.of(this);

  // ─── Snackbar ─────────────────────────────────────────────────────
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// String extensions for common transformations.
extension StringExtensions on String {
  static final RegExp _emailPattern = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
  );

  /// Capitalize the first letter.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case.
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Check if string is a valid email.
  bool get isValidEmail {
    return _emailPattern.hasMatch(this);
  }

  /// Check if string is a valid phone number (10 digits).
  bool get isValidPhone {
    return RegExp(r'^\d{10}$').hasMatch(this);
  }
}

/// DateTime formatting extensions.
extension DateTimeExtensions on DateTime {
  /// Format as "Feb 12, 2026".
  String get formatted {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Format as "12 Feb".
  String get shortFormatted {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day ${months[month - 1]}';
  }

  /// Format as relative time ("2h ago", "3d ago").
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return formatted;
  }
}
