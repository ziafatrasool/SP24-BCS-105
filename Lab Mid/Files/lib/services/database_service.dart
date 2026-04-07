import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/subtask_item.dart';
import '../models/task_item.dart';

class DatabaseService {
  Database? _database;

  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(databasePath, 'taskflow_pro.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            due_date TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            completed_at TEXT,
            repeat_type TEXT NOT NULL DEFAULT 'none',
            repeat_days TEXT NOT NULL DEFAULT '',
            notification_sound TEXT NOT NULL DEFAULT 'default'
          )
        ''');
        await db.execute('''
          CREATE TABLE subtasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(task_id) REFERENCES tasks(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Database get _db {
    final database = _database;
    if (database == null) {
      throw StateError('Database has not been initialized.');
    }
    return database;
  }

  Future<List<TaskItem>> fetchTasks() async {
    final taskRows = await _db.query('tasks', orderBy: 'due_date ASC');
    final subtaskRows = await _db.query('subtasks');

    return taskRows.map((taskMap) {
      final taskId = taskMap['id'] as int?;
      final subtasks = subtaskRows
          .where((subtask) => subtask['task_id'] == taskId)
          .map(SubtaskItem.fromMap)
          .toList(growable: false);
      return TaskItem.fromMap(taskMap, subtasks);
    }).toList(growable: false);
  }

  Future<TaskItem> saveTask(TaskItem task) async {
    return _db.transaction((transaction) async {
      final taskMap = task.toMap();
      int taskId;

      if (task.id == null) {
        taskId = await transaction.insert('tasks', taskMap..remove('id'));
      } else {
        taskId = task.id!;
        await transaction.update(
          'tasks',
          taskMap..remove('id'),
          where: 'id = ?',
          whereArgs: <Object>[taskId],
        );
        await transaction.delete(
          'subtasks',
          where: 'task_id = ?',
          whereArgs: <Object>[taskId],
        );
      }

      for (final subtask in task.subtasks) {
        final subtaskMap = subtask.toMap(taskId)..remove('id');
        await transaction.insert('subtasks', subtaskMap);
      }

      return task.copyWith(id: taskId);
    });
  }

  Future<void> deleteTask(int taskId) async {
    await _db.transaction((transaction) async {
      await transaction.delete(
        'subtasks',
        where: 'task_id = ?',
        whereArgs: <Object>[taskId],
      );
      await transaction.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: <Object>[taskId],
      );
    });
  }

  Future<void> saveSetting(String key, String value) async {
    await _db.insert(
      'settings',
      <String, Object?>{'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final rows = await _db.query(
      'settings',
      where: 'key = ?',
      whereArgs: <Object>[key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value'] as String?;
  }
}
