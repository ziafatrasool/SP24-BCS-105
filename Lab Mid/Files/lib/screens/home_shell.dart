import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../models/task_item.dart';
import '../services/settings_service.dart';
import '../widgets/task_form_sheet.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'settings_screen.dart';
import 'today_tasks_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.controller,
    required this.settingsService,
  });

  final TaskController controller;
  final SettingsService settingsService;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final screens = <Widget>[
          TodayTasksScreen(
            controller: widget.controller,
            onEditTask: _openTaskSheet,
          ),
          CompletedTasksScreen(
            controller: widget.controller,
            onEditTask: _openTaskSheet,
          ),
          RepeatedTasksScreen(
            controller: widget.controller,
            onEditTask: _openTaskSheet,
          ),
          SettingsScreen(
            controller: widget.controller,
            settingsService: widget.settingsService,
          ),
        ];

        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          floatingActionButton: _currentIndex == 3
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _openTaskSheet(context),
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('New Task'),
                ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            destinations: const <Widget>[
              NavigationDestination(
                icon: Icon(Icons.today_outlined),
                selectedIcon: Icon(Icons.today),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.done_all_outlined),
                selectedIcon: Icon(Icons.done_all),
                label: 'Completed',
              ),
              NavigationDestination(
                icon: Icon(Icons.repeat_outlined),
                selectedIcon: Icon(Icons.repeat),
                label: 'Repeated',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Settings',
              ),
            ],
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Future<void> _openTaskSheet(
    BuildContext context, [
    TaskItem? task,
  ]) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TaskFormSheet(
          initialTask: task,
          settingsService: widget.settingsService,
          onSubmit: (draftTask) async {
            if (task == null) {
              await widget.controller.addTask(draftTask);
            } else {
              await widget.controller.updateTask(draftTask);
            }
          },
        );
      },
    );
  }
}
