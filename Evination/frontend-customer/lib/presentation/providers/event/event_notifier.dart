import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/event/event_category_model.dart';
import '../../../domain/usecases/event/get_categories_usecase.dart';
import '../app/app_provider.dart';

class EventState {
  final List<EventCategoryModel> categories;
  final bool isLoading;
  final String? error;

  EventState({required this.categories, required this.isLoading, this.error});

  EventState.initial() : categories = [], isLoading = false, error = null;
}

class EventNotifier extends StateNotifier<EventState> {
  final GetCategoriesUseCase _getCategoriesUseCase;

  EventNotifier(this._getCategoriesUseCase) : super(EventState.initial()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    state = EventState(categories: state.categories, isLoading: true);
    try {
      final categories = await _getCategoriesUseCase.execute();
      state = EventState(categories: categories, isLoading: false);
    } catch (e) {
      state = EventState(categories: state.categories, isLoading: false, error: e.toString());
    }
  }
}

final eventProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
  return EventNotifier(getCategoriesUseCase);
});
