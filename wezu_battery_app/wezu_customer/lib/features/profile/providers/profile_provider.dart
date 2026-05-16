import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wezu_customer_app/features/auth/providers/auth_provider.dart';
import 'package:wezu_customer_app/features/profile/services/profile_service.dart';
import 'package:wezu_customer_app/features/auth/models/user_model.dart';
import '../models/address_model.dart';

class ProfileState {
  final bool isLoading;
  final bool isAvatarUploading;
  final bool isAddressLoading;
  final String? error;
  final List<AddressModel> addresses;

  ProfileState({
    this.isLoading = false,
    this.isAvatarUploading = false,
    this.isAddressLoading = false,
    this.error,
    this.addresses = const [],
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isAvatarUploading,
    bool? isAddressLoading,
    String? error,
    List<AddressModel>? addresses,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isAvatarUploading: isAvatarUploading ?? this.isAvatarUploading,
      isAddressLoading: isAddressLoading ?? this.isAddressLoading,
      error: error,
      addresses: addresses ?? this.addresses,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  final AuthNotifier _authNotifier;

  ProfileNotifier(this._profileService, this._authNotifier)
      : super(ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profileData = await _profileService.getProfile();

      if (profileData.containsKey('id')) {
        _authNotifier.updateUser(User.fromJson(profileData));
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAddresses({bool force = false}) async {
    if (!force && state.addresses.isNotEmpty) {
      return;
    }

    state = state.copyWith(isAddressLoading: true, error: null);
    try {
      final addresses = await _profileService.getAddresses();
      state = state.copyWith(isAddressLoading: false, addresses: addresses);
    } catch (e) {
      state = state.copyWith(isAddressLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _profileService.updateProfile(data);
      if (result.containsKey('id')) {
        _authNotifier.updateUser(User.fromJson(result));
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> uploadProfilePicture(XFile file) async {
    state = state.copyWith(isAvatarUploading: true, error: null);

    try {
      final user = await _profileService.uploadProfilePicture(file);
      if (user != null) {
        _authNotifier.updateUser(user);
      }
      state = state.copyWith(isAvatarUploading: false);
    } catch (e) {
      state = state.copyWith(isAvatarUploading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> removeProfilePicture() async {
    state = state.copyWith(isAvatarUploading: true, error: null);

    try {
      final user = await _profileService.removeProfilePicture();
      if (user != null) {
        _authNotifier.updateUser(user);
      }
      state = state.copyWith(isAvatarUploading: false);
    } catch (e) {
      state = state.copyWith(isAvatarUploading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    state = state.copyWith(isAddressLoading: true, error: null);
    try {
      final newAddress = await _profileService.addAddress(addressData);

      // Optimistically add to local state
      final updated = [...state.addresses, newAddress];
      state = state.copyWith(isAddressLoading: false, addresses: updated);
    } catch (e) {
      state = state.copyWith(isAddressLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> setDefaultAddress(int id) async {
    // Optimistically update UI immediately
    final optimistic = state.addresses.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
    state = state.copyWith(addresses: optimistic);

    try {
      await _profileService.setDefaultAddress(id);
      await loadAddresses(force: true);
    } catch (e) {
      // Revert on error
      await loadAddresses(force: true);
      rethrow;
    }
  }

  Future<void> deleteAddress(int id) async {
    // Optimistically remove from list
    final optimistic = state.addresses.where((a) => a.id != id).toList();
    state = state.copyWith(addresses: optimistic);

    try {
      await _profileService.deleteAddress(id);
    } catch (e) {
      // Restore on error
      await loadAddresses(force: true);
      rethrow;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    ref.watch(profileServiceProvider),
    ref.read(authProvider.notifier),
  );
});
