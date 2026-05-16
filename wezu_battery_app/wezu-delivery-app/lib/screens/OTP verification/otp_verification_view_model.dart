import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../repositories/auth_repository.dart';
import '../../utils/app_logger.dart';

class OtpVerificationViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AppLogger _logger = AppLogger('OtpVerificationViewModel');

  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get timerSeconds => _timerSeconds;
  bool get canResend => _canResend;

  OtpVerificationViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository {
    startTimer();
  }

  void startTimer() {
    _timerSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _canResend = true;
        _timer?.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<bool> verifyOtp(String otp, String phoneNumber) async {
    try {
      _logger.info('Verifying OTP for $phoneNumber');
      _setLoading(true);
      _setError(null);

      if (otp.length != 6) {
        _setError('Please enter a valid 6-digit code');
        return false;
      }

      final success = await _authRepository.verifyOtp(otp);

      if (success) {
        _logger.info('OTP verification successful');
        return true;
      } else {
        _logger.warning('OTP verification failed');
        _setError('Invalid OTP. Please try again.');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.error('Error verifying OTP', e, stackTrace);
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    if (!_canResend) return;

    try {
      _logger.info('Resending OTP to $phoneNumber');
      _setLoading(true);
      final success = await _authRepository.requestOtp(phoneNumber);
      if (success) {
        startTimer();
        _logger.info('OTP resent successfully');
      } else {
        _setError('Failed to resend OTP. Please try again.');
      }
    } catch (e) {
      _logger.error('Error resending OTP', e);
      _setError('Failed to resend OTP');
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
