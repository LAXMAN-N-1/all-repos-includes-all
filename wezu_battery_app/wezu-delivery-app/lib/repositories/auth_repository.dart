import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthRepository extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  UserProfile? _currentUser;
  bool _isAuthenticated = false;
  String _pendingPhone = '';

  AuthRepository({
    required AuthService authService,
    required StorageService storageService,
  }) : _authService = authService,
       _storageService = storageService;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  String get pendingPhone => _pendingPhone;

  /// Initialize: restore existing session from stored token.
  Future<void> initialize() async {
    final token = await _storageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      _authService.applyToken(token);
      final valid = await _authService.validateToken(token);
      if (valid) {
        _isAuthenticated = true;
        try {
          await _fetchAndApplyUserProfile();
        } catch (_) {
          // Keep session alive even if profile enrichment fails.
        }
      } else {
        await logout();
      }
    }
  }

  /// Step 1 – request OTP. Stores phone for the subsequent verify step.
  /// Also callable as [login] to match the existing LoginViewModel interface.
  Future<bool> login(String phoneNumber) => requestOtp(phoneNumber);

  Future<bool> requestOtp(String phoneNumber) async {
    _pendingPhone = phoneNumber;
    await _storageService.setPhoneNumber(phoneNumber);
    return _authService.requestOtp(phoneNumber);
  }

  /// Step 2 – verify OTP received via SMS.
  Future<bool> verifyOtp(String otp) async {
    final phone = _pendingPhone.isNotEmpty
        ? _pendingPhone
        : (await _storageService.getPhoneNumber() ?? '');

    final token = await _authService.verifyOtp(phone, otp);
    if (token == null || token.isEmpty) return false;

    await _storageService.setAuthToken(token);
    _authService.applyToken(token);
    _isAuthenticated = true;

    await _fetchAndApplyUserProfile();
    notifyListeners();
    return true;
  }

  /// Logout – clear token and user data.
  Future<void> logout() async {
    _authService.clearToken();
    await _storageService.clearAuthToken();
    _currentUser = null;
    _isAuthenticated = false;
    _pendingPhone = '';
    notifyListeners();
  }

  /// Fetch user profile from backend (/users/me) and map to [UserProfile].
  Future<void> _fetchAndApplyUserProfile() async {
    final userData = await _authService.fetchUserProfile();
    if (userData == null) return;

    final driverProfile = await _authService.fetchDriverProfile();
    _currentUser = _mapProfile(userData, driverProfile: driverProfile);
    notifyListeners();
  }

  UserProfile _mapProfile(
    Map<String, dynamic> data, {
    Map<String, dynamic>? driverProfile,
  }) {
    final profileId =
        _parseInt(driverProfile?['id']) ?? _parseInt(data['driver_profile_id']);
    if (profileId != null && profileId > 0) {
      _storageService.setDriverProfileId(profileId);
    }

    return UserProfile(
      id: data['id']?.toString() ?? '',
      name: data['full_name']?.toString() ?? data['name']?.toString() ?? '',
      phone:
          data['phone_number']?.toString() ?? data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      address: _buildAddress(data),
      profileImageUrl:
          data['avatar_url']?.toString() ??
          data['profile_image_url']?.toString() ??
          '',
      vehicle: _mapVehicle(driverProfile),
    );
  }

  VehicleDetails _mapVehicle(Map<String, dynamic>? profile) {
    if (profile == null) return VehicleDetails.empty();
    return VehicleDetails(
      type: profile['vehicle_type']?.toString() ?? '',
      model: profile['vehicle_model']?.toString() ?? '',
      plateNumber: profile['vehicle_plate']?.toString() ?? '',
      color: profile['vehicle_color']?.toString() ?? '',
      year: profile['vehicle_year']?.toString() ?? '',
    );
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  String _buildAddress(Map<String, dynamic> data) {
    final line =
        [
              data['address_line_1']?.toString(),
              data['address_line_2']?.toString(),
              data['city']?.toString(),
              data['state']?.toString(),
              data['pin_code']?.toString(),
              data['country']?.toString(),
            ]
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
    return line.join(', ');
  }

  /// Update profile fields (name, email).
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      email: email,
      address: address,
    );
    notifyListeners();
    // Sync to backend – partial update via /users/me PATCH
    // (backend supports PUT /users/me with {full_name, email})
  }

  /// Update vehicle details locally (sync if backend supports it).
  Future<void> updateVehicle({
    String? type,
    String? model,
    String? plateNumber,
    String? color,
    String? year,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      vehicle: _currentUser!.vehicle.copyWith(
        type: type,
        model: model,
        plateNumber: plateNumber,
        color: color,
        year: year,
      ),
    );
    notifyListeners();
  }
}
