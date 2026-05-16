import '../../repositories/i_event_repository.dart';
import '../../../data/models/event/event_category_model.dart';

class GetCategoriesUseCase {
  final IEventRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<List<EventCategoryModel>> execute() async {
    return await _repository.getCategories();
  }
}
