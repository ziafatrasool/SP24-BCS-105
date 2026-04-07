import 'package:flutter/material.dart';

import 'app.dart';
import 'controllers/task_controller.dart';
import 'services/database_service.dart';
import 'services/export_service.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseService = DatabaseService();
  await databaseService.initialize();

  final settingsService = SettingsService(databaseService);
  await settingsService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final taskController = TaskController(
    databaseService: databaseService,
    notificationService: notificationService,
    settingsService: settingsService,
    exportService: ExportService(),
  );
  await taskController.loadTasks();

  runApp(
    TaskFlowApp(
      controller: taskController,
      settingsService: settingsService,
    ),
  );
}
