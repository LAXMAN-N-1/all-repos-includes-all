class WithdrawalRequest {
  final double amount;
  final String? accountNo;
  final String? accountHolder;
  final String? ifsc;
  final String? upiId;
  final String method;

  WithdrawalRequest({
    required this.amount,
    this.accountNo,
    this.accountHolder,
    this.ifsc,
    this.upiId,
    required this.method,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'bank_details': 'Method: $method${accountNo != null ? ', Acc: $accountNo' : ''}${accountHolder != null ? ', Name: $accountHolder' : ''}${ifsc != null ? ', IFSC: $ifsc' : ''}${upiId != null ? ', UPI: $upiId' : ''}',
    };
  }
}
