import 'package:dio/dio.dart';
import '../../../data/models/event/event_category_model.dart';
import '../../../../core/api/api_endpoints.dart';

class EventRemoteDataSource {
  final Dio _dio;

  EventRemoteDataSource(this._dio);

  Future<List<EventCategoryModel>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.categories);
    return (response.data as List)
        .map((e) => EventCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
