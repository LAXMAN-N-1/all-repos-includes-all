/// TimeUtils — single source of truth for all timestamp formatting.
///
/// All methods accept ISO-8601 strings (with or without UTC 'Z' suffix).
/// They convert to the device's local timezone before formatting, so the
/// dealer always sees times in *their* timezone regardless of where the
/// customer rented the battery.
library time_utils;

class TimeUtils {
  TimeUtils._();

  // ── Low-level parser ────────────────────────────────────────────────────────

  /// Parse [iso] to a local [DateTime].
  /// Returns `null` if the string is blank or unparseable.
  static DateTime? parseLocal(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final raw = iso.trim();
    if (raw.isEmpty) return null;

    // Backend currently returns a mix of:
    // - ISO with timezone: 2026-04-30T11:45:00+00:00 / ...Z
    // - "str(datetime)" with space separator
    // - legacy naive UTC timestamps with no timezone suffix.
    // For naive timestamps, DateTime.parse treats them as local time by
    // default, so we explicitly reinterpret them as UTC before localizing.
    final normalized = raw.contains(' ') ? raw.replaceFirst(' ', 'T') : raw;
    final parsed = DateTime.tryParse(normalized);
    if (parsed == null) return null;

    final hasTime = RegExp(r'\d{2}:\d{2}').hasMatch(normalized);
    final hasExplicitTimezone =
        RegExp(r'(Z|z|[+-]\d{2}(:?\d{2})?)$').hasMatch(normalized);

    if (!hasExplicitTimezone && hasTime) {
      final asUtc = DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
      return asUtc.toLocal();
    }

    return parsed.toLocal();
  }

  // ── Display formatters ──────────────────────────────────────────────────────

  /// `DD/MM  HH:mm` in 24-hour, local timezone.
  /// Used in swap history table, active-rentals table, swap-visualisation table.
  static String shortDateTime(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    final d = _p2(dt.day);
    final mo = _p2(dt.month);
    final h = _p2(dt.hour);
    final mi = _p2(dt.minute);
    return '$d/$mo  $h:$mi';
  }

  /// `DD MMM YYYY, HH:mm` in 24-hour, local timezone.
  /// Used in detail drawers and panels where full clarity matters.
  static String longDateTime(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = _p2(dt.day);
    final mo = months[dt.month - 1];
    final h = _p2(dt.hour);
    final mi = _p2(dt.minute);
    return '$d $mo ${dt.year}, $h:$mi';
  }

  /// `DD MMM YYYY` — date only, local timezone.
  static String dateOnly(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// `HH:mm` — time only, local timezone. 24-hour format.
  static String timeOnly(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '—';
    return '${_p2(dt.hour)}:${_p2(dt.minute)}';
  }

  /// Relative human-readable label like "5m ago", "3h ago", "2d ago".
  static String timeAgo(String? iso) {
    final dt = parseLocal(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 10) return 'Just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  // ── Internal ────────────────────────────────────────────────────────────────
  static String _p2(int n) => n.toString().padLeft(2, '0');
}
