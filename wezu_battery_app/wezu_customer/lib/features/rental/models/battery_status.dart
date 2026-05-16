class BatteryStatus {
  final double chargePercentage; // 0.0 - 1.0
  final double healthPercentage; // 0.0 - 1.0
  final double temperature; // °C
  final double voltage; // V
  final DateTime timestamp;

  BatteryStatus({
    required this.chargePercentage,
    required this.healthPercentage,
    required this.temperature,
    required this.voltage,
    required this.timestamp,
  });

  factory BatteryStatus.initial() {
    return BatteryStatus(
      chargePercentage: 0.95,
      healthPercentage: 0.98,
      temperature: 32.5,
      voltage: 74.2,
      timestamp: DateTime.now(),
    );
  }

  BatteryStatus copyWith({
    double? chargePercentage,
    double? healthPercentage,
    double? temperature,
    double? voltage,
    DateTime? timestamp,
  }) {
    return BatteryStatus(
      chargePercentage: chargePercentage ?? this.chargePercentage,
      healthPercentage: healthPercentage ?? this.healthPercentage,
      temperature: temperature ?? this.temperature,
      voltage: voltage ?? this.voltage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
