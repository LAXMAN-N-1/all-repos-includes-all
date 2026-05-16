import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api_client.dart';
import '../models/menu_model.dart';

final menuServiceProvider = Provider<MenuService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MenuService(apiClient);
});

class MenuService {
  final ApiClient _apiClient;

  MenuService(this._apiClient);

  Future<List<Menu>> getMenus() async {
    try {
      final response = await _apiClient.get('/menus/');
      final List<dynamic> data = response.data;
      return data.map((json) => Menu.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load menus: $e');
    }
  }
}
