import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/data/models/onboarding/onboarding_models.dart';
import 'package:vendor_app/data/repositories/onboarding_repository_impl.dart';
import 'package:vendor_app/data/datasources/onboarding_remote_source.dart';
import 'package:vendor_app/logic/providers/auth_provider.dart'; // Adjust if needed for dio/auth
import 'package:dio/dio.dart';

// --- Dependency Injection ---

final onboardingRemoteSourceProvider = Provider<OnboardingRemoteSource>((ref) {
  // Assuming dio is available globally or via another provider
  // For now creating new or getting from a dioProvider if exists.
  // Ideally: final dio = ref.watch(dioProvider);
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000')); // Replace with config
  // For integration, usually we reuse the authenticated Dio instance
  // ref.watch(dioProvider) is better.
  return OnboardingRemoteSourceImpl(dio); 
});

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingRemoteSourceProvider));
});


// --- State Management ---

class OnboardingState {
  final int currentStep;
  final bool isLoading;
  final String? error;
  
  // Form Data
  final String vendorType;
  final InitiateRequest? basicInfo;
  final BusinessDetailsRequest? businessDetails;
  final List<DocItem> documents;
  
  OnboardingState({
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
    this.vendorType = 'company',
    this.basicInfo,
    this.businessDetails,
    this.documents = const [],
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    String? vendorType,
    InitiateRequest? basicInfo,
    BusinessDetailsRequest? businessDetails,
    List<DocItem>? documents,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullifiable if not passed? usually we clear error on new action
      vendorType: vendorType ?? this.vendorType,
      basicInfo: basicInfo ?? this.basicInfo,
      businessDetails: businessDetails ?? this.businessDetails,
      documents: documents ?? this.documents,
    );
  }
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState();
  }

  void setVendorType(String type) {
    state = state.copyWith(vendorType: type);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }
  
  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<bool> submitBasicInfo(InitiateRequest data) async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = ref.read(onboardingRepositoryProvider);
    final result = await repository.initiateOnboarding(data);
    return result.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.message);
        return false;
      },
      (r) {
        state = state.copyWith(isLoading: false, basicInfo: data);
        nextStep();
        return true;
      },
    );
  }

  Future<bool> submitBusinessDetails(BusinessDetailsRequest data) async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = ref.read(onboardingRepositoryProvider);
    final result = await repository.saveBusinessDetails(data);
    return result.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.message);
        return false;
      },
      (r) {
        state = state.copyWith(isLoading: false, businessDetails: data);
        nextStep();
        return true;
      },
    );
  }
  
  Future<bool> submitDocuments(List<DocItem> docs) async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = ref.read(onboardingRepositoryProvider);
    final result = await repository.saveDocuments(DocumentUploadRequest(documents: docs));
    return result.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.message);
        return false;
      },
      (r) {
        state = state.copyWith(isLoading: false, documents: docs);
        nextStep();
        return true;
      },
    );
  }

  Future<bool> finalSubmit() async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = ref.read(onboardingRepositoryProvider);
    final result = await repository.submitApplication();
    return result.fold(
      (l) {
        state = state.copyWith(isLoading: false, error: l.message);
        return false;
      },
      (r) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }
}

final onboardingProvider = NotifierProvider<OnboardingController, OnboardingState>(() {
  return OnboardingController();
});
