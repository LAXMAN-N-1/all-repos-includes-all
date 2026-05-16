import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nav_app.dart';
import '../services/navigation_service.dart';

/// Manages user's preferred navigation app
class NavigationNotifier extends StateNotifier<NavAppType> {
  NavigationNotifier() : super(NavAppType.googleMaps) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('preferred_nav_app');
    if (saved != null) {
      state = NavAppType.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => NavAppType.googleMaps,
      );
    }
  }

  Future<void> setPreference(NavAppType app) async {
    state = app;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_nav_app', app.name);
  }

  Future<void> navigateToStation(double lat, double lng,
      {String? label}) async {
    NavigationService.navigateTo(lat, lng,
        label: label, preference: _toNavigationApp(state));
  }

  NavigationApp _toNavigationApp(NavAppType type) {
    switch (type) {
      case NavAppType.googleMaps:
        return NavigationApp.googleMaps;
      case NavAppType.appleMaps:
        return NavigationApp.appleMaps;
      case NavAppType.waze:
        return NavigationApp.waze;
    }
  }
}

final navigationPreferenceProvider =
    StateNotifierProvider<NavigationNotifier, NavAppType>((ref) {
  return NavigationNotifier();
});

/// Provider for available navigation apps on the device
final availableNavAppsProvider =
    FutureProvider<List<NavigationApp>>((ref) async {
  return NavigationService.getInstalledApps();
});
