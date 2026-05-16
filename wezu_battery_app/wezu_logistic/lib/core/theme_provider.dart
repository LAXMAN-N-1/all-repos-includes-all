import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'providers.dart';

/// Provider for the current theme mode.
/// Persists the selection to storage.
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeNotifier(this._storage) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _storage.getThemeMode();
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  void toggle() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    if (mode == ThemeMode.light) {
      _storage.saveThemeMode('light');
    } else if (mode == ThemeMode.dark) {
      _storage.saveThemeMode('dark');
    } else {
      _storage.saveThemeMode('system');
    }
  }
}

/// Provider for AMOLED (True Black) mode preference.
final amoledModeProvider = StateNotifierProvider<AmoledModeNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AmoledModeNotifier(storage);
});

class AmoledModeNotifier extends StateNotifier<bool> {
  final StorageService _storage;

  AmoledModeNotifier(this._storage) : super(false) {
    _loadAmoledMode();
  }

  void _loadAmoledMode() {
    state = _storage.getAmoledMode();
  }

  void toggle() {
    state = !state;
    _storage.saveAmoledMode(state);
  }
  
  void setAmoled(bool enabled) {
    state = enabled;
    _storage.saveAmoledMode(enabled);
  }
}
