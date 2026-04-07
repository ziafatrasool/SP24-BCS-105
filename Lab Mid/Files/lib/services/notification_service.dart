import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/task_item.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'taskflow_alerts',
    'Task Alerts',
    description: 'Upcoming task reminders',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(initializationSettings);

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(_channel);
    await androidImplementation?.requestNotificationsPermission();
  }

  Future<void> scheduleTask(TaskItem task) async {
    if (task.id == null) {
      return;
    }

    await _plugin.cancel(task.id!);

    if (task.isCompleted || task.dueDate.isBefore(DateTime.now())) {
      return;
    }

    final playSound = task.notificationSound != 'silent';

    await _plugin.zonedSchedule(
      task.id!,
      task.title,
      task.description.isEmpty ? 'Task is due now' : 'Due soon: ${task.description}',
      tz.TZDateTime.from(task.dueDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: playSound,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTask(int taskId) => _plugin.cancel(taskId);
}
