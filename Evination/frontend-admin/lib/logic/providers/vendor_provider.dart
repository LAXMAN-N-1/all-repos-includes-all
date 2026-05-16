import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_panel/data/models/vendor/vendor_admin_model.dart';
import 'package:admin_panel/data/models/vendor/vendor_registration_model.dart';
import 'package:admin_panel/data/repositories/vendor_repository_impl.dart';
import 'package:admin_panel/data/datasources/vendor_remote_source.dart';
import 'package:admin_panel/core/api_client.dart';

final vendorRemoteSourceProvider = Provider<VendorRemoteSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VendorRemoteSourceImpl(apiClient);
});

final vendorRepositoryProvider = Provider<VendorRepositoryImpl>((ref) {
  return VendorRepositoryImpl(ref.watch(vendorRemoteSourceProvider));
});

// State
class VendorState {
  final bool isLoading;
  final List<AdminVendorModel> vendors;
  final String? error;
  final String currentFilter;
  final int? categoryId;

  VendorState({
    this.isLoading = false, 
    this.vendors = const [], 
    this.error,
    this.currentFilter = 'pending',
    this.categoryId,
  });
}

class VendorController extends Notifier<VendorState> {
  @override
  VendorState build() {
    return VendorState();
  }

  Future<void> loadVendors(String status, {int? categoryId}) async {
    state = VendorState(isLoading: true, currentFilter: status, categoryId: categoryId);
    final repository = ref.read(vendorRepositoryProvider);
    final result = await repository.getVendors(status, categoryId: categoryId);
    result.fold(
      (l) => state = VendorState(isLoading: false, error: l.message, currentFilter: status, categoryId: categoryId),
      (r) => state = VendorState(isLoading: false, vendors: r, currentFilter: status, categoryId: categoryId),
    );
  }

  // Alias for backward compatibility/initial load
  Future<void> loadPendingVendors() async => loadVendors('pending');

  Future<bool> approveVendor(int id) async {
    final repository = ref.read(vendorRepositoryProvider);
    final result = await repository.approveVendor(id);
    return result.fold(
      (l) => false,
      (r) {
        loadVendors(state.currentFilter, categoryId: state.categoryId); // Refresh current list
        return true; 
      },
    );
  }

  Future<bool> verifyDocument(int vendorId, int docId, String status) async {
    final repository = ref.read(vendorRepositoryProvider);
    final result = await repository.verifyDocument(vendorId, docId, status);
    return result.isRight();
  }

  Future<bool> createVendor(VendorRegistrationModel data) async {
    state = VendorState(isLoading: true, vendors: state.vendors, currentFilter: state.currentFilter);
    final repository = ref.read(vendorRepositoryProvider);
    final result = await repository.createVendor(data);
    
    // Always refresh list after create, or handle error
    return result.fold(
      (l) {
        state = VendorState(isLoading: false, vendors: state.vendors, currentFilter: state.currentFilter, error: l.message);
        return false;
      },
      (r) {
        loadVendors(state.currentFilter, categoryId: state.categoryId); 
        return true;
      },
    );
  }
}

final vendorProvider = NotifierProvider<VendorController, VendorState>(() {
  return VendorController();
});
