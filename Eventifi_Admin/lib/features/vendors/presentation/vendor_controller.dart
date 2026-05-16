import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:eventifi_admin/features/vendors/data/vendor_repository.dart';
import 'package:eventifi_admin/features/vendors/domain/vendor_models.dart';

part 'vendor_controller.g.dart';

@riverpod
class VendorController extends _$VendorController {
  @override
  FutureOr<List<Vendor>> build() async {
    return _fetchVendors();
  }

  Future<List<Vendor>> _fetchVendors() async {
    final repository = ref.read(vendorRepositoryProvider);
    return await repository.getVendors();
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchVendors());
  }

  Future<void> createVendor(CreateVendorRequest request) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.createVendor(request);
    ref.invalidateSelf();
  }

  Future<void> updateVendor(int id, CreateVendorRequest request) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.updateVendor(id, request);
    ref.invalidateSelf();
  }

  Future<void> deleteVendor(int id) async {
    final repository = ref.read(vendorRepositoryProvider);
    await repository.deleteVendor(id);
    ref.invalidateSelf();
  }
}
