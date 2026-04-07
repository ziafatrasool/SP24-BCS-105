class SubtaskItem {
  const SubtaskItem({
    this.id,
    required this.title,
    this.isCompleted = false,
  });

  final int? id;
  final String title;
  final bool isCompleted;

  SubtaskItem copyWith({
    int? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubtaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, Object?> toMap(int taskId) {
    return <String, Object?>{
      'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory SubtaskItem.fromMap(Map<String, Object?> map) {
    return SubtaskItem(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }
}
