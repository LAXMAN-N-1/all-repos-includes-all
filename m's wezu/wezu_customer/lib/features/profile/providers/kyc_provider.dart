import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/kyc_service.dart';

class KYCState {
  final bool isLoading;
  final String? error;
  
  KYCState({this.isLoading = false, this.error});

  KYCState copyWith({bool? isLoading, String? error}) {
    return KYCState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class KYCNotifier extends StateNotifier<KYCState> {
  final KYCService _kycService;
  final AuthNotifier _authNotifier;

  KYCNotifier(this._kycService, this._authNotifier) : super(KYCState());

  Future<void> submitKYC({
    required String idNumber,
    required String idType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _kycService.submitKYC(idNumber: idNumber, idType: idType);
      state = state.copyWith(isLoading: false);
      // Ideally refresh auth user status or profile
      _authNotifier.refreshUser(); // Refresh user profile after KYC update
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> uploadDocument(String filePath, String docType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _kycService.uploadDocument(filePath: filePath, docType: docType);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final kycProvider = StateNotifierProvider<KYCNotifier, KYCState>((ref) {
  return KYCNotifier(
    ref.watch(kycServiceProvider),
    ref.read(authProvider.notifier),
  );
});
