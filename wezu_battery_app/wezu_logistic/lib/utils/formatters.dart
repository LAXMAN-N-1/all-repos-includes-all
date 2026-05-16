import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _date = DateFormat('MMM dd, yyyy');
  static final _dateTime = DateFormat('MMM dd, yyyy HH:mm');

  static String formatCurrency(double amount) => _currency.format(amount);
  
  static String formatDate(DateTime date) => _date.format(date);
  
  static String formatDateTime(DateTime date) => _dateTime.format(date);

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return formatDate(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
