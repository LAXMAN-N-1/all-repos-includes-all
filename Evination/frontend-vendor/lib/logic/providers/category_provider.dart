import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

final categoryListProvider = AsyncNotifierProvider<CategoryListNotifier, List<Category>>(() {
  return CategoryListNotifier();
});

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final service = ref.read(categoryServiceProvider);
    return service.getCategories();
  }

  Future<void> addCategory(String name, String code, String? description, String? icon, String? color) async {
    final service = ref.read(categoryServiceProvider);
    final newCategory = await service.createCategory({
      'name': name,
      'code': code,
      'description': description,
      'icon': icon,
      'color': color,
    });
    // Optimistic update or refetch
    final previousState = state.asData?.value ?? [];
    state = AsyncValue.data([...previousState, newCategory]);
  }

  Future<void> updateCategory(int id, String name, String? description, String? icon, String? color) async {
    final service = ref.read(categoryServiceProvider);
    final updatedCategory = await service.updateCategory(id, {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
    });
    
    final previousState = state.asData?.value ?? [];
    state = AsyncValue.data([
      for (final cat in previousState)
        if (cat.id == id) updatedCategory else cat
    ]);
  }

  Future<void> deleteCategory(int id) async {
    final service = ref.read(categoryServiceProvider);
    await service.deleteCategory(id);
    
    final previousState = state.asData?.value ?? [];
    state = AsyncValue.data([
      for (final cat in previousState)
        if (cat.id != id) cat
    ]);
  }
}
