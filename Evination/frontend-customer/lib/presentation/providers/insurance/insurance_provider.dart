import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/insurance/insurance_model.dart';
import '../../../data/repositories/insurance_repository_impl.dart';

final insuranceListProvider = FutureProvider<List<InsuranceModel>>((ref) async {
  final repository = ref.watch(insuranceRepositoryProvider);
  return repository.getInsurancePlans();
});
