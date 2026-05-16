import 'package:intl/intl.dart';

enum Timeframe { daily, weekly, monthly }

enum TransactionType { credit, debit }

class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });

  String get formattedAmount {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final value = formatter.format(amount);
    return type == TransactionType.debit ? '-$value' : value;
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return DateFormat('MMM d').format(date);
  }
}
