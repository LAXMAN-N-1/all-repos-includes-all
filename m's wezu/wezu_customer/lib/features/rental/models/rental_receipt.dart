class RentalReceipt {
  final String rentalId;
  final String batteryId;
  final String batteryModel;
  final int durationDays;
  final double dailyRate;
  final double subtotal;
  final double deposit;
  final double serviceFee;
  final double gst;
  final double discount;
  final double totalAmount;
  final DateTime timestamp;

  RentalReceipt({
    required this.rentalId,
    required this.batteryId,
    required this.batteryModel,
    required this.durationDays,
    required this.dailyRate,
    required this.subtotal,
    required this.deposit,
    required this.serviceFee,
    required this.gst,
    required this.discount,
    required this.totalAmount,
    required this.timestamp,
  });

  factory RentalReceipt.generate({
    required String batteryId,
    required String batteryModel,
    required int durationDays,
    required double dailyRate,
    required double subtotal,
    required double deposit,
    required double serviceFee,
    required double gst,
    required double discount,
    required double totalAmount,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomStr = (now.microsecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    
    return RentalReceipt(
      rentalId: 'WZ-RN-$dateStr-$randomStr',
      batteryId: batteryId,
      batteryModel: batteryModel,
      durationDays: durationDays,
      dailyRate: dailyRate,
      subtotal: subtotal,
      deposit: deposit,
      serviceFee: serviceFee,
      gst: gst,
      discount: discount,
      totalAmount: totalAmount,
      timestamp: now,
    );
  }
}
