import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';
import '../../services/security_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_logger.dart';

enum SplashDestination { dashboard, login }

/// Startup orchestration for session restoration and app unlock.
class SplashViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storageService;
  final SecurityService _securityService;
  final AppLogger _logger = AppLogger('SplashViewModel');

  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SplashViewModel({
    required AuthRepository authRepository,
    required StorageService storageService,
    required SecurityService securityService,
  }) : _authRepository = authRepository,
       _storageService = storageService,
       _securityService = securityService;

  Future<SplashDestination> resolveStartupDestination() async {
    try {
      _setLoading(true);
      _setError(null);

      _logger.info('Initializing storage and auth session');
      await _storageService.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _logger.warning('Storage init timed out; continuing with defaults.');
        },
      );
      await _authRepository.initialize().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          _logger.warning(
            'Auth restore timed out; continuing without profile hydration.',
          );
        },
      );

      if (!_authRepository.isAuthenticated) {
        _logger.info('No active session found, route to login');
        return SplashDestination.login;
      }

      final unlockEnabled = await _storageService.isBiometricUnlockEnabled();
      if (!unlockEnabled) {
        _logger.info('Biometric unlock disabled, route to dashboard');
        return SplashDestination.dashboard;
      }

      final unlocked = await _attemptBiometricUnlock();
      if (unlocked) {
        _logger.info('App unlock successful');
        return SplashDestination.dashboard;
      }

      _logger.warning('App unlock failed/cancelled. Clearing session.');
      await _authRepository.logout();
      return SplashDestination.login;
    } catch (e, stackTrace) {
      _logger.error('Startup resolution failed', e, stackTrace);
      _setError('Failed to initialize app: ${e.toString()}');
      await _authRepository.logout();
      return SplashDestination.login;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> _attemptBiometricUnlock() async {
    try {
      return await _securityService.authenticateForAppUnlock();
    } on SecurityAuthException catch (e) {
      if (e.isNotEnrolled) {
        _logger.warning('No biometric/device lock enrolled. Skipping prompt.');
        return true;
      }
      _logger.warning('Biometric auth failed: ${e.message}');
      return false;
    } catch (_) {
      return false;
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
