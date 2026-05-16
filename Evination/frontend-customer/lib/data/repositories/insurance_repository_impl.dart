import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_insurance_repository.dart';
import '../models/insurance/insurance_model.dart';

class InsuranceRepositoryImpl implements IInsuranceRepository {
  @override
  Future<List<InsuranceModel>> getInsurancePlans() async {
    // Mock Data
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const InsuranceModel(
        id: '1',
        title: 'Basic Protection',
        description: 'Covers cancellation due to vendor issues',
        coverageAmount: 50000,
        premiumAmount: 999,
        providerName: 'SafeGuard',
        features: ['Vendor Cancellation', 'Weather Issues'],
      ),
      const InsuranceModel(
        id: '2',
        title: 'Premium Coverage',
        description: 'Complete event protection including medical',
        coverageAmount: 200000,
        premiumAmount: 2499,
        providerName: 'SecureEvent',
        features: ['All Basic', 'Medical Emergency', 'Equipment Damage'],
      ),
    ];
  }

  @override
  Future<InsuranceModel> getInsurancePlanById(String id) async {
    final plans = await getInsurancePlans();
    return plans.firstWhere((element) => element.id == id);
  }
}

final insuranceRepositoryProvider = Provider<IInsuranceRepository>((ref) {
  return InsuranceRepositoryImpl();
});
