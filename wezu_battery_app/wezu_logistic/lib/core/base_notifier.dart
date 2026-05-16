import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'result.dart';

/// Base notifier for features managing async data.
/// Eliminates repetitive loading/error/loaded boilerplate.
///
/// Usage:
/// ```dart
/// class DashboardNotifier extends BaseNotifier<DashboardStats> {
///   final DashboardRepository _repo;
///   DashboardNotifier(this._repo);
///
///   Future<void> loadStats() => execute(() => _repo.fetchStats());
/// }
/// ```
class BaseNotifier<T> extends StateNotifier<AsyncState<T>> {
  BaseNotifier() : super(AsyncState.initial());

  /// Current data if loaded, null otherwise.
  T? get currentData {
    final s = state;
    return s is AsyncLoaded<T> ? s.data : null;
  }

  /// Execute an async operation that returns `Result<T>`.
  /// Automatically manages loading → loaded/error transitions.
  Future<void> execute(
    Future<Result<T>> Function() operation, {
    bool showLoading = true,
  }) async {
    if (showLoading) state = AsyncState.loading();

    final result = await operation();
    result.when(
      success: (data) => state = AsyncState.loaded(data),
      failure: (message, code) => state = AsyncState.error(message),
    );
  }

  /// Set loading state explicitly.
  void setLoading() => state = AsyncState.loading();

  /// Set error state explicitly.
  void setError(String message) => state = AsyncState.error(message);

  /// Update data if currently loaded. Useful for optimistic updates.
  void updateData(T Function(T current) updater) {
    final data = currentData;
    if (data != null) {
      state = AsyncState.loaded(updater(data));
    }
  }

  /// Reset to initial state.
  void reset() => state = AsyncState.initial();
}

/// Base notifier for paginated lists.
/// Manages page index, hasMore flag, and appends items on load.
///
/// Usage:
/// ```dart
/// class InventoryNotifier extends BasePaginatedNotifier<BatteryModel> {
///   final InventoryRepository _repo;
///   InventoryNotifier(this._repo);
///
///   Future<void> loadBatteries({String? filter}) => loadPage(
///     (page) => _repo.fetchBatteries(page: page, filter: filter),
///   );
/// }
/// ```
class BasePaginatedNotifier<T> extends StateNotifier<AsyncState<List<T>>> {
  BasePaginatedNotifier() : super(AsyncState.initial());

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isFetching = false;
  final List<T> _allItems = [];

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isFetching => _isFetching;
  List<T> get allItems => List.unmodifiable(_allItems);

  /// Load first page (resets state).
  Future<void> loadPage(
    Future<Result<List<T>>> Function(int page) fetcher, {
    int pageSize = 20,
  }) async {
    _currentPage = 1;
    _hasMore = true;
    _allItems.clear();
    _isFetching = true;
    state = AsyncState.loading();

    final result = await fetcher(_currentPage);
    _isFetching = false;

    result.when(
      success: (items) {
        _allItems.addAll(items);
        _hasMore = items.isNotEmpty;
        _currentPage++;
        state = AsyncState.loaded(List.unmodifiable(_allItems));
      },
      failure: (message, code) {
        state = AsyncState.error(message);
      },
    );
  }

  /// Load next page (appends to existing items).
  Future<void> loadNextPage(
    Future<Result<List<T>>> Function(int page) fetcher, {
    int pageSize = 20,
  }) async {
    if (!_hasMore || _isFetching) return;
    _isFetching = true;

    final result = await fetcher(_currentPage);
    _isFetching = false;

    result.when(
      success: (items) {
        if (items.isEmpty) {
          _hasMore = false;
          state = AsyncState.loaded(List.unmodifiable(_allItems));
          return;
        }

        var addedCount = 0;
        for (final item in items) {
          if (!_allItems.contains(item)) {
            _allItems.add(item);
            addedCount++;
          }
        }
        _hasMore = addedCount > 0;
        _currentPage++;
        state = AsyncState.loaded(List.unmodifiable(_allItems));
      },
      failure: (message, code) {
        // Keep existing data, just stop loading
        state = AsyncState.loaded(List.unmodifiable(_allItems));
      },
    );
  }

  /// Remove an item locally (optimistic delete).
  void removeItem(bool Function(T item) predicate) {
    _allItems.removeWhere(predicate);
    state = AsyncState.loaded(List.unmodifiable(_allItems));
  }

  /// Update an item locally (optimistic update).
  void updateItem(bool Function(T item) predicate, T Function(T item) updater) {
    final index = _allItems.indexWhere(predicate);
    if (index != -1) {
      _allItems[index] = updater(_allItems[index]);
      state = AsyncState.loaded(List.unmodifiable(_allItems));
    }
  }

  /// Prepend a new item (e.g., after creating).
  void prependItem(T item) {
    _allItems.insert(0, item);
    state = AsyncState.loaded(List.unmodifiable(_allItems));
  }

  /// Reset to initial state.
  void reset() {
    _currentPage = 1;
    _hasMore = true;
    _isFetching = false;
    _allItems.clear();
    state = AsyncState.initial();
  }
}
