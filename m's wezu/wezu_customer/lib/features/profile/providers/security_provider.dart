import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/security_service.dart';

class SecurityState {
  final bool isLoading;
  final String? error;
  final bool
      is2FAEnabled; // This needs to be fetched from user profile actually
  final List<dynamic> devices;

  SecurityState({
    this.isLoading = false,
    this.error,
    this.is2FAEnabled = false,
    this.devices = const [],
  });

  SecurityState copyWith({
    bool? isLoading,
    String? error,
    bool? is2FAEnabled,
    List<dynamic>? devices,
  }) {
    return SecurityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      is2FAEnabled: is2FAEnabled ?? this.is2FAEnabled,
      devices: devices ?? this.devices,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  final SecurityService _securityService;
  final FlutterSecureStorage _storage;

  SecurityNotifier(this._securityService, this._storage)
      : super(SecurityState()) {
    _load2FAStatus();
  }

  Future<void> _load2FAStatus() async {
    final status = await _storage.read(key: 'is_2fa_enabled');
    state = state.copyWith(is2FAEnabled: status == 'true');
  }

  Future<void> loadDevices() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final devices = await _securityService.getDevices();
      state = state.copyWith(isLoading: false, devices: devices);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> request2FAOTP() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _securityService.enable2FA();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> requestDisable2FAOTP() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _securityService.requestDisable2FA();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> registerBiometric(
      String deviceId, String credentialId, String biometricToken) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _securityService.registerBiometric(
          deviceId: deviceId,
          credentialId: credentialId,
          biometricToken: biometricToken);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verify2FAOTP(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _securityService.verify2FA(code);
      await _storage.write(key: 'is_2fa_enabled', value: 'true');
      state = state.copyWith(isLoading: false, is2FAEnabled: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> disable2FA(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _securityService.disable2FA(code);
      await _storage.delete(key: 'is_2fa_enabled');
      state = state.copyWith(isLoading: false, is2FAEnabled: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> revokeDevice(String deviceId) async {
    try {
      await _securityService.revokeDevice(deviceId);
      await loadDevices();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier(
      ref.watch(securityServiceProvider), const FlutterSecureStorage());
});
