import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(apiClientProvider));
});

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categories/');
    return (response.data as List).map((json) => Category.fromJson(json)).toList();
  }

  Future<Category> createCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/categories/', data: data);
    return Category.fromJson(response.data);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/categories/$id', data: data);
    return Category.fromJson(response.data);
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('/categories/$id');
  }
}
