/// TimeUtils — single source of truth for all timestamp formatting.
///
/// All methods accept ISO-8601 strings (with or without UTC 'Z' suffix) OR
/// pre-parsed [DateTime] objects.  They convert to the device's local timezone
/// before formatting, so every customer sees times in *their* timezone
/// regardless of where the backend stores them (UTC).
///
/// All time output is 24-hour format for clarity and consistency.
library time_utils;

class TimeUtils {
  TimeUtils._();

  // ── Low-level parser ────────────────────────────────────────────────────────

  /// Parse an ISO-8601 string to a local [DateTime].
  /// Returns `null` if the string is blank or unparseable.
  static DateTime? parseLocal(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso)?.toLocal();
  }

  // ── Display formatters (String → String) ───────────────────────────────────

  /// `DD MMM YYYY, HH:mm` — full date + 24h time in local timezone.
  /// e.g. "30 Apr 2026, 16:45"
  static String longDateTime(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${dt.day} ${_mon(dt.month)} ${dt.year}, ${_p2(dt.hour)}:${_p2(dt.minute)}';
  }

  /// `DD MMM, HH:mm` — short date + 24h time in local timezone.
  /// e.g. "30 Apr, 16:45"
  static String shortDateTime(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${dt.day} ${_mon(dt.month)}, ${_p2(dt.hour)}:${_p2(dt.minute)}';
  }

  /// `DD MMM YYYY` — date only, local timezone.
  static String dateOnly(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${dt.day} ${_mon(dt.month)} ${dt.year}';
  }

  /// `DD/MM/YYYY` — numeric date, local timezone.
  static String numericDate(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${_p2(dt.day)}/${_p2(dt.month)}/${dt.year}';
  }

  /// `DD/MM` — short numeric date (no year), local timezone.
  static String shortNumericDate(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${_p2(dt.day)}/${_p2(dt.month)}';
  }

  /// `HH:mm` — time only, 24-hour, local timezone.
  static String timeOnly(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${_p2(dt.hour)}:${_p2(dt.minute)}';
  }

  // ── DateTime overloads (already-parsed objects) ────────────────────────────

  /// Format a pre-parsed local [DateTime] as `HH:mm` (24-hour).
  static String timeFromDt(DateTime dt) =>
      '${_p2(dt.hour)}:${_p2(dt.minute)}';

  /// Format a pre-parsed local [DateTime] as `DD MMM YYYY, HH:mm`.
  static String longDateFromDt(DateTime dt) =>
      '${dt.day} ${_mon(dt.month)} ${dt.year}, ${_p2(dt.hour)}:${_p2(dt.minute)}';

  /// Format a pre-parsed local [DateTime] as `DD MMM, HH:mm`.
  static String shortDateFromDt(DateTime dt) =>
      '${dt.day} ${_mon(dt.month)}, ${_p2(dt.hour)}:${_p2(dt.minute)}';

  /// Format a pre-parsed local [DateTime] as `DD MMM YYYY`.
  static String dateOnlyFromDt(DateTime dt) =>
      '${dt.day} ${_mon(dt.month)} ${dt.year}';

  /// Format a pre-parsed local [DateTime] as `DD/MM/YYYY`.
  static String numericDateFromDt(DateTime dt) =>
      '${_p2(dt.day)}/${_p2(dt.month)}/${dt.year}';

  // ── Internals ───────────────────────────────────────────────────────────────
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _mon(int m) => _months[m - 1];
  static String _p2(int n) => n.toString().padLeft(2, '0');
}
