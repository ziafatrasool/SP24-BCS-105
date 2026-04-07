import 'package:flutter/material.dart';

import '../models/subtask_item.dart';
import '../models/task_item.dart';
import '../services/database_service.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';

class TaskController extends ChangeNotifier {
  TaskController({
    required DatabaseService databaseService,
    required NotificationService notificationService,
    required SettingsService settingsService,
    required ExportService exportService,
  })  : _databaseService = databaseService,
        _notificationService = notificationService,
        _settingsService = settingsService,
        _exportService = exportService;

  final DatabaseService _databaseService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;
  final ExportService _exportService;

  List<TaskItem> _tasks = const <TaskItem>[];
  bool _isBusy = false;

  List<TaskItem> get allTasks => _tasks;
  bool get isBusy => _isBusy;

  List<TaskItem> get todayTasks {
    final today = DateUtils.dateOnly(DateTime.now());
    return _tasks
        .where(
          (task) =>
              !task.isCompleted && DateUtils.isSameDay(task.dueDate, today),
        )
        .toList(growable: false);
  }

  List<TaskItem> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList(growable: false);

  List<TaskItem> get repeatedTasks =>
      _tasks.where((task) => task.isRepeating).toList(growable: false);

  int get overdueCount {
    final today = DateUtils.dateOnly(DateTime.now());
    return _tasks.where((task) {
      return !task.isCompleted &&
          DateUtils.dateOnly(task.dueDate).isBefore(today);
    }).length;
  }

  Future<void> loadTasks() async {
    _isBusy = true;
    notifyListeners();

    _tasks = await _databaseService.fetchTasks();
    await _refreshRecurringTasks();
    await _rescheduleNotifications();

    _isBusy = false;
    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    final savedTask = await _databaseService.saveTask(
      task.copyWith(notificationSound: _settingsService.notificationSound),
    );
    await _notificationService.scheduleTask(savedTask);
    await loadTasks();
  }

  Future<void> updateTask(TaskItem task) async {
    final savedTask = await _databaseService.saveTask(task);
    await _notificationService.scheduleTask(savedTask);
    await loadTasks();
  }

  Future<void> deleteTask(TaskItem task) async {
    if (task.id == null) {
      return;
    }
    await _databaseService.deleteTask(task.id!);
    await _notificationService.cancelTask(task.id!);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(TaskItem task, bool value) async {
    final updatedTask = task.copyWith(
      isCompleted: value,
      completedAt: value ? DateTime.now() : null,
      resetCompletedAt: !value,
      subtasks: task.subtasks
          .map((subtask) => subtask.copyWith(isCompleted: value))
          .toList(growable: false),
    );
    await _databaseService.saveTask(updatedTask);
    await _notificationService.scheduleTask(updatedTask);
    await loadTasks();
  }

  Future<void> toggleSubtask(
    TaskItem task,
    SubtaskItem subtask,
    bool value,
  ) async {
    final updatedSubtasks = task.subtasks
        .map(
          (item) => item.id == subtask.id
              ? item.copyWith(isCompleted: value)
              : item,
        )
        .toList(growable: false);

    final allDone =
        updatedSubtasks.isNotEmpty && updatedSubtasks.every((item) => item.isCompleted);

    final updatedTask = task.copyWith(
      subtasks: updatedSubtasks,
      isCompleted: allDone,
      completedAt: allDone ? DateTime.now() : null,
      resetCompletedAt: !allDone,
    );

    await _databaseService.saveTask(updatedTask);
    await _notificationService.scheduleTask(updatedTask);
    await loadTasks();
  }

  Future<void> exportCsv() => _exportService.exportCsv(_tasks);

  Future<void> exportPdf() => _exportService.exportPdf(_tasks);

  Future<void> exportEmail() => _exportService.emailTasks(_tasks);

  Future<void> _refreshRecurringTasks() async {
    final now = DateTime.now();
    var didChange = false;

    for (final task in _tasks.where((item) => item.isRepeating && item.isCompleted)) {
      final nextDate = _nextRelevantRepeatDate(task, now);
      if (nextDate != null) {
        final refreshed = task.copyWith(
          dueDate: nextDate,
          isCompleted: false,
          resetCompletedAt: true,
          subtasks: task.subtasks
              .map((subtask) => subtask.copyWith(isCompleted: false))
              .toList(growable: false),
        );
        await _databaseService.saveTask(refreshed);
        didChange = true;
      }
    }

    if (didChange) {
      _tasks = await _databaseService.fetchTasks();
    }
  }

  DateTime? _nextRelevantRepeatDate(TaskItem task, DateTime now) {
    var seed = task.completedAt ?? task.dueDate;
    var nextDate = _nextRepeatDate(task, seed);

    while (nextDate != null &&
        DateUtils.dateOnly(nextDate).isBefore(DateUtils.dateOnly(now))) {
      seed = nextDate;
      nextDate = _nextRepeatDate(task, seed);
    }

    if (nextDate == null) {
      return null;
    }

    if (DateUtils.isSameDay(nextDate, now)) {
      return nextDate;
    }

    return null;
  }

  DateTime? _nextRepeatDate(TaskItem task, DateTime from) {
    switch (task.repeatType) {
      case RepeatType.none:
        return null;
      case RepeatType.daily:
        return from.add(const Duration(days: 1));
      case RepeatType.weeklyCustom:
        if (task.repeatDays.isEmpty) {
          return from.add(const Duration(days: 7));
        }
        for (var offset = 1; offset <= 7; offset++) {
          final candidate = from.add(Duration(days: offset));
          if (task.repeatDays.contains(candidate.weekday)) {
            return candidate;
          }
        }
        return from.add(const Duration(days: 7));
    }
  }

  Future<void> _rescheduleNotifications() async {
    for (final task in _tasks) {
      if (task.id != null) {
        await _notificationService.scheduleTask(task);
      }
    }
  }
}
