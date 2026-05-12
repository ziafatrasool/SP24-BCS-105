import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _apiKeyPref = 'api_key';
  static const String _unitPref = 'temperature_unit';
  static const String _lastCityPref = 'last_city';

  static Future<String> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyPref) ?? '';
  }

  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPref, apiKey);
  }

  static Future<String> getUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitPref) ?? 'metric';
  }

  static Future<void> saveUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitPref, unit);
  }

  static Future<String> getLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastCityPref) ?? '';
  }

  static Future<void> saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCityPref, city);
  }
}
