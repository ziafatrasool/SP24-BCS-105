class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final int pressure;
  final int visibility;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> current, Map<String, dynamic> forecast) {
    final List<HourlyForecast> hourly = [];
    final List<DailyForecast> daily = [];

    if (forecast['list'] != null) {
      final list = forecast['list'] as List;
      for (int i = 0; i < list.length && i < 8; i++) {
        hourly.add(HourlyForecast.fromJson(list[i]));
      }
      final Map<String, DailyForecast> dailyMap = {};
      for (final item in list) {
        final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final key = '${date.year}-${date.month}-${date.day}';
        if (!dailyMap.containsKey(key)) {
          dailyMap[key] = DailyForecast.fromJson(item);
        }
      }
      daily.addAll(dailyMap.values.take(7));
    }

    return WeatherModel(
      cityName: current['name'] ?? '',
      country: current['sys']['country'] ?? '',
      temperature: (current['main']['temp'] as num).toDouble(),
      feelsLike: (current['main']['feels_like'] as num).toDouble(),
      tempMin: (current['main']['temp_min'] as num).toDouble(),
      tempMax: (current['main']['temp_max'] as num).toDouble(),
      humidity: current['main']['humidity'] as int,
      windSpeed: (current['wind']['speed'] as num).toDouble(),
      windDeg: current['wind']['deg'] as int,
      description: current['weather'][0]['description'] ?? '',
      icon: current['weather'][0]['icon'] ?? '',
      pressure: current['main']['pressure'] as int,
      visibility: (current['visibility'] ?? 10000) as int,
      uvIndex: 0,
      sunrise: DateTime.fromMillisecondsSinceEpoch(current['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(current['sys']['sunset'] * 1000),
      hourlyForecast: hourly,
      dailyForecast: daily,
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String icon;
  final String description;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
    required this.description,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '',
      description: json['weather'][0]['description'] ?? '',
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String icon;
  final String description;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.icon,
    required this.description,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
      icon: json['weather'][0]['icon'] ?? '',
      description: json['weather'][0]['description'] ?? '',
    );
  }
}
