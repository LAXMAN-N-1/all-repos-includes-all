import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wezu_customer_app/core/network/dio_provider.dart';
import 'package:wezu_customer_app/features/auth/models/user_model.dart';
import 'package:wezu_customer_app/features/profile/models/address_model.dart';

class ProfileService {
  final Dio _dio;
  ProfileService(this._dio);

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  dynamic _unwrapData(dynamic payload) {
    if (payload is Map && payload['data'] != null) {
      return payload['data'];
    }
    return payload;
  }

  User? _extractUser(dynamic payload) {
    final unwrapped = _unwrapData(payload);
    if (unwrapped is Map && unwrapped['user'] is Map) {
      return User.fromJson(_asMap(unwrapped['user']));
    }
    if (unwrapped is Map && unwrapped['id'] != null) {
      return User.fromJson(_asMap(unwrapped));
    }
    return null;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/users/me');
    return _asMap(_unwrapData(response.data));
  }

  Future<User?> uploadProfilePicture(XFile file) async {
    final formData = FormData.fromMap({
      'file': kIsWeb
          ? MultipartFile.fromBytes(await file.readAsBytes(),
              filename: file.name)
          : await MultipartFile.fromFile(file.path),
    });
    try {
      final response = await _dio.post('/users/me/profile-picture', data: formData);
      final embeddedUser = _extractUser(response.data);
      if (embeddedUser != null) return embeddedUser;
    } on DioException {
      // Fall back to legacy avatar endpoint for older backend variants.
      await _dio.post('/users/me/avatar', data: formData);
    }
    final profile = await getProfile();
    return profile.isNotEmpty ? User.fromJson(profile) : null;
  }

  Future<User?> removeProfilePicture() async {
    await _dio.delete('/users/me/avatar');
    final profile = await getProfile();
    return profile.isNotEmpty ? User.fromJson(profile) : null;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/users/me', data: data);
    return _asMap(_unwrapData(response.data));
  }

  // Addresses
  Future<List<AddressModel>> getAddresses() async {
    final response = await _dio.get('/users/me/addresses');
    final unwrapped = _unwrapData(response.data);
    if (unwrapped is! List) return const [];
    return unwrapped
        .map((item) => AddressModel.fromJson(_asMap(item)))
        .toList();
  }

  Future<AddressModel> addAddress(Map<String, dynamic> address) async {
    final response = await _dio.post('/users/me/addresses', data: address);
    return AddressModel.fromJson(_asMap(_unwrapData(response.data)));
  }

  Future<void> deleteAddress(int id) async {
    await _dio.delete('/users/me/addresses/$id');
  }

  Future<void> setDefaultAddress(int id) async {
    await _dio.put('/users/me/addresses/$id/default');
  }

  // Backward-compatible aliases used by older UI code paths.
  Future<Map<String, dynamic>> uploadAvatar(XFile file) async {
    final user = await uploadProfilePicture(file);
    return user?.toJson() ?? {};
  }

  Future<void> removeAvatar() async {
    await removeProfilePicture();
  }
}

final profileServiceProvider = Provider((ref) {
  return ProfileService(ref.read(authenticatedDioProvider));
});
