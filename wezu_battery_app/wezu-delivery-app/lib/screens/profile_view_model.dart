import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;

  ProfileViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    _authRepository.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _authRepository.removeListener(notifyListeners);
    super.dispose();
  }

  UserProfile get user => _authRepository.currentUser ?? UserProfile.empty();
  bool get isLoading => _isLoading;

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.updateProfile(
      name: name,
      phone: phone,
      email: email,
      address: address,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateVehicle({
    String? type,
    String? model,
    String? plateNumber,
    String? color,
    String? year,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.updateVehicle(
      type: type,
      model: model,
      plateNumber: plateNumber,
      color: color,
      year: year,
    );

    _isLoading = false;
    notifyListeners();
  }
}
