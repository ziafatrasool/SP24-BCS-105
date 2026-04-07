import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({
    super.key,
    required this.controller,
    required this.onEditTask,
  });

  final TaskController controller;
  final Future<void> Function(BuildContext context, [TaskItem? task]) onEditTask;

  @override
  Widget build(BuildContext context) {
    final tasks = controller.completedTasks;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF081C15), Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: const Color(0xFFF1FAEE),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Achievement wall for everything you have finished.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFD8F3DC),
                          ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF40916C), Color(0xFF74C69D)],
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Done Count',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${tasks.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0x30FFFFFF),
                            child: Icon(Icons.auto_awesome_rounded, color: Colors.white),
                          ),
                        ],
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
                  child: const _CompletedEmptyCard(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == tasks.length - 1 ? 0 : 14),
                      child: _CompletedShowcaseCard(
                        task: task,
                        onReopen: () => controller.toggleTaskCompletion(task, false),
                        onDelete: () => controller.deleteTask(task),
                        onEdit: () => onEditTask(context, task),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompletedShowcaseCard extends StatelessWidget {
  const _CompletedShowcaseCard({
    required this.task,
    required this.onReopen,
    required this.onDelete,
    required this.onEdit,
  });

  final TaskItem task;
  final VoidCallback onReopen;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: const Color(0xFFF1FAEE),
        border: Border.all(color: const Color(0xFFB7E4C7)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD8F3DC),
                  border: Border.all(color: const Color(0xFF95D5B2)),
                ),
                child: const Icon(Icons.done_rounded, color: Color(0xFF2D6A4F)),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                color: Colors.white,
                iconColor: const Color(0xFF2D6A4F),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'reopen') {
                    onReopen();
                  } else {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'reopen', child: Text('Reopen')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF081C15),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description.isEmpty ? 'Finished with no extra note.' : task.description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF35544A)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFD8F3DC),
                ),
                child: Text(
                  DateFormat('dd MMM').format(task.completedAt ?? task.dueDate),
                  style: const TextStyle(
                    color: Color(0xFF1B4332),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFB7E4C7),
                ),
                child: Text(
                  'Progress ${(task.progress * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF1B4332),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onReopen,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reopen'),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedEmptyCard extends StatelessWidget {
  const _CompletedEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFF1FAEE),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.emoji_events_outlined, color: Color(0xFF2D6A4F), size: 56),
          const SizedBox(height: 14),
          Text(
            'No trophies yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF081C15),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Finish a task and it will appear here as a completed achievement card.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF35544A)),
          ),
        ],
      ),
    );
  }
}
