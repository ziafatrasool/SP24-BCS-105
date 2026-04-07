import 'package:flutter/material.dart';

import 'controllers/task_controller.dart';
import 'screens/home_shell.dart';
import 'services/settings_service.dart';

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({
    super.key,
    required this.controller,
    required this.settingsService,
  });

  final TaskController controller;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, settingsService]),
      builder: (context, _) {
        return MaterialApp(
          title: 'TaskFlow Pro',
          debugShowCheckedModeBanner: false,
          themeMode: settingsService.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: HomeShell(
            controller: controller,
            settingsService: settingsService,
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    const seed = Color(0xFF0F766E);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? const Color(0xFFF4F7FB) : const Color(0xFF07131A),
      fontFamily: brightness == Brightness.light ? 'serif' : 'sans-serif',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.light ? Colors.white : const Color(0xFF10202A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            brightness == Brightness.light ? Colors.white : const Color(0xFF10202A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }
}
