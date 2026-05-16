import '../../domain/repositories/i_event_repository.dart';
import '../datasources/remote/event_remote_datasource.dart';
import '../models/event/event_category_model.dart';

class EventRepositoryImpl implements IEventRepository {
  final EventRemoteDataSource _remoteDataSource;

  EventRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<EventCategoryModel>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }
}
