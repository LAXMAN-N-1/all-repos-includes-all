import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../../data/services/customer_admin_service.dart';
import '../../data/models/customer/customer_admin_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Service Provider
final customerAdminServiceProvider = Provider<CustomerAdminService>((ref) {
  return CustomerAdminService(ref.watch(apiClientProvider));
});

// Providers
final customerListProvider = FutureProvider.autoDispose.family<List<CustomerStatModel>, String?>((ref, search) async {
  final service = ref.watch(customerAdminServiceProvider);
  return service.getCustomers(search: search);
});

final customerDetailProvider = FutureProvider.autoDispose.family<CustomerDetailModel, int>((ref, id) async {
  final service = ref.watch(customerAdminServiceProvider);
  return service.getCustomerDetails(id);
});
