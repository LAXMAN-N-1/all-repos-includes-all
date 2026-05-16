import 'dart:math';

final Random _idempotencyRandom = Random.secure();

String buildIdempotencyKey(String scope) {
  final cleanedScope = scope.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  final nonce = _idempotencyRandom.nextInt(1 << 32).toRadixString(16);
  return '$cleanedScope-$timestamp-$nonce';
}

Map<String, String> buildIdempotencyHeaders(String scope) {
  return {'Idempotency-Key': buildIdempotencyKey(scope)};
}
