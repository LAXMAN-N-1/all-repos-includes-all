import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vendor_model.dart';
import '../../data/services/vendor_service.dart';

final vendorsProvider = AsyncNotifierProvider<VendorsNotifier, List<Vendor>>(VendorsNotifier.new);

class VendorsNotifier extends AsyncNotifier<List<Vendor>> {
  @override
  Future<List<Vendor>> build() async {
    final vendorService = ref.watch(vendorServiceProvider);
    return vendorService.getVendors();
  }

  Future<void> updateStatus(int id, String status) async {
    final vendorService = ref.read(vendorServiceProvider);
    try {
      await vendorService.updateVendorStatus(id, status);
      // Optimistic update
      final currentList = state.value ?? [];
       state = AsyncValue.data(currentList.map((v) {
          if (v.id == id) {
             return Vendor(
              id: v.id,
              userId: v.userId,
              companyName: v.companyName,
              businessType: v.businessType,
              phone: v.phone,
              address: v.address,
              city: v.city,
              state: v.state,
              zipCode: v.zipCode,
              website: v.website,
              yearEstablished: v.yearEstablished,
              teamSize: v.teamSize,
              description: v.description,
              status: status,
            );
          }
          return v;
        }).toList());
    } catch (e) {
      print(e);
    }
  }
}
