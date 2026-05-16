import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_constants.dart';

class SecurityService {
  final Dio _dio;
  SecurityService(this._dio);

  Future<void> enable2FA() async {
    await _dio.post(ApiConstants.twoFAEnable);
  }

  Future<void> verify2FA(String code) async {
    await _dio.post(ApiConstants.twoFAVerify, data: {'code': code});
  }

  Future<void> requestDisable2FA() async {
    // Backend disables 2FA directly through /auth/2fa/disable.
    // The OTP screen will call disable2FA() with the entered code.
    return;
  }

  Future<void> registerBiometric(
      {required String deviceId,
      required String credentialId,
      required String biometricToken}) async {
    await _dio.post(
      ApiConstants.biometricRegister,
      data: {
        'device_id': deviceId,
        'credential_id': credentialId,
        'public_key': biometricToken,
        'biometric_token': biometricToken,
      },
    );
  }

  Future<void> disable2FA(String code) async {
    await _dio.post(ApiConstants.twoFADisable, data: {
      'code': code,
      'password': code,
    });
  }

  Future<List<dynamic>> getDevices() async {
    try {
      final response =
          await _dio.get('${ApiConstants.apiBaseUrl}/users/devices');
      return response.data['data'] ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> revokeDevice(String deviceId) async {
    try {
      await _dio
          .delete('${ApiConstants.apiBaseUrl}/security/devices/$deviceId');
    } catch (_) {}
  }
}

final securityServiceProvider = Provider((ref) {
  return SecurityService(ref.read(authenticatedDioProvider));
});
