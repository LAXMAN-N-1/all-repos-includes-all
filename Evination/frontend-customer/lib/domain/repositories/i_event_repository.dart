import '../../data/models/event/event_category_model.dart';

abstract class IEventRepository {
  Future<List<EventCategoryModel>> getCategories();
}
