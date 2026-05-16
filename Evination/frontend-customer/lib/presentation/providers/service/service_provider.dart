import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/service/service_model.dart';
import '../../../data/repositories/service_repository_impl.dart';

final servicesProvider = FutureProvider.family<List<ServiceModel>, String>((ref, category) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return repository.getServices(category);
});
