class PurchaseInvoice {
  final String invoiceId;
  final String orderId;
  final DateTime date;
  final String customerName;
  final String customerAddress;
  final List<InvoiceItem> items;
  final double subTotal;
  final double gstAmount; // 18% GST
  final double totalAmount;
  final String paymentMethod;
  final String transactionId;

  PurchaseInvoice({
    required this.invoiceId,
    required this.orderId,
    required this.date,
    required this.customerName,
    required this.customerAddress,
    required this.items,
    required this.subTotal,
    required this.gstAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.transactionId,
  });

  factory PurchaseInvoice.fromOrderDetails({
    required String orderId,
    required String customerName,
    required String customerAddress,
    required String productName,
    required double price,
    required String method,
    required String txnId,
  }) {
    final subTotal = price / 1.18; // Reverse GST calculation
    final gst = price - subTotal;
    
    return PurchaseInvoice(
      invoiceId: 'INV-${orderId.split('-').last}',
      orderId: orderId,
      date: DateTime.now(),
      customerName: customerName,
      customerAddress: customerAddress,
      items: [
        InvoiceItem(name: productName, quantity: 1, unitPrice: subTotal),
      ],
      subTotal: subTotal,
      gstAmount: gst,
      totalAmount: price,
      paymentMethod: method,
      transactionId: txnId,
    );
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });
}
