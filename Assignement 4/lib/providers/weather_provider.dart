import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/prefs_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _weather;
  List<HourlyForecast> _forecast = [];
  bool _loading = false;
  String _error = '';

  WeatherModel? get weather => _weather;
  List<HourlyForecast> get forecast => _forecast;
  bool get loading => _loading;
  String get error => _error;

  Future<void> fetchWeather(String city) async {
    _loading = true;
    _error = '';
    notifyListeners();

    try {
      final apiKey = await PrefsService.getApiKey();
      if (apiKey.isEmpty) {
        _error = 'API key not set. Please set it in settings.';
        _loading = false;
        notifyListeners();
        return;
      }

      final service = WeatherService(apiKey);
      final weatherModel = await service.getWeatherByCity(city);
      _weather = weatherModel;
      _forecast = weatherModel.hourlyForecast;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}