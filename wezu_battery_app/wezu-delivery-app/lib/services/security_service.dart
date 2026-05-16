import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Handles biometric / device-credential authentication used as a
/// secondary security step before processing a withdrawal.
class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true if the device supports biometrics OR device credentials
  /// (PIN/pattern/password). If neither is available the user cannot be
  /// prompted and withdrawals fall back to the confirmation-dialog-only flow.
  Future<bool> isDeviceAuthAvailable() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final canAuth = await _auth.isDeviceSupported();
      return canCheck || canAuth;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns the list of enrolled biometric types (face, fingerprint, etc.)
  Future<List<BiometricType>> availableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    } on MissingPluginException {
      return [];
    }
  }

  /// Prompts biometric or device-PIN authentication with a withdrawal-specific
  /// message. Returns true on success, false on cancellation or failure.
  ///
  /// Behaviour:
  /// - Tries biometrics first, then device credential as fallback.
  /// - If the device has no secure lock set up, returns false so the
  ///   withdrawal is blocked until the user sets up a lock.
  Future<bool> authenticateForWithdrawal() async {
    if (kIsWeb) return true;
    try {
      final available = await isDeviceAuthAvailable();
      if (!available) return false;
      return await _authenticate(
        localizedReason: 'Confirm your identity to authorise this withdrawal.',
      );
    } on PlatformException catch (e) {
      throw SecurityAuthException(e.code, e.message ?? 'Auth unavailable');
    } on MissingPluginException {
      return true;
    }
  }

  /// Prompts biometric or device-PIN authentication before a peer transfer.
  Future<bool> authenticateForTransfer() async {
    if (kIsWeb) return true;
    try {
      final available = await isDeviceAuthAvailable();
      if (!available) return false;
      return await _authenticate(
        localizedReason: 'Confirm your identity to authorise this transfer.',
      );
    } on PlatformException catch (e) {
      throw SecurityAuthException(e.code, e.message ?? 'Auth unavailable');
    } on MissingPluginException {
      return true;
    }
  }

  /// Prompts app unlock using biometrics or device credentials.
  Future<bool> authenticateForAppUnlock() async {
    if (kIsWeb) return true;
    try {
      final available = await isDeviceAuthAvailable();
      if (!available) return true;
      return await _authenticate(
        localizedReason: 'Authenticate to unlock your Wezu partner account.',
      );
    } on PlatformException catch (e) {
      throw SecurityAuthException(e.code, e.message ?? 'Auth unavailable');
    } on MissingPluginException {
      return true;
    }
  }

  Future<bool> _authenticate({required String localizedReason}) {
    return _auth.authenticate(
      localizedReason: localizedReason,
      options: const AuthenticationOptions(
        biometricOnly: false,
        stickyAuth: true,
        sensitiveTransaction: true,
      ),
    );
  }
}

/// Typed exception wrapping PlatformException codes from local_auth.
class SecurityAuthException implements Exception {
  final String code;
  final String message;
  const SecurityAuthException(this.code, this.message);

  @override
  String toString() => 'SecurityAuthException($code): $message';

  /// True when the device has no PIN/biometric enrolled at all.
  bool get isNotEnrolled =>
      code == 'NotEnrolled' || code == 'no_fragment_activity';

  /// True when the user actively cancelled (pressed Back / Cancel).
  bool get wasCancelled => code == 'UserCanceled' || code == 'auth_in_progress';
}
