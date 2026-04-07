import 'subtask_item.dart';

enum RepeatType {
  none,
  daily,
  weeklyCustom,
}

class TaskItem {
  const TaskItem({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.repeatType = RepeatType.none,
    this.repeatDays = const <int>[],
    this.notificationSound = 'default',
    this.subtasks = const <SubtaskItem>[],
  });

  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final RepeatType repeatType;
  final List<int> repeatDays;
  final String notificationSound;
  final List<SubtaskItem> subtasks;

  double get progress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1 : 0;
    }
    final completedCount = subtasks.where((item) => item.isCompleted).length;
    return completedCount / subtasks.length;
  }

  bool get isRepeating => repeatType != RepeatType.none;

  String get repeatLabel {
    switch (repeatType) {
      case RepeatType.none:
        return 'One time';
      case RepeatType.daily:
        return 'Daily';
      case RepeatType.weeklyCustom:
        if (repeatDays.isEmpty) {
          return 'Weekly';
        }
        const names = <int, String>{
          DateTime.monday: 'Mon',
          DateTime.tuesday: 'Tue',
          DateTime.wednesday: 'Wed',
          DateTime.thursday: 'Thu',
          DateTime.friday: 'Fri',
          DateTime.saturday: 'Sat',
          DateTime.sunday: 'Sun',
        };
        return repeatDays.map((day) => names[day] ?? '').join(' • ');
    }
  }

  TaskItem copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    bool resetCompletedAt = false,
    RepeatType? repeatType,
    List<int>? repeatDays,
    String? notificationSound,
    List<SubtaskItem>? subtasks,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: resetCompletedAt ? null : completedAt ?? this.completedAt,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      notificationSound: notificationSound ?? this.notificationSound,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
      'repeat_type': repeatType.name,
      'repeat_days': repeatDays.join(','),
      'notification_sound': notificationSound,
    };
  }

  factory TaskItem.fromMap(
    Map<String, Object?> map,
    List<SubtaskItem> subtasks,
  ) {
    final repeatDaysText = map['repeat_days'] as String? ?? '';
    return TaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: DateTime.parse(map['due_date'] as String),
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.tryParse(map['completed_at'] as String),
      repeatType: RepeatType.values.firstWhere(
        (value) => value.name == map['repeat_type'],
        orElse: () => RepeatType.none,
      ),
      repeatDays: repeatDaysText.isEmpty
          ? const <int>[]
          : repeatDaysText.split(',').map(int.parse).toList(growable: false),
      notificationSound: map['notification_sound'] as String? ?? 'default',
      subtasks: subtasks,
    );
  }
}
