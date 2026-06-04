import 'package:flutter/material.dart';

import '../core/constants/images.dart';

class PageBackground extends StatelessWidget {
  final Widget child;

  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) {
      // Light mode: pure white background
      return Container(
        color: Colors.white,
        child: child,
      );
    }
    // Dark mode: image with overlay
    return Container(
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage(AppImages.splashBg),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.55),
              Colors.black.withOpacity(0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
