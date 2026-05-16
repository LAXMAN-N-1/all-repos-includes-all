import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/app_logger.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AppLogger _logger = AppLogger('LoginViewModel');

  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Attempt to login with phone number
  Future<bool> loginWithPhoneNumber(String phoneNumber) async {
    try {
      _logger.info('Attempting login with phone number: $phoneNumber');
      _setLoading(true);
      _setError(null);

      // Validate input
      if (phoneNumber.isEmpty) {
        _setError('Phone number cannot be empty');
        return false;
      }

      if (phoneNumber.length != 10) {
        _setError('Phone number must be exactly 10 digits');
        return false;
      }

      // Call auth repository
      final success = await _authRepository.login(phoneNumber);

      if (success) {
        _logger.info('Login successful');
        return true;
      } else {
        _logger.warning('Login failed');
        _setError('Login failed. Please try again.');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error during login', e, stackTrace);
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}
