import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';

class RepeatedTasksScreen extends StatelessWidget {
  const RepeatedTasksScreen({
    super.key,
    required this.controller,
    required this.onEditTask,
  });

  final TaskController controller;
  final Future<void> Function(BuildContext context, [TaskItem? task]) onEditTask;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.repeatedTasks;

    return Container(
      decoration: const BoxDecoration(color: Color(0xFFF7EDE2)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2F1E13),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Repeat Lab',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A habit board for routines, recurring actions, and reset cycles.',
                    style: TextStyle(color: Color(0xFFF4D3B2)),
                  ),
                  const SizedBox(height: 18),
                  _WeekStrip(tasks: tasks),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (tasks.isEmpty)
              const _RepeatEmptyPanel()
            else
              ...tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RepeatBoardCard(
                    task: task,
                    onEdit: () => onEditTask(context, task),
                    onDelete: () => controller.deleteTask(task),
                    onToggle: () =>
                        controller.toggleTaskCompletion(task, !task.isCompleted),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    final days = <MapEntry<int, String>>[
      const MapEntry(DateTime.monday, 'M'),
      const MapEntry(DateTime.tuesday, 'T'),
      const MapEntry(DateTime.wednesday, 'W'),
      const MapEntry(DateTime.thursday, 'T'),
      const MapEntry(DateTime.friday, 'F'),
      const MapEntry(DateTime.saturday, 'S'),
      const MapEntry(DateTime.sunday, 'S'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((entry) {
        final count = tasks.where((task) => task.repeatDays.contains(entry.key)).length;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: count > 0 ? const Color(0xFFF3A261) : const Color(0xFF4B3427),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text('$count', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _RepeatBoardCard extends StatelessWidget {
  const _RepeatBoardCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final TaskItem task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFFFFBF7),
        border: Border.all(color: const Color(0xFFE2C8AF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF3D2617),
                      ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.description.isEmpty ? 'No description added' : task.description,
            style: const TextStyle(color: Color(0xFF7A5A43)),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _InfoTile(
                  label: 'Pattern',
                  value: task.repeatLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  label: 'Next Due',
                  value: DateFormat('dd MMM').format(task.dueDate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onToggle,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5C2F),
                  ),
                  icon: Icon(
                    task.isCompleted ? Icons.restart_alt_rounded : Icons.done_all_rounded,
                  ),
                  label: Text(task.isCompleted ? 'Reset' : 'Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E7D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(color: Color(0xFF8B6A53))),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF3D2617)),
          ),
        ],
      ),
    );
  }
}

class _RepeatEmptyPanel extends StatelessWidget {
  const _RepeatEmptyPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFFFFBF7),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.repeat_one_on_rounded, size: 52, color: Color(0xFF9A5C2F)),
          const SizedBox(height: 12),
          Text(
            'Build your first routine',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Daily and weekday repeating tasks will show up here as habit-style cards.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
