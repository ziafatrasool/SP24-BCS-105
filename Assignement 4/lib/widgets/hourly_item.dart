import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class HourlyItem extends StatelessWidget {
  final HourlyForecast data;

  const HourlyItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('h a').format(data.time),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Image.network(
            'https://openweathermap.org/img/wn/${data.icon}.png',
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.cloud,
              size: 28,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${data.temperature.round()}°',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}