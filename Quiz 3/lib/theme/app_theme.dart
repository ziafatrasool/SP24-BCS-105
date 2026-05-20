import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4AF37);
  static const Color darkBg = Color(0xFF050505);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBorder = Color(0xFF1A1A1A);
  static const Color darkMuted = Color(0xFF555555);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      surface: darkSurface,
      onSurface: Colors.white,
      outline: darkBorder,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: gold,
        fontStyle: FontStyle.italic,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0A0A0A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: darkMuted, fontWeight: FontWeight.bold, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          fontSize: 12,
        ),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: gold,
    colorScheme: ColorScheme.fromSeed(seedColor: gold),
  );
}
