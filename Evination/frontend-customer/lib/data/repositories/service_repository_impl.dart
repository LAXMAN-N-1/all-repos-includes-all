import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_service_repository.dart';
import '../models/service/service_model.dart';

class ServiceRepositoryImpl implements IServiceRepository {
  @override
  Future<List<ServiceModel>> getServices(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock based on category ?
    return [
       ServiceModel(
         id: '1',
         vendorId: 'v1',
         name: '$category Package A',
         description: 'Basic package for $category',
         price: 5000,
         category: category,
         imageUrl: 'https://via.placeholder.com/150',
       ),
       ServiceModel(
         id: '2',
         vendorId: 'v2',
         name: '$category Premium',
         description: 'Premium package for $category',
         price: 15000,
         category: category,
         imageUrl: 'https://via.placeholder.com/150',
       ),
    ];
  }

  @override
  Future<ServiceModel> getServiceById(String id) async {
    return ServiceModel(
         id: id,
         vendorId: 'v1',
         name: 'Service $id',
         description: 'Description',
         price: 1000,
         category: 'General',
    );
  }
}

final serviceRepositoryProvider = Provider<IServiceRepository>((ref) {
  return ServiceRepositoryImpl();
});
