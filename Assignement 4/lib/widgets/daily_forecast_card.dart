import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> forecasts;

  const DailyForecastCard({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '7-DAY FORECAST',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecasts.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              final isToday = index == 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        isToday ? 'Today' : DateFormat('EEEE').format(forecast.date),
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Image.network(
                      'https://openweathermap.org/img/wn/${forecast.icon}.png',
                      width: 36,
                      height: 36,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.cloud,
                        size: 28,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${forecast.tempMin.round()}°',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTempBar(forecast.tempMin, forecast.tempMax),
                    const SizedBox(width: 8),
                    Text(
                      '${forecast.tempMax.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTempBar(double min, double max) {
    return Container(
      width: 80,
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: [
            _tempColor(min),
            _tempColor(max),
          ],
        ),
      ),
    );
  }

  Color _tempColor(double temp) {
    if (temp < 0) return const Color(0xFF90CAF9);
    if (temp < 10) return const Color(0xFF42A5F5);
    if (temp < 20) return const Color(0xFF66BB6A);
    if (temp < 30) return const Color(0xFFFFCA28);
    return const Color(0xFFEF5350);
  }
}
