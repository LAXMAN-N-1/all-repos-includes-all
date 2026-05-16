enum TempState { normal, warning, critical }

class BatteryHealth {
  final double voltage;
  final double minVoltage;
  final double maxVoltage;
  final double temperature;
  final TempState tempState;
  final int soc; // State of Charge (0-100)
  final int soh; // State of Health (0-100)
  final List<int> degradationTrend; // Past 10 readings

  BatteryHealth({
    required this.voltage,
    required this.minVoltage,
    required this.maxVoltage,
    required this.temperature,
    required this.tempState,
    required this.soc,
    required this.soh,
    required this.degradationTrend,
  });

  bool get isHealthCritical => soh < 80;
}
