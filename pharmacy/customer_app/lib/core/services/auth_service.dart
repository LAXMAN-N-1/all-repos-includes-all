import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  // Use 192.168.1.11 (Your Mac's Local IP) for physical device testing
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.11:8001/api/v1/auth', 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _token;
  bool get isAuthenticated => _token != null;

  Future<void> sendOTP(String phoneNumber) async {
    _setLoading(true);
    try {
      await _dio.post('/otp/send', data: {'phone_number': phoneNumber});
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to send OTP');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOTP(String phoneNumber, String otp) async {
    _setLoading(true);
    try {
      final response = await _dio.post('/otp/verify', data: {
        'phone_number': phoneNumber,
        'otp': otp,
      });
      
      final data = response.data;
      _token = data['access_token'];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      await prefs.setString('user_id', data['user']['id']);
      
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Invalid OTP');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
