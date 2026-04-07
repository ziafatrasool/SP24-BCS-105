import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/task_controller.dart';
import '../models/subtask_item.dart';
import '../models/task_item.dart';

class TodayTasksScreen extends StatelessWidget {
  const TodayTasksScreen({
    super.key,
    required this.controller,
    required this.onEditTask,
  });

  final TaskController controller;
  final Future<void> Function(BuildContext context, [TaskItem? task]) onEditTask;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.todayTasks;
    final completionRate = tasks.isEmpty
        ? 0.0
        : tasks.where((task) => task.progress >= 1).length / tasks.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFFF4FBFF), Color(0xFFE6FFF8), Color(0xFFFFF4DE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Today',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, dd MMMM').format(DateTime.now()),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF44606B),
                          ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: _GlassSummaryCard(
                            title: 'Daily rhythm',
                            subtitle: '${tasks.length} tasks planned',
                            accent: const Color(0xFF0F766E),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: completionRate,
                                    minHeight: 9,
                                    backgroundColor: const Color(0x140F766E),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${(completionRate * 100).round()}% of today already closed',
                                  style: const TextStyle(
                                    color: Color(0xFF32505B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStatCard(
                            label: 'Overdue',
                            value: '${controller.overdueCount}',
                            tint: const Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Agenda Flow',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (tasks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _EmptyTodayCard(onCreate: () => onEditTask(context)),
                ),
              )
            else
              SliverList.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isLast = index == tasks.length - 1;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, isLast ? 120 : 8),
                    child: _AgendaTaskCard(
                      task: task,
                      index: index + 1,
                      onToggleComplete: (value) =>
                          controller.toggleTaskCompletion(task, value),
                      onToggleSubtask: (subtask, value) =>
                          controller.toggleSubtask(task, subtask, value),
                      onEdit: () => onEditTask(context, task),
                      onDelete: () => controller.deleteTask(task),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassSummaryCard extends StatelessWidget {
  const _GlassSummaryCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: 0.78),
        border: Border.all(color: Colors.white),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.bubble_chart_rounded, color: accent),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Color(0xFF58707A))),
          child,
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.tint,
  });

  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: <Color>[tint, tint.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.schedule_send_rounded, color: Colors.white),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _AgendaTaskCard extends StatelessWidget {
  const _AgendaTaskCard({
    required this.task,
    required this.index,
    required this.onToggleComplete,
    required this.onToggleSubtask,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskItem task;
  final int index;
  final ValueChanged<bool> onToggleComplete;
  final void Function(SubtaskItem subtask, bool value) onToggleSubtask;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Container(
              width: 68,
              decoration: const BoxDecoration(
                color: Color(0xFF0F766E),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(30)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$index',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm').format(task.dueDate),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
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
                                ),
                          ),
                        ),
                        Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) => onToggleComplete(value ?? false),
                          activeColor: const Color(0xFF0F766E),
                        ),
                      ],
                    ),
                    Text(
                      task.description.isEmpty ? 'No description added' : task.description,
                      style: const TextStyle(color: Color(0xFF5B717B)),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _Pill(label: task.repeatLabel, color: const Color(0xFFE2F7F3)),
                        _Pill(
                          label: '${(task.progress * 100).round()}% done',
                          color: const Color(0xFFFFF1D8),
                        ),
                      ],
                    ),
                    if (task.subtasks.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 12),
                      ...task.subtasks.map(
                        (subtask) => SwitchListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: subtask.isCompleted,
                          activeThumbColor: const Color(0xFF0F766E),
                          title: Text(subtask.title),
                          onChanged: (value) => onToggleSubtask(subtask, value),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        TextButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyTodayCard extends StatelessWidget {
  const _EmptyTodayCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.spa_outlined, size: 54, color: Color(0xFF0F766E)),
          const SizedBox(height: 12),
          Text(
            'Open day, clean slate',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You do not have any tasks due today yet. Add one and start shaping the flow.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Create first task'),
          ),
        ],
      ),
    );
  }
}
