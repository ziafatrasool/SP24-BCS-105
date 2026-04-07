import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/subtask_item.dart';
import '../models/task_item.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.accentColor,
    required this.backgroundColor,
    required this.onToggleComplete,
    required this.onToggleSubtask,
    required this.onEdit,
    required this.onDelete,
    this.foregroundColor,
  });

  final TaskItem task;
  final Color accentColor;
  final Color backgroundColor;
  final Color? foregroundColor;
  final ValueChanged<bool> onToggleComplete;
  final void Function(SubtaskItem subtask, bool value) onToggleSubtask;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textColor = foregroundColor ?? const Color(0xFF12212B);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: task.isCompleted,
                activeColor: accentColor,
                onChanged: (value) => onToggleComplete(value ?? false),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            decoration:
                                task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor.withValues(alpha: 0.82),
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _MetaChip(
                icon: Icons.schedule_rounded,
                label: DateFormat('dd MMM, hh:mm a').format(task.dueDate),
                accentColor: accentColor,
              ),
              _MetaChip(
                icon: Icons.repeat_rounded,
                label: task.repeatLabel,
                accentColor: accentColor,
              ),
              _MetaChip(
                icon: Icons.track_changes_rounded,
                label: '${(task.progress * 100).round()}% progress',
                accentColor: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: task.progress,
              minHeight: 8,
              backgroundColor: accentColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          if (task.subtasks.isNotEmpty) ...<Widget>[
            const SizedBox(height: 16),
            ...task.subtasks.map(
              (subtask) => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: subtask.isCompleted,
                activeColor: accentColor,
                title: Text(
                  subtask.title,
                  style: TextStyle(
                    color: textColor,
                    decoration:
                        subtask.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                onChanged: (value) => onToggleSubtask(subtask, value ?? false),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: accentColor),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
