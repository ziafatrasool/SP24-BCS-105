import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class SunCard extends StatelessWidget {
  final WeatherModel weather;

  const SunCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final totalDayMs = weather.sunset.millisecondsSinceEpoch - weather.sunrise.millisecondsSinceEpoch;
    final elapsedMs = now.millisecondsSinceEpoch - weather.sunrise.millisecondsSinceEpoch;
    final progress = (elapsedMs / totalDayMs).clamp(0.0, 1.0);

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'SUNRISE & SUNSET',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomPaint(
            size: const Size(double.infinity, 60),
            painter: _SunArcPainter(progress: progress),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSunTime(
                Icons.wb_twilight,
                'Sunrise',
                DateFormat('h:mm a').format(weather.sunrise),
                const Color(0xFFFF7043),
              ),
              _buildSunTime(
                Icons.nights_stay_outlined,
                'Sunset',
                DateFormat('h:mm a').format(weather.sunset),
                const Color(0xFF1565C0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunTime(IconData icon, String label, String time, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final arcRect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    final trackPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 3.14, 3.14, false, trackPaint);

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF7043), Color(0xFFFFCA28)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 3.14, 3.14 * progress, false, progressPaint);

    final angle = 3.14 + 3.14 * progress;
    final cx = size.width / 2 + (size.width / 2) * -1 * (progress < 0.5 ? (1 - progress * 2) : (progress * 2 - 1));
    final cy = size.height - size.height * 2 * (1 - (1 - (progress - 0.5).abs() * 2).abs()) * 0.5;

    final sunPaint = Paint()
      ..color = const Color(0xFFFFCA28)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2 + (size.width / 2) * -Math.cos(angle);
    final centerY = size.height + (size.height * 2) * Math.sin(-angle) / 2;

    canvas.drawCircle(Offset(centerX, centerY), 8, sunPaint);
  }

  @override
  bool shouldRepaint(_SunArcPainter oldDelegate) => oldDelegate.progress != progress;
}

class Math {
  static double cos(double x) => _cos(x);
  static double sin(double x) => _sin(x);

  static double _cos(double x) {
    double result = 0;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      result += term;
      term *= -x * x / ((2 * i - 1) * (2 * i));
    }
    return result;
  }

  static double _sin(double x) {
    double result = 0;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }
}
