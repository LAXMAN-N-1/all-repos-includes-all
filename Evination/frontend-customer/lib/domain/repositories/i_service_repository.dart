import '../../data/models/service/service_model.dart';

abstract class IServiceRepository {
  Future<List<ServiceModel>> getServices(String category);
  Future<ServiceModel> getServiceById(String id);
}
