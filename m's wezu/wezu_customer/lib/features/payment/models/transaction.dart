enum TransactionStatus {
  success,
  failed,
  refunded,
  processing,
  approved,
  rejected
}

enum TransactionType { rental, purchase, swap, walletTopUp, refund, withdrawal }

enum PaymentMethod { upi, creditCard, debitCard, wallet, netBanking }

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final TransactionType type;
  final PaymentMethod method;
  final String description;
  final String? invoiceUrl;
  final double? taxAmount;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
    required this.method,
    required this.description,
    this.invoiceUrl,
    this.taxAmount,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final statusRaw = json['status']?.toString().toLowerCase() ?? 'success';
    final typeRaw = (json['transaction_type'] ??
            json['category'] ??
            json['type'] ??
            'purchase')
        .toString()
        .toLowerCase();
    final normalizedType = switch (typeRaw) {
      'wallet_topup' || 'deposit' => 'walletTopUp',
      'withdrawal' || 'withdrawal_request' => 'withdrawal',
      'refund' => 'refund',
      'rental' => 'rental',
      'swap' => 'swap',
      _ => 'purchase',
    };
    final methodRaw = (json['method'] ?? json['payment_method'] ?? 'wallet')
        .toString()
        .toLowerCase();
    final normalizedMethod = switch (methodRaw) {
      'upi' => 'upi',
      'credit_card' => 'creditCard',
      'debit_card' => 'debitCard',
      'netbanking' || 'net_banking' => 'netBanking',
      'wallet' => 'wallet',
      _ => 'wallet',
    };
    return Transaction(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['timestamp']?.toString() ??
              json['created_at']?.toString() ??
              '')?.toLocal() ??
          DateTime.now(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == statusRaw,
        orElse: () => TransactionStatus.success,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == normalizedType,
        orElse: () => TransactionType.purchase,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == normalizedMethod,
        orElse: () => PaymentMethod.wallet,
      ),
      description: json['description'] ?? '',
      invoiceUrl: json['invoice_url'],
      taxAmount: json['tax_amount'] != null
          ? (json['tax_amount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'status': status.name,
      'transaction_type': type.name,
      'description': description,
    };
  }
}
