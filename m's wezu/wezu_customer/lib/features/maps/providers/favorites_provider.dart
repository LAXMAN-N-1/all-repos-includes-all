import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';

class FavoritesNotifier extends StateNotifier<List<int>> {
  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_stations') ?? [];
    state = ids.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }

  Future<void> toggleFavorite(int stationId) async {
    if (state.contains(stationId)) {
      state = state.where((id) => id != stationId).toList();
    } else {
      state = [...state, stationId];
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'favorite_stations', state.map((e) => e.toString()).toList());
  }

  bool isFavorite(int stationId) => state.contains(stationId);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<int>>((ref) {
  return FavoritesNotifier();
});

/// Provides the list of favorite station objects by filtering from all stations.
final favoriteStationsProvider = Provider<List<Station>>((ref) {
  ref.watch(favoritesProvider);
  // This would normally come from a cached list of all stations
  return [];
});
