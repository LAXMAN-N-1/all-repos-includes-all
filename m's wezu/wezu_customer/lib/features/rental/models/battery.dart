class Battery {
  String get modelName => modelNumber;
  String get capacityAh => (capacityMAh / 1000).toStringAsFixed(1);

  final int id;
  final String serialNumber;
  final String modelNumber;
  final String manufacturer;
  final String type;
  final int capacityMAh;
  final double voltage;
  final double healthPercentage;
  final double currentCharge;
  final double currentVoltage;
  final double currentTemp;
  final String status;
  final double rentalPricePerDay;
  final double damageDepositAmount;
  final List<String> certifications;
  final int cycleCount;
  final String warrantyInfo;
  final Map<String, dynamic> technicalSpecs;
  final String? qrCodeData;

  Battery({
    required this.id,
    required this.serialNumber,
    required this.modelNumber,
    required this.manufacturer,
    required this.type,
    required this.capacityMAh,
    required this.voltage,
    required this.healthPercentage,
    required this.status,
    required this.rentalPricePerDay,
    required this.damageDepositAmount,
    this.currentCharge = 100.0,
    this.currentVoltage = 72.0,
    this.currentTemp = 25.0,
    this.cycleCount = 0,
    this.warrantyInfo = '12 Months Standard',
    this.technicalSpecs = const {},
    this.certifications = const [],
    this.qrCodeData,
  });

  factory Battery.fromJson(Map<String, dynamic> json) {
    final sku = json['sku'];
    final skuMap = sku is Map ? sku : const {};
    return Battery(
      id: (json['id'] as num?)?.toInt() ?? 0,
      serialNumber: json['serial_number'] ?? 'SN-${json['id']}',
      modelNumber: json['model_number'] ??
          skuMap['model'] ??
          skuMap['name'] ??
          'Model-X',
      manufacturer: json['manufacturer'] ?? 'Wezu Energy',
      type: json['battery_type'] ?? skuMap['battery_type'] ?? 'Li-ion',
      capacityMAh:
          (json['capacity_mah'] ?? skuMap['capacity_mah'] ?? 5000).toInt(),
      voltage: (json['voltage_v'] as num?)?.toDouble() ??
          (json['voltage'] as num?)?.toDouble() ??
          (skuMap['voltage'] as num?)?.toDouble() ??
          72.0,
      healthPercentage:
          (json['health_percentage'] as num?)?.toDouble() ?? 100.0,
      currentCharge: (json['current_charge'] as num?)?.toDouble() ?? 100.0,
      currentVoltage: (json['current_voltage'] as num?)?.toDouble() ?? 72.0,
      currentTemp: (json['current_temp'] as num?)?.toDouble() ??
          (json['temp'] as num?)?.toDouble() ??
          25.0,
      status: json['status'] ?? 'available',
      rentalPricePerDay: (json['rental_price_per_day'] as num?)?.toDouble() ??
          (json['daily_rate'] as num?)?.toDouble() ??
          45.0,
      damageDepositAmount:
          (json['damage_deposit_amount'] as num?)?.toDouble() ??
              (json['security_deposit'] as num?)?.toDouble() ??
              500.0,
      cycleCount: json['cycle_count'] ?? 12,
      warrantyInfo: json['warranty_info'] ?? '1 Year Limited',
      technicalSpecs: json['technical_specs'] ?? {},
      certifications: json['certification_details'] != null
          ? List<String>.from(json['certification_details'])
          : ['ISO 9001', 'CE Certified', 'BIS Approved'],
      qrCodeData: json['qr_code_data'] ?? json['serial_number'],
    );
  }
}
