import 'package:intl/intl.dart';

/// String utility extensions.
extension StringExtension on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');
  String truncate(int max, {String suffix = '…'}) =>
      length <= max ? this : '${substring(0, max)}$suffix';
  String get initials => split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
  String get slug => toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

  bool get isEmail => RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.\-]+$').hasMatch(this);
  bool get isPhone => RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(this);
  bool get isNumeric => double.tryParse(this) != null;
}

/// DateTime utility extensions.
extension DateTimeExtension on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String format([String pattern = 'dd MMM yyyy']) => DateFormat(pattern).format(this);
  String get formatDate => DateFormat.yMMMd().format(this);
  String get formatTime => DateFormat.jm().format(this);
  String get formatFull => DateFormat('dd MMM yyyy, hh:mm a').format(this);
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

/// Number utility extensions.
extension NumberExtension on num {
  String toCurrency({String symbol = '₹', int decimals = 2}) =>
      '$symbol${NumberFormat('#,##0.${List.filled(decimals, '0').join()}').format(this)}';

  String toCompact() {
    if (this >= 10000000) return '${(this / 10000000).toStringAsFixed(1)}Cr';
    if (this >= 100000) return '${(this / 100000).toStringAsFixed(1)}L';
    if (this >= 1000) return '${(this / 1000).toStringAsFixed(1)}K';
    return toStringAsFixed(0);
  }

  String get ordinal {
    final n = toInt();
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  Duration get ms => Duration(milliseconds: toInt());
  Duration get seconds => Duration(seconds: toInt());
  Duration get minutes => Duration(minutes: toInt());
}
