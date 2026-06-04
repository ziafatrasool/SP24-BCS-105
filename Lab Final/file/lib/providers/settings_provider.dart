import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  double _volume = 0.8;
  bool _initialized = false;

  SettingsProvider() {
    _loadPreferences();
  }

  bool get initialized => _initialized;
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final darkMode = prefs.getBool('dark_mode_enabled') ?? false;
    _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _soundEnabled = prefs.getBool('sound_enabled') ?? true;
    _volume = prefs.getDouble('sound_volume') ?? 0.8;
    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = mode;
    await prefs.setBool('dark_mode_enabled', mode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = value;
    await prefs.setBool('notifications_enabled', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = value;
    await prefs.setBool('sound_enabled', value);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    _volume = value.clamp(0.0, 1.0);
    await prefs.setDouble('sound_volume', _volume);
    notifyListeners();
  }
}
