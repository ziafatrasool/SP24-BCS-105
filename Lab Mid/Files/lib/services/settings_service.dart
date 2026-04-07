import 'package:flutter/material.dart';

import 'database_service.dart';

class SettingsService extends ChangeNotifier {
  SettingsService(this._databaseService);

  final DatabaseService _databaseService;

  ThemeMode _themeMode = ThemeMode.system;
  String _notificationSound = 'default';

  ThemeMode get themeMode => _themeMode;
  String get notificationSound => _notificationSound;

  Future<void> initialize() async {
    final savedTheme = await _databaseService.getSetting('theme_mode');
    final savedSound = await _databaseService.getSetting('notification_sound');

    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
    _notificationSound = savedSound ?? 'default';
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _databaseService.saveSetting('theme_mode', mode.name);
    notifyListeners();
  }

  Future<void> updateNotificationSound(String value) async {
    _notificationSound = value;
    await _databaseService.saveSetting('notification_sound', value);
    notifyListeners();
  }
}
