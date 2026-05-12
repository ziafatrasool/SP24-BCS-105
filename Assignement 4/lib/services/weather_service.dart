import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  final String apiKey;

  WeatherService(this.apiKey);

  Future<WeatherModel> getWeatherByCity(String city) async {
    final currentUrl = Uri.parse('$_baseUrl/weather?q=$city&appid=$apiKey&units=metric');
    final forecastUrl = Uri.parse('$_baseUrl/forecast?q=$city&appid=$apiKey&units=metric');

    final currentResponse = await http.get(currentUrl);
    final forecastResponse = await http.get(forecastUrl);

    if (currentResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final currentData = json.decode(currentResponse.body);
      final forecastData = json.decode(forecastResponse.body);
      return WeatherModel.fromJson(currentData, forecastData);
    } else if (currentResponse.statusCode == 401) {
      throw Exception('Invalid API key. Please check your settings.');
    } else if (currentResponse.statusCode == 404) {
      throw Exception('City not found. Please check the city name.');
    } else {
      throw Exception('Failed to fetch weather data. Please try again.');
    }
  }

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final currentUrl = Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric');
    final forecastUrl = Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric');

    final currentResponse = await http.get(currentUrl);
    final forecastResponse = await http.get(forecastUrl);

    if (currentResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
      final currentData = json.decode(currentResponse.body);
      final forecastData = json.decode(forecastResponse.body);
      return WeatherModel.fromJson(currentData, forecastData);
    } else if (currentResponse.statusCode == 401) {
      throw Exception('Invalid API key. Please check your settings.');
    } else {
      throw Exception('Failed to fetch weather data. Please try again.');
    }
  }

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable them.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable in settings.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getCityFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ?? placemarks.first.administrativeArea ?? 'Current Location';
      }
    } catch (_) {}
    return 'Current Location';
  }
}
