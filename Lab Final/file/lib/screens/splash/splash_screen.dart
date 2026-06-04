import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/constants/images.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage(AppImages.splashBg),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.35),
                  ]
                : [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.0),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage(AppImages.logo), height: 90),
              const SizedBox(height: 20),
              Text(
                "SkillVerse Pro",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall?.color ??
                        Colors.black87),
              ),
              const SizedBox(height: 10),
              Text(
                "Learn • Compete • Conquer",
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black87),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 60,
                width: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
