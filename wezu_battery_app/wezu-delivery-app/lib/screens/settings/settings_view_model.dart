import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;

  final List<String> supportedLanguages = [
    'English',
    'Spanish',
    'Hindi',
    'Kannada',
  ];

  // Toggle Theme (Mock)
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Change Language (Mock)
  void changeLanguage(String language) {
    if (supportedLanguages.contains(language)) {
      _selectedLanguage = language;
      notifyListeners();
    }
  }

  // Toggle Notifications (Mock)
  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
