import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/menu_model.dart';
import '../../data/services/menu_service.dart';

final menusProvider = FutureProvider<List<Menu>>((ref) async {
  final service = ref.watch(menuServiceProvider);
  return service.getMenus();
});
