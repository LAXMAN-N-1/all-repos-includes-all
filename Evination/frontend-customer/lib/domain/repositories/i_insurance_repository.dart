import '../../data/models/insurance/insurance_model.dart';

abstract class IInsuranceRepository {
  Future<List<InsuranceModel>> getInsurancePlans();
  Future<InsuranceModel> getInsurancePlanById(String id);
}
