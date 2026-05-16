class RentalTimer {
  final String rentalId;
  final DateTime expiryTime;
  final Duration remainingDuration;
  final double lateFeeAmount;
  final double hourlyLateFee;
  final double dailyCap;

  RentalTimer({
    required this.rentalId,
    required this.expiryTime,
    required this.remainingDuration,
    this.lateFeeAmount = 0.0,
    this.hourlyLateFee = 1.50, // Mock $1.50 per hour
    this.dailyCap = 15.00,    // Mock max $15.00/day
  });

  bool get isWarningState => remainingDuration.inHours < 24 && !isExpired;
  bool get isCriticalState => remainingDuration.inMinutes < 60 && !isExpired;
  bool get isExpired => expiryTime.isBefore(DateTime.now());
  bool get isOverdue => isExpired;

  String get formattedRemaining {
    if (isExpired) return "OVERDUE";
    
    final days = remainingDuration.inDays;
    final hours = remainingDuration.inHours % 24;
    final minutes = remainingDuration.inMinutes % 60;

    if (days > 0) {
      return "${days}d ${hours}h ${minutes}m";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }
}
