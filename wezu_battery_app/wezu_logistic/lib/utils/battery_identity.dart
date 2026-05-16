String normalizeBatterySerial(String value) => value.trim().toUpperCase();

List<String> normalizeBatterySerials(Iterable<String> values) {
  final unique = <String>{};
  final normalized = <String>[];
  for (final raw in values) {
    final serial = normalizeBatterySerial(raw);
    if (serial.isEmpty || unique.contains(serial)) {
      continue;
    }
    unique.add(serial);
    normalized.add(serial);
  }
  return normalized;
}
